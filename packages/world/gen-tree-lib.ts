interface Vec3 {
  x: number;
  y: number;
  z: number;
}

interface TreeDef {
  name: string;
  objectTypeId: string;
  logType: string;
  leafType: string;
  trunkHeight: number;
  canopyStart: number;
  canopyEnd: number; // exclusive
  canopyWidth: number;
  stretch: number;
  centerOffset: number;
}

export const TREES: TreeDef[] = [
  {
    name: "Oak",
    objectTypeId: "ObjectTypes.OakSapling",
    logType: "ObjectTypes.OakLog",
    leafType: "ObjectTypes.OakLeaf",
    trunkHeight: 5,
    canopyStart: 3,
    canopyEnd: 7,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: -2,
  },
  {
    name: "Birch",
    objectTypeId: "ObjectTypes.BirchSapling",
    logType: "ObjectTypes.BirchLog",
    leafType: "ObjectTypes.BirchLeaf",
    trunkHeight: 7,
    canopyStart: 6,
    canopyEnd: 8,
    canopyWidth: 1,
    stretch: 2,
    centerOffset: 0,
  },
  {
    name: "Jungle",
    objectTypeId: "ObjectTypes.JungleSapling",
    logType: "ObjectTypes.JungleLog",
    leafType: "ObjectTypes.JungleLeaf",
    trunkHeight: 12,
    canopyStart: 11,
    canopyEnd: 16,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: 1,
  },
  {
    name: "Sakura",
    objectTypeId: "ObjectTypes.SakuraSapling",
    logType: "ObjectTypes.SakuraLog",
    leafType: "ObjectTypes.SakuraLeaf",
    trunkHeight: 6,
    canopyStart: 4,
    canopyEnd: 9,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: -1,
  },
  {
    name: "Acacia",
    objectTypeId: "ObjectTypes.AcaciaSapling",
    logType: "ObjectTypes.AcaciaLog",
    leafType: "ObjectTypes.AcaciaLeaf",
    trunkHeight: 6,
    canopyStart: 6,
    canopyEnd: 8,
    canopyWidth: 2,
    stretch: 3,
    centerOffset: 0,
  },
  {
    name: "Spruce",
    objectTypeId: "ObjectTypes.SpruceSapling",
    logType: "ObjectTypes.SpruceLog",
    leafType: "ObjectTypes.SpruceLeaf",
    trunkHeight: 9,
    canopyStart: 3,
    canopyEnd: 12,
    canopyWidth: 3,
    stretch: 1,
    centerOffset: -2,
  },
  {
    name: "DarkOak",
    objectTypeId: "ObjectTypes.DarkOakSapling",
    logType: "ObjectTypes.DarkOakLog",
    leafType: "ObjectTypes.DarkOakLeaf",
    trunkHeight: 6,
    canopyStart: 2,
    canopyEnd: 8,
    canopyWidth: 3,
    stretch: 1,
    centerOffset: -1,
  },
  {
    name: "Mangrove",
    objectTypeId: "ObjectTypes.MangroveSapling",
    logType: "ObjectTypes.MangroveLog",
    leafType: "ObjectTypes.MangroveLeaf",
    trunkHeight: 8,
    canopyStart: 6,
    canopyEnd: 12,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: 0,
  },
];

const abs = Math.abs;

/* uint32‑wrap (handles negative ints via 2‑complement) */
const asU32 = (n: number) => n >>> 0;

/* pack exactly like on‑chain vec3:  z | y | x  (uint96) */
function pack96(x: number, y: number, z: number): bigint {
  return (
    (BigInt(asU32(z)) << 64n) | (BigInt(asU32(y)) << 32n) | BigInt(asU32(x))
  );
}

/* 24‑hex‑char big‑endian string */
const hex96 = (b: bigint) => b.toString(16).padStart(24, "0");

/* concat 12‑byte words into one hex blob */
const blobHex = (vs: Vec3[]) =>
  vs.map((v) => hex96(pack96(v.x, v.y, v.z))).join("");

/* convert "Dark Oak" -> "DARK_OAK" */
const constName = (label: string) => label.replace(/\s+/g, "_").toUpperCase();

export function classifyLeaves(tree: TreeDef): {
  fixed: Vec3[];
  random: Vec3[];
} {
  const fixed: Vec3[] = [];
  const random: Vec3[] = [];

  const centre = tree.trunkHeight + tree.centerOffset;

  for (let y = tree.canopyStart; y < tree.canopyEnd; ++y) {
    const dy = abs(y - centre);
    const band = Math.floor(dy / tree.stretch);
    const radius = tree.canopyWidth - band;
    if (radius < 0) continue;

    for (let x = -radius; x <= radius; ++x) {
      for (let z = -radius; z <= radius; ++z) {
        if (x === 0 && z === 0 && y < tree.trunkHeight) continue;

        const isCorner = radius !== 0 && abs(x) === radius && abs(z) === radius;

        if (isCorner) {
          // skip all corners on duplicated‑layer indices
          if ((dy + 1) % tree.stretch === 0) continue;

          // surviving corners are subject to RNG → random set
          random.push({ x, y, z });
        } else {
          // non‑corner leaves are always present
          fixed.push({ x, y, z });
        }
      }
    }
  }
  return { fixed, random };
}

export function genTreeLib() {
  const blobs: string[] = [];
  const treePieces: string[] = [];
  const dataPieces: string[] = [];
  const chancePieces: string[] = [];

  for (const t of TREES) {
    const { fixed, random } = classifyLeaves(t);
    const FIX = blobHex(fixed);
    const RND = blobHex(random);
    const N = constName(t.name);

    blobs.push(`
  /* ${t.name} – ${fixed.length} fixed, ${random.length} random */
  bytes constant ${N}_FIXED  = hex"${FIX}";
  bytes constant ${N}_RANDOM = hex"${RND}";`);

    treePieces.push(`
    if (objectType == ${t.objectTypeId}) {
      fixedLeaves  = _loadLeaves(TreeBlobs.${N}_FIXED );
      randomLeaves = _loadLeaves(TreeBlobs.${N}_RANDOM);
    }`);

    dataPieces.push(`
    if (objectType == ${t.objectTypeId}) {
      return TreeData({
        logType:  ${t.logType},
        leafType: ${t.leafType},
        trunkHeight: ${t.trunkHeight}
      });
    }`);

    chancePieces.push(`
    if (objectType == ${t.leafType}) {
      return uint256(3) * 100 / ${fixed.length + random.length};
    }`);
  }

  console.info(`// SPDX-License-Identifier: MIT
/* Auto‑generated. DO NOT EDIT. */
pragma solidity >=0.8.24;

import { Vec3 }         from "./Vec3.sol";
import { ObjectTypeId } from "./ObjectTypeId.sol";
import { ObjectTypes }  from "./ObjectTypes.sol";

library TreeBlobs {${blobs.join("")}
}

struct TreeData {
  ObjectTypeId logType;
  ObjectTypeId leafType;
  uint32       trunkHeight;
}

library TreeLib {
  function getTreeData(ObjectTypeId objectType)
    internal
    pure
    returns (TreeData memory)
  {${dataPieces.join("")}
    revert("Tree type not supported");
  }

  function getLeafCoords(ObjectTypeId objectType)
    internal
    pure
    returns (Vec3[] memory fixedLeaves, Vec3[] memory randomLeaves)
  {${treePieces.join(" else ")}
    else {
      revert("Tree type not supported");
    }
  }

  function getLeafDropChance(ObjectTypeId objectType)
    internal
    pure
    returns (uint256)
  {${chancePieces.join("")}
    revert("Leaf type not supported");
  }

  /* decode blob → Vec3[] */
  function _loadLeaves(bytes memory blob)
    private
    pure
    returns (Vec3[] memory out)
  {
    uint256 words = blob.length / 12;
    out = new Vec3[](words);

    assembly {
      let src := add(blob, 32)          // skip length
      let dst := add(out , 32)

      for { let i := 0 } lt(i, words) { i := add(i, 1) } {
        let w := mload(add(src, mul(i, 12)))   // 12‑byte chunk in low bytes
        w := shr(160, w)                       // shift to low 96 bits
        mstore(dst, w)                         // Vec3.wrap(uint96)
        dst := add(dst, 32)
      }
    }
  }

}
`);
}
