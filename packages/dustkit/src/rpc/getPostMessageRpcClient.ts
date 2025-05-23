import type { RpcRequest } from "ox/RpcRequest";
import { WebSocketRequestError } from "viem";
import { type SocketRpcClient, getSocketRpcClient } from "viem/utils";
import packageJson from "../../package.json";
import { type RpcRequestEnvelope, rpcResponseEnvelope } from "./envelope";

export async function getPostMessageRpcClient(
  target: Window,
  targetOrigin = "*",
): Promise<
  SocketRpcClient<{
    readonly target: Window;
    readonly targetOrigin: string;
  }>
> {
  return getSocketRpcClient({
    async getSocket({ onClose, onError, onOpen, onResponse }) {
      let closed = false;

      function onMessage(event: MessageEvent) {
        if (rpcResponseEnvelope.allows(event.data)) {
          onResponse(event.data.rpcResponse);
        }
      }
      window.addEventListener("message", onMessage);

      onOpen();

      return {
        target,
        targetOrigin,
        close() {
          window.removeEventListener("message", onMessage);
          closed = true;
          onClose();
        },
        request({ body }) {
          if (closed) {
            throw new WebSocketRequestError({
              body,
              url: targetOrigin,
              details: "PostMessageRpcClient is closed.",
            });
          }
          return target.postMessage(
            {
              dustkit: packageJson.version,
              rpcRequest: body as RpcRequest,
            } satisfies RpcRequestEnvelope,
            targetOrigin,
          );
        },
      };
    },
    url: targetOrigin,
  });
}
