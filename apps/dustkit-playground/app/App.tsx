import {
  type AppRpcSchema,
  createMessagePortRpcServer,
} from "dustkit/internal";
import { useEffect } from "react";
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

  return (
    <div>
      <h1>App</h1>
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
          Set waypoint
        </button>
      </p>
    </div>
  );
}
