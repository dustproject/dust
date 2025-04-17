import { Messenger } from "dustkit";
import {
  type AppSchema,
  getMessagePortRpcClient,
  messagePort,
} from "dustkit/internal";
import { RpcResponse } from "ox";
import { useEffect, useState } from "react";
import { useConfig, useConnect, useConnectorClient } from "wagmi";

export function App() {
  const [bridge, setBridge] = useState<Messenger.Bridge>();
  // destroy bridge when it changes or we unmount
  useEffect(() => {
    if (!bridge) return;
    return () => bridge.destroy();
  }, [bridge]);

  // TODO: pass in chain ID?
  const connectorClient = useConnectorClient();
  const { connect, connectors } = useConnect();

  useEffect(() => {
    if (!bridge) return;
    return bridge.on("client:rpcRequest", async (request, reply) => {
      console.info("got request", request);

      switch (request.method) {
        case "eth_accounts": {
          return reply(
            RpcResponse.from({
              jsonrpc: request.jsonrpc,
              id: request.id,
              result: connectorClient.data
                ? [connectorClient.data.account.address]
                : [],
            }),
          );
        }
      }

      // try {
      //   const result = await connectorClient.transport.request(request);
      //   console.info("replying with result", result);
      //   reply(
      //     RpcResponse.from({
      //       id: request.id,
      //       jsonrpc: request.jsonrpc,
      //       result,
      //     }),
      //   );
      // } catch (error) {
      //   console.info("replying with error", error);
      //   reply(
      //     RpcResponse.from({
      //       id: request.id,
      //       jsonrpc: request.jsonrpc,
      //       error: {
      //         code: error.code,
      //         message: error.message,
      //       },
      //     }),
      //   );
      // }
    });
  }, [bridge, connectorClient]);

  return (
    <div>
      <h1>Client</h1>
      <p>
        Connector client {connectorClient.status} for chain{" "}
        {connectorClient.data?.chain.id} (uid: {connectorClient.data?.uid})
      </p>
      <p>
        <button
          type="button"
          onClick={() => connect({ connector: connectors[0]! })}
        >
          Connect
        </button>
      </p>
      <iframe
        title="DustKit app"
        src={import.meta.env.VITE_DUSTKIT_APP_URL}
        onLoad={async (event) => {
          const bridge = Messenger.bridge({
            from: Messenger.fromWindow(window),
            to: Messenger.fromWindow(event.currentTarget.contentWindow!),
            waitForReady: true,
          });

          bridge.send("app:open", {
            appConfig: {
              name: "DustKit app",
              startUrl: "/",
            },
          });

          setBridge(bridge);

          console.info("setting up app transport");
          const appTransport = messagePort<AppSchema>(
            event.currentTarget.contentWindow!,
          );
          console.info("rpc client ready, sending hello");
          const res = await appTransport({}).request({
            method: "dustApp_init",
            params: {},
          });
          await appTransport({}).request({
            method: "example",
          });
          console.info("got hello reply", res);
        }}
      />
    </div>
  );
}
