import type { SystemCalls } from "@latticexyz/world/internal";
import type { RpcSchema } from "ox";
import type { Abi, Address, Hex, OneOf } from "viem";
import type { RpcSchema as viem_RpcSchema } from "viem";
import type { AppConfig } from "../apps/appConfig";
import type { EntityId, ProgramId } from "../common";

export type ClientViemRpcSchema = validateViemRpcSchema<
  [
    {
      Method: "dustClient_setWaypoint";
      Params: {
        entity: EntityId;
        label: string;
      };
      ReturnType: void;
    },
    {
      Method: "dustClient_systemCall";
      Params: {
        systemCalls: SystemCalls<readonly Abi[]>;
      };
      ReturnType: OneOf<
        { readonly userOperationHash: Hex } | { readonly transactionHash: Hex }
      >;
    },
  ]
>;

type validateViemRpcSchema<schema extends viem_RpcSchema> = schema;

export type ClientRpcSchema = RpcSchema.From<
  | {
      Request: {
        method: "dustClient_setWaypoint";
        params: {
          entity: EntityId;
          label: string;
        };
      };
      ReturnType: void;
    }
  | {
      Request: {
        method: "dustClient_systemCall";
        params: SystemCalls<readonly Abi[]>;
      };
      ReturnType: OneOf<
        { readonly userOperationHash: Hex } | { readonly transactionHash: Hex }
      >;
    }
>;

export type AppRpcSchema = RpcSchema.From<{
  Request: {
    method: "dustApp_init";
    params: {
      appConfig: AppConfig;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
      userAddress?: Address;
    };
  };
}>;
