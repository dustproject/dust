import type { RpcSchema } from "ox";
import {
  type CreateTransportErrorType,
  RpcRequestError,
  type Transport,
  type TransportConfig,
  type UrlRequiredErrorType,
  createTransport,
} from "viem";
import {
  type PostMessageRpcClient,
  getPostMessageRpcClient,
} from "./getPostMessageRpcClient";

export type PostMessageTransportConfig = {
  /** The key of the PostMessage transport. */
  key?: TransportConfig["key"] | undefined;
  /** Methods to include or exclude from executing RPC requests. */
  methods?: TransportConfig["methods"] | undefined;
  /** The name of the PostMessage transport. */
  name?: TransportConfig["name"] | undefined;
  /** The max number of times to retry. */
  retryCount?: TransportConfig["retryCount"] | undefined;
  /** The base delay (in ms) between retries. */
  retryDelay?: TransportConfig["retryDelay"] | undefined;
  /** The timeout (in ms) for async PostMessage requests. Default: 10_000 */
  timeout?: TransportConfig["timeout"] | undefined;
};

export type PostMessageTransport<schema extends RpcSchema.Generic> = Transport<
  "postMessage",
  // biome-ignore lint/complexity/noBannedTypes: not needed yet
  {},
  // @ts-ignore I can't get this to comply with Viem's `EIP1193RequestFn`. I tried to convert the Ox `RpcSchema` to a Viem `RpcSchema`, but then calling the `request` function doesn't narrow types based on `method`.
  <method extends RpcSchema.ExtractMethodName<schema>>(
    args: unknown extends RpcSchema.ExtractParams<schema, method>
      ? {
          method: method;
          params?: RpcSchema.ExtractParams<schema, method>;
        }
      : {
          method: method;
          params: RpcSchema.ExtractParams<schema, method>;
        },
  ) => Promise<RpcSchema.ExtractReturnType<schema, method>>
>;

export type PostMessageTransportErrorType =
  | CreateTransportErrorType
  | UrlRequiredErrorType;

/**
 * @description Creates an IPC transport that connects to a JSON-RPC API.
 */
export function postMessageTransport<schema extends RpcSchema.Generic>(
  target: Window,
  // TODO: targetOrigin
  config: PostMessageTransportConfig = {},
): PostMessageTransport<schema> {
  const {
    key = "postMessage",
    methods,
    name = "PostMessage JSON-RPC",
    retryDelay,
  } = config;
  return ({ retryCount: retryCount_, timeout: timeout_ }) => {
    const retryCount = config.retryCount ?? retryCount_;
    const timeout = timeout_ ?? config.timeout ?? 10_000;
    return createTransport(
      {
        key,
        methods,
        name,
        async request({ method, params }) {
          const body = { method, params };
          const rpcClient = await getPostMessageRpcClient(target);
          const { error, result } = await rpcClient.requestAsync({
            body,
            timeout,
          });
          if (error)
            throw new RpcRequestError({
              body,
              error,
              url: rpcClient.socket.targetOrigin,
            });
          return result;
        },
        retryCount,
        retryDelay,
        timeout,
        type: "postMessage",
      },
      {},
    );
  };
}
