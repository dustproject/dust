import {
  type AppRpcSchema,
  type ClientRpcSchema,
  createMessagePortRpcServer,
  messagePort,
} from "dustkit/internal";
import { useEffect } from "react";
import { useConnect, useConnectorClient } from "wagmi";

export function App() {
  // TODO: pass in chain ID?
  const connectorClient = useConnectorClient();
  const { connect, connectors } = useConnect();

  useEffect(
    () =>
      createMessagePortRpcServer<ClientRpcSchema>({
        async dustClient_setWaypoint(params) {
          console.info("app asked for waypoint", params);
        },
      }),
    [],
  );

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
          console.info("setting up app transport");
          const appTransport = messagePort<AppRpcSchema>(
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
            },
          });
          console.info("got hello reply", res);
        }}
      />
    </div>
  );
}
