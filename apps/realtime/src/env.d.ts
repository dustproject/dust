import type { HubActor } from "./actors/HubActor";
import type { ShardActor } from "./actors/ShardActor";

export interface Env {
  REGION_HINT: DurableObjectLocationHint;
  SHARDS: string;
  TICK_HZ: string;
  CHAIN_ID: string;
  WORLD_ADDRESS: `0x${string}`;
  RPC_HTTP_URL: string;
  Hub: DurableObjectNamespace<HubActor>;
  Shard: DurableObjectNamespace<ShardActor>;
}
