import {
  channelsSchema,
  clientDataSchema,
  parseSession,
  parseSignedSessionData,
} from "dustkit/realtime";
import type { Env } from "./env";

export { AuthorityActor } from "./actors/AuthorityActor";
export { IngressActor } from "./actors/IngressActor";

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.headers.get("upgrade") !== "websocket") {
      return new Response("Expected WebSocket", { status: 426 });
    }

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
        Math.floor(Math.random() * Number.parseInt(env.INGRESS_SHARDS ?? "8")),
      ].join(":");

      // create ingress via authority to bind it to a location relative to authority
      // instead of relative to the client
      const authority = env.Authority.get(env.Authority.idFromName("global"), {
        locationHint: env.REGION_HINT,
      });
      await authority.ensureIngress(shardName);

      const ingress = env.Ingress.get(env.Ingress.idFromName(shardName));
      const clientData = clientDataSchema.from({ userAddress, channels });

      return ingress.fetch(
        `https://ingress/?${new URLSearchParams({ client: JSON.stringify(clientData) })}`,
        { headers: { Upgrade: "websocket" } },
      );
    }

    return new Response("not found", { status: 404 });
  },
};
