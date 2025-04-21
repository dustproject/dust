import {
  type Category,
  allCategoryMetadata,
  blockCategories,
  blockCategoryMetadata,
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
    .map((cat) => `(uint128(1) << ${blockCategories.indexOf(cat) + 1})`)
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
${nonBlockCategoryMetadata
  .map(
    (cat) =>
      `  uint16 constant ${cat.name} = uint16(${cat.id}) << CATEGORY_SHIFT;`,
  )
  .join("\n")}
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint128; mask bit k set if raw category ID k belongs)
  uint128 constant BLOCK_MASK = uint128(type(uint64).max);
  uint128 constant PASS_THROUGH_MASK = ${renderMetaCategoryMask(passThroughCategories)};
  uint128 constant IS_MINEABLE_MASK = BLOCK_MASK & ~(uint128(1) << ${blockCategories.indexOf("NON_SOLID") + 1});
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
    return category(self) == ${cat.id};
  }`,
  )
  .join("")}

  // Meta Category Checks
  function isPassThrough(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << c) & Category.PASS_THROUGH_MASK) != 0;
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << c) & Category.IS_MINEABLE_MASK) != 0;
  }
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
${objects
  .filter((obj) => obj.mass !== 0n || obj.energy !== 0n)
  .map((obj) => {
    const categoryRef = `Category.${obj.category}`;
    return `  ObjectType constant ${obj.name} = ObjectType.wrap(${categoryRef} | ${obj.id});`;
  })
  .join("\n")}
}

using ObjectTypeLib for ObjectType global;
`;
}

// Execute the generator when this module is run directly
if (require.main === module) {
  console.info(generateObjectTypeSol());
}
