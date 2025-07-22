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
  | {
      Request: {
        method: "setBlueprint";
        params: {
          blocks: {
            objectTypeId: number;
            x: number;
            y: number;
            z: number;
            orientation: number;
          }[];
          options:
            | {
                showBlocksToMine: boolean;
                showBlocksToBuild: boolean;
              }
            | undefined;
        };
      };
      ReturnType: void;
    }
  | {
      Request: {
        method: "getSelectedObjectType";
      };
      ReturnType: number;
    }
  | {
      Request: {
        method: "getForceFieldAt";
        params: {
          x: number;
          y: number;
          z: number;
        };
      };
      ReturnType:
        | {
            forceFieldId: Hex;
            fragmentId: Hex;
            fragmentPos: {
              x: number;
              y: number;
              z: number;
            };
            forceFieldCreatedAt: bigint;
            extraDrainRate: bigint;
          }
        | undefined;
    }
>;
