// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* 8-bit CHD helper with packed A */
library PerfectHashLib {
  /**
   * @param id       key (object id)
   * @param S        slot count
   * @param packedA  A0 | A1<<16 | A2<<32
   * @param G0-G3    packed g[] words (unused = 0)
   */
  function slot(uint16 id, uint8 S, uint48 packedA, uint256 G0, uint256 G1, uint256 G2, uint256 G3)
    internal
    pure
    returns (uint8 _slot)
  {
    /// @solidity memory-safe-assembly
    assembly {
      // g[idx]
      function gByte(idx, g0, g1, g2, g3) -> g {
        let off := and(idx, 0x1f) // idx % 32
        let be := sub(31, off) // flip -> big-endian
        switch shr(5, idx)
        // idx / 32   0…3
        case 0 { g := byte(be, g0) }
        case 1 { g := byte(be, g1) }
        case 2 { g := byte(be, g2) }
        default { g := byte(be, g3) } // 96-127
      }

      // unpack 16-bit multipliers
      let A0 := and(packedA, 0xFFFF)
      let A1 := and(shr(16, packedA), 0xFFFF)
      let A2 := and(shr(32, packedA), 0xFFFF)

      // h0 = (id*A0)>>8 % S
      let h := and(shr(8, mul(id, A0)), 0xff)
      _slot := gByte(mod(h, S), G0, G1, G2, G3)

      // h1 = (id*A1)>>8 % S
      h := and(shr(8, mul(id, A1)), 0xff)
      _slot := add(_slot, gByte(mod(h, S), G0, G1, G2, G3))

      // h2 = (id*A2)>>8 % S
      h := and(shr(8, mul(id, A2)), 0xff)
      _slot := add(_slot, gByte(mod(h, S), G0, G1, G2, G3))

      _slot := mod(_slot, S) // final slot
    }
  }

  /**
   * @param id       key (object id)
   * @param S        slot count
   * @param packedA  A0 | A1<<16 | A2<<32
   * @param G0-G3    packed g[] words (unused = 0)
   */
  function slot2(uint16 id, uint8 S, uint48 packedA, uint256 G0, uint256 G1, uint256 G2, uint256 G3)
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
