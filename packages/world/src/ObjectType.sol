// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type ObjectType is uint16;
// Category bits (bits 15..11), id bits (bits 10..0)

uint16 constant CATEGORY_MASK = 0xF800;
uint16 constant CATEGORY_SHIFT = 11;
uint16 constant BlOCK_CATEGORY_COUNT = 128 / 2; // 31

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  uint16 constant NONE = 0;

  // Block Categories
  uint16 constant NON_SOLID = uint16(1) << CATEGORY_SHIFT;
  uint16 constant STONE = uint16(2) << CATEGORY_SHIFT;
  uint16 constant GEMSTONE = uint16(3) << CATEGORY_SHIFT;
  uint16 constant SOIL = uint16(4) << CATEGORY_SHIFT;
  uint16 constant ORE = uint16(5) << CATEGORY_SHIFT;
  uint16 constant SAND = uint16(6) << CATEGORY_SHIFT;
  uint16 constant CLAY = uint16(7) << CATEGORY_SHIFT;
  uint16 constant LOG = uint16(8) << CATEGORY_SHIFT;
  uint16 constant LEAF = uint16(9) << CATEGORY_SHIFT;
  uint16 constant FLOWER = uint16(10) << CATEGORY_SHIFT;
  uint16 constant GREENERY = uint16(11) << CATEGORY_SHIFT;
  uint16 constant CROP = uint16(12) << CATEGORY_SHIFT;
  uint16 constant UNDERWATER_PLANT = uint16(13) << CATEGORY_SHIFT;
  // Non-terrain
  uint16 constant PLANK = uint16(14) << CATEGORY_SHIFT;
  uint16 constant ORE_BLOCK = uint16(15) << CATEGORY_SHIFT;
  uint16 constant GROWABLE = uint16(16) << CATEGORY_SHIFT;
  uint16 constant STATION = uint16(17) << CATEGORY_SHIFT;
  uint16 constant SMART = uint16(18) << CATEGORY_SHIFT;

  // Non-Block Categories (raw IDs)
  uint16 constant TOOL = (BlOCK_CATEGORY_COUNT + 1) << CATEGORY_SHIFT;
  uint16 constant OREBAR = (BlOCK_CATEGORY_COUNT + 2) << CATEGORY_SHIFT;
  uint16 constant BUCKET = (BlOCK_CATEGORY_COUNT + 3) << CATEGORY_SHIFT;
  uint16 constant FOOD = (BlOCK_CATEGORY_COUNT + 4) << CATEGORY_SHIFT;
  uint16 constant MOVABLE = (BlOCK_CATEGORY_COUNT + 5) << CATEGORY_SHIFT;
  uint16 constant MISC = (BlOCK_CATEGORY_COUNT + 6) << CATEGORY_SHIFT;
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint128; mask bit k set if raw category ID k belongs)
  uint128 constant BLOCK_MASK = uint128(type(uint64).max);
  uint128 constant PASS_THROUGH_MASK = (uint128(1) << NON_SOLID) | (uint128(1) << LEAF) | (uint128(1) << FLOWER)
    | (uint128(1) << GROWABLE) | (uint128(1) << GREENERY) | (uint128(1) << CROP) | (uint128(1) << UNDERWATER_PLANT);

  uint128 constant IS_MINEABLE_MASK = BLOCK_MASK & ~(uint128(1) << NON_SOLID);
}

library ObjectTypeLib {
  function unwrap(ObjectType self) internal pure returns (uint16) {
    return ObjectType.unwrap(self);
  }

  /// @dev Extract raw category ID from the top bits
  function category(ObjectType self) internal pure returns (uint16) {
    return self.unwrap() & CATEGORY_MASK;
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    return category(self) < BlOCK_CATEGORY_COUNT && !self.isNull();
  }

  //---- Direct Category Checks ----
  function isTool(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.TOOL;
  }

  function isOrebar(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.OREBAR;
  }

  function isBucket(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.BUCKET;
  }

  function isFood(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.FOOD;
  }

  function isMovable(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MOVABLE;
  }

  function isMisc(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MISC;
  }

  function isNonSolid(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.NON_SOLID;
  }

  function isStone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.STONE;
  }

  function isGemstone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GEMSTONE;
  }

  function isSoil(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SOIL;
  }

  function isOre(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.ORE;
  }

  function isSand(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SAND;
  }

  function isClay(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.CLAY;
  }

  function isLog(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.LOG;
  }

  function isLeaf(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.LEAF;
  }

  function isFlower(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.FLOWER;
  }

  function isGreenery(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GREENERY;
  }

  function isCrop(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.CROP;
  }

  function isUnderwaterPlant(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.UNDERWATER_PLANT;
  }

  function isPlank(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.PLANK;
  }

  function isOreBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.ORE_BLOCK;
  }

  function isGrowable(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GROWABLE;
  }

  function isStation(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.STATION;
  }

  function isSmart(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SMART;
  }

  //---- Meta Category Checks ----
  function isPassThrough(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << c) & Category.PASS_THROUGH_MASK) != 0;
  }
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes { }

using ObjectTypeLib for ObjectType global;
