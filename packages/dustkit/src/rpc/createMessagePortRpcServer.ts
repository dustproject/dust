import { type RpcRequest, RpcResponse, type RpcSchema } from "ox";
import { MethodNotSupportedError } from "ox/RpcResponse";
import { anyInitialMessage } from "./common";
import { debug } from "./debug";

// Ideally we'd have one `onRequest` handler, but unfortunately I couldn't figure out how
// to get strong types, where narrowing on the RPC method would also narrow the params and
// enforce the method's specific return type.
//
// Instead, we have a map of `handlers`, where each RPC method is implemented as its own
// handler function.

export function createMessagePortRpcServer<
  schema extends RpcSchema.Generic,
  context = undefined,
>(
  createHandlers: (options: { context: context }) => {
    [method in RpcSchema.ExtractMethodName<schema>]?: (
      params: RpcSchema.ExtractParams<schema, method>,
    ) => Promise<RpcSchema.ExtractReturnType<schema, method>>;
  },
): () => void {
  let connectedPort: MessagePort | undefined;

  function onMessage(event: MessageEvent) {
    if (!anyInitialMessage.allows(event.data)) return;

    const [port] = event.ports;
    if (!port) {
      console.warn("Got initial message with no message port.");
      return;
    }

    const handlers = createHandlers({ context: event.data.context as never });

    port.addEventListener(
      "message",
      async (event: MessageEvent<RpcRequest.RpcRequest>) => {
        const { jsonrpc, id, method, params } = event.data;
        debug("got rpc request", { id, method, params });
        try {
          const handler =
            handlers[method as RpcSchema.ExtractMethodName<schema>];
          // TODO: is there another error we can throw that won't cause viem transport to retry?
          if (!handler) throw new MethodNotSupportedError();

          const result = await handler(params);
          debug("got result", { id, method, params, result });
          port.postMessage({
            jsonrpc,
            id,
            result,
          } satisfies RpcResponse.RpcResponse);
        } catch (error) {
          debug("got error", { id, method, params, error });
          port.postMessage({
            jsonrpc,
            id,
            error: RpcResponse.parseError(error),
          } satisfies RpcResponse.RpcResponse);
        }
      },
    );

    connectedPort?.close();
    connectedPort = port;

    port.start();
    port.postMessage(event.data);
  }

  window.addEventListener("message", onMessage);
  return () => {
    window.removeEventListener("message", onMessage);
    connectedPort?.close();
  };
}
