import { AccountButton, useSessionClient } from "@latticexyz/entrykit/internal";
import { useState } from "react";
import { AppPane } from "./AppPane";

export function Game() {
  const { data: sessionClient, status: sessionClientStatus } =
    useSessionClient();
  const [appOpen, setAppOpen] = useState(false);

  return (
    <div>
      <h1>Client</h1>
      <AccountButton />
      <p>
        Connector client {sessionClientStatus} for chain{" "}
        {sessionClient?.chain.id} (uid: {sessionClient?.uid})
      </p>
      <button type="button" onClick={() => setAppOpen(!appOpen)}>
        {appOpen ? "Close App" : "Open App"}
      </button>
      {appOpen ? <AppPane /> : null}
    </div>
  );
}
