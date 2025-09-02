import {
  channelsSchema,
  clientDataSchema,
  parseSession,
  parseSignedSessionData,
} from "dustkit/realtime";
import type { Env } from "./env";

export { HubActor } from "./actors/HubActor";
export { ShardActor } from "./actors/ShardActor";

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    console.info("got worker request", req.url);
    const url = new URL(req.url);

    if (url.pathname === "/health") return new Response("ok");

    if (url.pathname === "/ws") {
      if (req.headers.get("upgrade") !== "websocket") {
        return new Response("Expected WebSocket", { status: 426 });
      }

      // validate session and extract user address if provided
      const userAddress = url.searchParams.has("session")
        ? await (async () => {
            const { signature, signedSessionData } = parseSession.assert(
              url.searchParams.get("session"),
            );
            const { userAddress, sessionAddress, signedAt } =
              parseSignedSessionData.assert(signedSessionData);

            // TODO: validate signed session data

            return userAddress;
          })()
        : undefined;

      const channels = channelsSchema.assert(
        url.searchParams.getAll("channels"),
      );

      const shardName = [
        "shard",
        Math.floor(Math.random() * Number.parseInt(env.SHARDS ?? "8")),
      ].join(":");

      // create shard via hub to bind it to a location relative to hub
      // instead of relative to the client
      const hub = env.Hub.get(env.Hub.idFromName("global"), {
        locationHint: env.REGION_HINT,
      });

      console.info("ensuring shard");
      await hub.ensureShard(shardName);
      console.info("shard is ready");

      const shard = env.Shard.get(env.Shard.idFromName(shardName));
      console.info("shard is ready", shard);

      const clientData = clientDataSchema({ userAddress, channels });
      console.info("client data", String(clientData));

      console.info("establishing socket with shard");
      return shard.fetch(
        `https://shard/?${new URLSearchParams({ client: JSON.stringify(clientData) })}`,
        { headers: { Upgrade: "websocket" } },
      );
    }

    return new Response("not found", { status: 404 });
  },
};
