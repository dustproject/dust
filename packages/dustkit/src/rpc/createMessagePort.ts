import { anyInitialMessage, version } from "./common";
import { debug } from "./debug";
import { defer } from "./defer";
import { MessagePortUnexpectedReadyMessageError } from "./errors";
import { timeout as createTimeout } from "./timeout";

export type CreateMessagePortOptions<context = undefined> = {
  target: Window;
  targetOrigin?: string;
  context: context;
};

export async function createMessagePort<context = undefined>({
  target,
  targetOrigin = "*",
  context,
}: CreateMessagePortOptions<context>): Promise<{
  readonly port: MessagePort;
  readonly context: context;
}> {
  const initialMessage = {
    dustkit: version,
    context,
  } satisfies typeof anyInitialMessage.infer;

  const timeout = createTimeout(500);

  const port = defer<{
    readonly port: MessagePort;
    readonly context: context;
  }>();
  const channel = new MessageChannel();
  channel.port1.addEventListener(
    "message",
    function onMessage(event) {
      debug("Got message from port", event);
      // TODO: validate that event.data is the same as initialMessage (may need fast-deep-equal)
      if (anyInitialMessage.allows(event.data)) {
        port.resolve({
          port: channel.port1,
          context: event.data.context as never,
        });
      } else {
        port.reject(new MessagePortUnexpectedReadyMessageError());
      }
    },
    { once: true, signal: timeout.signal },
  );
  channel.port1.start();
  debug("establishing MessagePortProvider with", targetOrigin);
  target.postMessage(initialMessage, targetOrigin, [channel.port2]);

  return await Promise.race([port.promise, timeout.promise]);
}
