import { Actor, type ActorState, handler } from "@cloudflare/actors";
import type { positionChange } from "dustkit/realtime";
import type { Address } from "viem";
import { createInterval, createTimeout } from "../common";
import type { Env } from "../env";
import { hubSocket } from "../schemas";

export class HubActor extends Actor<Env> {
  private shards = new Map<WebSocket, { id: string; presence: Address[] }>();
  private positionChanges = new Map<Address, typeof positionChange.infer>();

  constructor(state: ActorState, env: Env) {
    super(state, env);

    state.setWebSocketAutoResponse(
      new WebSocketRequestResponsePair("ping", "pong"),
    );

    for (const ws of state.getWebSockets()) {
      const attachment = ws.deserializeAttachment();
      if (attachment?.shard) {
        this.shards.set(ws, { id: attachment.shard, presence: [] });
      }
    }
    this.onShards();
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

    try {
      const url = new URL(req.url);
      const shard = url.searchParams.get("shard");
      if (!shard) return new Response("missing shard", { status: 400 });

      const { 0: client, 1: server } = new WebSocketPair();
      server.serializeAttachment({ shard });
      this.ctx.acceptWebSocket(server);

      this.shards.set(server, { id: shard, presence: [] });
      this.onShards();

      return new Response(null, { status: 101, webSocket: client });
    } catch (error) {
      console.error(String(error));
      return new Response(String(error), { status: 500 });
    }
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    if (!this.shards.has(ws)) {
      console.warn(
        "got a message from an unknown websocket",
        ws.deserializeAttachment(),
        message,
      );
      return;
    }

    const data = hubSocket.in.receive(message);

    if (data.t === "positions") {
      for (const change of data.d) {
        this.positionChanges.set(change.u, change);
      }
    } else if (data.t === "presence") {
      this.shards.set(ws, { ...this.shards.get(ws)!, presence: data.d });
    }
  }

  async webSocketClose(ws: WebSocket, code: number) {
    ws.close();
    this.shards.delete(ws);
    this.onShards();
  }

  async webSocketError(ws: WebSocket, code: number) {
    ws.close();
    this.shards.delete(ws);
    this.onShards();
  }

  private positionsOff?: () => void;
  private presenceOff?: () => void;

  private onShards(): void {
    if (!this.shards.size) {
      this.positionsOff?.();
      this.positionsOff = undefined;
      this.presenceOff?.();
      this.presenceOff = undefined;
      return;
    }

    this.positionsOff ??= createInterval(1000 / 20, () => {
      console.info("hub positions tick");
      for (const [ws] of this.shards) {
        try {
          hubSocket.out.send(ws, "tickPositions");
        } catch {}
      }
      // fan out after a short timeout to ensure we get replies from the shards
      // if one of the shards doesn't get its update in, it'll still land in the next interval
      createTimeout(20, () => {
        if (!this.positionChanges.size) return;

        const positions = Array.from(this.positionChanges.values());
        this.positionChanges.clear();

        for (const [ws] of this.shards) {
          try {
            hubSocket.out.send(ws, { t: "positions", d: positions });
          } catch {}
        }
      });
    });

    this.presenceOff ??= createInterval(1000, () => {
      console.info("hub presence tick");
      const presence = Array.from(
        new Set(
          Array.from(this.shards.values()).flatMap(
            (shardData) => shardData.presence,
          ),
        ),
      );

      for (const [ws] of this.shards) {
        try {
          hubSocket.out.send(ws, { t: "presence", d: presence });
        } catch {}
      }
    });
  }
}

export default handler(HubActor);
