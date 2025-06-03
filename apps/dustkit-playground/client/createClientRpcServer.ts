import type { SessionClient } from "@latticexyz/entrykit/internal";
import {
  encodeSystemCalls,
  encodeSystemCallsFrom,
} from "@latticexyz/world/internal";
import {
  type ClientRpcSchema,
  createMessagePortRpcServer,
} from "dustkit/internal";
import { type Hex, isHex } from "viem";
import { sendUserOperation } from "viem/account-abstraction";
import { waitForTransactionReceipt, writeContract } from "viem/actions";
import { getAction } from "viem/utils";
import { waitForUserOperation } from "./waitForUserOperation";
import { worldCallAbi } from "./worldCallAbi";

export function createClientRpcServer({
  sessionClient,
  worldAddress,
}: { sessionClient?: SessionClient; worldAddress: Hex }) {
  console.info("setting up client rpc server", { sessionClient, worldAddress });
  const close = createMessagePortRpcServer<ClientRpcSchema>({
    async dustClient_setWaypoint(waypoint) {
      console.info("app asked for waypoint", waypoint);
    },
    async dustClient_systemCall(systemCalls) {
      if (!sessionClient) {
        throw new Error("Not connected.");
      }

      const abi = [
        ...worldCallAbi,
        ...systemCalls.flatMap((systemCall) =>
          systemCall.abi.filter((item) => item.type === "error"),
        ),
      ];

      // `callFrom` action skips `call`, so we have to reroute here
      if (
        sessionClient.account.type === "smart" &&
        "userAddress" in sessionClient &&
        isHex(sessionClient.userAddress)
      ) {
        const args = encodeSystemCallsFrom(
          sessionClient.userAddress,
          systemCalls,
        );
        const userOperationHash = await getAction(
          sessionClient,
          sendUserOperation,
          "sendUserOperation",
        )({
          account: sessionClient.account,
          calls: [
            {
              to: worldAddress,
              abi,
              functionName: "batchCallFrom",
              args,
            },
          ],
        });
        const { receipt } = await waitForUserOperation({
          sessionClient,
          userOperationHash,
          abi,
        });

        return {
          userOperationHash,
          receipt,
        };
      }

      const args = encodeSystemCalls(systemCalls);
      const transactionHash = await getAction(
        sessionClient,
        writeContract,
        "writeContract",
      )({
        // TODO: figure out how to make types happy so we don't have to pass these in
        chain: null,
        account: sessionClient.account,
        address: worldAddress,
        abi,
        functionName: "batchCall",
        args,
      });
      const receipt = await getAction(
        sessionClient,
        waitForTransactionReceipt,
        "waitForTransactionReceipt",
      )({
        hash: transactionHash,
      });

      return {
        transactionHash,
        receipt,
      };
    },
    // async dustClient_getSlots() {
    //   // TODO
    // },
    // async dustClient_getPlayerPosition() {
    //   // TODO
    // },
  });

  return () => {
    console.info("closing client rpc server", {
      sessionClient,
      worldAddress,
    });
    close();
  };
}
