import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { Address, Hex } from "viem";
import type { Env } from "../env";

export class IngressActor extends Actor<Env> {
  private uplink?: WebSocket;
  private clients = new Set<WebSocket>();
  private latest = new Map<
    Address,
    { u: Address; x: number; y: number; z: number; ts: number }
  >();

  constructor(state: ActorState, env: Env) {
    super(state, env);
    for (const ws of state.getWebSockets()) {
      const attachment = ws.deserializeAttachment();
      if (attachment?.userAddress) {
        this.clients.add(ws);
      }
    }
  }

  async fetch(req: Request): Promise<Response> {
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    const url = new URL(req.url);
    const userAddress = url.searchParams.get("userAddress") as Hex;
    console.info("ingress connection for user", userAddress);

    const { 0: client, 1: server } = new WebSocketPair();
    server.serializeAttachment({ userAddress });
    server.addEventListener("message", (event) => {
      console.info("got message for user", userAddress, event);
      const data =
        typeof event.data === "string"
          ? event.data
          : new TextDecoder().decode(event.data as ArrayBuffer);
      try {
        const { x, y, z } = JSON.parse(data);
        if (Number.isFinite(x) && Number.isFinite(y) && Number.isFinite(z)) {
          this.latest.set(userAddress, {
            u: userAddress,
            x: Number(x),
            y: Number(y),
            z: Number(z),
            ts: Date.now(),
          });
        }
      } catch {}
    });
    server.addEventListener("close", () => {
      console.info("client closed");
      this.clients.delete(server);
    });
    server.addEventListener("error", (event) => {
      console.info("client error", event);
      this.clients.delete(server);
    });

    // We have to call `server.accept()` here rather than `this.ctx.acceptWebSocket(server)` because
    // this is an outgoing websocket that can't be hibernated:
    // https://developers.cloudflare.com/durable-objects/examples/websocket-hibernation-server/
    // server.accept();
    this.ctx.acceptWebSocket(server);
    this.clients.add(server);
    await this.ensureAuthority();

    return new Response(null, { status: 101, webSocket: client });
  }

  private async ensureAuthority(): Promise<void> {
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
          if (this.latest.size) {
            console.info(
              "sending latest positions to authority",
              this.latest.size,
            );
            ws.send(JSON.stringify([...this.latest.values()])); // one batch per frame
            this.latest.clear();
          }
          return;
        }

        for (const client of this.clients) {
          try {
            console.info("broadcasting data from authority to clients", data);
            client.send(data);
          } catch {}
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

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const attachment = ws.deserializeAttachment();
    if (!attachment?.userAddress) {
      console.warn("got ws message not from client", attachment, message);
      return;
    }
    const userAddress = attachment.userAddress as Hex;

    const data =
      typeof message === "string" ? message : new TextDecoder().decode(message);
    try {
      const { x, y, z } = JSON.parse(data);
      if (Number.isFinite(x) && Number.isFinite(y) && Number.isFinite(z)) {
        this.latest.set(userAddress, {
          u: userAddress,
          x: Number(x),
          y: Number(y),
          z: Number(z),
          ts: Date.now(),
        });
      }
    } catch {}
  }

  async webSocketClose(ws: WebSocket, code: number) {
    console.info("got ws close", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.ensureAuthority();
  }

  async webSocketError(ws: WebSocket, code: number) {
    console.info("got ws error", ws.deserializeAttachment(), code);
    ws.close();
    this.clients.delete(ws);
    await this.ensureAuthority();
  }
}

export default handler(IngressActor);
