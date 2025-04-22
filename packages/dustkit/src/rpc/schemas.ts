import type { RpcSchema } from "ox";
import type { AppConfig } from "../apps/appConfig";
import type { EntityId, ProgramId } from "../common";

export type ClientRpcSchema = RpcSchema.From<{
  Request: {
    method: "dustClient_setWaypoint";
    params: {
      entity: EntityId;
      label: string;
    };
  };
}>;

export type AppRpcSchema = RpcSchema.From<{
  Request: {
    method: "dustApp_init";
    params: {
      appConfig: AppConfig;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
    };
  };
}>;
