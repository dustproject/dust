import { debug } from "./debug";
import { defer } from "./defer";
import {
  MessagePortTargetClosedBeforeReadyError,
  MessagePortUnexpectedReadyMessageError,
} from "./errors";
import { timeout as createTimeout } from "./timeout";

// TODO: replace with envelope that contains optional context
export const initMessage = "dustkit:messagePort";

export type CreateMessagePortOptions = {
  target: Window;
  targetOrigin?: string;
};

export async function createMessagePort({
  target,
  targetOrigin = "*",
}: CreateMessagePortOptions): Promise<MessagePort> {
  const timeout = createTimeout(500);

  const port = defer<MessagePort>();
  const channel = new MessageChannel();
  channel.port1.addEventListener(
    "message",
    function onMessage(event) {
      debug("Got message from port", event);
      if (event.data === "ready") {
        port.resolve(channel.port1);
      } else {
        port.reject(new MessagePortUnexpectedReadyMessageError());
      }
    },
    { once: true, signal: timeout.signal },
  );
  channel.port1.start();
  debug("establishing MessagePortProvider with", targetOrigin);
  target.postMessage(initMessage, targetOrigin, [channel.port2]);

  return await Promise.race([port.promise, timeout.promise]);
}
