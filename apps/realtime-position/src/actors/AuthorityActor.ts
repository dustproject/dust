import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { Env } from "../env";

type WireTick = { t: "tick"; seq: number };
type WireFrame = { t: "delta"; seq: number; payload: any };

export class AuthorityActor extends Actor<Env> {
  private uplinks = new Map<string, WebSocket>(); // shardName -> WS
  private seq = 0;
  private tickTimer?: NodeJS.Timeout;

  constructor(state: ActorState, env: Env) {
    super(state, env);
    for (const ws of state.getWebSockets()) {
      const att = ws.deserializeAttachment();
      if (att?.type === "uplink" && att?.shard) {
        this.uplinks.set(String(att.shard), ws);
      }
    }
  }

  // ---- typed RPC (control plane) ----
  async ensureShard(name: string): Promise<void> {
    const id = this.env.Ingress.idFromName(name);
    this.env.Ingress.get(id, {
      locationHint: this.env.REGION_HINT,
    });
  }

  // ---- WS upgrade (data plane) ----
  async fetch(req: Request): Promise<Response> {
    const url = new URL(req.url);
    if (
      url.pathname === "/uplink" &&
      req.headers.get("upgrade") === "websocket"
    ) {
      const shard = url.searchParams.get("from");
      if (!shard) return new Response("missing shard", { status: 400 });

      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair) as [WebSocket, WebSocket];
      server.serializeAttachment({ type: "uplink", shard });
      server.addEventListener("message", (event) => {
        console.info("authority got message from ingress", event);
        this.onBatch(event);
      });
      server.addEventListener("close", () => {
        console.info("authority<>ingress socket closed");
        this.onClose(shard);
      });
      server.addEventListener("error", (event) => {
        console.info("authority<>ingress socket error", event);
        this.onClose(shard);
      });
      this.ctx.acceptWebSocket(server);
      this.uplinks.set(shard, server);

      this.startTicks();
      return new Response(null, { status: 101, webSocket: client });
    }
    return new Response("ok");
  }

  private onBatch(event: MessageEvent): void {
    const data =
      typeof event.data === "string"
        ? event.data
        : new TextDecoder().decode(event.data as ArrayBuffer);
    const payload = JSON.parse(data);
    const wire = JSON.stringify({
      t: "delta",
      seq: this.seq,
      payload,
    } satisfies WireFrame);
    for (const ws of this.uplinks.values()) {
      try {
        ws.send(wire);
      } catch {}
    }
  }

  private onClose(shard: string): void {
    this.uplinks.delete(shard);
    if (!this.uplinks.size) this.stopTicks();
  }

  private startTicks(): void {
    if (this.tickTimer) return;
    const hz = Math.max(
      1,
      Math.min(60, Number.parseInt(this.env.TICK_HZ ?? "20")),
    );
    const period = Math.floor(1000 / hz);
    const tick = () => {
      this.seq++;
      const wire = JSON.stringify({
        t: "tick",
        seq: this.seq,
      } satisfies WireTick);
      for (const ws of this.uplinks.values()) {
        try {
          ws.send(wire);
        } catch {}
      }
      this.tickTimer = this.uplinks.size ? setTimeout(tick, period) : undefined;
    };
    this.tickTimer = setTimeout(tick, period);
  }

  private stopTicks(): void {
    if (this.tickTimer) {
      clearTimeout(this.tickTimer);
      this.tickTimer = undefined;
    }
  }
}

export default handler(AuthorityActor);
