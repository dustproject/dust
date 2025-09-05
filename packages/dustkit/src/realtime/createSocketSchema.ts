import { type } from "arktype";

export function createSocketSchema<const outDef, const inDef>({
  in: inDef,
  out: outDef,
}: {
  in: type.validate<inDef>;
  out: type.validate<outDef>;
}): {
  in: {
    schema: type.instantiate<inDef>;
    send: (socket: WebSocket, data: type.infer.In<inDef>) => void;
    receive: (message: string | ArrayBuffer) => type.infer.Out<inDef>;
  };
  out: {
    schema: type.instantiate<outDef>;
    send: (socket: WebSocket, data: type.infer.In<outDef>) => void;
    receive: (message: string | ArrayBuffer) => type.infer.Out<outDef>;
  };
} {
  const inSchema = type(inDef);
  const inParse = type("string.json.parse").to(inSchema as never);
  const outSchema = type(outDef);
  const outParse = type("string.json.parse").to(outSchema as never);
  return {
    in: {
      schema: inSchema as never,
      send(socket, data) {
        socket.send(JSON.stringify(inSchema.assert(data)));
      },
      receive(message) {
        const data = inParse.assert(
          typeof message === "string"
            ? message
            : new TextDecoder().decode(message),
        );
        return data as never;
      },
    },
    out: {
      schema: outSchema as never,
      send(socket, data) {
        socket.send(JSON.stringify(outSchema.assert(data)));
      },
      receive(message) {
        const data = outParse.assert(
          typeof message === "string"
            ? message
            : new TextDecoder().decode(message),
        );
        return data as never;
      },
    },
  };
}
