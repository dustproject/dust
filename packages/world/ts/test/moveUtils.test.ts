import { describe, it, expect } from "vitest";
import { packDirections, unpackDirections } from "../moveUtils";
import config from "../../mud.config";

type Direction = (typeof config.enums.Direction)[number];

describe("moveUtils", () => {
  describe("packDirections", () => {
    it("should pack simple directions correctly", () => {
      const directions: Direction[] = ["PositiveX", "PositiveZ", "NegativeX"];
      const packed = packDirections(directions);
      
      // Count should be 3 in top 6 bits
      const count = Number(packed >> BigInt(250)) & 0x3F;
      expect(count).toBe(3);
      
      // Check individual directions
      const mask = BigInt(0x1F);
      expect(Number(packed & mask)).toBe(config.enums.Direction.indexOf("PositiveX"));
      expect(Number((packed >> BigInt(5)) & mask)).toBe(config.enums.Direction.indexOf("PositiveZ"));
      expect(Number((packed >> BigInt(10)) & mask)).toBe(config.enums.Direction.indexOf("NegativeX"));
    });
    
    it("should handle maximum capacity", () => {
      const directions: Direction[] = new Array(30).fill("PositiveX");
      const packed = packDirections(directions);
      
      const count = Number(packed >> BigInt(250)) & 0x3F;
      expect(count).toBe(30);
    });
    
    it("should throw error for too many directions", () => {
      const directions: Direction[] = new Array(51).fill("PositiveX");
      expect(() => packDirections(directions)).toThrow("Too many directions: maximum 50 allowed");
    });
    
    it("should handle complex diagonal movements", () => {
      const directions: Direction[] = [
        "PositiveXPositiveZ",
        "NegativeXPositiveZ", 
        "PositiveY",
        "NegativeZ",
        "PositiveXNegativeY"
      ];
      const packed = packDirections(directions);
      
      const count = Number(packed >> BigInt(250)) & 0x3F;
      expect(count).toBe(5);
    });
  });
  
  describe("unpackDirections", () => {
    it("should unpack directions correctly", () => {
      const originalDirections: Direction[] = ["PositiveX", "PositiveZ", "NegativeX"];
      const packed = packDirections(originalDirections);
      const unpacked = unpackDirections(packed);
      
      expect(unpacked).toEqual(originalDirections);
    });
    
    it("should handle empty directions", () => {
      const packed = packDirections([]);
      const unpacked = unpackDirections(packed);
      
      expect(unpacked).toEqual([]);
    });
    
    it("should round-trip complex directions", () => {
      const directions: Direction[] = [
        "PositiveX",
        "NegativeY",
        "PositiveXPositiveYPositiveZ",
        "NegativeXNegativeYNegativeZ",
        "PositiveZ"
      ];
      
      const packed = packDirections(directions);
      const unpacked = unpackDirections(packed);
      
      expect(unpacked).toEqual(directions);
    });
  });
});