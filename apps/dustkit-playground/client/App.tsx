import { AccountButton, useSessionClient } from "@latticexyz/entrykit/internal";
import { type AppRpcSchema, messagePort } from "dustkit/internal";
import { useEffect } from "react";
import { getWorldAddress } from "./common";
import { createClientRpcServer } from "./createClientRpcServer";

export function App() {
  const { data: sessionClient, status: sessionClientStatus } =
    useSessionClient();

  useEffect(
    () =>
      createClientRpcServer({ sessionClient, worldAddress: getWorldAddress() }),
    [sessionClient],
  );

  return (
    <div>
      <h1>Client</h1>
      <AccountButton />
      <p>
        Connector client {sessionClientStatus} for chain{" "}
        {sessionClient?.chain.id} (uid: {sessionClient?.uid})
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
