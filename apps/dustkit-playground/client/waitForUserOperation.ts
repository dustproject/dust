import type { SessionClient } from "@latticexyz/entrykit/internal";
import type { Abi, Hex } from "viem";
import { decodeErrorResult, parseAbi, parseEventLogs } from "viem";
import type { UserOperationReceipt } from "viem/account-abstraction";
import {
  entryPoint07Abi,
  waitForUserOperationReceipt,
} from "viem/account-abstraction";

export type WaitForUserOperationArgs = {
  sessionClient: SessionClient;
  userOperationHash: Hex;
  abi?: Abi;
  timeout?: number;
};

export type WaitForUserOperationResult =
  | {
      status: "success";
      receipt: UserOperationReceipt;
    }
  | {
      status: "reverted";
      reason?: string;
      receipt: UserOperationReceipt;
    }
  | {
      status: "timeout";
      reason: string;
    };

export async function waitForUserOperation({
  sessionClient,
  userOperationHash,
  abi,
  timeout = 10_000,
}: WaitForUserOperationArgs): Promise<WaitForUserOperationResult> {
  try {
    const receipt = await waitForUserOperationReceipt(sessionClient as never, {
      hash: userOperationHash,
      timeout,
    });
    if (receipt.success) {
      return {
        status: "success",
        receipt,
      };
    }

    try {
      const encodedReason = parseEventLogs({
        logs: receipt.receipt.logs,
        abi: entryPoint07Abi,
      }).find((log) => log.eventName === "UserOperationRevertReason")?.args
        .revertReason;

      const errorAbi = parseAbi(["error Error(string)"]);
      const decodedReason =
        encodedReason &&
        decodeErrorResult({
          data: encodedReason,
          abi: abi ? [...abi, errorAbi] : errorAbi,
        }).args[0];

      return {
        status: "reverted",
        reason: decodedReason,
        receipt,
      };
    } catch (error) {
      return {
        status: "reverted",
        receipt,
      };
    }
  } catch {
    return {
      status: "timeout",
      reason: `Not confirmed after ${Math.floor(timeout / 1000)} seconds`,
    };
  }
}
