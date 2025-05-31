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
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 10,
          width: "fit-content",
        }}
      >
        <button
          type="button"
          onClick={() => setAppOpen(!appOpen)}
          style={{ width: "fit-content" }}
        >
          {appOpen ? "Close app" : "Open app"}
        </button>
        {appOpen ? <AppPane /> : null}
      </div>
    </div>
  );
}
