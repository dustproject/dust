import { createTimeout } from "../createTimeout";

// TODO: replace with envelope that contains optional context
export const initMessage = "dustkit:messagePort";

// TODO: configurable timeout
// TODO: retry with backoff
// TODO: add health check, recreate port if closed (see https://github.com/whatwg/html/issues/1766)

export type CreateMessagePortOptions = {
  target: Window;
  targetOrigin?: string;
};

export async function createMessagePort({
  target,
  targetOrigin = "*",
}: CreateMessagePortOptions): Promise<MessagePort> {
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

    timeout.addEventListener(
      "abort",
      () => {
        // TODO: clean up message channel/ports?
        reject(timeout.reason);
      },
      { once: true },
    );
  });
}
