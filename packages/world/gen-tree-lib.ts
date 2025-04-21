import { TREES } from "./tree-lib";
import { classifyLeaves } from "./tree-lib";

interface Vec3 {
  x: number;
  y: number;
  z: number;
}

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
import { ObjectType } from "./ObjectType.sol";
import { ObjectTypes }  from "./ObjectType.sol";

library TreeBlobs {${blobs.join("")}
}

struct TreeData {
  ObjectType logType;
  ObjectType leafType;
  uint32       trunkHeight;
}

library TreeLib {
  function getTreeData(ObjectType objectType)
    internal
    pure
    returns (TreeData memory)
  {${dataPieces.join("")}
    revert("Tree type not supported");
  }

  function getLeafCoords(ObjectType objectType)
    internal
    pure
    returns (Vec3[] memory fixedLeaves, Vec3[] memory randomLeaves)
  {${treePieces.join(" else ")}
    else {
      revert("Tree type not supported");
    }
  }

  function getLeafDropChance(ObjectType objectType)
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

genTreeLib();
