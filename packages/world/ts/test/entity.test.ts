import { describe, expect, it } from "vitest";
import { encodeBlock } from "../entityid";

describe("EntityId conversions", () => {
  it("encodeBlock", () => {
    expect(encodeBlock([0, 0, 0])).toEqual(
      "0x0300000000000000000000000000000000000000000000000000000000000000",
    );
    expect(encodeBlock([39, 62, 16])).toEqual(
      "0x03000000270000003e0000001000000000000000000000000000000000000000",
    );
    expect(encodeBlock([-12, 0, 3])).toEqual(
      "0x03fffffff4000000000000000300000000000000000000000000000000000000",
    );
    expect(encodeBlock([-102, -2, 3044])).toEqual(
      "0x03ffffff9afffffffe00000be400000000000000000000000000000000000000",
    );
    expect(encodeBlock([-1002, -2, -3044])).toEqual(
      "0x03fffffc16fffffffefffff41c00000000000000000000000000000000000000",
    );
  });
});
