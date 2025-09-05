// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

// FixedPointMathLib wrapper
library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return FixedPointMathLib.max(a, b);
  }

  function max(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
    return max(a, max(b, c));
  }

  function min(uint128 a, uint128 b) internal pure returns (uint128) {
    return uint128(FixedPointMathLib.min(a, b));
  }

  function dist(int128 a, int128 b) internal pure returns (uint128) {
    return uint128(FixedPointMathLib.dist(a, b));
  }

  function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
    return FixedPointMathLib.divUp(a, b);
  }

  function abs(int256 a) internal pure returns (uint256) {
    return FixedPointMathLib.abs(a);
  }

  function sign(int256 x) external pure returns (int8) {
    unchecked {
      return int8(((0 < x) ? 1 : 0) - ((x < 0) ? 1 : 0));
    }
  }
}
