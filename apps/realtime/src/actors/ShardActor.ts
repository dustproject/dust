import { Actor, type ActorState, handler } from "@cloudflare/actors";
import {
  clientDataSchema,
  parseClientMessage,
  parseConnectionData,
  parseServerMessage,
  type positionChange,
  serverMessageSchema,
  type,
} from "dustkit/realtime";
import type { Address } from "viem";
import type { Env } from "../env";

export class ShardActor extends Actor<Env> {
  private hub?: WebSocket;
  private clients = new Map<WebSocket, typeof clientDataSchema.infer>();
  private positionChanges = new Map<Address, typeof positionChange.infer>();

  constructor(state: ActorState, env: Env) {
    super(state, env);
    for (const ws of state.getWebSockets()) {
      const clientData = ws.deserializeAttachment();
      if (clientDataSchema.allows(clientData)) {
        this.clients.set(ws, clientData);
      } else {
        try {
          ws.close();
        } catch {}
      }
    }
  }

  async fetch(req: Request): Promise<Response> {
    console.info("got shard request", req.url);
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    const url = new URL(req.url);
    const clientData = parseConnectionData.assert(
      url.searchParams.get("client"),
    );
    console.info("new client", clientData);

    const { 0: client, 1: server } = new WebSocketPair();
    server.serializeAttachment(clientData);
    this.ctx.acceptWebSocket(server);
    this.clients.set(server, clientData);

    await this.ensureUplink();

    return new Response(null, { status: 101, webSocket: client });
  }

  private async ensureUplink(): Promise<void> {
    if (this.hub && !this.clients.size) {
      console.info("no more clients, closing hub socket for now");
      try {
        this.hub.close();
      } catch {}
      this.hub = undefined;
      return;
    }

    if (!this.hub && this.clients.size) {
      const hub = this.env.Hub.get(this.env.Hub.idFromName("global"));
      const res = await hub.fetch(
        `https://hub/?${new URLSearchParams({ shard: this.ctx.id.toString() })}`,
        { headers: { Upgrade: "websocket" } },
      );
      const ws = res.webSocket!;

      ws.addEventListener("message", (event) => {
        if (ws !== this.hub) return;

        const data =
          typeof event.data === "string"
            ? event.data
            : new TextDecoder().decode(event.data as ArrayBuffer);

        if (data === "tick") {
          if (this.positionChanges.size) {
            console.info(
              "got tick, sending",
              this.positionChanges.size,
              "position changes to hub",
            );
            ws.send(
              JSON.stringify(
                serverMessageSchema.from({
                  t: "positions",
                  d: [...this.positionChanges.values()],
                }),
              ),
            );
            this.positionChanges.clear();
          }
          return;
        }

        const message = parseServerMessage(data);
        if (message instanceof type.errors) {
          console.info("ignoring invalid message", message.toString(), data);
          return;
        }
        if (message.t === "pong") {
          console.info("igoring message", message);
          return;
        }

        const clients = Array.from(this.clients.entries()).filter(
          ([client, clientData]) => clientData.channels.includes(message.t),
        );
        console.info("fanning out", message.t, "to", clients.length, "clients");
        for (const [client, clientData] of clients) {
          try {
            client.send(data);
          } catch {}
        }
      });

      ws.addEventListener("close", () => {
        if (ws !== this.hub) return;

        this.hub = undefined;
      });

      ws.addEventListener("error", () => {
        if (ws !== this.hub) return;

        try {
          ws.close();
        } catch {}
        this.hub = undefined;
      });

      ws.accept();
      this.hub = ws;
    }
  }

  async webSocketMessage(ws: WebSocket, data: string | ArrayBuffer) {
    const clientData = this.clients.get(ws);
    // ignore message from unknown sockets
    if (!clientData) return;

    const rawMessage =
      typeof data === "string" ? data : new TextDecoder().decode(data);
    const message = parseClientMessage(rawMessage);
    if (message instanceof type.errors) {
      console.debug("ignoring invalid message from", clientData, rawMessage);
      return;
    }

    if (message === "ping") {
      ws.send(JSON.stringify(serverMessageSchema.from({ t: "pong", d: null })));
      return;
    }

    if (clientData.userAddress) {
      this.positionChanges.set(clientData.userAddress, {
        u: clientData.userAddress,
        t: Date.now(),
        d: message,
      });
    }
  }

  async webSocketClose(ws: WebSocket, code: number) {
    console.info("got ws close", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.ensureUplink();
  }

  async webSocketError(ws: WebSocket, code: number) {
    console.info("got ws error", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.ensureUplink();
  }
}

export default handler(ShardActor);
