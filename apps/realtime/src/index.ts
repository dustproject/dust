import {
  channelsSchema,
  sessionSchema,
  signedSessionDataSchema,
  type,
} from "dustkit/realtime";
import { http, createClient, recoverMessageAddress } from "viem";
import { getBlock } from "viem/actions";
import type { Env } from "./env";
import { validateSigner } from "./mud/validateSigner";
import { clientDataSchema } from "./schemas";

export { HubActor } from "./actors/HubActor";
export { ShardActor } from "./actors/ShardActor";

const parseSession = type("string.json.parse").to(sessionSchema);
const parseSignedSessionData = type("string.json.parse").to(
  signedSessionDataSchema,
);

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    console.info("got worker request", req.url);
    const url = new URL(req.url);

    if (url.pathname === "/health") return new Response("ok");

    if (url.pathname === "/ws") {
      if (req.headers.get("upgrade") !== "websocket") {
        return new Response("Expected WebSocket", { status: 426 });
      }

      try {
        // validate session and extract user address if provided
        const userAddress = url.searchParams.has("session")
          ? await (async () => {
              const { signature, signedSessionData } = parseSession.assert(
                url.searchParams.get("session"),
              );
              const { userAddress, sessionAddress, signedAt } =
                parseSignedSessionData.assert(signedSessionData);

              const client = createClient({
                transport: http(env.RPC_HTTP_URL),
              });
              const block = await getBlock(client);
              const elapsed = Number(block.timestamp) - signedAt;
              if (elapsed > 15) {
                throw new Error("message signature expired");
              }
              // don't allow signatures from future timestamps
              // but allow some slop in case of load balanced RPC
              if (elapsed < -10) {
                throw new Error("cannot use future block timestamp");
              }

              const signerAddress = await recoverMessageAddress({
                message: signedSessionData,
                signature: signature,
              });

              await validateSigner({
                client,
                worldAddress: env.WORLD_ADDRESS,
                userAddress,
                sessionAddress,
                signerAddress,
              });

              return userAddress;
            })()
          : undefined;

        const channels = channelsSchema.assert(
          url.searchParams.getAll("channels"),
        );

        // always assign a user to the same shard to reduce duplicate data when connecting across multiple sockets
        // but observers (no user address) can be randomly assigned to any shard
        const shardHash = userAddress
          ? hash(userAddress)
          : Math.floor(Math.random() * 0xffffffff);
        const shardName = [
          "shard",
          shardHash % Number.parseInt(env.SHARDS ?? "8"),
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

        const clientData = clientDataSchema.assert({ userAddress, channels });
        console.info("client data", clientData);

        console.info("establishing socket with shard");
        return shard.fetch(
          `https://shard/?${new URLSearchParams({ client: JSON.stringify(clientData) })}`,
          { headers: { Upgrade: "websocket" } },
        );
      } catch (error) {
        console.error(String(error));
        return new Response(String(error), { status: 500 });
      }
    }

    return new Response("not found", { status: 404 });
  },
};

function hash(input: string): number {
  let h = 0x811c9dc5;
  for (let i = 0; i < input.length; i++) {
    h ^= input.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  return h >>> 0;
}
