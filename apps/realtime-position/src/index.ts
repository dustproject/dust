import { scope } from "arktype";
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

const parseSignedSessionData = $.type([
  "string.json.parse",
  "|>",
  signedSessionDataSchema,
]);

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    if (url.pathname === "/health") return new Response("ok");

    if (url.pathname === "/ws" && req.headers.get("upgrade") === "websocket") {
      const { signature, signedSessionData } = sessionSchema.from({
        signature: url.searchParams.get("signature") as Hex,
        signedSessionData: url.searchParams.get("signedSessionData")!,
      });

      const { userAddress, sessionAddress, signedAt } =
        parseSignedSessionData.from(signedSessionData);

      // TODO: validate signed session data

      const shardName = `shard:${getShard(userAddress, Number.parseInt(env.INGRESS_SHARDS ?? "8"))}`;

      const authority = env.Authority.get(env.Authority.idFromName("global"), {
        locationHint: env.REGION_HINT,
      });
      await authority.ensureShard(shardName);

      // Forward original Upgrade to the shard's /ws
      const ingress = env.Ingress.get(env.Ingress.idFromName(shardName));

      console.info(
        "[entry] fwd → DO url=%s upgrade=%s",
        new URL(req.url).toString(),
        req.headers.get("upgrade"),
      );
      // const target = new URL(req.url);
      // target.searchParams.set("userAddress", userAddress);
      return ingress.fetch(req);
    }

    return new Response("not found", { status: 404 });
  },
};

function getShard(key: string, shards: number): number {
  let h = 0x811c9dc5;
  for (let i = 0; i < key.length; i++) {
    h ^= key.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  return (h >>> 0) % shards;
}
