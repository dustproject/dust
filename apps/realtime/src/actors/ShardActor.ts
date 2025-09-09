import { Actor, type ActorState, handler } from "@cloudflare/actors";
import { clientSocket, type positionChange, type } from "dustkit/realtime";
import type { Address } from "viem";
import { isDefined } from "../common";
import type { Env } from "../env";
import { clientDataSchema, hubSocket } from "../schemas";

const parseClientData = type("string.json.parse").to(clientDataSchema);

export class ShardActor extends Actor<Env> {
  private hub?: WebSocket;
  private clients = new Map<WebSocket, typeof clientDataSchema.infer>();
  private positionChanges = new Map<Address, typeof positionChange.infer>();

  constructor(state: ActorState, env: Env) {
    super(state, env);

    state.setWebSocketAutoResponse(
      new WebSocketRequestResponsePair("ping", "pong"),
    );

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
    this.onClients();
  }

  async fetch(req: Request): Promise<Response> {
    console.info("got shard request", req.url);
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    try {
      const url = new URL(req.url);
      const clientData = parseClientData.assert(url.searchParams.get("client"));
      console.info("new client", clientData);

      const { 0: client, 1: server } = new WebSocketPair();
      server.serializeAttachment(clientData);
      this.ctx.acceptWebSocket(server);
      this.clients.set(server, clientData);
      await this.onClients();

      return new Response(null, { status: 101, webSocket: client });
    } catch (error) {
      console.error(String(error));
      return new Response(String(error), { status: 500 });
    }
  }

  private async onClients(): Promise<void> {
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

        const data = hubSocket.out.receive(event.data);

        if (data === "tickPositions") {
          if (this.positionChanges.size) {
            console.info(
              "got players tick, sending",
              this.positionChanges.size,
              "position changes to hub",
            );
            hubSocket.in.send(ws, {
              t: "positions",
              d: Array.from(this.positionChanges.values()),
            });
            this.positionChanges.clear();
          }
          return;
        }

        const clients = Array.from(this.clients.entries()).filter(
          ([client, clientData]) => clientData.channels.includes(data.t),
        );
        console.info("fanning out", data.t, "to", clients.length, "clients");
        for (const [client, clientData] of clients) {
          try {
            clientSocket.in.send(client, data);
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
      // return;
    }

    // send presence to hub
    const hub = this.hub;
    if (hub) {
      if (hub.readyState === WebSocket.CONNECTING) {
        await new Promise((resolve, reject) => {
          hub.addEventListener("open", resolve, { once: true });
          hub.addEventListener("close", reject, { once: true });
          hub.addEventListener("error", reject, { once: true });
        });
      }
      if (hub.readyState === WebSocket.OPEN) {
        const presence = Array.from(this.clients.values())
          .map((clientData) => clientData.userAddress)
          .filter(isDefined);
        console.info("sending presence to hub", presence);
        hubSocket.in.send(hub, { t: "presence", d: presence });
      }
    }
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const clientData = this.clients.get(ws);
    // ignore message from unknown sockets
    if (!clientData) return;

    const data = clientSocket.out.receive(message);

    if (clientData.userAddress) {
      this.positionChanges.set(clientData.userAddress, {
        u: clientData.userAddress,
        t: Date.now(),
        d: data,
      });
    }
  }

  async webSocketClose(ws: WebSocket, code: number) {
    console.info("got ws close", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.onClients();
  }

  async webSocketError(ws: WebSocket, code: number) {
    console.info("got ws error", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.onClients();
  }
}

export default handler(ShardActor);
