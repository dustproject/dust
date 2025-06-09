import type { SystemCalls } from "@latticexyz/world/internal";
import type { RpcSchema } from "ox";
import type { Abi, Hex, OneOf, TransactionReceipt } from "viem";
import type { UserOperationReceipt } from "viem/account-abstraction";
import type { EntityId } from "../common";

export type ClientRpcSchema = RpcSchema.From<
  | {
      Request: {
        method: "setWaypoint";
        params: {
          entity: EntityId;
          label: string;
        };
      };
      ReturnType: void;
    }
  | {
      Request: {
        method: "getSlots";
        params: {
          entity: EntityId;
          objectType: number;
          amount: number;
          operationType: "withdraw" | "deposit";
        };
      };
      ReturnType: {
        slots: {
          slot: number;
          amount: number;
        }[];
      };
    }
  | {
      Request: {
        method: "systemCall";
        params: SystemCalls<readonly Abi[]>;
      };
      ReturnType: OneOf<
        | {
            readonly userOperationHash: Hex;
            readonly receipt: UserOperationReceipt;
          }
        | {
            readonly transactionHash: Hex;
            readonly receipt: TransactionReceipt;
          }
      >;
    }
  | {
      Request: {
        method: "getPlayerPosition";
        params: {
          entity: EntityId;
        };
      };
      ReturnType: {
        x: number;
        y: number;
        z: number;
      };
    }
>;
<<<<<<< HEAD:packages/dustkit/src/bridge/schemas.ts
=======

export type AppRpcSchema = RpcSchema.From<{
  Request: {
    method: "dustApp_init";
    params: {
      appConfig: AppConfig;
      worldAddress: Address;
      userAddress: Address;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
    };
  };
}>;
>>>>>>> a82659a (pass world address):packages/dustkit/src/rpc/schemas.ts
