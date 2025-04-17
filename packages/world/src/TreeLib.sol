// SPDX-License-Identifier: MIT
/* Auto‑generated. DO NOT EDIT. */
pragma solidity >=0.8.24;

import { ObjectTypeId } from "./ObjectTypeId.sol";
import { ObjectTypes } from "./ObjectTypes.sol";
import { Vec3 } from "./Vec3.sol";

library TreeBlobs {
  /* Oak – 50 fixed, 8 random */
  bytes constant OAK_FIXED =
    hex"ffffffff00000003fffffffe0000000000000003fffffffe0000000100000003fffffffefffffffe00000003ffffffffffffffff00000003ffffffff0000000000000003ffffffff0000000100000003ffffffff0000000200000003fffffffffffffffe0000000300000000ffffffff0000000300000000000000010000000300000000000000020000000300000000fffffffe0000000300000001ffffffff0000000300000001000000000000000300000001000000010000000300000001000000020000000300000001ffffffff0000000300000002000000000000000300000002000000010000000300000002ffffffff00000004fffffffe0000000000000004fffffffe0000000100000004fffffffefffffffe00000004ffffffffffffffff00000004ffffffff0000000000000004ffffffff0000000100000004ffffffff0000000200000004fffffffffffffffe0000000400000000ffffffff0000000400000000000000010000000400000000000000020000000400000000fffffffe0000000400000001ffffffff0000000400000001000000000000000400000001000000010000000400000001000000020000000400000001ffffffff00000004000000020000000000000004000000020000000100000004000000020000000000000005ffffffffffffffff00000005000000000000000000000005000000000000000100000005000000000000000000000005000000010000000000000006ffffffffffffffff0000000600000000000000000000000600000000000000010000000600000000000000000000000600000001";
  bytes constant OAK_RANDOM =
    hex"fffffffe00000003fffffffe0000000200000003fffffffefffffffe0000000300000002000000020000000300000002ffffffff00000005ffffffff0000000100000005ffffffffffffffff0000000500000001000000010000000500000001";
  /* Birch – 9 fixed, 4 random */
  bytes constant BIRCH_FIXED =
    hex"0000000000000006ffffffffffffffff00000006000000000000000100000006000000000000000000000006000000010000000000000007ffffffffffffffff0000000700000000000000000000000700000000000000010000000700000000000000000000000700000001";
  bytes constant BIRCH_RANDOM =
    hex"ffffffff00000007ffffffff0000000100000007ffffffffffffffff0000000700000001000000010000000700000001";
  /* Jungle – 72 fixed, 12 random */
  bytes constant JUNGLE_FIXED =
    hex"000000000000000bffffffffffffffff0000000b00000000000000010000000b00000000000000000000000b00000001ffffffff0000000cfffffffe000000000000000cfffffffe000000010000000cfffffffefffffffe0000000cffffffffffffffff0000000cffffffff000000000000000cffffffff000000010000000cffffffff000000020000000cfffffffffffffffe0000000c00000000ffffffff0000000c00000000000000000000000c00000000000000010000000c00000000000000020000000c00000000fffffffe0000000c00000001ffffffff0000000c00000001000000000000000c00000001000000010000000c00000001000000020000000c00000001ffffffff0000000c00000002000000000000000c00000002000000010000000c00000002ffffffff0000000dfffffffe000000000000000dfffffffe000000010000000dfffffffefffffffe0000000dffffffffffffffff0000000dffffffff000000000000000dffffffff000000010000000dffffffff000000020000000dfffffffffffffffe0000000d00000000ffffffff0000000d00000000000000000000000d00000000000000010000000d00000000000000020000000d00000000fffffffe0000000d00000001ffffffff0000000d00000001000000000000000d00000001000000010000000d00000001000000020000000d00000001ffffffff0000000d00000002000000000000000d00000002000000010000000d00000002ffffffff0000000efffffffe000000000000000efffffffe000000010000000efffffffefffffffe0000000effffffffffffffff0000000effffffff000000000000000effffffff000000010000000effffffff000000020000000efffffffffffffffe0000000e00000000ffffffff0000000e00000000000000000000000e00000000000000010000000e00000000000000020000000e00000000fffffffe0000000e00000001ffffffff0000000e00000001000000000000000e00000001000000010000000e00000001000000020000000e00000001ffffffff0000000e00000002000000000000000e00000002000000010000000e00000002000000000000000fffffffffffffffff0000000f00000000000000000000000f00000000000000010000000f00000000000000000000000f00000001";
  bytes constant JUNGLE_RANDOM =
    hex"ffffffff0000000bffffffff000000010000000bffffffffffffffff0000000b00000001000000010000000b00000001fffffffe0000000dfffffffe000000020000000dfffffffefffffffe0000000d00000002000000020000000d00000002ffffffff0000000fffffffff000000010000000fffffffffffffffff0000000f00000001000000010000000f00000001";
  /* Sakura – 71 fixed, 8 random */
  bytes constant SAKURA_FIXED =
    hex"ffffffff00000004fffffffe0000000000000004fffffffe0000000100000004fffffffefffffffe00000004ffffffffffffffff00000004ffffffff0000000000000004ffffffff0000000100000004ffffffff0000000200000004fffffffffffffffe0000000400000000ffffffff0000000400000000000000010000000400000000000000020000000400000000fffffffe0000000400000001ffffffff0000000400000001000000000000000400000001000000010000000400000001000000020000000400000001ffffffff0000000400000002000000000000000400000002000000010000000400000002ffffffff00000005fffffffe0000000000000005fffffffe0000000100000005fffffffefffffffe00000005ffffffffffffffff00000005ffffffff0000000000000005ffffffff0000000100000005ffffffff0000000200000005fffffffffffffffe0000000500000000ffffffff0000000500000000000000010000000500000000000000020000000500000000fffffffe0000000500000001ffffffff0000000500000001000000000000000500000001000000010000000500000001000000020000000500000001ffffffff0000000500000002000000000000000500000002000000010000000500000002ffffffff00000006fffffffe0000000000000006fffffffe0000000100000006fffffffefffffffe00000006ffffffffffffffff00000006ffffffff0000000000000006ffffffff0000000100000006ffffffff0000000200000006fffffffffffffffe0000000600000000ffffffff0000000600000000000000000000000600000000000000010000000600000000000000020000000600000000fffffffe0000000600000001ffffffff0000000600000001000000000000000600000001000000010000000600000001000000020000000600000001ffffffff00000006000000020000000000000006000000020000000100000006000000020000000000000007ffffffffffffffff00000007000000000000000000000007000000000000000100000007000000000000000000000007000000010000000000000008ffffffffffffffff0000000800000000000000000000000800000000000000010000000800000000000000000000000800000001";
  bytes constant SAKURA_RANDOM =
    hex"fffffffe00000005fffffffe0000000200000005fffffffefffffffe0000000500000002000000020000000500000002ffffffff00000007ffffffff0000000100000007ffffffffffffffff0000000700000001000000010000000700000001";
  /* Acacia – 42 fixed, 8 random */
  bytes constant ACACIA_FIXED =
    hex"ffffffff00000006fffffffe0000000000000006fffffffe0000000100000006fffffffefffffffe00000006ffffffffffffffff00000006ffffffff0000000000000006ffffffff0000000100000006ffffffff0000000200000006fffffffffffffffe0000000600000000ffffffff0000000600000000000000000000000600000000000000010000000600000000000000020000000600000000fffffffe0000000600000001ffffffff0000000600000001000000000000000600000001000000010000000600000001000000020000000600000001ffffffff0000000600000002000000000000000600000002000000010000000600000002ffffffff00000007fffffffe0000000000000007fffffffe0000000100000007fffffffefffffffe00000007ffffffffffffffff00000007ffffffff0000000000000007ffffffff0000000100000007ffffffff0000000200000007fffffffffffffffe0000000700000000ffffffff0000000700000000000000000000000700000000000000010000000700000000000000020000000700000000fffffffe0000000700000001ffffffff0000000700000001000000000000000700000001000000010000000700000001000000020000000700000001ffffffff0000000700000002000000000000000700000002000000010000000700000002";
  bytes constant ACACIA_RANDOM =
    hex"fffffffe00000006fffffffe0000000200000006fffffffefffffffe0000000600000002000000020000000600000002fffffffe00000007fffffffe0000000200000007fffffffefffffffe0000000700000002000000020000000700000002";
  /* Spruce – 94 fixed, 0 random */
  bytes constant SPRUCE_FIXED =
    hex"0000000000000005ffffffffffffffff0000000500000000000000010000000500000000000000000000000500000001ffffffff00000006fffffffe0000000000000006fffffffe0000000100000006fffffffefffffffe00000006ffffffffffffffff00000006ffffffff0000000000000006ffffffff0000000100000006ffffffff0000000200000006fffffffffffffffe0000000600000000ffffffff0000000600000000000000010000000600000000000000020000000600000000fffffffe0000000600000001ffffffff0000000600000001000000000000000600000001000000010000000600000001000000020000000600000001ffffffff0000000600000002000000000000000600000002000000010000000600000002fffffffe00000007fffffffdffffffff00000007fffffffd0000000000000007fffffffd0000000100000007fffffffd0000000200000007fffffffdfffffffd00000007fffffffefffffffe00000007fffffffeffffffff00000007fffffffe0000000000000007fffffffe0000000100000007fffffffe0000000200000007fffffffe0000000300000007fffffffefffffffd00000007fffffffffffffffe00000007ffffffffffffffff00000007ffffffff0000000000000007ffffffff0000000100000007ffffffff0000000200000007ffffffff0000000300000007fffffffffffffffd0000000700000000fffffffe0000000700000000ffffffff0000000700000000000000010000000700000000000000020000000700000000000000030000000700000000fffffffd0000000700000001fffffffe0000000700000001ffffffff0000000700000001000000000000000700000001000000010000000700000001000000020000000700000001000000030000000700000001fffffffd0000000700000002fffffffe0000000700000002ffffffff0000000700000002000000000000000700000002000000010000000700000002000000020000000700000002000000030000000700000002fffffffe0000000700000003ffffffff0000000700000003000000000000000700000003000000010000000700000003000000020000000700000003ffffffff00000008fffffffe0000000000000008fffffffe0000000100000008fffffffefffffffe00000008ffffffffffffffff00000008ffffffff0000000000000008ffffffff0000000100000008ffffffff0000000200000008fffffffffffffffe0000000800000000ffffffff0000000800000000000000010000000800000000000000020000000800000000fffffffe0000000800000001ffffffff0000000800000001000000000000000800000001000000010000000800000001000000020000000800000001ffffffff00000008000000020000000000000008000000020000000100000008000000020000000000000009ffffffffffffffff0000000900000000000000000000000900000000000000010000000900000000000000000000000900000001000000000000000a00000000";
  bytes constant SPRUCE_RANDOM = hex"";
  /* DarkOak – 94 fixed, 0 random */
  bytes constant DARKOAK_FIXED =
    hex"0000000000000003ffffffffffffffff0000000300000000000000010000000300000000000000000000000300000001ffffffff00000004fffffffe0000000000000004fffffffe0000000100000004fffffffefffffffe00000004ffffffffffffffff00000004ffffffff0000000000000004ffffffff0000000100000004ffffffff0000000200000004fffffffffffffffe0000000400000000ffffffff0000000400000000000000010000000400000000000000020000000400000000fffffffe0000000400000001ffffffff0000000400000001000000000000000400000001000000010000000400000001000000020000000400000001ffffffff0000000400000002000000000000000400000002000000010000000400000002fffffffe00000005fffffffdffffffff00000005fffffffd0000000000000005fffffffd0000000100000005fffffffd0000000200000005fffffffdfffffffd00000005fffffffefffffffe00000005fffffffeffffffff00000005fffffffe0000000000000005fffffffe0000000100000005fffffffe0000000200000005fffffffe0000000300000005fffffffefffffffd00000005fffffffffffffffe00000005ffffffffffffffff00000005ffffffff0000000000000005ffffffff0000000100000005ffffffff0000000200000005ffffffff0000000300000005fffffffffffffffd0000000500000000fffffffe0000000500000000ffffffff0000000500000000000000010000000500000000000000020000000500000000000000030000000500000000fffffffd0000000500000001fffffffe0000000500000001ffffffff0000000500000001000000000000000500000001000000010000000500000001000000020000000500000001000000030000000500000001fffffffd0000000500000002fffffffe0000000500000002ffffffff0000000500000002000000000000000500000002000000010000000500000002000000020000000500000002000000030000000500000002fffffffe0000000500000003ffffffff0000000500000003000000000000000500000003000000010000000500000003000000020000000500000003ffffffff00000006fffffffe0000000000000006fffffffe0000000100000006fffffffefffffffe00000006ffffffffffffffff00000006ffffffff0000000000000006ffffffff0000000100000006ffffffff0000000200000006fffffffffffffffe0000000600000000ffffffff0000000600000000000000000000000600000000000000010000000600000000000000020000000600000000fffffffe0000000600000001ffffffff0000000600000001000000000000000600000001000000010000000600000001000000020000000600000001ffffffff00000006000000020000000000000006000000020000000100000006000000020000000000000007ffffffffffffffff0000000700000000000000000000000700000000000000010000000700000000000000000000000700000001";
  bytes constant DARKOAK_RANDOM = hex"";
  /* Mangrove – 76 fixed, 12 random */
  bytes constant MANGROVE_FIXED =
    hex"0000000000000006ffffffffffffffff0000000600000000000000010000000600000000000000000000000600000001ffffffff00000007fffffffe0000000000000007fffffffe0000000100000007fffffffefffffffe00000007ffffffffffffffff00000007ffffffff0000000000000007ffffffff0000000100000007ffffffff0000000200000007fffffffffffffffe0000000700000000ffffffff0000000700000000000000010000000700000000000000020000000700000000fffffffe0000000700000001ffffffff0000000700000001000000000000000700000001000000010000000700000001000000020000000700000001ffffffff0000000700000002000000000000000700000002000000010000000700000002ffffffff00000008fffffffe0000000000000008fffffffe0000000100000008fffffffefffffffe00000008ffffffffffffffff00000008ffffffff0000000000000008ffffffff0000000100000008ffffffff0000000200000008fffffffffffffffe0000000800000000ffffffff0000000800000000000000000000000800000000000000010000000800000000000000020000000800000000fffffffe0000000800000001ffffffff0000000800000001000000000000000800000001000000010000000800000001000000020000000800000001ffffffff0000000800000002000000000000000800000002000000010000000800000002ffffffff00000009fffffffe0000000000000009fffffffe0000000100000009fffffffefffffffe00000009ffffffffffffffff00000009ffffffff0000000000000009ffffffff0000000100000009ffffffff0000000200000009fffffffffffffffe0000000900000000ffffffff0000000900000000000000000000000900000000000000010000000900000000000000020000000900000000fffffffe0000000900000001ffffffff0000000900000001000000000000000900000001000000010000000900000001000000020000000900000001ffffffff0000000900000002000000000000000900000002000000010000000900000002000000000000000affffffffffffffff0000000a00000000000000000000000a00000000000000010000000a00000000000000000000000a00000001000000000000000bffffffffffffffff0000000b00000000000000000000000b00000000000000010000000b00000000000000000000000b00000001";
  bytes constant MANGROVE_RANDOM =
    hex"ffffffff00000006ffffffff0000000100000006ffffffffffffffff0000000600000001000000010000000600000001fffffffe00000008fffffffe0000000200000008fffffffefffffffe0000000800000002000000020000000800000002ffffffff0000000affffffff000000010000000affffffffffffffff0000000a00000001000000010000000a00000001";
}

struct TreeData {
  ObjectTypeId logType;
  ObjectTypeId leafType;
  uint32 trunkHeight;
}

library TreeLib {
  /* decode blob → Vec3[] */
  function _loadLeaves(bytes memory blob) private pure returns (Vec3[] memory out) {
    uint256 words = blob.length / 12;
    out = new Vec3[](words);

    assembly {
      let src := add(blob, 32) // skip length
      let dst := add(out, 32)

      for { let i := 0 } lt(i, words) { i := add(i, 1) } {
        let w := mload(add(src, mul(i, 12))) // 12‑byte chunk in low bytes
        w := shr(160, w) // shift to low 96 bits
        mstore(dst, w) // Vec3.wrap(uint96)
        dst := add(dst, 32)
      }
    }
  }

  function getTreeData(ObjectTypeId objectType) internal pure returns (TreeData memory) {
    if (objectType == ObjectTypes.OakSapling) {
      return TreeData({ logType: ObjectTypes.OakLog, leafType: ObjectTypes.OakLeaf, trunkHeight: 5 });
    }
    if (objectType == ObjectTypes.BirchSapling) {
      return TreeData({ logType: ObjectTypes.BirchLog, leafType: ObjectTypes.BirchLeaf, trunkHeight: 7 });
    }
    if (objectType == ObjectTypes.JungleSapling) {
      return TreeData({ logType: ObjectTypes.JungleLog, leafType: ObjectTypes.JungleLeaf, trunkHeight: 12 });
    }
    if (objectType == ObjectTypes.SakuraSapling) {
      return TreeData({ logType: ObjectTypes.SakuraLog, leafType: ObjectTypes.SakuraLeaf, trunkHeight: 6 });
    }
    if (objectType == ObjectTypes.AcaciaSapling) {
      return TreeData({ logType: ObjectTypes.AcaciaLog, leafType: ObjectTypes.AcaciaLeaf, trunkHeight: 6 });
    }
    if (objectType == ObjectTypes.SpruceSapling) {
      return TreeData({ logType: ObjectTypes.SpruceLog, leafType: ObjectTypes.SpruceLeaf, trunkHeight: 9 });
    }
    if (objectType == ObjectTypes.DarkOakSapling) {
      return TreeData({ logType: ObjectTypes.DarkOakLog, leafType: ObjectTypes.DarkOakLeaf, trunkHeight: 6 });
    }
    if (objectType == ObjectTypes.MangroveSapling) {
      return TreeData({ logType: ObjectTypes.MangroveLog, leafType: ObjectTypes.MangroveLeaf, trunkHeight: 8 });
    }
    revert("Tree type not supported");
  }

  function getLeafCoords(ObjectTypeId objectType)
    internal
    pure
    returns (Vec3[] memory fixedLeaves, Vec3[] memory randomLeaves)
  {
    if (objectType == ObjectTypes.OakSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.OAK_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.OAK_RANDOM);
    } else if (objectType == ObjectTypes.BirchSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.BIRCH_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.BIRCH_RANDOM);
    } else if (objectType == ObjectTypes.JungleSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.JUNGLE_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.JUNGLE_RANDOM);
    } else if (objectType == ObjectTypes.SakuraSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.SAKURA_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.SAKURA_RANDOM);
    } else if (objectType == ObjectTypes.AcaciaSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.ACACIA_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.ACACIA_RANDOM);
    } else if (objectType == ObjectTypes.SpruceSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.SPRUCE_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.SPRUCE_RANDOM);
    } else if (objectType == ObjectTypes.DarkOakSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.DARKOAK_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.DARKOAK_RANDOM);
    } else if (objectType == ObjectTypes.MangroveSapling) {
      fixedLeaves = _loadLeaves(TreeBlobs.MANGROVE_FIXED);
      randomLeaves = _loadLeaves(TreeBlobs.MANGROVE_RANDOM);
    } else {
      revert("Tree type not supported");
    }
  }
}
