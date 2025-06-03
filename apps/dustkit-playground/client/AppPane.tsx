import { useSessionClient } from "@latticexyz/entrykit/internal";
import {
  encodeSystemCalls,
  encodeSystemCallsFrom,
} from "@latticexyz/world/internal";
import { connectDustApp } from "dustkit/internal";
import { useEffect, useState } from "react";
import { isHex } from "viem";
import { sendUserOperation } from "viem/account-abstraction";
import { waitForTransactionReceipt, writeContract } from "viem/actions";
import { getAction } from "viem/utils";
import { getWorldAddress } from "./common";
import { waitForUserOperation } from "./waitForUserOperation";
import { worldCallAbi } from "./worldCallAbi";

let nextAppId = 0;

export function AppPane() {
  const { data: sessionClient } = useSessionClient();
  const worldAddress = getWorldAddress();

  const [appWindow, setAppWindow] = useState<Window | null>(null);
  useEffect(() => {
    if (!sessionClient) return;
    if (!appWindow) return;

    return connectDustApp({
      target: appWindow,
      appContext: {
        id: `app:${++nextAppId}`,
        config: {
          name: "Playground",
          startUrl: "/",
        },
        userAddress: sessionClient.userAddress,
      },
      handlers: {
        async setWaypoint(waypoint) {
          console.info("app asked for waypoint", waypoint);
        },
        async systemCall(systemCalls) {
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
        // async getSlots() {
        //   // TODO
        // },
        // async getPlayerPosition() {
        //   // TODO
        // },
      },
    });
  }, [sessionClient, appWindow, worldAddress]);

  return (
    <iframe
      ref={(el) => setAppWindow(el?.contentWindow ?? null)}
      title="DustKit app"
      src={new URL(
        import.meta.env.VITE_DUSTKIT_APP_URL,
        window.location.href,
      ).toString()}
    />
  );
}
