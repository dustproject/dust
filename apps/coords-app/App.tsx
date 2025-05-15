import defaultProgramAbi from "@dust/programs/out/DefaultProgram.sol/DefaultProgram.abi";
import { resourceToHex } from "@latticexyz/common";
import {
  type AppRpcSchema,
  type ClientRpcSchema,
  type MessagePortTransport,
  createMessagePortRpcServer,
  getMessagePortRpcClient,
  messagePort,
} from "dustkit/internal";
import { useCallback, useEffect, useRef, useState } from "react";
import { zeroHash } from "viem";

export function App() {
  const dustClientRef = useRef<MessagePortTransport<ClientRpcSchema> | null>(
    null,
  );

  const loadDustClient = useCallback(async () => {
    if (!window.opener && !window.parent) {
      console.error("no parent or opener");
      return;
    }

    const rpcClient = await getMessagePortRpcClient(
      window.opener ?? window.parent,
    );

    const newDustClient = messagePort<ClientRpcSchema>(rpcClient);
    dustClientRef.current = newDustClient;
  }, []);

  useEffect(() => {
    loadDustClient();

    return createMessagePortRpcServer<AppRpcSchema>({
      async dustApp_init(params) {
        console.info("client asked this app to initialize with", params);
        return { success: true };
      },
    });
  }, [loadDustClient]);

  return (
    <div>
      <h1>App</h1>
      <p>
        <button
          type="button"
          onClick={async () => {
            if (!dustClientRef.current) {
              console.error("no dust client");
              return;
            }

            await dustClientRef.current({}).request({
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
            if (!dustClientRef.current) {
              console.error("no dust client");
              return;
            }

            await dustClientRef.current({}).request({
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
