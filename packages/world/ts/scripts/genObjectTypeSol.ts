import {
  type Category,
  type ObjectAmount,
  categories,
  objects,
  objectsByName,
} from "../objects";

// Build minimal sliding windows over sorted ids
function buildSlidingWindows(ids: number[]): { start: number; mask: bigint }[] {
  const sorted = Array.from(new Set(ids)).sort((a, b) => a - b);
  const windows: { start: number; mask: bigint }[] = [];
  let i = 0;
  const n = sorted.length;

  while (i < n) {
    const start = sorted[i]!;
    let mask = 0n;
    // build bitmap for [start..start+255]
    while (i < n && sorted[i]! <= start + 255) {
      mask |= 1n << BigInt(sorted[i]! - start);
      i++;
    }
    windows.push({ start, mask });
  }
  return windows;
}

export function renderCheck(
  name: string,
  ids: number[],
  customFnName?: string,
): string {
  if (ids.length === 0) {
    throw new Error(`No ids for ${name} Category`);
  }

  const fn = customFnName ?? `is${name}`;
  const orig = buildSlidingWindows(ids);

  // consider zero-based alternative only if orig[0].start>0 && we have some id < 256
  let windows = orig;
  if (orig[0]!.start > 0 && ids.some((x) => x < 256)) {
    // build an alternative window starting at 0
    const lowIds = ids.filter((x) => x < 256);
    let lowMask = 0n;
    for (const x of lowIds) lowMask |= 1n << BigInt(x);
    const rest = ids.filter((x) => x > 255);
    const alt = [{ start: 0, mask: lowMask }, ...buildSlidingWindows(rest)];
    if (alt.length <= orig.length) windows = alt;
  }

  const blocks = windows.map(({ start, mask }, i) => {
    const returnValue = i === 0 ? "ok := bit" : "ok := or(ok, bit)";
    const hex = mask.toString(16);
    if (start === 0) {
      return `
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x${hex}), 1)
        ${returnValue}
      }`;
    }

    return `
    // IDs in [${start}..${start + 255}]
    {
      let off := sub(self, ${start})
      let bit := and(shr(off, 0x${hex}), 1)
      ${returnValue}
    }`;
  });

  return `
function ${fn}(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    ${blocks.join("\n")}
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

import { IMachineSystem } from "../codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "../codegen/world/ITransferSystem.sol";
import { Vec3, vec3 } from "./Vec3.sol";
import { Orientation } from "./Orientation.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
${objects
  .map((obj) => {
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
  .map(([name, data]: [string, Category]) => {
    return renderCheck(
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
      bedRelativePositions[0] = vec3(1, 0, 0);
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
  function getRelativeCoords(ObjectType self, Vec3 baseCoord, Orientation orientation)
    internal
    pure
    returns (Vec3[] memory)
  {
    require(isOrientationSupported(self, orientation), "Orientation not supported");

    Vec3[] memory schemaCoords = getObjectTypeSchema(self);
    Vec3[] memory coords = new Vec3[](schemaCoords.length + 1);

    coords[0] = baseCoord;

    for (uint256 i = 0; i < schemaCoords.length; i++) {
      coords[i + 1] = baseCoord + schemaCoords[i].applyOrientation(orientation);
    }

    return coords;
  }

  function isOrientationSupported(ObjectType self, Orientation orientation) internal pure returns (bool) {
    ${objects
      .filter((obj) => obj.supportedOrientations !== undefined)
      .map((obj) => {
        return `if (self == ObjectTypes.${obj.name}) {
          return ${obj.supportedOrientations!.map((orientation) => `orientation == Orientation.wrap(${orientation})`).join(" || ")};
        }`;
      })
      .join("\n    ")}

    return orientation == Orientation.wrap(0);
  }

  function getRelativeCoords(ObjectType self, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(self, baseCoord, Orientation.wrap(0));
  }

  function isActionAllowed(ObjectType self, bytes4 sig) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    if (self == ObjectTypes.Chest) {
      return sig == ITransferSystem.transfer.selector || sig == ITransferSystem.transferAmounts.selector || sig == IMachineSystem.fuelMachine.selector;
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

  function getGrowableEnergy(ObjectType self) public pure returns(uint128) {
    // First check explicit growableEnergy (for saplings)
    ${objects
      .filter((obj) => obj.growableEnergy)
      .map(
        (obj) =>
          `if (self == ObjectTypes.${obj.name}) return ${obj.growableEnergy};`,
      )
      .join("\n    ")}

    return 0;
  }

  function isPlantableOn(ObjectType self, ObjectType on) internal pure returns (bool) {
    if(self.isSeed()) {
      return on == ObjectTypes.WetFarmland;
    }
    if(self.isSapling()) {
      return on == ObjectTypes.Dirt || on == ObjectTypes.Grass || on == ObjectTypes.Moss;
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
