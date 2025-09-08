// src/realtime/createSocket.test.ts
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { WS } from "vitest-websocket-mock";
// Adjust this import to your path
import { createSocket } from "./createSocket";

const WS_URL = "ws://test";

function createConnectSpy(url = WS_URL) {
  return vi.fn(() => new WebSocket(url));
}

describe("createSocket", () => {
  afterEach(() => {
    WS.clean();
  });

  it("send waits for open and resolves after underlying send", async () => {
    const server = new WS(WS_URL);

    const connect = createConnectSpy();
    const socket = createSocket({ connect });

    // Call send before 'open'
    const sendPromise = socket.send("hello");

    // When the server accepts the connection, queued send should flush
    await server.connected;
    await expect(server).toReceiveMessage("hello");
    await expect(sendPromise).resolves.toBeUndefined();

    // Only one connect call (initial)
    expect(connect).toHaveBeenCalledTimes(1);
  });

  it("listeners fire and unsubscribe works", async () => {
    const server = new WS(WS_URL);

    const connect = createConnectSpy();
    const socket = createSocket({ connect });

    await server.connected;

    const onMessage = vi.fn();
    const off = socket.on("message", (ev) =>
      onMessage((ev as MessageEvent).data),
    );

    server.send("a");
    expect(onMessage).toHaveBeenCalledTimes(1);
    expect(onMessage).toHaveBeenLastCalledWith("a");

    off(); // unsubscribe
    server.send("b");
    expect(onMessage).toHaveBeenCalledTimes(1);
  });

  it("reconnects after unexpected close and continues to work", async () => {
    const server = new WS(WS_URL);

    const connect = createConnectSpy();
    const socket = createSocket({ connect });

    const onOpen = vi.fn();
    socket.on("open", onOpen);

    const onClose = vi.fn();
    socket.on("close", onClose);

    expect(onOpen).toHaveBeenCalledTimes(0);
    expect(onClose).toHaveBeenCalledTimes(0);

    await server.connected;
    expect(connect).toHaveBeenCalledTimes(1);

    expect(onOpen).toHaveBeenCalledTimes(1);
    expect(onClose).toHaveBeenCalledTimes(0);

    console.info("test: disconnecting server");

    // Simulate an abrupt server-side close
    await new Promise((resolve) => setTimeout(resolve, 100));
    server.close({ code: 1006, reason: "abrupt", wasClean: false });

    expect(onOpen).toHaveBeenCalledTimes(1);
    expect(onClose).toHaveBeenCalledTimes(1);

    // New server on the same URL to accept the reconnect
    const server2 = new WS(WS_URL);

    // Wait until the new server sees the client
    await server2.connected;

    expect(onOpen).toHaveBeenCalledTimes(2);
    expect(onClose).toHaveBeenCalledTimes(1);

    // Should have called connect() again to create a fresh WebSocket
    expect(connect).toHaveBeenCalledTimes(2);

    // Comms continue over the reconnected socket
    await socket.send("after-reconnect");
    await expect(server2).toReceiveMessage("after-reconnect");

    server2.close();
    expect(onClose).toHaveBeenCalledTimes(2);
  });

  it("reconnects after server error", async () => {
    const server = new WS(WS_URL);

    const connect = createConnectSpy();
    const socket = createSocket({ connect });

    const onOpen = vi.fn();
    socket.on("open", onOpen);

    const onClose = vi.fn();
    socket.on("close", onClose);

    const onError = vi.fn();
    socket.on("error", onError);

    expect(connect).toHaveBeenCalledTimes(1);
    expect(onOpen).toHaveBeenCalledTimes(0);
    expect(onClose).toHaveBeenCalledTimes(0);
    expect(onError).toHaveBeenCalledTimes(0);

    await server.connected;

    expect(connect).toHaveBeenCalledTimes(1);
    expect(onOpen).toHaveBeenCalledTimes(1);
    expect(onClose).toHaveBeenCalledTimes(0);
    expect(onError).toHaveBeenCalledTimes(0);

    console.info("test: closing with server error");

    await new Promise((resolve) => setTimeout(resolve, 100));
    server.error({ code: 1006, reason: "abrupt", wasClean: false });

    expect(onOpen).toHaveBeenCalledTimes(1);
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(onError).toHaveBeenCalledTimes(1);

    const server2 = new WS(WS_URL);
    await server2.connected;

    expect(connect).toHaveBeenCalledTimes(2);
    expect(onOpen).toHaveBeenCalledTimes(2);
    expect(onClose).toHaveBeenCalledTimes(1);
    expect(onError).toHaveBeenCalledTimes(1);

    // Comms continue over the reconnected socket
    await socket.send("after-reconnect");
    await expect(server2).toReceiveMessage("after-reconnect");

    server2.close();
    expect(onClose).toHaveBeenCalledTimes(2);
  });

  it("close() shuts down and does NOT reconnect", async () => {
    const server = new WS(WS_URL);

    const connect = createConnectSpy();
    const socket = createSocket({ connect });

    await server.connected;
    expect(connect).toHaveBeenCalledTimes(1);

    // User-initiated close should stop any auto-reconnect behavior
    await expect(socket.close()).resolves.toBeUndefined();

    // Even if the server closes afterwards, no reconnect should occur
    server.close({ code: 1000, reason: "normal", wasClean: true });

    expect(connect).toHaveBeenCalledTimes(1); // still only the initial connect

    // Further sends should reject (socket permanently closed)
    await expect(socket.send("nope")).rejects.toThrow();
  });
});
