import { SocketClosedError, WebSocketRequestError } from "viem";
import { type SocketRpcClient, getSocketRpcClient } from "viem/utils";

export const initMessage = "MessagePortRpcClient";

export type MessagePortRpcClient = SocketRpcClient<{
  readonly target: Window;
  readonly targetOrigin: string;
  readonly port: MessagePort;
}>;

export async function getMessagePortRpcClient({
  target,
  targetOrigin = "*",
  key = "messagePort",
}: {
  target: Window;
  targetOrigin?: string;
  key?: string;
}): Promise<MessagePortRpcClient> {
  let closed = false;
  return getSocketRpcClient({
    key,
    url: targetOrigin,
    async getSocket({ onClose, onError, onOpen, onResponse }) {
      if (closed) {
        // If we initiated closing the socket, don't allow reconnecting.
        throw new SocketClosedError({ url: targetOrigin });
      }

      const port = await new Promise<MessagePort>((resolve, reject) => {
        const channel = new MessageChannel();
        channel.port1.addEventListener(
          "message",
          function onMessage(event) {
            console.info("Got message from port", event);
            if (event.data === "ready") {
              resolve(channel.port1);
            } else {
              reject(new Error("Unexpected first message from MessagePort."));
            }
          },
          { once: true },
        );
        channel.port1.start();
        console.info("establishing MessagePort with", target);
        target.postMessage(initMessage, targetOrigin, [channel.port2]);
      });

      port.addEventListener("message", function onMessage(event: MessageEvent) {
        onResponse(event.data);
      });
      port.addEventListener("messageerror", onError);

      onOpen();

      console.info("port ready");

      const closePort = port.close.bind(port);
      return {
        target,
        targetOrigin,
        port,
        close() {
          console.info("closing port");
          closed = true;
          closePort();
          onClose();
        },
        request({ body }) {
          if (closed) {
            throw new WebSocketRequestError({
              body,
              url: targetOrigin,
              details: "MessagePort is closed.",
            });
          }
          return port.postMessage(body);
        },
      };
    },
  });
}
