import { type RpcRequest, RpcResponse, type RpcSchema } from "ox";
import { MethodNotSupportedError } from "ox/RpcResponse";
import { initMessage } from "./getMessagePortProvider";

// Ideally we'd have one `onRequest` handler, but unfortunately I couldn't figure out how
// to get strong types, where narrowing on the RPC method would also narrow the params and
// enforce the method's specific return type.
//
// Instead, we have a map of `handlers`, where each RPC method is implemented as its own
// handler function.

let nextId = 0;
const portCache = new Map<MessagePort, string>();

export function createMessagePortRpcServer<schema extends RpcSchema.Generic>(
  handlers: {
    [method in RpcSchema.ExtractMethodName<schema>]: (
      params: RpcSchema.ExtractParams<schema, method>,
    ) => Promise<RpcSchema.ExtractReturnType<schema, method>>;
  },
): () => void {
  const id = `MessagePortRpcServer:${nextId++}`;

  let connectedPort: MessagePort | undefined;

  function onMessage(event: MessageEvent) {
    if (event.data !== initMessage) return;

    console.info("message via", id, event);

    const [port] = event.ports;
    if (!port) {
      console.warn(`Got "${initMessage}" message with no message port.`);
      return;
    }

    if (portCache.has(port)) {
      console.warn("port already consumed by", portCache.get(port));
    } else {
      portCache.set(port, id);
    }

    port.addEventListener(
      "message",
      async (event: MessageEvent<RpcRequest.RpcRequest>) => {
        const { jsonrpc, id, method, params } = event.data;
        console.info("got rpc request", { id, method, params });
        try {
          const handler =
            handlers[method as RpcSchema.ExtractMethodName<schema>];
          // TODO: is there another error we can throw that won't cause viem transport to retry?
          if (!handler) throw new MethodNotSupportedError();

          const result = await handler(params);
          console.info("got result", { id, method, params, result });
          port.postMessage({
            jsonrpc,
            id,
            result,
          } satisfies RpcResponse.RpcResponse);
        } catch (error) {
          console.info("got error", { id, method, params, error });
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
    port.postMessage("ready");
  }

  window.addEventListener("message", onMessage);
  return () => {
    window.removeEventListener("message", onMessage);
    connectedPort?.close();
  };
}
