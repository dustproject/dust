import type { Env } from "../env";

import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { Hex } from "viem";

type WireInput = { u: Hex; x: number; y: number; z: number; ts: number };

export class IngressActor extends Actor<Env> {
  private clients = new Set<WebSocket>();
  private latest = new Map<string, WireInput>([
    ["0x", { u: "0x", x: 0, y: 0, z: 0, ts: 0 }],
  ]);
  private uplink?: WebSocket;

  constructor(state: ActorState, env: Env) {
    super(state, env);
    for (const ws of state.getWebSockets()) {
      const att = ws.deserializeAttachment();
      if (att?.type === "client") this.clients.add(ws);
      if (att?.type === "uplink") this.uplink = ws;
    }
  }

  async fetch(req: Request): Promise<Response> {
    const url = new URL(req.url);
    if (url.pathname !== "/ws" || req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    const userAddress = url.searchParams.get("userAddress") as Hex;
    console.info("ingress connection for user", userAddress);

    const { 0: client, 1: server } = new WebSocketPair();
    server.serializeAttachment({ type: "client", userAddress });
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
      try {
        server.send('{"t":"ack"}');
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
    this.ctx.acceptWebSocket(server);
    this.clients.add(server);
    try {
      server.send('{"t":"ready"}');
    } catch {}

    await this.ensureUplink();
    return new Response(null, { status: 101, webSocket: client });
  }

  private async ensureUplink(): Promise<void> {
    if (this.uplink) return;

    const authority = this.env.Authority.get(
      this.env.Authority.idFromName("global"),
    );
    const url = new URL("https://authority/uplink");
    url.searchParams.set("from", this.ctx.id.toString());

    const res = await authority.fetch(url.toString(), {
      headers: { Upgrade: "websocket" },
    });
    const ws = res.webSocket!;

    ws.addEventListener("message", (event) => {
      const data =
        typeof event.data === "string"
          ? event.data
          : new TextDecoder().decode(event.data as ArrayBuffer);

      if (data.startsWith('{"t":"tick"')) {
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
    ws.addEventListener("close", () => (this.uplink = undefined));
    ws.addEventListener("error", () => (this.uplink = undefined));

    ws.accept();
    this.uplink = ws;
  }
}

export default handler(IngressActor);
