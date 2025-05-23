import { useSessionClient } from "@latticexyz/entrykit/internal";
import {
  type AppRpcSchema,
  type PostMessageRpcClient,
  getMessagePortRpcClient,
  getPostMessageRpcClient,
  messagePort,
  postMessageTransport,
} from "dustkit/internal";
import { useEffect } from "react";
import { useAccount } from "wagmi";
import { getWorldAddress } from "./common";
import { createClientRpcServer } from "./createClientRpcServer";

export function AppPane() {
  const { address: userAddress } = useAccount();

  const { data: sessionClient } = useSessionClient();
  const worldAddress = getWorldAddress();

  useEffect(() => {
    if (!sessionClient) return;
    return createClientRpcServer({ sessionClient, worldAddress });
  }, [sessionClient, worldAddress]);

  const url = new URL(
    import.meta.env.VITE_DUSTKIT_APP_URL,
    window.location.href,
  );

  return (
    <iframe
      title="DustKit app"
      src={url.toString()}
      onLoad={async (event) => {
        if (!userAddress) {
          console.info("no user address, skipping app init");
          return;
        }

        console.info("setting up app provider");

        const appTransport = messagePort<AppRpcSchema>(
          getMessagePortRpcClient({
            target: event.currentTarget.contentWindow!,
            targetOrigin: url.origin,
          }),
        );
        console.info("rpc client ready, sending hello");
        const res = await appTransport({ timeout: 1000 }).request({
          method: "dustApp_init",
          params: {
            appConfig: {
              name: "Playground",
              startUrl: "/",
            },
            userAddress,
          },
        });
        console.info("got hello reply", res);
      }}
    />
  );
}
