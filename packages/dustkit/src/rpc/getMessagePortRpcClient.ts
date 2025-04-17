import { WebSocketRequestError } from "viem";
import {
  type GetSocketRpcClientParameters,
  type Socket,
  type SocketRpcClient,
  getSocketRpcClient,
} from "viem/utils";

export type GetMessagePortRpcClientOptions = Pick<
  GetSocketRpcClientParameters,
  "reconnect"
>;

export const initMessage = "MessagePortRpcClient";

export async function getMessagePortRpcClient(
  target: Window,
  options: GetMessagePortRpcClientOptions | undefined = {},
): Promise<SocketRpcClient<MessagePort>> {
  const { reconnect } = options;

  return getSocketRpcClient({
    async getSocket({ onClose, onError, onOpen, onResponse }) {
      let closed = false;

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

      return Object.assign(port, {
        close() {
          closed = true;
          port.close();
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
    reconnect,
    url: "*",
  });
}
