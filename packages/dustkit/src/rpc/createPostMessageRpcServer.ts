import { RpcResponse, type RpcSchema } from "ox";
import { rpcRequestEnvelope } from "./envelope";

// Ideally we'd have one `onRequest` handler, but unfortunately I couldn't figure out how
// to get strong types, where narrowing on the RPC method would also narrow the params and
// enforce the method's specific return type.
//
// Instead, we have a map of `handlers`, where each RPC method is implemented as its own
// handler function.

export function createPostMessageRpcServer<schema extends RpcSchema.Generic>(
  handlers: {
    [method in RpcSchema.ExtractMethodName<schema>]: (
      params: RpcSchema.ExtractParams<schema, method>,
    ) => Promise<RpcSchema.ExtractReturnType<schema, method>>;
  },
): () => void {
  async function onMessage(event: MessageEvent) {
    if (!event.source) return;
    if (!rpcRequestEnvelope.allows(event.data)) return;

    const { jsonrpc, id, method, params } = event.data.rpcRequest;
    console.info("got rpc request", { id, method, params });
    try {
      const handler = handlers[method as RpcSchema.ExtractMethodName<schema>];
      // TODO: is there another error we can throw that won't cause viem transport to retry?
      if (!handler) throw new RpcResponse.MethodNotSupportedError();

      const result = await handler(params);
      console.info("got result", { id, method, params, result });
      event.source.postMessage(
        {
          jsonrpc,
          id,
          result,
        } satisfies RpcResponse.RpcResponse,
        { targetOrigin: "*" },
      );
    } catch (error) {
      console.info("got error", { id, method, params, error });
      event.source.postMessage(
        {
          jsonrpc,
          id,
          error: RpcResponse.parseError(error),
        } satisfies RpcResponse.RpcResponse,
        { targetOrigin: "*" },
      );
    }
  }

  window.addEventListener("message", onMessage);
  return () => {
    window.removeEventListener("message", onMessage);
  };
}
