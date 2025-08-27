import { Actor, type ActorState, handler } from "@cloudflare/actors";
import { scope, type } from "arktype";
import type { Address, Hex } from "viem";
import type { Env } from "../env";

const $ = scope({
  vec2: ["number", "number"],
  vec3: ["number", "number", "number"],
});

const userDataSchema = $.type([
  // position
  "vec3",
  // orientation
  "vec2",
  // velocity
  "vec3",
]);

const parseUserData = type("string.json.parse").to(userDataSchema);

export class IngressActor extends Actor<Env> {
  private uplink?: WebSocket;
  private clients = new Set<WebSocket>();
  private latest = new Map<
    Address,
    { u: Address; t: number; d: typeof userDataSchema.infer }
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
    this.ctx.acceptWebSocket(server);
    this.clients.add(server);

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

        const message =
          typeof event.data === "string"
            ? event.data
            : new TextDecoder().decode(event.data as ArrayBuffer);

        if (message === "tick") {
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
            console.info(
              "broadcasting message from authority to clients",
              message,
            );
            client.send(message);
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

  async webSocketMessage(ws: WebSocket, rawMessage: string | ArrayBuffer) {
    const message =
      typeof rawMessage === "string"
        ? rawMessage
        : new TextDecoder().decode(rawMessage);

    const attachment = ws.deserializeAttachment();
    if (!attachment?.userAddress) {
      console.warn("got ws message not from client", attachment, message);
      return;
    }
    const userAddress = attachment.userAddress as Hex;

    const userData = parseUserData(message);
    if (userData instanceof type.errors) {
      console.debug("ignoring invalid message", message);
    } else {
      this.latest.set(userAddress, {
        u: userAddress,
        t: Date.now(),
        d: userData,
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
