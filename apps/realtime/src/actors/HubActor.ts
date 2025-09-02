import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { Env } from "../env";

export class HubActor extends Actor<Env> {
  private shards = new Set<WebSocket>();

  constructor(state: ActorState, env: Env) {
    super(state, env);

    for (const ws of state.getWebSockets()) {
      const attachment = ws.deserializeAttachment();
      if (attachment?.shard) {
        this.shards.add(ws);
      }
    }
    this.ensureTick();

    this.ctx.setWebSocketAutoResponse(
      new WebSocketRequestResponsePair("ping", "pong"),
    );
  }

  // Create the Shard from the Hub so they're located relative to
  // the Hub rather than the client, to reduce latency between
  // Shard <> Hub.
  async ensureShard(name: string): Promise<void> {
    const id = this.env.Shard.idFromName(name);
    this.env.Shard.get(id, {
      locationHint: this.env.REGION_HINT,
    });
  }

  async fetch(req: Request): Promise<Response> {
    console.info("got hub request", req.url);
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    const url = new URL(req.url);
    const shard = url.searchParams.get("shard");
    if (!shard) return new Response("missing shard", { status: 400 });

    const { 0: client, 1: server } = new WebSocketPair();
    server.serializeAttachment({ shard });
    this.ctx.acceptWebSocket(server);

    this.shards.add(server);
    this.ensureTick();

    return new Response(null, { status: 101, webSocket: client });
  }

  private tick?: number;
  private ensureTick(): void {
    if (!this.shards.size && this.tick) {
      clearInterval(this.tick);
      this.tick = undefined;
      return;
    }

    if (this.shards.size && !this.tick) {
      const delay = Math.floor(
        1000 / Number.parseFloat(this.env.TICK_HZ ?? "20"),
      );

      this.tick = setInterval(() => {
        for (const ws of this.shards) {
          try {
            ws.send("tick");
          } catch {}
        }
      }, delay);
    }
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    if (!this.shards.has(ws)) {
      console.warn(
        "Got a message from an unknown websocket",
        ws.deserializeAttachment(),
        message,
      );
      return;
    }

    console.info("fanning out message to", this.shards.size, "shards");
    for (const shard of this.shards) {
      try {
        shard.send(message);
      } catch {}
    }
  }

  async webSocketClose(ws: WebSocket, code: number) {
    ws.close();
    this.shards.delete(ws);
    this.ensureTick();
  }

  async webSocketError(ws: WebSocket, code: number) {
    ws.close();
    this.shards.delete(ws);
    this.ensureTick();
  }
}

export default handler(HubActor);
