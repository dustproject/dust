import { Provider, RpcRequest } from "ox";
import type { Bridge } from "../apps/Messenger";

const emitter = Provider.createEmitter();
const store = RpcRequest.createStore();

type GenericProviderRpcError = {
  code: number;
  details?: string;
};

function toProviderRpcError({
  code,
  details,
}: GenericProviderRpcError): Provider.ProviderRpcError {
  switch (code) {
    case 4001:
      return new Provider.UserRejectedRequestError();
    case 4100:
      return new Provider.UnauthorizedError();
    case 4200:
      return new Provider.UnsupportedMethodError();
    case 4900:
      return new Provider.DisconnectedError();
    case 4901:
      return new Provider.ChainDisconnectedError();
    default:
      return new Provider.ProviderRpcError(
        code,
        details ?? "Unknown provider RPC error",
      );
  }
}

export type ProviderConfig = {
  bridge: Bridge;
};

export function createProvider(config: ProviderConfig) {
  // TODO: replace with a real ready signal
  const isReady = new Promise((resolve) => setTimeout(resolve, 1000));

  return Provider.from({
    ...emitter,
    async request(args) {
      // TODO: replace with a real ready signal
      await isReady;

      // @ts-expect-error
      const request = store.prepare(args);

      console.info("sending request", request);
      const [response] = await config.bridge.sendAsync("client:rpcRequests", [
        request,
      ]);
      console.info("got response", response);

      if (response!.error) {
        throw toProviderRpcError(response!.error);
      }

      return response!.result;
    },
  });
}
