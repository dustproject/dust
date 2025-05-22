import {
  type AppRpcSchema,
  type ClientRpcSchema,
  type MessagePortTransport,
  createMessagePortRpcServer,
  getMessagePortRpcClient,
  messagePort,
} from "dustkit/internal";
import { useCallback, useEffect, useRef, useState } from "react";

export function App() {
  const dustClientRef = useRef<MessagePortTransport<ClientRpcSchema> | null>(
    null,
  );
  const [playerPosition, setPlayerPosition] = useState<{
    x: number;
    y: number;
    z: number;
  } | null>(null);

  const updatePlayerPosition = useCallback(async () => {
    if (!dustClientRef.current) {
      console.error("no dust client");
      return;
    }

    const position = await dustClientRef.current({}).request({
      method: "dustClient_getPlayerPosition",
      params: {
        entity: "0x",
      },
    });

    setPlayerPosition(position);
  }, []);

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

  useEffect(() => {
    updatePlayerPosition();

    // run every 100ms
    const interval = setInterval(updatePlayerPosition, 100);

    return () => clearInterval(interval);
  }, [updatePlayerPosition]);

  return (
    <div
      style={{
        width: "100vw",
        height: "100vh",
        display: "grid",
        placeItems: "center",
        color: "white",
        fontFamily: "monospace",
        whiteSpace: "nowrap",
      }}
    >
      {playerPosition ? (
        <>
          {Math.floor(playerPosition.x)}, {Math.floor(playerPosition.y)},{" "}
          {Math.floor(playerPosition.z)}
        </>
      ) : null}
    </div>
  );
}
