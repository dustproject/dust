import type { RpcSchema } from "ox";
import {
  type CreateTransportErrorType,
  type EIP1193RequestFn,
  RpcRequestError,
  type Transport,
  type TransportConfig,
  type UrlRequiredErrorType,
  createTransport,
} from "viem";
import { getMessagePortRpcClient } from "./getMessagePortRpcClient.js";

export type MessagePortTransportConfig = {
  /** The key of the MessagePort transport. */
  key?: TransportConfig["key"] | undefined;
  /** Methods to include or exclude from executing RPC requests. */
  methods?: TransportConfig["methods"] | undefined;
  /** The name of the MessagePort transport. */
  name?: TransportConfig["name"] | undefined;
  /** The max number of times to retry. */
  retryCount?: TransportConfig["retryCount"] | undefined;
  /** The base delay (in ms) between retries. */
  retryDelay?: TransportConfig["retryDelay"] | undefined;
  /** The timeout (in ms) for async MessagePort requests. Default: 10_000 */
  timeout?: TransportConfig["timeout"] | undefined;
};

type OxRpcSchemaToViemRpcSchema<schema extends RpcSchema.Generic> = readonly {
  [method in RpcSchema.ExtractMethodName<schema>]: unknown extends RpcSchema.ExtractParams<
    schema,
    method
  >
    ? {
        Method: method;
        Parameters?: RpcSchema.ExtractParams<schema, method>;
        ReturnType: RpcSchema.ExtractReturnType<schema, method>;
      }
    : RpcSchema.ExtractParams<schema, method> extends undefined
      ? {
          Method: method;
          Parameters?: RpcSchema.ExtractParams<schema, method>;
          ReturnType: RpcSchema.ExtractReturnType<schema, method>;
        }
      : {
          Method: method;
          Parameters: RpcSchema.ExtractParams<schema, method>;
          ReturnType: RpcSchema.ExtractReturnType<schema, method>;
        };
}[RpcSchema.ExtractMethodName<schema>][];

export type MessagePortTransport<schema extends RpcSchema.Generic> = Transport<
  "messagePort",
  // biome-ignore lint/complexity/noBannedTypes: not needed yet
  {}
  // TODO: typed `request` function (improve EIP1193RequestFn)
>;

export type MessagePortTransportErrorType =
  | CreateTransportErrorType
  | UrlRequiredErrorType;

/**
 * @description Creates an IPC transport that connects to a JSON-RPC API.
 */
export function messagePort<schema extends RpcSchema.Generic>(
  target: Window,
  config: MessagePortTransportConfig = {},
): MessagePortTransport<schema> {
  const {
    key = "messagePort",
    methods,
    name = "MessagePort JSON-RPC",
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
          const rpcClient = await getMessagePortRpcClient(target);
          const { error, result } = await rpcClient.requestAsync({
            body,
            timeout,
          });
          if (error)
            throw new RpcRequestError({
              body,
              error,
              url: "*",
            });
          return result;
        },
        retryCount,
        retryDelay,
        timeout,
        type: "messagePort",
      },
      {},
    );
  };
}
