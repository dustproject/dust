import { SocketClosedError, WebSocketRequestError } from "viem";
import { type SocketRpcClient, getSocketRpcClient } from "viem/utils";
import { createMessagePort } from "./createMessagePort";

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

      const port = await createMessagePort({ target, targetOrigin });

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
