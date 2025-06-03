import { type } from "arktype";
import { type Hex, isHex } from "viem";
import packageJson from "../../package.json";
import { appConfig } from "../apps/appConfig";

export const hex = type("string").narrow(
  (input, ctx): input is Hex => isHex(input) || ctx.mustBe("a hex string"),
);

export const version = packageJson.version;

export const initialMessageShape = type({
  dustkit: "string", // version
  "context?": "unknown",
});

export const appContextShape = type({
  id: "string",
  config: appConfig,
  "via?": {
    entity: hex,
    program: hex,
  },
  userAddress: hex,
});
