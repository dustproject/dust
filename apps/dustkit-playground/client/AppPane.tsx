import {
  type AppRpcSchema,
  getMessagePortRpcClient,
  messagePort,
} from "dustkit/internal";
import { useEffect, useRef } from "react";
import type { SocketRpcClient } from "viem/utils";
import { useAccount } from "wagmi";
import { useClientRpcServer } from "./useClientRpcServer";

export function AppPane() {
  const { address: userAddress } = useAccount();
  const rpcClientRef = useRef<SocketRpcClient<MessagePort> | null>(null);
  useClientRpcServer();

  useEffect(() => {
    return () => {
      if (rpcClientRef.current) {
        console.info("closing rpc client");
        rpcClientRef.current.close();
      }
    };
  }, []);

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
        const rpcClient = await getMessagePortRpcClient(
          event.currentTarget.contentWindow!,
        );
        rpcClientRef.current = rpcClient;
        const appTransport = messagePort<AppRpcSchema>(rpcClient);
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
