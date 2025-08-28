import { scope, type } from "arktype";
import { type Hex, isHex } from "viem";
import type { Env } from "./env";

export { AuthorityActor } from "./actors/AuthorityActor";
export { IngressActor } from "./actors/IngressActor";

const $ = scope({
  hex: [
    "string",
    ":",
    (data, ctx): data is Hex => isHex(data) || ctx.mustBe("a hex string"),
  ],
});

const signedSessionDataSchema = $.type({
  userAddress: "hex",
  sessionAddress: "hex",
  signedAt: "number.epoch",
});

const sessionSchema = $.type({
  signature: "hex",
  signedSessionData: "string.json",
});

const parseSignedSessionData = type("string.json.parse").to(
  signedSessionDataSchema,
);

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
      const userAddress =
        url.searchParams.has("signature") &&
        url.searchParams.has("signedSessionData")
          ? await (async () => {
              const { signature, signedSessionData } = sessionSchema.assert({
                signature: url.searchParams.get("signature"),
                signedSessionData: url.searchParams.get("signedSessionData"),
              });

              const parsed = parseSignedSessionData(signedSessionData);
              if (parsed instanceof type.errors) return parsed.throw();
              const { userAddress, sessionAddress, signedAt } = parsed;

              // TODO: validate signed session data

              return userAddress;
            })()
          : null;

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
      return ingress.fetch(
        `https://ingress/?${new URLSearchParams({ userAddress: userAddress ?? "" })}`,
        { headers: { Upgrade: "websocket" } },
      );
    }

    return new Response("not found", { status: 404 });
  },
};
