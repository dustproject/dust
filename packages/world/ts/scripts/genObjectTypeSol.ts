import { type ObjectAmount, categories, objects, objectsByName } from "../objects";

export function buildSlidingWindows(ids: number[]) {
  if (!ids.length) throw new Error("empty set");
  ids = Array.from(new Set(ids)).sort((a, b) => a - b);

  type Win = { start: number; mask: bigint };
  const windows: Win[] = [];

  let curStart = ids[0]!;
  let buf = new Uint8Array(32); // big-endian byte buffer

  const flushWindow = () => {
    // pack big-endian
    let w = 0n;
    for (const b of buf) {
      w = (w << 8n) | BigInt(b);
    }
    windows.push({ start: curStart, mask: w });
    buf.fill(0);
  };

  for (const id of ids) {
    const delta = id - curStart;
    if (delta >= 256) {
      // finish previous window
      flushWindow();
      // start new one
      curStart = id;
    }
    const off = id - curStart; // 0..255
    const byteIndex = off >> 3; // 0..31
    const bitInByte = off & 7; // 0..7
    // big-endian buffer: byte 0 is MSB
    buf[byteIndex]! |= 1 << bitInByte;
  }
  // final window
  flushWindow();

  return windows;
}

export function renderCheck(name: string, ids: number[], customFnName?: string) {
  const fn = customFnName ?? `is${name}`;
  const windows = buildSlidingWindows(ids);

  // Emit one `off/shr/and/or` block per window
  const body = windows
    .map(({ start, mask }, i) => {
      return `
      {
        // window ${i}: [${start} .. ${start + 255}]
        let off := sub(id, ${start})
        let bit := and(shr(off, 0x${mask.toString(16)}), 1)
        ok := or(ok, bit)
      }`;
    })
    .join("\n");

  return `
/// @notice true iff \`self\` is in your ${name} set
function ${fn}(ObjectType self) internal pure returns (bool ok) {
  uint16 id = ObjectType.unwrap(self);
  /// @solidity memory-safe-assembly
  assembly {
    ok := 0
${body}
  }
}
`;
}

export function renderCategoryCheck(name: string, ids: number[], customFnName?: string): string {
  const fn = customFnName ?? `is${name}`;

  if (ids.length === 0) {
    return "";
  }

  // figure out absolute window of IDs
  const minId = Math.min(...ids);
  const maxId = Math.max(...ids);
  const w0 = minId >>> 8;
  const w1 = maxId >>> 8;

  // If they all sit in the same 256-bit window, compact ids into a bitmap
  if (w0 === w1) {
    const base = w0 << 8; // window * 256
    // build a 32-byte little-endian bitmap for (id – base)
    const le = new Uint8Array(32);
    for (const id of ids) {
      const off = id - base;
      le[off >>> 3]! |= 1 << (off & 7);
    }
    // reverse into big-endian for the PUSH32 literal
    const be = Uint8Array.from({ length: 32 }, (_, i) => le[31 - i] || 0);
    const BITS = `0x${[...be].map((b) => b.toString(16).padStart(2, "0")).join("")}`;

    return `
    // ${name} — single 256-bit window
    function ${fn}(ObjectType self) internal pure returns (bool ok) {
      /// @solidity memory-safe-assembly
      assembly {
        ${base !== 0 ? `self := sub(self, ${base})` : ""}
        let ix   := shr(3, self)
        let bits := byte(sub(31, ix), ${BITS})
        let mask := shl(and(self, 7), 1)
        ok       := gt(and(bits, mask), 0)
      }
    }`;
  }

  if (ids.length <= 4) {
    return renderEqChainCategoryCheck(name, fn, ids);
  }

  // otherwise fall back to the multi-window OR/shr/eq approach
  return renderMultiWindowCheck(name, ids, minId, fn);
}

// multi-window fallback (≈114 gas)
function renderMultiWindowCheck(name: string, ids: number[], minId: number, fn: string): string {
  const words = buildBitmapWords(ids.map((id) => id - minId));
  const lines = words.map(({ idx, val }, i) => {
    const hex = `0x${val.toString(16)}`;
    return i === 0
      ? `ok := and(shr(bitpos, ${hex}), eq(bucket, ${idx}))`
      : `ok := or(ok,  and(shr(bitpos, ${hex}), eq(bucket, ${idx})))`;
  });

  return `
  // ${name} — sparse, ${ids.length} keys over ${words.length} window(s)
  function ${fn}(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      let off    := sub(self, ${minId})
      let bucket := shr(8, off)
      let bitpos := and(off, 0xff)

      ${lines.join("\n    ")}
    }
  }`;
}

// helper to pack 0-based offsets into 32-byte windows
function buildBitmapWords(offsetIds: number[]): { idx: number; val: bigint }[] {
  const buckets: Uint8Array[] = [];
  for (const off of offsetIds) {
    const byteIx = off >>> 3;
    const bit = 1 << (off & 7);
    const win = byteIx >>> 5;
    const pos = 31 - (byteIx & 31);
    if (!buckets[win]) buckets[win] = new Uint8Array(32);
    buckets[win]![pos]! |= bit;
  }
  return buckets.map((buf, idx) => {
    let w = 0n;
    for (const b of buf) w = (w << 8n) | BigInt(b);
    return { idx, val: w };
  });
}

// Direct eq-chain renderer
function renderEqChainCategoryCheck(name: string, fn: string, ids: number[]): string {
  const exprs = ids.map((i) => `eq(self, ${i})`);
  const [first, ...rest] = exprs;
  return `
  // ${name} — ${ids.length} keys via eq-chain
  function ${fn}(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      ok := ${first}
      ${rest.map((e) => `ok := or(ok, ${e})`).join("\n")}
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
  .map(([name, data]) => {
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
