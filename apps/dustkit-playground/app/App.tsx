import {
  type AppRpcSchema,
  createMessagePortRpcServer,
} from "dustkit/internal";
import { useEffect } from "react";
import { useConnectorClient } from "wagmi";
import { dustClient } from "./dust";

export function App() {
  useEffect(
    () =>
      createMessagePortRpcServer<AppRpcSchema>({
        async dustApp_init(params) {
          console.info("client asked this app to initialize with", params);
          return { success: true };
        },
      }),
    [],
  );

  // TODO: pass in chain ID?
  const connectorClient = useConnectorClient();

  return (
    <div>
      <h1>App</h1>
      <p>
        Connector client {connectorClient.status} for chain{" "}
        {connectorClient.data?.chain.id} (uid: {connectorClient.data?.uid})
      </p>
      <p>
        <button
          type="button"
          onClick={async () => {
            await dustClient({}).request({
              method: "dustClient_setWaypoint",
              params: {
                entity: "0x",
                label: "Somewhere",
              },
            });
          }}
        >
          Write
        </button>
      </p>
    </div>
  );
}
