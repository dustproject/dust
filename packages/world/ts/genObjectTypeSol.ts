import {
  type Category,
  allCategories,
  allCategoryMetadata,
  blockCategories,
  blockCategoryMetadata,
  hasAnyCategories,
  nonBlockCategoryMetadata,
  objects,
  passThroughCategories,
} from "./objects.ts";

// Helper to format category names correctly for function generation
function formatCategoryName(name: string): string {
  return name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
}

function renderMetaCategoryMask(categories: Category[]): string {
  return categories
    .map((cat) => `(uint128(1) << (${cat} >> CATEGORY_SHIFT))`)
    .join(" | ");
}

// Template for the Solidity file
function generateObjectTypeSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type ObjectType is uint16;

// Category bits (bits 15..11), id bits (bits 10..0)
uint16 constant CATEGORY_MASK = 0xF800;
uint16 constant CATEGORY_SHIFT = 11;
uint16 constant BLOCK_CATEGORY_COUNT = 128 / 2; // 31

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  uint16 constant NONE = 0;
  // Block Categories
${blockCategoryMetadata.map((cat) => `  uint16 constant ${cat.name} = uint16(${cat.id}) << CATEGORY_SHIFT;`).join("\n")}
  // Non-Block Categories
${nonBlockCategoryMetadata.map((cat) => `  uint16 constant ${cat.name} = uint16(${cat.id}) << CATEGORY_SHIFT;`).join("\n")}
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint128; mask bit k set if raw category ID k belongs)
  uint128 constant BLOCK_MASK = uint128(type(uint64).max);
  uint128 constant HAS_ANY_MASK = ${renderMetaCategoryMask(hasAnyCategories)};
  uint128 constant PASS_THROUGH_MASK = ${renderMetaCategoryMask(passThroughCategories)};
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

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    return category(self) < BLOCK_CATEGORY_COUNT && !self.isNull();
  }

  // Direct Category Checks
${allCategoryMetadata
  .filter((cat) => cat.name !== "NONE")
  .map(
    (cat) => `
  function is${formatCategoryName(cat.name)}(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.${cat.name};
  }`,
  )
  .join("")}


  // Meta Category Checks
  function isAny(ObjectType self) internal pure returns (bool) {
    // Check if:
    // 1. ID bits are all 0
    // 2. Category is one that supports "Any" types
    uint16 c = self.category();
    uint16 idx = self.unwrap() & ~CATEGORY_MASK;

    return idx == 0 && ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.HAS_ANY_MASK) != 0;
  }

  function isPassThrough(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.PASS_THROUGH_MASK) != 0;
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.MINEABLE_MASK) != 0;
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
