import {
  type SessionClient,
  useSessionClient,
} from "@latticexyz/entrykit/internal";
import { useQuery } from "@tanstack/react-query";
import { useEffect } from "react";
import { getBlock } from "viem/actions";
import { getAction } from "viem/utils";

export function World() {
  const { data: sessionClient } = useSessionClient();

  const socket = useQuery({
    queryKey: ["dust position socket", sessionClient?.uid],
    async queryFn() {
      if (!sessionClient) throw new Error("Not connected");
      return connectPositionSocket(sessionClient);
    },
  });

  useEffect(() => {
    if (!socket.data) return;
    const timer = setInterval(() => {
      console.debug("sending position");
      socket.data.send(JSON.stringify({ x: 0, y: 0, z: 0 }));
    }, 1000);
    return () => {
      clearInterval(timer);
    };
  }, [socket.data]);

  return <>world</>;
}

async function connectPositionSocket(sessionClient: SessionClient) {
  console.debug("getting block");
  const block = await getAction(sessionClient, getBlock, "getBlock")({});
  const signedSessionData = JSON.stringify({
    userAddress: sessionClient.userAddress,
    sessionAddress: sessionClient.account.address,
    signedAt: Number(block.timestamp),
  });

  console.debug("signing session");
  const signature = await sessionClient.internal_signer.signMessage({
    message: signedSessionData,
  });

  return new Promise<WebSocket>((resolve, reject) => {
    console.debug("opening socket");
    const socket = new WebSocket(
      `ws://localhost:8787/ws?${new URLSearchParams({ signedSessionData, signature })}`,
    );

    socket.addEventListener("message", (event) => {
      const data =
        typeof event.data === "string"
          ? event.data
          : new TextDecoder().decode(event.data as ArrayBuffer);
      console.debug("got position socket data", data);
    });

    socket.addEventListener("open", () => {
      console.debug("position socket opened");
      resolve(socket);
    });
    socket.addEventListener("close", () => {
      console.debug("position socket closed");
    });
  });
}
