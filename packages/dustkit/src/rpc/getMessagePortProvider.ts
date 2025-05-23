import { Provider, RpcRequest, RpcResponse, type RpcSchema } from "ox";

// TODO: add context that we send with each connection instead of init rpc method
export function getMessagePortProvider<schema extends RpcSchema.Generic>({
  target,
  targetOrigin = "*",
}: {
  target: Window;
  targetOrigin?: string;
}): Provider.Provider<undefined, schema> {
  const portPromise = createPort({ target, targetOrigin })
    .catch(() => createPort({ target, targetOrigin }))
    .catch(() => createPort({ target, targetOrigin }));

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

export const initMessage = "MessagePortProvider";

async function createPort({
  target,
  targetOrigin = "*",
}: {
  target: Window;
  targetOrigin?: string;
}) {
  // TODO: configurable timeout
  // TODO: retry with backoff
  // TODO: add health check, recreate port if closed (see https://github.com/whatwg/html/issues/1766)

  return new Promise<MessagePort>((resolve, reject) => {
    const timeout = AbortSignal.timeout(1_000);
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
    console.info("establishing MessagePortProvider with", targetOrigin);
    target.postMessage(initMessage, targetOrigin, [channel.port2]);

    timeout.addEventListener("abort", () => {
      // TODO: clean up message channel/ports?
      reject(timeout.reason);
    });
  });
}
