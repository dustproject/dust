// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type Orientation is uint8;

library OrientationLib {
  bytes18 constant PERMUTATIONS_BYTES = hex"000102000201010002010200020001020100";
  bytes24 constant REFLECTIONS_BYTES = hex"000000010000000100010100000001010001000101010101";

  function getPermutation(Orientation orientation) internal pure returns (uint8 a, uint8 b, uint8 c) {
    /// @solidity memory-safe-assembly
    assembly {
      let permIdx := shr(3, orientation)
      let offset := mul(permIdx, 3)
      a := byte(offset, PERMUTATIONS_BYTES)
      b := byte(add(offset, 1), PERMUTATIONS_BYTES)
      c := byte(add(offset, 2), PERMUTATIONS_BYTES)
    }
  }

  function getReflection(Orientation orientation) internal pure returns (bool rx, bool ry, bool rz) {
    /// @solidity memory-safe-assembly
    assembly {
      let reflIdx := and(orientation, 7)
      let offset := mul(reflIdx, 3)
      rx := byte(offset, REFLECTIONS_BYTES)
      ry := byte(add(offset, 1), REFLECTIONS_BYTES)
      rz := byte(add(offset, 2), REFLECTIONS_BYTES)
    }
  }
}

function eq(Orientation self, Orientation other) pure returns (bool) {
  return Orientation.unwrap(self) == Orientation.unwrap(other);
}

using { eq as == } for Orientation global;
using OrientationLib for Orientation global;
