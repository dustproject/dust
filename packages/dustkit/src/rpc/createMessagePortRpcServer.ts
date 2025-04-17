import { type RpcRequest, RpcResponse, type RpcSchema } from "ox";
import { initMessage } from "./getMessagePortRpcClient";

export function createMessagePortRpcServer<schema extends RpcSchema.Generic>({
  onRequest,
}: {
  onRequest: {
    [method in RpcSchema.ExtractMethodName<schema>]: (request: {
      method: method;
      params: RpcSchema.ExtractParams<schema, method>;
    }) => Promise<RpcSchema.ExtractReturnType<schema, method>>;
  }[RpcSchema.ExtractMethodName<schema>];
}) {
  window.addEventListener("message", (event) => {
    if (event.data !== initMessage) return;

    const [port] = event.ports;
    if (!port) {
      return console.warn(`Got "${initMessage}" message with no message port.`);
    }

    port.addEventListener(
      "message",
      async (event: MessageEvent<RpcRequest.RpcRequest>) => {
        const { jsonrpc, id, method, params } = event.data;
        try {
          const result = await onRequest({ method, params });
          port.postMessage({
            jsonrpc,
            id,
            result,
          } satisfies RpcResponse.RpcResponse);
        } catch (error) {
          port.postMessage({
            jsonrpc,
            id,
            error: RpcResponse.parseError(error),
          } satisfies RpcResponse.RpcResponse);
        }
      },
    );

    port.start();
    port.postMessage("ready");
  });
}
