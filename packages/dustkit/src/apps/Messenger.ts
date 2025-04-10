import type { MessengerSchema as Schema } from "./MessengerSchema";

/**
 * Adapted from https://github.com/ithacaxyz/porto/blob/95ebe37eca49bcdaf144af4b688309c7765c1353/src/core/Messenger.ts
 */

export type { Schema };

/** Messenger interface. */
export type Messenger = {
  destroy: () => void;
  on: <const topic extends Topic>(
    topic: topic | Topic,
    listener: (payload: Payload<topic>) => void,
    id?: string | undefined,
  ) => () => void;
  send: <const topic extends Topic>(
    topic: topic | Topic,
    payload: Payload<topic>,
    targetOrigin?: string | undefined,
  ) => Promise<{ id: string; topic: topic; payload: Payload<topic> }>;
  sendAsync: <const topic extends Topic>(
    topic: topic | Topic,
    payload: Payload<topic>,
  ) => Promise<Response<topic>>;
};

/** Bridge messenger. */
export type Bridge = Messenger & {
  ready: () => void;
};

export type Topic = Schema[number]["topic"];

export type Payload<topic extends Topic> = Extract<
  Schema[number],
  { topic: topic }
>["payload"];

export type Response<topic extends Topic> = Extract<
  Schema[number],
  { topic: topic }
>["response"];

/**
 * Instantiates a messenger.
 *
 * @param messenger - Messenger.
 * @returns Instantiated messenger.
 */
export function from(messenger: Messenger): Messenger {
  return messenger;
}

/**
 * Instantiates a messenger from a window instance.
 *
 * @param w - Window.
 * @param options - Options.
 * @returns Instantiated messenger.
 */
export function fromWindow(
  w: Window,
  options: fromWindow.Options = {},
): Messenger {
  const { targetOrigin } = options;
  const handlers: ((event: MessageEvent) => void)[] = [];
  return from({
    destroy() {
      for (const handler of handlers) {
        w.removeEventListener("message", handler);
      }
    },
    on(topic, listener, id) {
      function handler(event: MessageEvent) {
        if (event.data.topic !== topic) return;
        if (id && event.data.id !== id) return;
        if (targetOrigin && event.origin !== targetOrigin) return;
        listener(event.data.payload);
      }
      w.addEventListener("message", handler);
      handlers.push(handler);
      return () => w.removeEventListener("message", handler);
    },
    async send(topic, payload, target) {
      const id = crypto.randomUUID();
      w.postMessage({ id, topic, payload }, target ?? targetOrigin ?? "*");
      return { id, topic, payload } as never;
    },
    async sendAsync(topic, payload) {
      const { id } = await this.send(topic, payload);
      return new Promise<any>((resolve) => {
        const off = this.on(
          topic,
          (payload) => {
            off();
            resolve(payload);
          },
          id,
        );
      });
    },
  });
}

export declare namespace fromWindow {
  export type Options = {
    /**
     * Target origin.
     */
    targetOrigin?: string | undefined;
  };
}

/**
 * Bridges two messengers for cross-window (e.g. parent to iframe) communication.
 *
 * @param parameters - Parameters.
 * @returns Instantiated messenger.
 */
export function bridge(parameters: bridge.Parameters): Bridge {
  const { from: from_, to, waitForReady = false } = parameters;

  const ready = Promise.withResolvers<void>();
  from_.on("internal:ready", () => ready.resolve());

  const messenger = from({
    destroy() {
      from_.destroy();
      to.destroy();
      ready.reject(new Error("Bridge destroyed before ready."));
    },
    on(topic, listener, id) {
      return from_.on(topic, listener, id);
    },
    async send(topic, payload) {
      if (waitForReady) await ready.promise;
      return to.send(topic, payload);
    },
    async sendAsync(topic, payload) {
      if (waitForReady) await ready.promise;
      return to.sendAsync(topic, payload);
    },
  });

  return {
    ...messenger,
    ready() {
      messenger.send("internal:ready", undefined);
    },
  };
}

export declare namespace bridge {
  export type Parameters = {
    /**
     * Source messenger.
     */
    from: Messenger;
    /**
     * Target messenger.
     */
    to: Messenger;
    /**
     * Whether to wait for the target messenger to indicate that it is ready via
     * `messenger.ready()`.
     */
    waitForReady?: boolean | undefined;
  };
}

export function noop(): Bridge {
  return {
    destroy() {},
    on() {
      return () => {};
    },
    ready() {},
    send() {
      return Promise.resolve(undefined as never);
    },
    sendAsync() {
      return Promise.resolve(undefined as never);
    },
  };
}
