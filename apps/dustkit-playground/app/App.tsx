import defaultProgramAbi from "@dust/programs/out/DefaultProgram.sol/DefaultProgram.abi";
import { resourceToHex } from "@latticexyz/common";
import {
  type AppRpcSchema,
  createMessagePortRpcServer,
} from "dustkit/internal";
import { useEffect } from "react";
import { zeroHash } from "viem";
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
        </button>{" "}
        <button
          type="button"
          onClick={async () => {
            await dustClient({}).request({
              method: "dustClient_systemCall",
              params: [
                {
                  systemId: resourceToHex({
                    type: "system",
                    namespace: "",
                    name: "",
                  }),
                  abi: defaultProgramAbi,
                  // TODO: figure out why this isn't narrowing with the provided ABI
                  functionName: "setAllowed",
                  args: [zeroHash, zeroHash, true],
                },
              ],
            });
          }}
        >
          Call system
        </button>
      </p>
    </div>
  );
}
