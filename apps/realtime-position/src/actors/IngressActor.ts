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

export class IngressActor extends Actor<Env> {
  private uplink?: WebSocket;
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
    if (this.uplink && !this.clients.size) {
      console.info("no more clients, closing authority uplink for now");
      try {
        this.uplink.close();
      } catch {}
      this.uplink = undefined;
      return;
    }

    if (!this.uplink && this.clients.size) {
      const authority = this.env.Authority.get(
        this.env.Authority.idFromName("global"),
      );
      const res = await authority.fetch(
        `https://authority/?${new URLSearchParams({ ingress: this.ctx.id.toString() })}`,
        { headers: { Upgrade: "websocket" } },
      );
      const ws = res.webSocket!;

      ws.addEventListener("message", (event) => {
        if (ws !== this.uplink) return;

        const data =
          typeof event.data === "string"
            ? event.data
            : new TextDecoder().decode(event.data as ArrayBuffer);

        if (data === "tick") {
          console.info("ingress got tick from authority");
          if (this.positionChanges.size) {
            console.info(
              "sending",
              this.positionChanges.size,
              "position changes to authority",
            );
            ws.send(JSON.stringify([...this.positionChanges.values()]));
            this.positionChanges.clear();
          }
          return;
        }

        const message = parseServerMessage(data);
        if (message instanceof type.errors) return;
        if (message.t === "pong") return;

        for (const [client, clientData] of this.clients) {
          if (clientData.channels.includes(message.t)) {
            try {
              client.send(data);
            } catch {}
          }
        }
      });

      ws.addEventListener("close", () => {
        if (ws !== this.uplink) return;

        this.uplink = undefined;
      });

      ws.addEventListener("error", () => {
        if (ws !== this.uplink) return;

        try {
          ws.close();
        } catch {}
        this.uplink = undefined;
      });

      ws.accept();
      this.uplink = ws;
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

export default handler(IngressActor);
