import { type RpcRequest, RpcResponse, type RpcSchema } from "ox";
import { MethodNotSupportedError } from "ox/RpcResponse";
import { type appContextShape, initialMessageShape, version } from "./common";
import { debug } from "./debug";
import type { ClientRpcSchema } from "./schemas";

// Ideally we'd have one `onRequest` handler, but unfortunately I couldn't figure out how
// to get strong types, where narrowing on the RPC method would also narrow the params and
// enforce the method's specific return type.
//
// Instead, we have a map of `handlers`, where each RPC method is implemented as its own
// handler function.

export function connectDustApp<
  schema extends RpcSchema.Generic = ClientRpcSchema,
>({
  target,
  appContext,
  handlers,
}: {
  target: Window;
  appContext: typeof appContextShape.infer;
  handlers: {
    [method in RpcSchema.ExtractMethodName<schema>]?: (
      params: RpcSchema.ExtractParams<schema, method>,
    ) => Promise<RpcSchema.ExtractReturnType<schema, method>>;
  };
}): () => void {
  let connectedPort: MessagePort | undefined;

  function onWindowMessage(event: MessageEvent) {
    if (event.source !== target) return;
    if (!initialMessageShape.allows(event.data)) return;

    const [port] = event.ports;
    if (!port) {
      console.warn("Got initial message with no message port.");
      return;
    }

    if (event.data.dustkit !== version) {
      console.warn(
        `"${appContext.config.name}" app's DustKit version (${event.data.dustkit}) did not match client's DustKit version (${version}). This may lead to unexpected behavior.`,
      );
    }

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

    // close existing port and replace with new one
    connectedPort?.close();
    connectedPort = port;

    port.start();
    port.postMessage(
      initialMessageShape.from({
        dustkit: version,
        context: appContext,
      }),
    );
  }

  window.addEventListener("message", onWindowMessage);
  return () => {
    window.removeEventListener("message", onWindowMessage);
    connectedPort?.close();
  };
}
