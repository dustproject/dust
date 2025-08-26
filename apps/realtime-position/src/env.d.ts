import type { AuthorityActor } from "./actors/AuthorityActor";
import type { IngressActor } from "./actors/IngressActor";

export interface Env {
  REGION_HINT: DurableObjectLocationHint;
  INGRESS_SHARDS: string;
  TICK_HZ: string;
  CHAIN_ID: string;
  WORLD_ADDRESS: `0x${string}`;
  RPC_HTTP_URL: string;
  Authority: DurableObjectNamespace<AuthorityActor>;
  Ingress: DurableObjectNamespace<IngressActor>;
}
