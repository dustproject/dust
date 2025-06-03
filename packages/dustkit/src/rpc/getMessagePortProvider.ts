import { Provider, RpcRequest, RpcResponse, type RpcSchema } from "ox";
import pRetry from "p-retry";
import {
  type CreateMessagePortOptions,
  createMessagePort,
} from "./createMessagePort";
import { MessagePortTargetClosedBeforeReadyError } from "./errors";

// TODO: add health check, recreate port if closed? (see https://github.com/whatwg/html/issues/1766)

export function getMessagePortProvider<schema extends RpcSchema.Generic>({
  target,
  targetOrigin = "*",
}: CreateMessagePortOptions): Provider.Provider<undefined, schema> {
  const portPromise = pRetry(
    () => createMessagePort({ target, targetOrigin }),
    {
      retries: 10,
      shouldRetry(error) {
        if (error instanceof MessagePortTargetClosedBeforeReadyError) {
          return false;
        }
        return true;
      },
    },
  );

  const requestStore = RpcRequest.createStore<RpcSchema.Generic>();
  const provider = Provider.from({
    async request(args) {
      const port = await portPromise;
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

  return provider as never;
}
