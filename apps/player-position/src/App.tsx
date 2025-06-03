import {
  type AppRpcSchema,
  type ClientRpcSchema,
  createMessagePortRpcServer,
  getMessagePortProvider,
} from "dustkit/internal";
import { useEffect, useState } from "react";

const dustClientProvider = getMessagePortProvider<ClientRpcSchema>({
  target: window.opener ?? window.parent,
});

export function App() {
  const [playerPosition, setPlayerPosition] = useState<{
    x: number;
    y: number;
    z: number;
  } | null>(null);

  useEffect(() => {
    return createMessagePortRpcServer<AppRpcSchema>({
      async dustApp_init(params) {
        console.info("client asked this app to initialize with", params);
        return { success: true };
      },
    });
  }, []);

  useEffect(() => {
    async function updatePlayerPosition() {
      const position = await dustClientProvider.request({
        method: "dustClient_getPlayerPosition",
        params: {
          entity: "0x",
        },
      });
      setPlayerPosition(position);
    }

    updatePlayerPosition();

    const timer = setInterval(updatePlayerPosition, 100);
    return () => clearInterval(timer);
  }, []);

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
