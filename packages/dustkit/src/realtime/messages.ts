import { type } from "arktype";
import { $ } from "./common";

/** CLIENT SETUP */

export const signedSessionDataSchema = $.type({
  userAddress: "hex",
  sessionAddress: "hex",
  signedAt: "number.epoch",
});

export const sessionSchema = $.type({
  signature: "hex",
  signedSessionData: "string.json",
});

export const parseSession = type("string.json.parse").to(sessionSchema);
export const parseSignedSessionData = type("string.json.parse").to(
  signedSessionDataSchema,
);

export const channelsSchema = $.type("'positions' | 'presence'").array();

export const clientDataSchema = $.type({
  "userAddress?": "hex | undefined",
  channels: channelsSchema,
});

export const parseConnectionData =
  type("string.json.parse").to(clientDataSchema);

/** CLIENT -> SERVER */

const pingMessage = $.type("'ping'");
const positionMessage = $.type([
  // position
  "vec3",
  // orientation
  "vec2",
  // velocity
  "vec3",
]);

export const clientMessageSchema = $.type("never")
  .or(pingMessage)
  .or(positionMessage);

export const parseClientMessage =
  type("string.json.parse").to(clientMessageSchema);

/** SERVER -> CLIENT */

const messageOf = $.type("<messageType, messageData>", {
  t: "messageType",
  d: "messageData",
});

const pongMessage = messageOf("'pong'", "null");
export const positionChange = $.type({
  u: "hex",
  t: "number",
  d: positionMessage,
});
const positionsMessage = messageOf("'positions'", [positionChange, "[]"]);
const presenceMessage = messageOf("'presence'", ["hex", "[]"]);

export const serverMessageSchema = $.type("never")
  .or(pongMessage)
  .or(positionsMessage)
  .or(presenceMessage);

export const parseServerMessage =
  type("string.json.parse").to(serverMessageSchema);
