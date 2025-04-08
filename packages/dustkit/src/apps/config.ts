import { type } from "arktype";

export const config = type({
  name: "string",
  startUrl: "string",
  "frame?": {
    width: "number",
    height: "number",
  },
});
export type Config = typeof config.infer;

export const configInput = type({
  name: "string",
  "startUrl?": "string",
  "frame?": {
    width: "number",
    height: "number",
  },
});
export type ConfigInput = typeof configInput.infer;
