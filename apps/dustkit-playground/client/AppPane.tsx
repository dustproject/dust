import { useSessionClient } from "@latticexyz/entrykit/internal";
import {
  type AppRpcSchema,
  type PostMessageRpcClient,
  getPostMessageRpcClient,
  postMessageTransport,
} from "dustkit/internal";
import { useEffect, useRef } from "react";
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

  return (
    <iframe
      title="DustKit app"
      src={import.meta.env.VITE_DUSTKIT_APP_URL}
      onLoad={async (event) => {
        if (!userAddress) {
          console.info("no user address, skipping app transport");
          return;
        }

        console.info("setting up app transport");
        const appTransport = postMessageTransport<AppRpcSchema>(
          event.currentTarget.contentWindow!,
        );
        console.info("rpc client ready, sending hello");
        const res = await appTransport({}).request({
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
