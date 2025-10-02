import { scope } from "arktype";
import { type Hex, isHex } from "viem";

export const $ = scope({
  hex: [
    "string",
    ":",
    (data, ctx): data is Hex => isHex(data) || ctx.mustBe("a hex string"),
  ],
  vec2: ["number", "number"],
  vec3: ["number", "number", "number"],
});
