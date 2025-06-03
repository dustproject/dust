import {
  MessagePortTargetClosedBeforeReadyError,
  MessagePortUnexpectedReadyMessageError,
} from "./errors";

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
          reject(new MessagePortUnexpectedReadyMessageError());
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
        if (target.closed) {
          reject(new MessagePortTargetClosedBeforeReadyError());
        } else {
          reject(timeout.reason);
        }
      },
      { once: true },
    );
  });
}
