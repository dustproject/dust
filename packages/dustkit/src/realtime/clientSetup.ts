import { $ } from "./common";

export const signedSessionDataSchema = $.type({
  userAddress: "hex",
  sessionAddress: "hex",
  signedAt: "number.epoch",
});

export const sessionSchema = $.type({
  signature: "hex",
  signedSessionData: "string.json",
});

export const channelsSchema = $.type("'positions' | 'presence'").array();
