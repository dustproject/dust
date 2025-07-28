import defaultProgramAbi from "@dust/programs/out/DefaultProgramSystem.sol/DefaultProgramSystem.abi";
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
              method: "setWaypoint",
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
              method: "systemCall",
              params: [
                {
                  systemId: resourceToHex({
                    type: "system",
                    namespace: "",
                    name: "",
                  }),
                  abi: defaultProgramAbi,
                  functionName: "setMembership",
                  args: [zeroHash, zeroHash, zeroHash, true],
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
