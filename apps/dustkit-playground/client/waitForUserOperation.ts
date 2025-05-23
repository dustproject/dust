import type { SessionClient } from "@latticexyz/entrykit/internal";
import type { Abi, Hex } from "viem";
import { decodeErrorResult, parseAbi, parseEventLogs } from "viem";
import type { UserOperationReceipt } from "viem/account-abstraction";
import {
  entryPoint07Abi,
  waitForUserOperationReceipt,
} from "viem/account-abstraction";
import { formatAbiItemWithArgs, getAction } from "viem/utils";

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
    };

export async function waitForUserOperation({
  sessionClient,
  userOperationHash,
  abi,
  timeout = 10_000,
}: WaitForUserOperationArgs): Promise<WaitForUserOperationResult> {
  const receipt = await getAction(
    sessionClient,
    waitForUserOperationReceipt,
    "waitForUserOperationReceipt",
  )({
    hash: userOperationHash,
    timeout,
  });

  if (receipt.success) {
    return {
      status: "success",
      receipt,
    };
  }

  const reason = (() => {
    try {
      const revertReasonData = parseEventLogs({
        logs: receipt.receipt.logs,
        abi: entryPoint07Abi,
      }).find((log) => log.eventName === "UserOperationRevertReason")?.args
        .revertReason;

      if (revertReasonData) {
        return formatAbiItemWithArgs(
          decodeErrorResult({
            data: revertReasonData,
            abi: abi ? [...abi, ...errorAbi] : errorAbi,
          }),
        );
      }
    } catch (error) {
      console.warn("Could not decode user op revert reason.", receipt, error);
    }
  })();

  return {
    status: "reverted",
    reason,
    receipt,
  };
}

const errorAbi = parseAbi(["error Error(string)"]);
