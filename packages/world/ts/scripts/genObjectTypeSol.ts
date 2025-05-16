import { buildBitmap } from "../buildBitmap";
import { type ObjectAmount, categories, objects, objectsByName } from "../objects";

export function renderCategoryCheck(name: string, ids: number[], customFnName?: string): string {
  const fn = customFnName ?? `is${name}`;
  const { words } = buildBitmap(ids);
  if (words.length === 0) throw new Error("empty set");

  const hexLit = (v: bigint) => "0x" + v.toString(16).padStart(64, "0");

  // 1) FAST path: single word @ window 0
  if (words.length === 1 && words[0]!.idx === 0) {
    const lit = hexLit(words[0]!.val);
    return `
  // ${name} — ${ids.length} keys in 1 word @ window 0 (fast)
  function ${fn}(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix   := shr(3, self)                   // id/8
      let bits := byte(sub(31, ix), ${lit})     // pick that byte
      let mask := shl(and(self, 7), 1)           // 1 << (id % 8)
      ok        := gt(and(bits, mask), 0)
    }
  }`;
  }

  // 2) single non-zero window → cheap `if`
  let extractor: string;
  if (words.length === 1) {
    const { idx, val } = words[0]!;
    extractor = `
      // single word @ window ${idx}
      if eq(win, ${idx}) {
        chunk := byte(byteOff, ${hexLit(val)})
      }`;
  } else {
    // 3) multi-window → sparse switch + default debug‐revert
    extractor = `
      // sparse windows
      switch win
        ${words.map(({ idx, val }) => `case ${idx} { chunk := byte(byteOff, ${hexLit(val)}) }`).join("\n        ")}
        default {
          // unexpected window — shove win into return‐data so you can inspect it
          mstore(0x00, win)
          revert(0x00, 0x20)
        }`;
  }

  // 4) common on-chain path
  return `
  // ${name} — ${ids.length} keys in ${words.length} window${words.length > 1 ? "s" : ""}
  function ${fn}(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      let id      := self
      let win     := shr(8, id)                // window = id / 256
      let idx8    := shr(3, id)                // byte-offset = id / 8
      let byteOff := sub(31, and(idx8, 31))    // 31 - (idx8 % 32)
      let chunk   := 0
      ${extractor}
      let mask := shl(and(id, 7), 1)          // 1 << (id % 8)
      ok        := gt(and(chunk, mask), 0)
    }
  }`;
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
    return `  ObjectType constant ${obj.name} = ObjectType.wrap(${obj.id});`;
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

  // Direct Category Checks
${Object.entries(categories)
  .map(([name, data]) => {
    return renderCategoryCheck(
      name,
      data.objects.map((obj) => objectsByName[obj].id),
      data.checkName,
    );
  })
  .join("\n")}

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

  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (!self.isAny()) return self == other;

    return (self == ObjectTypes.AnyLog && other.isLog())
      || (self == ObjectTypes.AnyPlank && other.isPlank())
      || (self == ObjectTypes.AnyLeaf && other.isLeaf());
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
