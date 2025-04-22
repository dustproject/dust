import {
  type Category,
  allCategoryMetadata,
  blockCategoryMetadata,
  growableCategories,
  hasAnyCategories,
  nonBlockCategoryMetadata,
  objects,
  passThroughCategories,
  smartEntityCategories,
  toolCategories,
  uniqueObjectCategories,
} from "../objects";

// Helper to format category names correctly for function generation
function formatCategoryName(name: string): string {
  return name
    .toLowerCase()
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join("");
}

function renderMetaCategoryMask(categories: Category[]): string {
  return categories
    .map((cat) => `(uint128(1) << (${cat} >> OFFSET_BITS))`)
    .join(" | ");
}

function renderObjectAmount(objectAmount: {
  objectType: string;
  amount: number | bigint;
}): string {
  return `ObjectAmount(ObjectTypes.${objectAmount.objectType}, ${objectAmount.amount.toString()})`;
}

// Template for the Solidity file
function generateObjectTypeSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IMachineSystem } from "./codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "./codegen/world/ITransferSystem.sol";
import { Direction } from "./codegen/common.sol";
import { Vec3, vec3 } from "./Vec3.sol";

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

// 7 category bits (bits 15..9), 9 index bits (bits 8..0)
uint16 constant OFFSET_BITS = 9;
uint16 constant CATEGORY_MASK = type(uint16).max << OFFSET_BITS;
uint16 constant BLOCK_CATEGORY_COUNT = 128 / 2; // 31

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  // Block Categories
${blockCategoryMetadata.map((cat) => `  uint16 constant ${cat.name} = uint16(${cat.id}) << OFFSET_BITS;`).join("\n")}
  // Non-Block Categories
${nonBlockCategoryMetadata.map((cat) => `  uint16 constant ${cat.name} = uint16(${cat.id}) << OFFSET_BITS;`).join("\n")}
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint128; mask bit k set if raw category ID k belongs)
  uint128 constant BLOCK_MASK = uint128(type(uint64).max);
  uint128 constant HAS_ANY_MASK = ${renderMetaCategoryMask(hasAnyCategories)};
  uint128 constant PASS_THROUGH_MASK = ${renderMetaCategoryMask(passThroughCategories)};
  uint128 constant GROWABLE_MASK = ${renderMetaCategoryMask(growableCategories)};
  uint128 constant UNIQUE_OBJECT_MASK = ${renderMetaCategoryMask(uniqueObjectCategories)};
  uint128 constant SMART_ENTITY_MASK = ${renderMetaCategoryMask(smartEntityCategories)};
  uint128 constant TOOL_MASK = ${renderMetaCategoryMask(toolCategories)};
  uint128 constant MINEABLE_MASK = BLOCK_MASK & ~${renderMetaCategoryMask(["NON_SOLID"])};
}


// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
${objects
  .map((obj) => {
    const categoryRef = `Category.${obj.category}`;
    return `  ObjectType constant ${obj.name} = ObjectType.wrap(${categoryRef} | ${obj.id});`;
  })

  .join("\n")}
}

// ------------------------------------------------------------
library ObjectTypeLib {
  function unwrap(ObjectType self) internal pure returns (uint16) {
    return ObjectType.unwrap(self);
  }

  /// @dev Extract raw category ID from the top bits
  function category(ObjectType self) internal pure returns (uint16) {
    return self.unwrap() & CATEGORY_MASK;
  }

  function index(ObjectType self) internal pure returns (uint16) {
    return self.unwrap() & ~CATEGORY_MASK;
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    return (category(self) >> OFFSET_BITS) < BLOCK_CATEGORY_COUNT && !self.isNull();
  }

  // Direct Category Checks
${allCategoryMetadata
  .map(
    (cat) => `
  function is${formatCategoryName(cat.name)}(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.${cat.name};
  }`,
  )
  .join("")}

// Category getters
${allCategoryMetadata
  .map((cat) => {
    const categoryObjects = objects.filter((obj) => obj.category === cat.name);
    return `function get${formatCategoryName(cat.name)}Types() internal pure returns (ObjectType[${categoryObjects.length}] memory) {
    return [${categoryObjects.map((obj) => `ObjectTypes.${obj.name}`).join(", ")}];
  }`;
  })
  .join("\n")}

  // Specialized getters
  // TODO: these are currently part of the codegen, but we should define them in Solidity and import them here
  function getObjectTypeSchema(ObjectType self) internal pure returns (Vec3[] memory) {
    if (self == ObjectTypes.Player) {
      Vec3[] memory playerRelativePositions = new Vec3[](1);
      playerRelativePositions[0] = vec3(0, 1, 0);
      return playerRelativePositions;
    }

    if (self == ObjectTypes.Bed) {
      Vec3[] memory bedRelativePositions = new Vec3[](1);
      bedRelativePositions[0] = vec3(0, 0, 1);
      return bedRelativePositions;
    }

    if (self == ObjectTypes.TextSign) {
      Vec3[] memory textSignRelativePositions = new Vec3[](1);
      textSignRelativePositions[0] = vec3(0, 1, 0);
      return textSignRelativePositions;
    }

    return new Vec3[](0);
  }

  /// @dev Get relative schema coords, including base coord
  function getRelativeCoords(ObjectType self, Vec3 baseCoord, Direction direction)
    internal
    pure
    returns (Vec3[] memory)
  {
    Vec3[] memory schemaCoords = getObjectTypeSchema(self);
    Vec3[] memory coords = new Vec3[](schemaCoords.length + 1);

    coords[0] = baseCoord;

    for (uint256 i = 0; i < schemaCoords.length; i++) {
      require(isDirectionSupported(self, direction), "Direction not supported");
      coords[i + 1] = baseCoord + schemaCoords[i].rotate(direction);
    }

    return coords;
  }

  function isDirectionSupported(ObjectType self, Direction direction) internal pure returns (bool) {
    if (self == ObjectTypes.Bed) {
      // Note: before supporting more directions, we need to ensure clients can render it
      return direction == Direction.NegativeX || direction == Direction.NegativeZ;
    }

    return true;
  }

  function getRelativeCoords(ObjectType self, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(self, baseCoord, Direction.PositiveZ);
  }

  function isActionAllowed(ObjectType self, bytes4 sig) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    if (self == ObjectTypes.Chest) {
      return sig == ITransferSystem.transfer.selector || sig == IMachineSystem.fuelMachine.selector;
    }

    return false;
  }


  function getMaxInventorySlots(ObjectType self) internal pure returns (uint16) {
    if (self == ObjectTypes.Player) return 36;
    if (self == ObjectTypes.Chest) return 27;
    if (self.isPassThrough()) return type(uint16).max;
    return 0;
  }

  function getStackable(ObjectType self) internal pure returns (uint16) {
    if (self.isUniqueObject()) return 1;
    return 99;
  }

  function getOreAmount(ObjectType self) internal pure returns(ObjectAmount memory) {
    ${objects
      .filter((result) => result.oreAmount !== undefined)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ${renderObjectAmount(obj.oreAmount!)};`,
      )
      .join("\n    ")}
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function getPlankAmount(ObjectType self) internal pure returns(uint16) {
    ${objects
      .filter((obj) => obj.plankAmount !== undefined)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ${obj.plankAmount!.toString()};`,
      )
      .join("\n    ")}
    return 0;
  }

  function getCrop(ObjectType self) internal pure returns(ObjectType) {
    ${objects
      .filter((obj) => obj.crop)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ObjectTypes.${obj.crop};`,
      )
      .join("\n    ")}
    return ObjectTypes.Null;
  }

  function getSapling(ObjectType self) internal pure returns(ObjectType) {
    ${objects
      .filter((obj) => obj.sapling)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ObjectTypes.${obj.sapling};`,
      )
      .join("\n    ")}
    return ObjectTypes.Null;
  }

  function getTimeToGrow(ObjectType self) internal pure returns(uint128) {
    ${objects
      .filter((obj) => obj.timeToGrow)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ${obj.timeToGrow};`,
      )
      .join("\n    ")}
    return 0;
  }

  // TODO: use meta categories?
  function hasExtraDrops(ObjectType self) internal pure returns (bool) {
    return self == ObjectTypes.FescueGrass || self.isCrop() || self.isLeaf();
  }

  function isMachine(ObjectType self) internal pure returns (bool) {
    ${objects
      .filter((obj) => obj.isMachine)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ${obj.isMachine};`,
      )
      .join("\n    ")}
    return false;
  }

  // Meta Category Checks
  function isAny(ObjectType self) internal pure returns (bool) {
    // Check if:
    // 1. ID bits are all 0
    // 2. Category is one that supports "Any" types
    uint16 idx = self.unwrap() & ~CATEGORY_MASK;

    return idx == 0 && hasMetaCategory(self, Category.HAS_ANY_MASK);
  }

  function isPassThrough(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.PASS_THROUGH_MASK);
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.MINEABLE_MASK);
  }

  function isTool(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.TOOL_MASK);
  }

  function isUniqueObject(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.UNIQUE_OBJECT_MASK);
  }

  function isSmartEntity(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.SMART_ENTITY_MASK);
  }

  function isGrowable(ObjectType self) internal pure returns (bool) {
    return hasMetaCategory(self, Category.GROWABLE_MASK);
  }

  function hasMetaCategory(ObjectType self, uint128 mask) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << (c >> OFFSET_BITS)) & mask) != 0;
  }


  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (self.isAny()) {
      return self.category() == other.category();
    }
    return self == other;
  }
}

function eq(ObjectType self, ObjectType other) pure returns (bool) {
  return ObjectType.unwrap(self) == ObjectType.unwrap(other);
}

function neq(ObjectType self, ObjectType other) pure returns (bool) {
  return ObjectType.unwrap(self) != ObjectType.unwrap(other);
}

using { eq as ==, neq as != } for ObjectType global;

using ObjectTypeLib for ObjectType global;
`;
}

// Execute the generator when this module is run directly
if (require.main === module) {
  console.info(generateObjectTypeSol());
}
