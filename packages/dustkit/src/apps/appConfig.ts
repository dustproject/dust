import { type } from "arktype";

export const appConfig = type({
  name: "string",
  startUrl: "string",
  "defaultSize?": {
    width: "number",
    height: "number",
  },
});
export type AppConfig = typeof appConfig.infer;

export const appConfigInput = type({
  name: "string",
  "startUrl?": "string",
  "defaultSize?": {
    width: "number",
    height: "number",
  },
});
export type AppConfigInput = typeof appConfigInput.infer;
