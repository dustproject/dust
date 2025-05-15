// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* 8-bit CHD helper with packed A */
library PerfectHashLib {
  function slot(uint16 id, uint8 S, uint48 packedA, uint256 G0, uint256 G1, uint256 G2) internal pure returns (uint8) {
    return slot(id, S, packedA, G0, G1, G2, 0);
  }

  function slot(uint16 id, uint8 S, uint48 packedA, uint256 G0, uint256 G1) internal pure returns (uint8) {
    return slot(id, S, packedA, G0, G1, 0, 0);
  }

  function slot(uint16 id, uint8 S, uint48 packedA, uint256 G0) internal pure returns (uint8) {
    return slot(id, S, packedA, G0, 0, 0, 0);
  }

  /**
   * @param id       key (object id)
   * @param S        slot count
   * @param packedA  A0 | A1<<16 | A2<<32
   * @param G0-G3    packed g[] words (unused = 0)
   */
  function slot(uint16 id, uint8 S, uint48 packedA, uint256 G0, uint256 G1, uint256 G2, uint256 G3)
    internal
    pure
    returns (uint8)
  {
    unchecked {
      uint8 h0 = _h(id, uint16(packedA)) % S;
      uint8 h1 = _h(id, uint16(packedA >> 16)) % S;
      uint8 h2 = _h(id, uint16(packedA >> 32)) % S;
      return uint8(_g(G0, G1, G2, G3, h0) + _g(G0, G1, G2, G3, h1) + _g(G0, G1, G2, G3, h2)) % S;
    }
  }

  /* 16-bit multiply-shift hash (5 gas) */
  function _h(uint16 x, uint16 A) private pure returns (uint8) {
    return uint8(uint32(x) * A >> 8);
  }

  /* fetch g[i] (8-bit) from up to four 32-byte words */
  function _g(uint256 G0, uint256 G1, uint256 G2, uint256 G3, uint8 i) private pure returns (uint256) {
    if (i < 32) return uint8(G0 >> (i * 8));
    if (i < 64) return uint8(G1 >> ((i - 32) * 8));
    if (i < 96) return uint8(G2 >> ((i - 64) * 8));
    /* i < 128 */
    return uint8(G3 >> ((i - 96) * 8));
  }
}
