// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

library PerfectHashLib {
  function slot(uint16 id, uint8 S, uint16 A0, uint16 A1, uint16 A2, uint256 GPACK) internal pure returns (uint8) {
    unchecked {
      return uint8(_g(GPACK, _h(id, A0) % S) + _g(GPACK, _h(id, A1) % S) + _g(GPACK, _h(id, A2) % S)) % S;
    }
  }

  function _h(uint16 x, uint16 A) private pure returns (uint8) {
    return uint8(uint32(x) * A >> 8);
  }

  function _g(uint256 gpack, uint8 i) private pure returns (uint8) {
    return uint8((gpack >> (i << 1)) & 3);
  }
}
