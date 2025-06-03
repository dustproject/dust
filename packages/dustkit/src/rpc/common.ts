import { type } from "arktype";
import packageJson from "../../package.json";

export const version = packageJson.version;

export const initialMessage = type("<context>", {
  dustkit: "string", // version
  context: "context",
});

export const initialAppMessage = initialMessage("undefined");
export const initialClientMessage = initialMessage("undefined");
export const anyInitialMessage = initialMessage("unknown");
