import defaultProgramAbi from "@dust/programs/out/DefaultProgram.sol/DefaultProgram.abi";
import { resourceToHex } from "@latticexyz/common";
import { useQuery } from "@tanstack/react-query";
import { connectDustClient } from "dustkit/internal";
import { zeroHash } from "viem";

export function App() {
  const dustClient = useQuery({
    queryKey: ["dust-client"],
    queryFn: connectDustClient,
  });

  return (
    <div>
      <h1>App</h1>
      <p>
        <button
          type="button"
          onClick={async () => {
            await dustClient.data?.provider.request({
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
            await dustClient.data?.provider.request({
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
        </button>{" "}
        <a href={`?ts=${Date.now()}`}>Navigate</a>
      </p>
    </div>
  );
}
