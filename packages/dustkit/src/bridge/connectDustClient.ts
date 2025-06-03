import { Provider, RpcRequest, RpcResponse, type RpcSchema } from "ox";
import pRetry from "p-retry";
import { appContextShape } from "./common";
import { createMessagePort } from "./createMessagePort";
import { MessagePortTargetClosedBeforeReadyError } from "./errors";
import type { ClientRpcSchema } from "./schemas";

// TODO: add health check, recreate port if closed? (see https://github.com/whatwg/html/issues/1766)

export async function connectDustClient(): Promise<{
  readonly appContext: typeof appContextShape.infer;
  readonly provider: Provider.Provider<undefined, ClientRpcSchema>;
}> {
  const { port, initialMessage } = await pRetry(
    () => createMessagePort({ target: window.opener ?? window.parent }),
    {
      retries: 10,
      minTimeout: 100,
      shouldRetry(error) {
        if (error instanceof MessagePortTargetClosedBeforeReadyError) {
          return false;
        }
        return true;
      },
    },
  );

  const appContext = appContextShape.assert(initialMessage.context);

  const requestStore = RpcRequest.createStore<RpcSchema.Generic>();
  const provider = Provider.from({
    appContext,
    async request(args) {
      const request = requestStore.prepare(args);

      // TODO: timeout/retry?
      const response = new Promise<RpcResponse.RpcResponse>((resolve) => {
        port.addEventListener(
          "message",
          function onMessage(event: MessageEvent<RpcResponse.RpcResponse>) {
            if (event.data.id === request.id) {
              port.removeEventListener("message", onMessage);
              resolve(event.data);
            }
          },
        );
        port.postMessage(request);
      });

      return response.then(RpcResponse.parse);
    },
  });

  return {
    appContext,
    provider,
  };
}
