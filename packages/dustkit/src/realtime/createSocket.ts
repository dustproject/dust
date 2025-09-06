export type Socket = {
  on<eventType extends keyof WebSocketEventMap>(
    type: eventType,
    listener: (event: WebSocketEventMap[eventType]) => void,
  ): () => void;
  send: (message: string | ArrayBuffer) => Promise<void>;
  close: () => void;
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
    const socket = connect();
    const isOpen = waitForOpen(socket);

    function notify(event: Event) {
      for (const listener of listeners[event.type as keyof WebSocketEventMap]) {
        listener(event);
      }
    }

    socket.addEventListener("open", notify);
    socket.addEventListener("message", notify);
    socket.addEventListener("close", notify);
    socket.addEventListener("error", notify);

    await isOpen;

    return socket;
  }

  async function retryOpen(attempt = 0) {
    // TODO: make retry configurable
    const minDelay = 50;
    const maxDelay = 1000 * 30;
    const maxAttempts = 10;
    try {
      return await open();
    } catch (error) {
      if (attempt < maxAttempts) {
        await wait(Math.min(maxDelay, minDelay * 2 ** attempt));
        return retryOpen(attempt + 1);
      }
      throw error;
    }
  }

  let currentSocket: Promise<WebSocket> | null = null;
  let closed = false;

  async function getSocket() {
    if (currentSocket) {
      if (closed) return currentSocket;
      const previousSocket = currentSocket;
      const socket = await currentSocket;
      if (previousSocket !== currentSocket) {
        return getSocket();
      }
      if (socket.readyState !== socket.OPEN) {
        currentSocket = null;
        return getSocket();
      }
    }

    if (!currentSocket) {
      currentSocket = retryOpen();
      const socket = await currentSocket;
      socket.addEventListener("error", () => {
        try {
          socket.close();
        } catch {}
        getSocket();
      });
      socket.addEventListener("close", () => {
        getSocket();
      });
    }

    return currentSocket;
  }

  getSocket();

  return {
    on(type, listener) {
      listeners[type].add(listener);
      return () => listeners[type].delete(listener);
    },
    async send(message: string | ArrayBuffer) {
      const socket = await getSocket();
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
  switch (socket.readyState) {
    case socket.OPEN:
      return socket;
    case socket.CLOSING:
      throw new Error("WebSocket closing.");
    case socket.CLOSED:
      throw new Error("WebSocket closed.");
    case socket.CONNECTING:
      await new Promise((resolve, reject) => {
        socket.addEventListener("open", resolve, { once: true });
        // TODO: reject with proper errors
        socket.addEventListener("close", reject, { once: true });
        socket.addEventListener("error", reject, { once: true });
      });
      return socket;
    default:
      throw new Error(`Unexpected WebSocket readyState: ${socket.readyState}`);
  }
}

function wait(ms: number): Promise<void> {
  return new Promise<void>((resolve) => setTimeout(() => resolve(), ms));
}
