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
import { sendUserOperation as viem_sendUserOperation } from "viem/account-abstraction";
import { writeContract as viem_writeContract } from "viem/actions";
import { getAction } from "viem/utils";
import { worldCallAbi } from "./worldCallAbi";

export function createClientRpcServer({
  sessionClient,
  worldAddress,
}: { sessionClient?: SessionClient; worldAddress: Hex }) {
  console.info("setting up client rpc server", { sessionClient, worldAddress });
  return createMessagePortRpcServer<ClientRpcSchema>({
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
        const sendUserOperation = getAction(
          sessionClient,
          viem_sendUserOperation,
          "sendUserOperation",
        );
        const args = encodeSystemCallsFrom(
          sessionClient.userAddress,
          systemCalls,
        );

        return {
          userOperationHash: await sendUserOperation({
            account: sessionClient.account,
            calls: [
              {
                to: worldAddress,
                abi,
                functionName: "batchCallFrom",
                args,
              },
            ],
          }),
        };
      }

      const writeContract = getAction(
        sessionClient,
        viem_writeContract,
        "writeContract",
      );
      const args = encodeSystemCalls(systemCalls);

      return {
        transactionHash: await writeContract({
          // TODO: figure out how to make types happy so we don't have to pass these in
          chain: null,
          account: sessionClient.account,
          address: worldAddress,
          abi,
          functionName: "batchCall",
          args,
        }),
      };
    },
  });
}
