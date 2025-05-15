// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Vec3, vec3 } from "./Vec3.sol";
import { Direction } from "./codegen/common.sol";
import { IMachineSystem } from "./codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "./codegen/world/ITransferSystem.sol";

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

uint16 constant BLOCK_CATEGORY_COUNT = 256 / 2; // 128

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  // Meta Category Masks (fits within uint256; mask bit k set if raw category ID k belongs)
  uint256 constant BLOCK_MASK = uint256(type(uint128).max);
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
  ObjectType constant Null = ObjectType.wrap(0);
  ObjectType constant Air = ObjectType.wrap(1);
  ObjectType constant Water = ObjectType.wrap(2);
  ObjectType constant Stone = ObjectType.wrap(3);
  ObjectType constant Bedrock = ObjectType.wrap(4);
  ObjectType constant Deepslate = ObjectType.wrap(5);
  ObjectType constant Granite = ObjectType.wrap(6);
  ObjectType constant Tuff = ObjectType.wrap(7);
  ObjectType constant Calcite = ObjectType.wrap(8);
  ObjectType constant Basalt = ObjectType.wrap(9);
  ObjectType constant SmoothBasalt = ObjectType.wrap(10);
  ObjectType constant Andesite = ObjectType.wrap(11);
  ObjectType constant Diorite = ObjectType.wrap(12);
  ObjectType constant Cobblestone = ObjectType.wrap(13);
  ObjectType constant MossyCobblestone = ObjectType.wrap(14);
  ObjectType constant Obsidian = ObjectType.wrap(15);
  ObjectType constant Dripstone = ObjectType.wrap(16);
  ObjectType constant Blackstone = ObjectType.wrap(17);
  ObjectType constant CobbledDeepslate = ObjectType.wrap(18);
  ObjectType constant Amethyst = ObjectType.wrap(19);
  ObjectType constant Glowstone = ObjectType.wrap(20);
  ObjectType constant Grass = ObjectType.wrap(21);
  ObjectType constant Dirt = ObjectType.wrap(22);
  ObjectType constant Moss = ObjectType.wrap(23);
  ObjectType constant Podzol = ObjectType.wrap(24);
  ObjectType constant DirtPath = ObjectType.wrap(25);
  ObjectType constant Mud = ObjectType.wrap(26);
  ObjectType constant PackedMud = ObjectType.wrap(27);
  ObjectType constant Farmland = ObjectType.wrap(28);
  ObjectType constant WetFarmland = ObjectType.wrap(29);
  ObjectType constant UnrevealedOre = ObjectType.wrap(30);
  ObjectType constant CoalOre = ObjectType.wrap(31);
  ObjectType constant CopperOre = ObjectType.wrap(32);
  ObjectType constant IronOre = ObjectType.wrap(33);
  ObjectType constant GoldOre = ObjectType.wrap(34);
  ObjectType constant DiamondOre = ObjectType.wrap(35);
  ObjectType constant NeptuniumOre = ObjectType.wrap(36);
  ObjectType constant Gravel = ObjectType.wrap(37);
  ObjectType constant Sand = ObjectType.wrap(38);
  ObjectType constant RedSand = ObjectType.wrap(39);
  ObjectType constant Sandstone = ObjectType.wrap(40);
  ObjectType constant RedSandstone = ObjectType.wrap(41);
  ObjectType constant Clay = ObjectType.wrap(42);
  ObjectType constant AnyTerracotta = ObjectType.wrap(43);
  ObjectType constant Terracotta = ObjectType.wrap(44);
  ObjectType constant BrownTerracotta = ObjectType.wrap(45);
  ObjectType constant OrangeTerracotta = ObjectType.wrap(46);
  ObjectType constant WhiteTerracotta = ObjectType.wrap(47);
  ObjectType constant LightGrayTerracotta = ObjectType.wrap(48);
  ObjectType constant YellowTerracotta = ObjectType.wrap(49);
  ObjectType constant RedTerracotta = ObjectType.wrap(50);
  ObjectType constant LightBlueTerracotta = ObjectType.wrap(51);
  ObjectType constant CyanTerracotta = ObjectType.wrap(52);
  ObjectType constant BlackTerracotta = ObjectType.wrap(53);
  ObjectType constant PurpleTerracotta = ObjectType.wrap(54);
  ObjectType constant BlueTerracotta = ObjectType.wrap(55);
  ObjectType constant MagentaTerracotta = ObjectType.wrap(56);
  ObjectType constant AnyLog = ObjectType.wrap(57);
  ObjectType constant OakLog = ObjectType.wrap(58);
  ObjectType constant BirchLog = ObjectType.wrap(59);
  ObjectType constant JungleLog = ObjectType.wrap(60);
  ObjectType constant SakuraLog = ObjectType.wrap(61);
  ObjectType constant AcaciaLog = ObjectType.wrap(62);
  ObjectType constant SpruceLog = ObjectType.wrap(63);
  ObjectType constant DarkOakLog = ObjectType.wrap(64);
  ObjectType constant MangroveLog = ObjectType.wrap(65);
  ObjectType constant AnyLeaf = ObjectType.wrap(66);
  ObjectType constant OakLeaf = ObjectType.wrap(67);
  ObjectType constant BirchLeaf = ObjectType.wrap(68);
  ObjectType constant JungleLeaf = ObjectType.wrap(69);
  ObjectType constant SakuraLeaf = ObjectType.wrap(70);
  ObjectType constant SpruceLeaf = ObjectType.wrap(71);
  ObjectType constant AcaciaLeaf = ObjectType.wrap(72);
  ObjectType constant DarkOakLeaf = ObjectType.wrap(73);
  ObjectType constant AzaleaLeaf = ObjectType.wrap(74);
  ObjectType constant FloweringAzaleaLeaf = ObjectType.wrap(75);
  ObjectType constant MangroveLeaf = ObjectType.wrap(76);
  ObjectType constant MangroveRoots = ObjectType.wrap(77);
  ObjectType constant MuddyMangroveRoots = ObjectType.wrap(78);
  ObjectType constant AzaleaFlower = ObjectType.wrap(79);
  ObjectType constant BellFlower = ObjectType.wrap(80);
  ObjectType constant DandelionFlower = ObjectType.wrap(81);
  ObjectType constant DaylilyFlower = ObjectType.wrap(82);
  ObjectType constant LilacFlower = ObjectType.wrap(83);
  ObjectType constant RoseFlower = ObjectType.wrap(84);
  ObjectType constant FireFlower = ObjectType.wrap(85);
  ObjectType constant MorninggloryFlower = ObjectType.wrap(86);
  ObjectType constant PeonyFlower = ObjectType.wrap(87);
  ObjectType constant Ultraviolet = ObjectType.wrap(88);
  ObjectType constant SunFlower = ObjectType.wrap(89);
  ObjectType constant FlyTrap = ObjectType.wrap(90);
  ObjectType constant FescueGrass = ObjectType.wrap(91);
  ObjectType constant SwitchGrass = ObjectType.wrap(92);
  ObjectType constant VinesBush = ObjectType.wrap(93);
  ObjectType constant IvyVine = ObjectType.wrap(94);
  ObjectType constant HempBush = ObjectType.wrap(95);
  ObjectType constant GoldenMushroom = ObjectType.wrap(96);
  ObjectType constant RedMushroom = ObjectType.wrap(97);
  ObjectType constant CoffeeBush = ObjectType.wrap(98);
  ObjectType constant StrawberryBush = ObjectType.wrap(99);
  ObjectType constant RaspberryBush = ObjectType.wrap(100);
  ObjectType constant Wheat = ObjectType.wrap(101);
  ObjectType constant CottonBush = ObjectType.wrap(102);
  ObjectType constant Pumpkin = ObjectType.wrap(103);
  ObjectType constant Melon = ObjectType.wrap(104);
  ObjectType constant RedMushroomBlock = ObjectType.wrap(105);
  ObjectType constant BrownMushroomBlock = ObjectType.wrap(106);
  ObjectType constant MushroomStem = ObjectType.wrap(107);
  ObjectType constant BambooBush = ObjectType.wrap(108);
  ObjectType constant Cactus = ObjectType.wrap(109);
  ObjectType constant Coral = ObjectType.wrap(110);
  ObjectType constant SeaAnemone = ObjectType.wrap(111);
  ObjectType constant Algae = ObjectType.wrap(112);
  ObjectType constant HornCoralBlock = ObjectType.wrap(113);
  ObjectType constant FireCoralBlock = ObjectType.wrap(114);
  ObjectType constant TubeCoralBlock = ObjectType.wrap(115);
  ObjectType constant BubbleCoralBlock = ObjectType.wrap(116);
  ObjectType constant BrainCoralBlock = ObjectType.wrap(117);
  ObjectType constant Snow = ObjectType.wrap(118);
  ObjectType constant Ice = ObjectType.wrap(119);
  ObjectType constant Magma = ObjectType.wrap(120);
  ObjectType constant SpiderWeb = ObjectType.wrap(121);
  ObjectType constant Bone = ObjectType.wrap(122);
  ObjectType constant TextSign = ObjectType.wrap(123);
  ObjectType constant AnyPlank = ObjectType.wrap(124);
  ObjectType constant OakPlanks = ObjectType.wrap(125);
  ObjectType constant BirchPlanks = ObjectType.wrap(126);
  ObjectType constant JunglePlanks = ObjectType.wrap(127);
  ObjectType constant SakuraPlanks = ObjectType.wrap(128);
  ObjectType constant SprucePlanks = ObjectType.wrap(129);
  ObjectType constant AcaciaPlanks = ObjectType.wrap(130);
  ObjectType constant DarkOakPlanks = ObjectType.wrap(131);
  ObjectType constant MangrovePlanks = ObjectType.wrap(132);
  ObjectType constant CopperBlock = ObjectType.wrap(133);
  ObjectType constant IronBlock = ObjectType.wrap(134);
  ObjectType constant GoldBlock = ObjectType.wrap(135);
  ObjectType constant DiamondBlock = ObjectType.wrap(136);
  ObjectType constant NeptuniumBlock = ObjectType.wrap(137);
  ObjectType constant WheatSeed = ObjectType.wrap(138);
  ObjectType constant PumpkinSeed = ObjectType.wrap(139);
  ObjectType constant MelonSeed = ObjectType.wrap(140);
  ObjectType constant OakSapling = ObjectType.wrap(141);
  ObjectType constant BirchSapling = ObjectType.wrap(142);
  ObjectType constant JungleSapling = ObjectType.wrap(143);
  ObjectType constant SakuraSapling = ObjectType.wrap(144);
  ObjectType constant AcaciaSapling = ObjectType.wrap(145);
  ObjectType constant SpruceSapling = ObjectType.wrap(146);
  ObjectType constant DarkOakSapling = ObjectType.wrap(147);
  ObjectType constant MangroveSapling = ObjectType.wrap(148);
  ObjectType constant ForceField = ObjectType.wrap(149);
  ObjectType constant Chest = ObjectType.wrap(150);
  ObjectType constant SpawnTile = ObjectType.wrap(151);
  ObjectType constant Bed = ObjectType.wrap(152);
  ObjectType constant Workbench = ObjectType.wrap(153);
  ObjectType constant Powerstone = ObjectType.wrap(154);
  ObjectType constant Furnace = ObjectType.wrap(155);
  ObjectType constant Torch = ObjectType.wrap(156);
  ObjectType constant WoodenPick = ObjectType.wrap(157);
  ObjectType constant CopperPick = ObjectType.wrap(158);
  ObjectType constant IronPick = ObjectType.wrap(159);
  ObjectType constant GoldPick = ObjectType.wrap(160);
  ObjectType constant DiamondPick = ObjectType.wrap(161);
  ObjectType constant NeptuniumPick = ObjectType.wrap(162);
  ObjectType constant WoodenAxe = ObjectType.wrap(163);
  ObjectType constant CopperAxe = ObjectType.wrap(164);
  ObjectType constant IronAxe = ObjectType.wrap(165);
  ObjectType constant GoldAxe = ObjectType.wrap(166);
  ObjectType constant DiamondAxe = ObjectType.wrap(167);
  ObjectType constant NeptuniumAxe = ObjectType.wrap(168);
  ObjectType constant WoodenWhacker = ObjectType.wrap(169);
  ObjectType constant CopperWhacker = ObjectType.wrap(170);
  ObjectType constant IronWhacker = ObjectType.wrap(171);
  ObjectType constant WoodenHoe = ObjectType.wrap(172);
  ObjectType constant GoldBar = ObjectType.wrap(173);
  ObjectType constant IronBar = ObjectType.wrap(174);
  ObjectType constant Diamond = ObjectType.wrap(175);
  ObjectType constant NeptuniumBar = ObjectType.wrap(176);
  ObjectType constant Bucket = ObjectType.wrap(177);
  ObjectType constant WaterBucket = ObjectType.wrap(178);
  ObjectType constant WheatSlop = ObjectType.wrap(179);
  ObjectType constant PumpkinSoup = ObjectType.wrap(180);
  ObjectType constant MelonSmoothie = ObjectType.wrap(181);
  ObjectType constant Battery = ObjectType.wrap(182);
  ObjectType constant Player = ObjectType.wrap(183);
  ObjectType constant Fragment = ObjectType.wrap(184);
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

  function isNonSolid(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000000000000000000000000000000000000006)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isAny(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000000010000000000000040200080000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isBlock(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000ffffffffffffffffffffffffffffffffffffff8)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isOre(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000000000000000000000000000001fc0000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isLog(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000000000000000000000000000003fc00000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isLeaf(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000000000000000000000000007ff80000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isPlank(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000001fe0000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isSeed(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x00000000000000000000000000001c0000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isSapling(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000000001fe00000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isSmartEntity(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x00000000000000000100000001e0000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isStation(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000e00000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isPick(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000007e000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isAxe(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000001f80000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isHoe(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000010000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isWhacker(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000e000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isOreBar(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x00000000000000000001e0000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isFood(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000003800000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isFuel(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000004000000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isPlayer(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000008000000000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function hasExtraDrops(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000000000003ffff8007ff80000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function hasAxeMultiplier(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x00000000000000000000000013c0001fe8003f8000007ffbfc00000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function hasPickMultiplier(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000c2003e0000000000000000001fff81f801ffff8)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isPassThrough(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000000101ffc000001c07fffff80000000000000000006)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isGrowable(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000000000001ffc0000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isUniqueObject(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000061fffe1a0000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isTool(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x000000000000000000001fffe000000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isTillable(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000000000000000000000000000000000000600000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  function isMachine(ObjectType self) internal pure returns (bool _is) {
    /// @solidity memory-safe-assembly
    assembly {
      let ix := shr(3, self) // byte index = id / 8
      if lt(ix, 32) {
        let bits := byte(sub(31, ix), 0x0000000000000000000000000020000000000000000000000000000000000000)
        let mask := shl(and(self, 7), 1) // 1 << (id & 7)
        _is := eq(and(bits, mask), mask) // 1 if set
      }
    }
  }

  // Category getters
  function getNonSolidTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water];
  }

  function getAnyTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.AnyPlank, ObjectTypes.AnyLog, ObjectTypes.AnyLeaf, ObjectTypes.AnyTerracotta];
  }

  function getBlockTypes() internal pure returns (ObjectType[153] memory) {
    return [
      ObjectTypes.Magma,
      ObjectTypes.Stone,
      ObjectTypes.Bedrock,
      ObjectTypes.Deepslate,
      ObjectTypes.Granite,
      ObjectTypes.Tuff,
      ObjectTypes.Calcite,
      ObjectTypes.Basalt,
      ObjectTypes.SmoothBasalt,
      ObjectTypes.Andesite,
      ObjectTypes.Diorite,
      ObjectTypes.Cobblestone,
      ObjectTypes.MossyCobblestone,
      ObjectTypes.Obsidian,
      ObjectTypes.Dripstone,
      ObjectTypes.Blackstone,
      ObjectTypes.CobbledDeepslate,
      ObjectTypes.Amethyst,
      ObjectTypes.Glowstone,
      ObjectTypes.Grass,
      ObjectTypes.Dirt,
      ObjectTypes.Moss,
      ObjectTypes.Podzol,
      ObjectTypes.DirtPath,
      ObjectTypes.Mud,
      ObjectTypes.PackedMud,
      ObjectTypes.Farmland,
      ObjectTypes.WetFarmland,
      ObjectTypes.Snow,
      ObjectTypes.Ice,
      ObjectTypes.UnrevealedOre,
      ObjectTypes.CoalOre,
      ObjectTypes.CopperOre,
      ObjectTypes.IronOre,
      ObjectTypes.GoldOre,
      ObjectTypes.DiamondOre,
      ObjectTypes.NeptuniumOre,
      ObjectTypes.Gravel,
      ObjectTypes.Sand,
      ObjectTypes.RedSand,
      ObjectTypes.Sandstone,
      ObjectTypes.RedSandstone,
      ObjectTypes.Clay,
      ObjectTypes.AnyTerracotta,
      ObjectTypes.Terracotta,
      ObjectTypes.BrownTerracotta,
      ObjectTypes.OrangeTerracotta,
      ObjectTypes.WhiteTerracotta,
      ObjectTypes.LightGrayTerracotta,
      ObjectTypes.YellowTerracotta,
      ObjectTypes.RedTerracotta,
      ObjectTypes.LightBlueTerracotta,
      ObjectTypes.CyanTerracotta,
      ObjectTypes.BlackTerracotta,
      ObjectTypes.PurpleTerracotta,
      ObjectTypes.BlueTerracotta,
      ObjectTypes.MagentaTerracotta,
      ObjectTypes.AnyLog,
      ObjectTypes.OakLog,
      ObjectTypes.BirchLog,
      ObjectTypes.JungleLog,
      ObjectTypes.SakuraLog,
      ObjectTypes.AcaciaLog,
      ObjectTypes.SpruceLog,
      ObjectTypes.DarkOakLog,
      ObjectTypes.MangroveLog,
      ObjectTypes.AnyLeaf,
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.MangroveRoots,
      ObjectTypes.MuddyMangroveRoots,
      ObjectTypes.AzaleaFlower,
      ObjectTypes.BellFlower,
      ObjectTypes.DandelionFlower,
      ObjectTypes.DaylilyFlower,
      ObjectTypes.LilacFlower,
      ObjectTypes.RoseFlower,
      ObjectTypes.FireFlower,
      ObjectTypes.MorninggloryFlower,
      ObjectTypes.PeonyFlower,
      ObjectTypes.Ultraviolet,
      ObjectTypes.SunFlower,
      ObjectTypes.FlyTrap,
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.VinesBush,
      ObjectTypes.IvyVine,
      ObjectTypes.HempBush,
      ObjectTypes.Coral,
      ObjectTypes.SeaAnemone,
      ObjectTypes.Algae,
      ObjectTypes.HornCoralBlock,
      ObjectTypes.FireCoralBlock,
      ObjectTypes.TubeCoralBlock,
      ObjectTypes.BubbleCoralBlock,
      ObjectTypes.BrainCoralBlock,
      ObjectTypes.SpiderWeb,
      ObjectTypes.Bone,
      ObjectTypes.GoldenMushroom,
      ObjectTypes.RedMushroom,
      ObjectTypes.CoffeeBush,
      ObjectTypes.StrawberryBush,
      ObjectTypes.RaspberryBush,
      ObjectTypes.Wheat,
      ObjectTypes.CottonBush,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.RedMushroomBlock,
      ObjectTypes.BrownMushroomBlock,
      ObjectTypes.MushroomStem,
      ObjectTypes.BambooBush,
      ObjectTypes.Cactus,
      ObjectTypes.AnyPlank,
      ObjectTypes.OakPlanks,
      ObjectTypes.BirchPlanks,
      ObjectTypes.JunglePlanks,
      ObjectTypes.SakuraPlanks,
      ObjectTypes.SprucePlanks,
      ObjectTypes.AcaciaPlanks,
      ObjectTypes.DarkOakPlanks,
      ObjectTypes.MangrovePlanks,
      ObjectTypes.CopperBlock,
      ObjectTypes.IronBlock,
      ObjectTypes.GoldBlock,
      ObjectTypes.DiamondBlock,
      ObjectTypes.NeptuniumBlock,
      ObjectTypes.WheatSeed,
      ObjectTypes.PumpkinSeed,
      ObjectTypes.MelonSeed,
      ObjectTypes.OakSapling,
      ObjectTypes.BirchSapling,
      ObjectTypes.JungleSapling,
      ObjectTypes.SakuraSapling,
      ObjectTypes.AcaciaSapling,
      ObjectTypes.SpruceSapling,
      ObjectTypes.DarkOakSapling,
      ObjectTypes.MangroveSapling,
      ObjectTypes.Furnace,
      ObjectTypes.Workbench,
      ObjectTypes.Powerstone,
      ObjectTypes.ForceField,
      ObjectTypes.Chest,
      ObjectTypes.SpawnTile,
      ObjectTypes.Bed,
      ObjectTypes.TextSign
    ];
  }

  function getOreTypes() internal pure returns (ObjectType[7] memory) {
    return [
      ObjectTypes.UnrevealedOre,
      ObjectTypes.CoalOre,
      ObjectTypes.CopperOre,
      ObjectTypes.IronOre,
      ObjectTypes.GoldOre,
      ObjectTypes.DiamondOre,
      ObjectTypes.NeptuniumOre
    ];
  }

  function getLogTypes() internal pure returns (ObjectType[8] memory) {
    return [
      ObjectTypes.OakLog,
      ObjectTypes.BirchLog,
      ObjectTypes.JungleLog,
      ObjectTypes.SakuraLog,
      ObjectTypes.AcaciaLog,
      ObjectTypes.SpruceLog,
      ObjectTypes.DarkOakLog,
      ObjectTypes.MangroveLog
    ];
  }

  function getLeafTypes() internal pure returns (ObjectType[12] memory) {
    return [
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.MangroveRoots,
      ObjectTypes.MuddyMangroveRoots
    ];
  }

  function getPlankTypes() internal pure returns (ObjectType[8] memory) {
    return [
      ObjectTypes.OakPlanks,
      ObjectTypes.BirchPlanks,
      ObjectTypes.JunglePlanks,
      ObjectTypes.SakuraPlanks,
      ObjectTypes.SprucePlanks,
      ObjectTypes.AcaciaPlanks,
      ObjectTypes.DarkOakPlanks,
      ObjectTypes.MangrovePlanks
    ];
  }

  function getSeedTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed];
  }

  function getSaplingTypes() internal pure returns (ObjectType[8] memory) {
    return [
      ObjectTypes.OakSapling,
      ObjectTypes.BirchSapling,
      ObjectTypes.JungleSapling,
      ObjectTypes.SakuraSapling,
      ObjectTypes.AcaciaSapling,
      ObjectTypes.SpruceSapling,
      ObjectTypes.DarkOakSapling,
      ObjectTypes.MangroveSapling
    ];
  }

  function getSmartEntityTypes() internal pure returns (ObjectType[5] memory) {
    return [ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.Bed, ObjectTypes.Fragment];
  }

  function getStationTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.Furnace];
  }

  function getPickTypes() internal pure returns (ObjectType[6] memory) {
    return [
      ObjectTypes.WoodenPick,
      ObjectTypes.CopperPick,
      ObjectTypes.IronPick,
      ObjectTypes.GoldPick,
      ObjectTypes.DiamondPick,
      ObjectTypes.NeptuniumPick
    ];
  }

  function getAxeTypes() internal pure returns (ObjectType[6] memory) {
    return [
      ObjectTypes.WoodenAxe,
      ObjectTypes.CopperAxe,
      ObjectTypes.IronAxe,
      ObjectTypes.GoldAxe,
      ObjectTypes.DiamondAxe,
      ObjectTypes.NeptuniumAxe
    ];
  }

  function getHoeTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.WoodenHoe];
  }

  function getWhackerTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WoodenWhacker, ObjectTypes.CopperWhacker, ObjectTypes.IronWhacker];
  }

  function getOreBarTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.GoldBar, ObjectTypes.IronBar, ObjectTypes.Diamond, ObjectTypes.NeptuniumBar];
  }

  function getFoodTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WheatSlop, ObjectTypes.PumpkinSoup, ObjectTypes.MelonSmoothie];
  }

  function getFuelTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Battery];
  }

  function getPlayerTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Player];
  }

  function getExtraDropsTypes() internal pure returns (ObjectType[31] memory) {
    return [
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.MangroveRoots,
      ObjectTypes.MuddyMangroveRoots,
      ObjectTypes.GoldenMushroom,
      ObjectTypes.RedMushroom,
      ObjectTypes.CoffeeBush,
      ObjectTypes.StrawberryBush,
      ObjectTypes.RaspberryBush,
      ObjectTypes.Wheat,
      ObjectTypes.CottonBush,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.RedMushroomBlock,
      ObjectTypes.BrownMushroomBlock,
      ObjectTypes.MushroomStem,
      ObjectTypes.BambooBush,
      ObjectTypes.Cactus,
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.VinesBush,
      ObjectTypes.IvyVine,
      ObjectTypes.HempBush
    ];
  }

  function gethasAxeMultiplierTypes() internal pure returns (ObjectType[41] memory) {
    return [
      ObjectTypes.OakLog,
      ObjectTypes.BirchLog,
      ObjectTypes.JungleLog,
      ObjectTypes.SakuraLog,
      ObjectTypes.AcaciaLog,
      ObjectTypes.SpruceLog,
      ObjectTypes.DarkOakLog,
      ObjectTypes.MangroveLog,
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.MangroveRoots,
      ObjectTypes.MuddyMangroveRoots,
      ObjectTypes.OakPlanks,
      ObjectTypes.BirchPlanks,
      ObjectTypes.JunglePlanks,
      ObjectTypes.SakuraPlanks,
      ObjectTypes.SprucePlanks,
      ObjectTypes.AcaciaPlanks,
      ObjectTypes.DarkOakPlanks,
      ObjectTypes.MangrovePlanks,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.RedMushroomBlock,
      ObjectTypes.BrownMushroomBlock,
      ObjectTypes.MushroomStem,
      ObjectTypes.BambooBush,
      ObjectTypes.Cactus,
      ObjectTypes.Chest,
      ObjectTypes.Workbench,
      ObjectTypes.SpawnTile,
      ObjectTypes.Bed,
      ObjectTypes.TextSign,
      ObjectTypes.Torch
    ];
  }

  function gethasPickMultiplierTypes() internal pure returns (ObjectType[46] memory) {
    return [
      ObjectTypes.CoalOre,
      ObjectTypes.CopperOre,
      ObjectTypes.IronOre,
      ObjectTypes.GoldOre,
      ObjectTypes.DiamondOre,
      ObjectTypes.NeptuniumOre,
      ObjectTypes.Amethyst,
      ObjectTypes.Glowstone,
      ObjectTypes.Stone,
      ObjectTypes.Bedrock,
      ObjectTypes.Deepslate,
      ObjectTypes.Granite,
      ObjectTypes.Tuff,
      ObjectTypes.Calcite,
      ObjectTypes.Basalt,
      ObjectTypes.SmoothBasalt,
      ObjectTypes.Andesite,
      ObjectTypes.Diorite,
      ObjectTypes.Cobblestone,
      ObjectTypes.MossyCobblestone,
      ObjectTypes.Obsidian,
      ObjectTypes.Dripstone,
      ObjectTypes.Blackstone,
      ObjectTypes.CobbledDeepslate,
      ObjectTypes.AnyTerracotta,
      ObjectTypes.Terracotta,
      ObjectTypes.BrownTerracotta,
      ObjectTypes.OrangeTerracotta,
      ObjectTypes.WhiteTerracotta,
      ObjectTypes.LightGrayTerracotta,
      ObjectTypes.YellowTerracotta,
      ObjectTypes.RedTerracotta,
      ObjectTypes.LightBlueTerracotta,
      ObjectTypes.CyanTerracotta,
      ObjectTypes.BlackTerracotta,
      ObjectTypes.PurpleTerracotta,
      ObjectTypes.BlueTerracotta,
      ObjectTypes.MagentaTerracotta,
      ObjectTypes.CopperBlock,
      ObjectTypes.IronBlock,
      ObjectTypes.GoldBlock,
      ObjectTypes.DiamondBlock,
      ObjectTypes.NeptuniumBlock,
      ObjectTypes.Powerstone,
      ObjectTypes.Furnace,
      ObjectTypes.ForceField
    ];
  }

  function getPassThroughTypes() internal pure returns (ObjectType[41] memory) {
    return [
      ObjectTypes.Air,
      ObjectTypes.Water,
      ObjectTypes.AzaleaFlower,
      ObjectTypes.BellFlower,
      ObjectTypes.DandelionFlower,
      ObjectTypes.DaylilyFlower,
      ObjectTypes.LilacFlower,
      ObjectTypes.RoseFlower,
      ObjectTypes.FireFlower,
      ObjectTypes.MorninggloryFlower,
      ObjectTypes.PeonyFlower,
      ObjectTypes.Ultraviolet,
      ObjectTypes.SunFlower,
      ObjectTypes.FlyTrap,
      ObjectTypes.WheatSeed,
      ObjectTypes.PumpkinSeed,
      ObjectTypes.MelonSeed,
      ObjectTypes.OakSapling,
      ObjectTypes.BirchSapling,
      ObjectTypes.JungleSapling,
      ObjectTypes.SakuraSapling,
      ObjectTypes.AcaciaSapling,
      ObjectTypes.SpruceSapling,
      ObjectTypes.DarkOakSapling,
      ObjectTypes.MangroveSapling,
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.VinesBush,
      ObjectTypes.IvyVine,
      ObjectTypes.HempBush,
      ObjectTypes.GoldenMushroom,
      ObjectTypes.RedMushroom,
      ObjectTypes.CoffeeBush,
      ObjectTypes.StrawberryBush,
      ObjectTypes.RaspberryBush,
      ObjectTypes.Wheat,
      ObjectTypes.CottonBush,
      ObjectTypes.Coral,
      ObjectTypes.SeaAnemone,
      ObjectTypes.Algae,
      ObjectTypes.Torch
    ];
  }

  function getGrowableTypes() internal pure returns (ObjectType[11] memory) {
    return [
      ObjectTypes.WheatSeed,
      ObjectTypes.PumpkinSeed,
      ObjectTypes.MelonSeed,
      ObjectTypes.OakSapling,
      ObjectTypes.BirchSapling,
      ObjectTypes.JungleSapling,
      ObjectTypes.SakuraSapling,
      ObjectTypes.AcaciaSapling,
      ObjectTypes.SpruceSapling,
      ObjectTypes.DarkOakSapling,
      ObjectTypes.MangroveSapling
    ];
  }

  function getUniqueObjectTypes() internal pure returns (ObjectType[21] memory) {
    return [
      ObjectTypes.WoodenPick,
      ObjectTypes.CopperPick,
      ObjectTypes.IronPick,
      ObjectTypes.GoldPick,
      ObjectTypes.DiamondPick,
      ObjectTypes.NeptuniumPick,
      ObjectTypes.WoodenAxe,
      ObjectTypes.CopperAxe,
      ObjectTypes.IronAxe,
      ObjectTypes.GoldAxe,
      ObjectTypes.DiamondAxe,
      ObjectTypes.NeptuniumAxe,
      ObjectTypes.WoodenWhacker,
      ObjectTypes.CopperWhacker,
      ObjectTypes.IronWhacker,
      ObjectTypes.WoodenHoe,
      ObjectTypes.Bucket,
      ObjectTypes.WaterBucket,
      ObjectTypes.ForceField,
      ObjectTypes.Bed,
      ObjectTypes.SpawnTile
    ];
  }

  function getToolTypes() internal pure returns (ObjectType[16] memory) {
    return [
      ObjectTypes.WoodenPick,
      ObjectTypes.CopperPick,
      ObjectTypes.IronPick,
      ObjectTypes.GoldPick,
      ObjectTypes.DiamondPick,
      ObjectTypes.NeptuniumPick,
      ObjectTypes.WoodenAxe,
      ObjectTypes.CopperAxe,
      ObjectTypes.IronAxe,
      ObjectTypes.GoldAxe,
      ObjectTypes.DiamondAxe,
      ObjectTypes.NeptuniumAxe,
      ObjectTypes.WoodenWhacker,
      ObjectTypes.CopperWhacker,
      ObjectTypes.IronWhacker,
      ObjectTypes.WoodenHoe
    ];
  }

  function getTillableTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Dirt, ObjectTypes.Grass];
  }

  function getMachineTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.ForceField];
  }

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

  function getOreAmount(ObjectType self) internal pure returns (ObjectAmount memory) {
    if (self == ObjectTypes.CopperPick) return ObjectAmount(ObjectTypes.CopperOre, 3);
    if (self == ObjectTypes.IronPick) return ObjectAmount(ObjectTypes.IronOre, 3);
    if (self == ObjectTypes.GoldPick) return ObjectAmount(ObjectTypes.GoldOre, 3);
    if (self == ObjectTypes.DiamondPick) return ObjectAmount(ObjectTypes.DiamondOre, 3);
    if (self == ObjectTypes.NeptuniumPick) return ObjectAmount(ObjectTypes.NeptuniumOre, 3);
    if (self == ObjectTypes.CopperAxe) return ObjectAmount(ObjectTypes.CopperOre, 3);
    if (self == ObjectTypes.IronAxe) return ObjectAmount(ObjectTypes.IronOre, 3);
    if (self == ObjectTypes.GoldAxe) return ObjectAmount(ObjectTypes.GoldOre, 3);
    if (self == ObjectTypes.DiamondAxe) return ObjectAmount(ObjectTypes.DiamondOre, 3);
    if (self == ObjectTypes.NeptuniumAxe) return ObjectAmount(ObjectTypes.NeptuniumOre, 3);
    if (self == ObjectTypes.CopperWhacker) return ObjectAmount(ObjectTypes.CopperOre, 6);
    if (self == ObjectTypes.IronWhacker) return ObjectAmount(ObjectTypes.IronOre, 6);
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function getPlankAmount(ObjectType self) internal pure returns (uint16) {
    if (self == ObjectTypes.WoodenPick) return 5;
    if (self == ObjectTypes.CopperPick) return 2;
    if (self == ObjectTypes.IronPick) return 2;
    if (self == ObjectTypes.GoldPick) return 2;
    if (self == ObjectTypes.DiamondPick) return 2;
    if (self == ObjectTypes.NeptuniumPick) return 2;
    if (self == ObjectTypes.WoodenAxe) return 5;
    if (self == ObjectTypes.CopperAxe) return 2;
    if (self == ObjectTypes.IronAxe) return 2;
    if (self == ObjectTypes.GoldAxe) return 2;
    if (self == ObjectTypes.DiamondAxe) return 2;
    if (self == ObjectTypes.NeptuniumAxe) return 2;
    if (self == ObjectTypes.WoodenWhacker) return 8;
    if (self == ObjectTypes.CopperWhacker) return 2;
    if (self == ObjectTypes.IronWhacker) return 2;
    if (self == ObjectTypes.WoodenHoe) return 4;
    return 0;
  }

  function getCrop(ObjectType self) internal pure returns (ObjectType) {
    if (self == ObjectTypes.WheatSeed) return ObjectTypes.Wheat;
    if (self == ObjectTypes.PumpkinSeed) return ObjectTypes.Pumpkin;
    if (self == ObjectTypes.MelonSeed) return ObjectTypes.Melon;
    return ObjectTypes.Null;
  }

  function getSapling(ObjectType self) internal pure returns (ObjectType) {
    if (self == ObjectTypes.OakLeaf) return ObjectTypes.OakSapling;
    if (self == ObjectTypes.BirchLeaf) return ObjectTypes.BirchSapling;
    if (self == ObjectTypes.JungleLeaf) return ObjectTypes.JungleSapling;
    if (self == ObjectTypes.SakuraLeaf) return ObjectTypes.SakuraSapling;
    if (self == ObjectTypes.SpruceLeaf) return ObjectTypes.SpruceSapling;
    if (self == ObjectTypes.AcaciaLeaf) return ObjectTypes.AcaciaSapling;
    if (self == ObjectTypes.DarkOakLeaf) return ObjectTypes.DarkOakSapling;
    return ObjectTypes.Null;
  }

  function getTimeToGrow(ObjectType self) internal pure returns (uint128) {
    if (self == ObjectTypes.WheatSeed) return 900;
    if (self == ObjectTypes.PumpkinSeed) return 3600;
    if (self == ObjectTypes.MelonSeed) return 3600;
    if (self == ObjectTypes.OakSapling) return 345600;
    if (self == ObjectTypes.BirchSapling) return 345600;
    if (self == ObjectTypes.JungleSapling) return 345600;
    if (self == ObjectTypes.SakuraSapling) return 345600;
    if (self == ObjectTypes.AcaciaSapling) return 345600;
    if (self == ObjectTypes.SpruceSapling) return 345600;
    if (self == ObjectTypes.DarkOakSapling) return 345600;
    if (self == ObjectTypes.MangroveSapling) return 345600;
    return 0;
  }

  function getGrowableEnergy(ObjectType self) public pure returns (uint128) {
    if (self == ObjectTypes.WheatSeed) return 4300000000000000;
    if (self == ObjectTypes.PumpkinSeed) return 34300000000000000;
    if (self == ObjectTypes.MelonSeed) return 34300000000000000;
    if (self == ObjectTypes.OakSapling) return 148000000000000000;
    if (self == ObjectTypes.BirchSapling) return 139000000000000000;
    if (self == ObjectTypes.JungleSapling) return 300000000000000000;
    if (self == ObjectTypes.SakuraSapling) return 187000000000000000;
    if (self == ObjectTypes.AcaciaSapling) return 158000000000000000;
    if (self == ObjectTypes.SpruceSapling) return 256000000000000000;
    if (self == ObjectTypes.DarkOakSapling) return 202000000000000000;
    if (self == ObjectTypes.MangroveSapling) return 232000000000000000;
    return 0;
  }

  function isPlantableOn(ObjectType self, ObjectType on) internal pure returns (bool) {
    if (self.isSeed()) {
      return on == ObjectTypes.WetFarmland;
    }
    if (self.isSapling()) {
      return on == ObjectTypes.Dirt || on == ObjectTypes.Grass;
    }
    return false;
  }

  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (
      self == ObjectTypes.AnyLog && self.isLog() || self == ObjectTypes.AnyPlank && self.isPlank()
        || self == ObjectTypes.AnyLeaf && self.isLeaf()
    ) {
      return true;
    }
    return self == other;
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
