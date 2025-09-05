import type { SessionClient } from "@latticexyz/entrykit/internal";
import { WebSocket } from "isows";
import { type Address, type Client, getAddress } from "viem";
import { getBlock } from "viem/actions";
import { getAction } from "viem/utils";
import type { channelsSchema } from "./clientSetup";
import { clientSocket } from "./clientSocket";
import { toSearchParams } from "./toSearchParams";

// TODO: abstract over WebSocket so we can auto reconnect like Viem's `getWebSocketRpcClient`

export type RealtimeSocket = {
  socket: WebSocket;
  send: (data: {
    position: [number, number, number];
    orientation: [number, number];
    velocity: [number, number, number];
  }) => void;
};

export type GetSocketOptions = {
  url?: string;
  // TODO: consider making this `channels` arg and then using eventemitter so we can bind any number of listeners to each event type
  onPositions?: (data: {
    readonly positions: readonly {
      readonly player: Address;
      readonly timestamp: number;
      readonly position: readonly [number, number, number];
      readonly orientation: readonly [number, number];
      readonly velocity: readonly [number, number, number];
    }[];
  }) => void;
  onPresence?: (data: {
    readonly players: readonly Address[];
  }) => void;
} & (
  | {
      sessionClient?: undefined;
      publicClient?: undefined;
    }
  | {
      sessionClient: SessionClient;
      publicClient: Client;
    }
);

const sockets = new Map<string, Promise<RealtimeSocket>>();

function getSocketKey(
  config: {
    sessionClient?: SessionClient | undefined;
    channels?: typeof channelsSchema.infer;
  } = {},
): string {
  const userName = config.sessionClient
    ? getAddress(config.sessionClient.userAddress)
    : "guest";
  const channelNames = config.channels
    ? Array.from(new Set(config.channels.slice().sort()))
    : [];
  return `${userName}:${channelNames.join(",")}`;
}

export function getSocket({
  url = "wss://realtime.dust.computer/ws",
  sessionClient,
  publicClient,
  onPositions,
  onPresence,
}: GetSocketOptions = {}): Promise<RealtimeSocket> {
  const channels: typeof channelsSchema.infer = [];
  if (onPositions) channels.push("positions");
  if (onPresence) channels.push("presence");

  const socketKey = getSocketKey({ sessionClient, channels });
  const socket = sockets.get(socketKey);
  if (socket) return socket;

  const socketPromise = (async () => {
    const session =
      sessionClient && publicClient
        ? await (async () => {
            console.debug("getting block");
            const block = await getAction(
              publicClient,
              getBlock,
              "getBlock",
            )({});
            const signedSessionData = JSON.stringify({
              userAddress: sessionClient.userAddress,
              sessionAddress: sessionClient.account.address,
              signedAt: Number(block.timestamp),
            });
            console.debug("signing session", signedSessionData);
            const signature = await sessionClient.internal_signer.signMessage({
              message: signedSessionData,
            });
            return JSON.stringify({ signedSessionData, signature });
          })()
        : null;

    return new Promise<RealtimeSocket>((resolve, reject) => {
      console.debug("opening realtime socket");
      const socket = new WebSocket(
        `${url}?${toSearchParams({ session, channels })}`,
      );

      socket.addEventListener(
        "open",
        (event) => {
          console.debug("realtime socket open");
          resolve({
            socket,
            send({ position, orientation, velocity }) {
              clientSocket.out.send(socket, [position, orientation, velocity]);
            },
          });
        },
        { once: true },
      );

      socket.addEventListener(
        "close",
        (event) => {
          console.debug("realtime socket close", event.code, event.reason);
          reject(new Error("Socket closed before it could be opened."));
        },
        { once: true },
      );

      socket.addEventListener(
        "error",
        (event) => {
          console.error("realtime socket error");
          reject(new Error("Socket errored before it could be opened."));
          try {
            socket?.close();
          } catch {}
        },
        { once: true },
      );

      socket.addEventListener("message", (event) => {
        const data = clientSocket.in.receive(event.data);

        if (data.t === "positions" && onPositions) {
          onPositions({
            positions: data.d.map((pos) => ({
              player: pos.u,
              timestamp: pos.t,
              position: pos.d[0],
              orientation: pos.d[1],
              velocity: pos.d[2],
            })),
          });
        }

        if (data.t === "presence" && onPresence) {
          onPresence({
            players: data.d,
          });
        }
      });
    });
  })();

  sockets.set(socketKey, socketPromise);
  return socketPromise;
}
