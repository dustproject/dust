import type { SystemCalls } from "@latticexyz/world/internal";
import type { RpcSchema } from "ox";
import type { Abi, Address, Hex, OneOf, TransactionReceipt } from "viem";
import type { UserOperationReceipt } from "viem/account-abstraction";
import type { AppConfig } from "../apps/appConfig";
import type { EntityId, ProgramId } from "../common";

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
        | {
            readonly userOperationHash: Hex;
            readonly status: "success" | "reverted";
            readonly receipt: UserOperationReceipt;
          }
        | {
            readonly transactionHash: Hex;
            readonly status: "success" | "reverted";
            readonly receipt: TransactionReceipt;
          }
      >;
    }
>;

export type AppRpcSchema = RpcSchema.From<{
  Request: {
    method: "dustApp_init";
    params: {
      appConfig: AppConfig;
      userAddress: Address;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
    };
  };
}>;
