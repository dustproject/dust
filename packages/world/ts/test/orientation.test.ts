import { describe, expect, it } from "vitest";
import {
  PERMUTATIONS,
  REFLECTIONS,
  decodeOrientation,
  encodeOrientation,
} from "../orientation";

describe("Orientation encoding and decoding", () => {
  it("encodeOrientation", () => {
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[0])).toEqual(0);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[1])).toEqual(1);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[2])).toEqual(2);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[3])).toEqual(3);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[4])).toEqual(4);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[5])).toEqual(5);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[6])).toEqual(6);
    expect(encodeOrientation(PERMUTATIONS[0], REFLECTIONS[7])).toEqual(7);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[0])).toEqual(8);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[1])).toEqual(9);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[2])).toEqual(10);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[3])).toEqual(11);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[4])).toEqual(12);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[5])).toEqual(13);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[6])).toEqual(14);
    expect(encodeOrientation(PERMUTATIONS[1], REFLECTIONS[7])).toEqual(15);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[0])).toEqual(16);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[1])).toEqual(17);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[2])).toEqual(18);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[3])).toEqual(19);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[4])).toEqual(20);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[5])).toEqual(21);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[6])).toEqual(22);
    expect(encodeOrientation(PERMUTATIONS[2], REFLECTIONS[7])).toEqual(23);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[0])).toEqual(24);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[1])).toEqual(25);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[2])).toEqual(26);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[3])).toEqual(27);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[4])).toEqual(28);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[5])).toEqual(29);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[6])).toEqual(30);
    expect(encodeOrientation(PERMUTATIONS[3], REFLECTIONS[7])).toEqual(31);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[0])).toEqual(32);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[1])).toEqual(33);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[2])).toEqual(34);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[3])).toEqual(35);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[4])).toEqual(36);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[5])).toEqual(37);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[6])).toEqual(38);
    expect(encodeOrientation(PERMUTATIONS[4], REFLECTIONS[7])).toEqual(39);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[0])).toEqual(40);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[1])).toEqual(41);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[2])).toEqual(42);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[3])).toEqual(43);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[4])).toEqual(44);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[5])).toEqual(45);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[6])).toEqual(46);
    expect(encodeOrientation(PERMUTATIONS[5], REFLECTIONS[7])).toEqual(47);
  });
  it("decodeOrientation", () => {
    expect(decodeOrientation(0)).toEqual([PERMUTATIONS[0], REFLECTIONS[0]]);
    expect(decodeOrientation(1)).toEqual([PERMUTATIONS[0], REFLECTIONS[1]]);
    expect(decodeOrientation(2)).toEqual([PERMUTATIONS[0], REFLECTIONS[2]]);
    expect(decodeOrientation(3)).toEqual([PERMUTATIONS[0], REFLECTIONS[3]]);
    expect(decodeOrientation(4)).toEqual([PERMUTATIONS[0], REFLECTIONS[4]]);
    expect(decodeOrientation(5)).toEqual([PERMUTATIONS[0], REFLECTIONS[5]]);
    expect(decodeOrientation(6)).toEqual([PERMUTATIONS[0], REFLECTIONS[6]]);
    expect(decodeOrientation(7)).toEqual([PERMUTATIONS[0], REFLECTIONS[7]]);
    expect(decodeOrientation(8)).toEqual([PERMUTATIONS[1], REFLECTIONS[0]]);
    expect(decodeOrientation(9)).toEqual([PERMUTATIONS[1], REFLECTIONS[1]]);
    expect(decodeOrientation(10)).toEqual([PERMUTATIONS[1], REFLECTIONS[2]]);
    expect(decodeOrientation(11)).toEqual([PERMUTATIONS[1], REFLECTIONS[3]]);
    expect(decodeOrientation(12)).toEqual([PERMUTATIONS[1], REFLECTIONS[4]]);
    expect(decodeOrientation(13)).toEqual([PERMUTATIONS[1], REFLECTIONS[5]]);
    expect(decodeOrientation(14)).toEqual([PERMUTATIONS[1], REFLECTIONS[6]]);
    expect(decodeOrientation(15)).toEqual([PERMUTATIONS[1], REFLECTIONS[7]]);
    expect(decodeOrientation(16)).toEqual([PERMUTATIONS[2], REFLECTIONS[0]]);
    expect(decodeOrientation(17)).toEqual([PERMUTATIONS[2], REFLECTIONS[1]]);
    expect(decodeOrientation(18)).toEqual([PERMUTATIONS[2], REFLECTIONS[2]]);
    expect(decodeOrientation(19)).toEqual([PERMUTATIONS[2], REFLECTIONS[3]]);
    expect(decodeOrientation(20)).toEqual([PERMUTATIONS[2], REFLECTIONS[4]]);
    expect(decodeOrientation(21)).toEqual([PERMUTATIONS[2], REFLECTIONS[5]]);
    expect(decodeOrientation(22)).toEqual([PERMUTATIONS[2], REFLECTIONS[6]]);
    expect(decodeOrientation(23)).toEqual([PERMUTATIONS[2], REFLECTIONS[7]]);
    expect(decodeOrientation(24)).toEqual([PERMUTATIONS[3], REFLECTIONS[0]]);
    expect(decodeOrientation(25)).toEqual([PERMUTATIONS[3], REFLECTIONS[1]]);
    expect(decodeOrientation(26)).toEqual([PERMUTATIONS[3], REFLECTIONS[2]]);
    expect(decodeOrientation(27)).toEqual([PERMUTATIONS[3], REFLECTIONS[3]]);
    expect(decodeOrientation(28)).toEqual([PERMUTATIONS[3], REFLECTIONS[4]]);
    expect(decodeOrientation(29)).toEqual([PERMUTATIONS[3], REFLECTIONS[5]]);
    expect(decodeOrientation(30)).toEqual([PERMUTATIONS[3], REFLECTIONS[6]]);
    expect(decodeOrientation(31)).toEqual([PERMUTATIONS[3], REFLECTIONS[7]]);
    expect(decodeOrientation(32)).toEqual([PERMUTATIONS[4], REFLECTIONS[0]]);
    expect(decodeOrientation(33)).toEqual([PERMUTATIONS[4], REFLECTIONS[1]]);
    expect(decodeOrientation(34)).toEqual([PERMUTATIONS[4], REFLECTIONS[2]]);
    expect(decodeOrientation(35)).toEqual([PERMUTATIONS[4], REFLECTIONS[3]]);
    expect(decodeOrientation(36)).toEqual([PERMUTATIONS[4], REFLECTIONS[4]]);
    expect(decodeOrientation(37)).toEqual([PERMUTATIONS[4], REFLECTIONS[5]]);
    expect(decodeOrientation(38)).toEqual([PERMUTATIONS[4], REFLECTIONS[6]]);
    expect(decodeOrientation(39)).toEqual([PERMUTATIONS[4], REFLECTIONS[7]]);
    expect(decodeOrientation(40)).toEqual([PERMUTATIONS[5], REFLECTIONS[0]]);
    expect(decodeOrientation(41)).toEqual([PERMUTATIONS[5], REFLECTIONS[1]]);
    expect(decodeOrientation(42)).toEqual([PERMUTATIONS[5], REFLECTIONS[2]]);
    expect(decodeOrientation(43)).toEqual([PERMUTATIONS[5], REFLECTIONS[3]]);
    expect(decodeOrientation(44)).toEqual([PERMUTATIONS[5], REFLECTIONS[4]]);
    expect(decodeOrientation(45)).toEqual([PERMUTATIONS[5], REFLECTIONS[5]]);
    expect(decodeOrientation(46)).toEqual([PERMUTATIONS[5], REFLECTIONS[6]]);
    expect(decodeOrientation(47)).toEqual([PERMUTATIONS[5], REFLECTIONS[7]]);
  });
});
