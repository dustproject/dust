import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { Env } from "../env";

// TODO: store latest state so we can broadcast to newly connected ingress

export class AuthorityActor extends Actor<Env> {
  private uplinks = new Set<WebSocket>();

  constructor(state: ActorState, env: Env) {
    super(state, env);

    for (const ws of state.getWebSockets()) {
      const attachment = ws.deserializeAttachment();
      if (attachment?.ingress) {
        this.uplinks.add(ws);
      }
    }
    this.ensureTick();

    this.ctx.setWebSocketAutoResponse(
      new WebSocketRequestResponsePair("ping", "pong"),
    );
  }

  // Create the Ingress from the Authority so they're located relative to
  // the Authority rather than the client, to reduce latency between
  // Ingress <> Authority.
  async ensureIngress(name: string): Promise<void> {
    const id = this.env.Ingress.idFromName(name);
    this.env.Ingress.get(id, {
      locationHint: this.env.REGION_HINT,
    });
  }

  async fetch(req: Request): Promise<Response> {
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

    const url = new URL(req.url);
    const ingress = url.searchParams.get("ingress");
    if (!ingress) return new Response("missing ingress", { status: 400 });

    const { 0: client, 1: server } = new WebSocketPair();
    server.serializeAttachment({ ingress });
    this.ctx.acceptWebSocket(server);

    this.uplinks.add(server);
    this.ensureTick();

    return new Response(null, { status: 101, webSocket: client });
  }

  private tick?: NodeJS.Timeout;
  private ensureTick(): void {
    if (!this.uplinks.size && this.tick) {
      clearInterval(this.tick);
      this.tick = undefined;
      return;
    }

    if (this.uplinks.size && !this.tick) {
      const delay = Math.floor(
        1000 / Number.parseFloat(this.env.TICK_HZ ?? "20"),
      );

      this.tick = setInterval(() => {
        for (const ws of this.uplinks) {
          try {
            ws.send("tick");
          } catch {}
        }
      }, delay);
    }
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    if (!this.uplinks.has(ws)) {
      console.warn(
        "Got a message from an unknown websocket",
        ws.deserializeAttachment(),
        message,
      );
      return;
    }

    for (const uplink of this.uplinks) {
      try {
        uplink.send(message);
      } catch {}
    }
  }

  async webSocketClose(ws: WebSocket, code: number) {
    ws.close();
    this.uplinks.delete(ws);
    this.ensureTick();
  }

  async webSocketError(ws: WebSocket, code: number) {
    ws.close();
    this.uplinks.delete(ws);
    this.ensureTick();
  }
}

export default handler(AuthorityActor);
