import { Provider, RpcRequest, RpcResponse, type RpcSchema } from "ox";
import {
  type CreateMessagePortOptions,
  createMessagePort,
} from "./createMessagePort";

export function getMessagePortProvider<schema extends RpcSchema.Generic>({
  target,
  targetOrigin = "*",
}: CreateMessagePortOptions): Provider.Provider<undefined, schema> {
  const portPromise = createMessagePort({ target, targetOrigin })
    .catch(() => createMessagePort({ target, targetOrigin }))
    .catch(() => createMessagePort({ target, targetOrigin }));

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
