import { type } from "arktype";
import type { RpcRequest, RpcResponse } from "ox";

export const rpcRequestEnvelope = type({
  dustkit: "string",
  // TODO: do more validation here
  rpcRequest: type("object").as<RpcRequest.RpcRequest>(),
});
export type RpcRequestEnvelope = typeof rpcRequestEnvelope.infer;

export const rpcResponseEnvelope = type({
  dustkit: "string",
  // TODO: do more validation here
  rpcResponse: type("object").as<RpcResponse.RpcResponse>(),
});
export type RpcResponseEnvelope = typeof rpcResponseEnvelope.infer;
