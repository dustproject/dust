import type { RpcRequest, RpcResponse } from "ox";
import { initMessage } from "./messagePort";

// TODO: pass in rpc schema
export function createMessagePortRpcServer({
  onRequest,
}: {
  onRequest: (req: RpcRequest.RpcRequest) => Promise<RpcResponse.RpcResponse>;
}) {
  window.addEventListener("message", (event) => {
    if (event.data !== initMessage) return;

    const [port] = event.ports;
    if (!port) {
      return console.warn(`Got "${initMessage}" message with no message port.`);
    }

    port.addEventListener("message", async (event) => {
      // TODO: handle errors from onRequest?
      port.postMessage(await onRequest(event.data));
    });

    port.start();
    port.postMessage("ready");
  });
}
