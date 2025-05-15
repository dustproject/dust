import { type Bucket, buildBucket } from "../buildBucket";
import { type Category, type ObjectAmount, categories, objects, objectsByName } from "../objects";

const constName = (str: string): string =>
  str
    .replace(/\W+/g, " ")
    .split(/ |\B(?=[A-Z])/)
    .join("_")
    .toUpperCase();

const buckets: Record<string, Bucket> = {};

for (const [name, data] of Object.entries(categories)) {
  const ids = data.objects.map((obj) => objectsByName[obj].id);
  const bucket = buildBucket(ids);
  buckets[name] = bucket;
}

// function renderCategoryTable(name: string): string {
// const table = `${Buffer.from(buckets[name]!.table).toString("hex")}`;
// return `bytes constant ${constName(name)}_TABLE = hex"${table}";`;
// }

function renderCategoryCheck(name: string): string {
  const { checkName } = categories[name]!;
  const fn = checkName ?? `is${name}`;
  const { S, A, G, table } = buckets[name]!; // G & table already 0x… big-endian

  /* ---------- gByte helper ---------------------------------- */
  const numG = Math.ceil(S / 32); // 1‥4 words
  const gByte =
    numG === 1
      ? // single word → one BYTE, no switch
        `// g[0..${S - 1}] in one word
        function gByte(i) -> b { b := byte(i, ${G[0]}) }`
      : // 2‥4 words → BYTE + tiny switch
        `function gByte(i) -> b {
            let off := and(i, 31)              // idx within word
            switch shr(5, i)                   // word 0..${numG - 1}
        ${G.slice(0, numG)
          .map((w, i) => `case ${i} { b := byte(off, ${w}) }`)
          .join("\n            ")}
        }`;

  /* ---------- slot→id table --------------------------------- */
  const tableSwitch =
    table.length === 1
      ? `let w := ${table[0]}` // S ≤ 16 – single PUSH32
      : `
        let w
        switch shr(4, slot)                     // slot / 16
        ${table
          .map((w, i, arr) => (i === arr.length - 1 ? `default { w := ${w} }` : `case ${i} { w := ${w} }`))
          .join("\n        ")}`;

  /* ---------- function body --------------------------------- */
  return `
  function ${fn}(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self);      // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      ${gByte}

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, ${A[0]})), 0xFF)
      let h1 := and(shr(8, mul(id, ${A[1]})), 0xFF)
      let h2 := and(shr(8, mul(id, ${A[2]})), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, ${S})), add(gByte(mod(h1, ${S})), gByte(mod(h2, ${S}))))
      slot := addmod(slot, 0, ${S}) // 0‥S-1

      /* slot → id table -------------------------------------- */
      ${tableSwitch}

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is   := eq(ref, id)
    }
  }
  `;
}

function renderObjectAmount([objectType, amount]: ObjectAmount): string {
  return `ObjectAmount(ObjectTypes.${objectType}, ${amount})`;
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

uint16 constant BLOCK_CATEGORY_COUNT = 256 / 2; // 128

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  // Meta Category Masks (fits within uint256; mask bit k set if raw category ID k belongs)
  uint256 constant BLOCK_MASK = uint256(type(uint128).max);

}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
${objects
  .map((obj, i) => {
    return `  ObjectType constant ${obj.name} = ObjectType.wrap(${i});`;
  })
  .join("\n")}
}

// ------------------------------------------------------------
library ObjectTypeLib {
  function unwrap(ObjectType self) internal pure returns (uint16) {
    return ObjectType.unwrap(self);
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    // TODO
    return  !self.isNull();
  }

  // Direct Category Checks
${Object.keys(categories)
  .map((name) => renderCategoryCheck(name))
  .join("")}

// Category getters
${Object.entries(categories)
  .map(([name, data]) => {
    const categoryObjects = data.objects;
    return `function get${name}Types() internal pure returns (ObjectType[${categoryObjects.length}] memory) {
    return [${categoryObjects.map((obj) => `ObjectTypes.${obj}`).join(", ")}];
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
    if (self.isNonSolid() || self.isPlayer()) return 0;
    return 99;
  }

  function getOreAmount(ObjectType self) internal pure returns(ObjectAmount memory) {
    ${objects
      .filter((result) => result.oreAmount !== undefined)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ${renderObjectAmount(obj.oreAmount!)};`)
      .join("\n    ")}
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function getPlankAmount(ObjectType self) internal pure returns(uint16) {
    ${objects
      .filter((obj) => obj.plankAmount !== undefined)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ${obj.plankAmount!.toString()};`)
      .join("\n    ")}
    return 0;
  }

  function getCrop(ObjectType self) internal pure returns(ObjectType) {
    ${objects
      .filter((obj) => obj.crop)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ObjectTypes.${obj.crop};`)
      .join("\n    ")}
    return ObjectTypes.Null;
  }

  function getSapling(ObjectType self) internal pure returns(ObjectType) {
    ${objects
      .filter((obj) => obj.sapling)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ObjectTypes.${obj.sapling};`)
      .join("\n    ")}
    return ObjectTypes.Null;
  }

  function getTimeToGrow(ObjectType self) internal pure returns(uint128) {
    ${objects
      .filter((obj) => obj.timeToGrow)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ${obj.timeToGrow};`)
      .join("\n    ")}
    return 0;
  }

  function getGrowableEnergy(ObjectType self) public pure returns(uint128) {
    ${objects
      .filter((obj) => obj.growableEnergy)
      .map((obj) => `if (self == ObjectTypes.${obj.name}) return ${obj.growableEnergy};`)
      .join("\n    ")}
    return 0;
  }

  function isPlantableOn(ObjectType self, ObjectType on) internal pure returns (bool) {
    if(self.isSeed()) {
      return on == ObjectTypes.WetFarmland;
    }
    if(self.isSapling()) {
      return on == ObjectTypes.Dirt || on == ObjectTypes.Grass;
    }
    return false;
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
  }

  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (self == ObjectTypes.AnyLog && self.isLog() || self == ObjectTypes.AnyPlank && self.isPlank() || self == ObjectTypes.AnyLeaf && self.isLeaf()) {
      return true;
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

console.info(generateObjectTypeSol());
