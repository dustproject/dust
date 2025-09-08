export type Socket = {
  on<eventType extends keyof WebSocketEventMap>(
    type: eventType,
    listener: (event: WebSocketEventMap[eventType]) => void,
  ): () => void;
  send: (message: string | ArrayBuffer) => Promise<void>;
  close: () => Promise<void>;
};

export function createSocket({
  connect,
}: {
  connect: () => WebSocket;
}): Socket {
  const listeners = {
    open: new Set(),
    message: new Set(),
    close: new Set(),
    error: new Set(),
  } satisfies Record<keyof WebSocketEventMap, Set<(event: any) => void>>;

  async function open() {
    console.debug("open(): calling connect");
    const socket = connect();
    console.debug("open(): binding open listener/promise");
    const isOpen = waitForOpen(socket);

    console.debug("open(): binding listeners");
    function notify(event: Event) {
      for (const listener of listeners[event.type as keyof WebSocketEventMap]) {
        listener(event);
      }
    }
    socket.addEventListener("open", notify);
    socket.addEventListener("message", notify);
    socket.addEventListener("close", notify);
    socket.addEventListener("error", notify);

    console.debug("open(): waiting for open");
    await isOpen;

    console.debug("open(): returning socket");
    return socket;
  }

  let socketPromise: Promise<WebSocket> | null = null;
  let closed = false;

  async function getSocket() {
    if (socketPromise) {
      if (closed) {
        console.debug("getSocket(): socket was closed, returning socket");
        return socketPromise;
      }
      console.debug("getSocket(): have socket");

      const currentSocket = socketPromise;
      console.debug("getSocket(): awaiting socket");
      const socket = await currentSocket;
      if (currentSocket !== socketPromise) {
        console.debug(
          "getSocket(): socket promise changed while awaiting, trying again...",
        );
        return getSocket();
      }
      if (socket.readyState !== socket.OPEN) {
        console.debug(
          "getSocket(): socket not open, unsetting and trying again...",
        );
        socketPromise = null;
        return getSocket();
      }
    }

    if (!socketPromise) {
      console.debug("getSocket(): no socket, opening one");
      socketPromise = retry(open);
      const currentSocket = socketPromise;
      console.debug("getSocket(): awaiting socket");
      const socket = await currentSocket;
      console.debug("getSocket(): binding listeners");
      socket.addEventListener("error", (event) => {
        console.debug("socket error, closing and getting new one...");
        // try {
        //   socket.close();
        // } catch {}
        if (currentSocket === socketPromise) {
          getSocket();
        }
      });
      socket.addEventListener("close", (event) => {
        console.debug("socket close, getting new one...");
        if (currentSocket === socketPromise) {
          getSocket();
        }
      });
    }

    return socketPromise;
  }

  getSocket();

  return {
    on(type, listener) {
      listeners[type].add(listener);
      return () => listeners[type].delete(listener);
    },
    async send(message: string | ArrayBuffer) {
      console.info("send called, getting socket");
      const socket = await getSocket();
      if (socket.readyState !== socket.OPEN) {
        throw new Error("Socket not open");
      }
      socket.send(message);
    },
    async close() {
      closed = true;
      const socket = await getSocket();
      try {
        socket.close();
      } catch {}
    },
  };
}

async function waitForOpen(socket: WebSocket): Promise<WebSocket> {
  console.debug("waitForOpen(): called");
  switch (socket.readyState) {
    case socket.OPEN:
      console.debug("waitForOpen(): socket is open, returning");
      return socket;
    case socket.CLOSING:
      console.debug("waitForOpen(): socket is closing, throwing");
      throw new Error("WebSocket closing.");
    case socket.CLOSED:
      console.debug("waitForOpen(): socket is closed, throwing");
      throw new Error("WebSocket closed.");
    case socket.CONNECTING:
      console.debug("waitForOpen(): socket is connecting, adding listener");
      await new Promise((resolve, reject) => {
        socket.addEventListener("open", resolve, { once: true });
        // TODO: reject with proper errors
        socket.addEventListener("close", reject, { once: true });
        socket.addEventListener("error", reject, { once: true });
      });
      console.debug("waitForOpen(): open, returning");
      return socket;
    default:
      throw new Error(`Unexpected WebSocket readyState: ${socket.readyState}`);
  }
}

function wait(ms: number): Promise<void> {
  return new Promise<void>((resolve) => setTimeout(() => resolve(), ms));
}

async function retry(fn: (...args: any[]) => any, attempt = 0) {
  // TODO: make retry configurable
  const minDelay = 100;
  const maxDelay = 1000 * 30;
  const maxAttempts = 10;
  try {
    return await fn();
  } catch (error) {
    if (attempt < maxAttempts) {
      await wait(Math.min(maxDelay, minDelay * 2 ** attempt));
      return retry(fn, attempt + 1);
    }
    throw error;
  }
}
