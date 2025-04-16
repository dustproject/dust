import type { RpcRequest, RpcResponse } from "ox";
import type { EntityId, ProgramId } from "../common";
import type { AppConfig } from "./appConfig";

// TODO: split schema out into directional specific schemas (app->client, client->app)

export type MessengerSchema = [
  /**
   * Client -> App messages
   */
  {
    topic: "app:open";
    payload: {
      appConfig: AppConfig;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
    };
    response: undefined;
  },
  /**
   * App -> Client messages
   */
  {
    topic: "client:rpcRequests";
    payload: readonly RpcRequest.RpcRequest[];
    response: readonly RpcResponse.RpcResponse[];
  },
  {
    topic: "client:setWaypoint";
    payload: {
      target: EntityId;
      label: string;
    };
    response: undefined;
  },
  /**
   * Internal messages
   */
  {
    topic: "internal:ready";
    payload: undefined;
    response: undefined;
  },
];
