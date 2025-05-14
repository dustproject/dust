import { describe, expect, it } from "vitest";
import { encodeBlock, encodeFragment, encodePlayer } from "../entityid";

describe("EntityId encoding", () => {
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
  it("encodeFragment", () => {
    expect(encodeFragment([0, 0, 0])).toEqual(
      "0x0200000000000000000000000000000000000000000000000000000000000000",
    );
    expect(encodeFragment([39, 62, 16])).toEqual(
      "0x02000000270000003e0000001000000000000000000000000000000000000000",
    );
    expect(encodeFragment([-12, 0, 3])).toEqual(
      "0x02fffffff4000000000000000300000000000000000000000000000000000000",
    );
    expect(encodeFragment([-102, -2, 3044])).toEqual(
      "0x02ffffff9afffffffe00000be400000000000000000000000000000000000000",
    );
    expect(encodeFragment([-1002, -2, -3044])).toEqual(
      "0x02fffffc16fffffffefffff41c00000000000000000000000000000000000000",
    );
  });
  it("encodePlayer", () => {
    expect(encodePlayer("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")).toEqual(
      "0x01f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000",
    );
    expect(encodePlayer("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")).toEqual(
      "0x0170997970c51812dc3a010c7d01b50e0d17dc79c80000000000000000000000",
    );
    expect(encodePlayer("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")).toEqual(
      "0x013c44cdddb6a900fa2b585dd299e03d12fa4293bc0000000000000000000000",
    );
    expect(encodePlayer("0x90F79bf6EB2c4f870365E785982E1f101E93b906")).toEqual(
      "0x0190f79bf6eb2c4f870365e785982e1f101e93b9060000000000000000000000",
    );
    expect(encodePlayer("0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65")).toEqual(
      "0x0115d34aaf54267db7d7c367839aaf71a00a2c6a650000000000000000000000",
    );
    expect(encodePlayer("0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc")).toEqual(
      "0x019965507d1a55bcc2695c58ba16fb37d819b0a4dc0000000000000000000000",
    );
    expect(encodePlayer("0x976EA74026E726554dB657fA54763abd0C3a0aa9")).toEqual(
      "0x01976ea74026e726554db657fa54763abd0c3a0aa90000000000000000000000",
    );
    expect(encodePlayer("0x14dC79964da2C08b23698B3D3cc7Ca32193d9955")).toEqual(
      "0x0114dc79964da2c08b23698b3d3cc7ca32193d99550000000000000000000000",
    );
    expect(encodePlayer("0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f")).toEqual(
      "0x0123618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f0000000000000000000000",
    );
    expect(encodePlayer("0xa0Ee7A142d267C1f36714E4a8F75612F20a79720")).toEqual(
      "0x01a0ee7a142d267c1f36714e4a8f75612f20a797200000000000000000000000",
    );
  });
});
