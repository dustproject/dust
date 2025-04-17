import { useEffect } from "react";
import { useConnectorClient } from "wagmi";
import { dustBridge } from "./dust";

export function App() {
  useEffect(() => {
    dustBridge.ready();
    dustBridge.on("app:open", ({ appConfig, via }) => {
      console.info("client opened app", appConfig, "via", via);
    });
  }, []);

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
          disabled={!connectorClient.isSuccess}
          onClick={() => {}}
        >
          Write
        </button>
      </p>
    </div>
  );
}
