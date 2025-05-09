import { WebSocketRequestError } from "viem";
import {
  type Socket,
  type SocketRpcClient,
  getSocketRpcClient,
} from "viem/utils";

export const initMessage = "MessagePortRpcClient";

export async function getMessagePortRpcClient(
  target: Window,
): Promise<SocketRpcClient<MessagePort>> {
  let closed = false;
  return getSocketRpcClient({
    async getSocket({ onClose, onError, onOpen, onResponse }) {
      if (closed) {
        // On closure, viem will try to reconnect, but we don't want that
        // since we initiated the closure.
        throw new Error("MessagePortRpcClient is closed.");
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
        target.postMessage(initMessage, "*", [channel.port2]);
      });

      port.addEventListener("message", function onMessage(event: MessageEvent) {
        onResponse(event.data);
      });
      port.addEventListener("messageerror", onError);

      onOpen();

      console.info("port ready");

      const closePort = port.close.bind(port);
      return Object.assign(port, {
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
              url: "*",
              details: "MessagePort is closed.",
            });
          }
          return port.postMessage(body);
        },
      } as Socket<WebSocket>);
    },
    url: "*",
  });
}
