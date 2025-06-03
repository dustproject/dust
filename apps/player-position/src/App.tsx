import { useQuery } from "@tanstack/react-query";
import { connectDustClient } from "dustkit/internal";
import { useEffect, useState } from "react";

export function App() {
  const { data: dustClient } = useQuery({
    queryKey: ["dust-client"],
    queryFn: connectDustClient,
  });

  const [playerPosition, setPlayerPosition] = useState<{
    x: number;
    y: number;
    z: number;
  } | null>(null);

  useEffect(() => {
    async function updatePlayerPosition() {
      if (!dustClient) return;

      const position = await dustClient.provider.request({
        method: "getPlayerPosition",
        params: {
          entity: "0x",
        },
      });
      setPlayerPosition(position);
    }

    updatePlayerPosition();

    const timer = setInterval(updatePlayerPosition, 100);
    return () => clearInterval(timer);
  }, [dustClient]);

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
