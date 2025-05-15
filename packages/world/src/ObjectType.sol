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

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    // TODO
    return !self.isNull();
  }

  // Direct Category Checks

  function isNonSolid(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..2] in one word
      function gByte(i) -> b {
        b := byte(i, 452326652075959969500899029701911694102740779818102794052241512579358261248)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 36387)), 0xFF)
      let h1 := and(shr(8, mul(id, 30927)), 0xFF)
      let h2 := and(shr(8, mul(id, 59677)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 3)), add(gByte(mod(h1, 3)), gByte(mod(h2, 3))))
      slot := addmod(slot, 0, 3) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 281470681874433

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isAny(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..4] in one word
      function gByte(i) -> b {
        b := byte(i, 1360492945329020888807615753235470143630860818558933299714400485076610580480)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 50185)), 0xFF)
      let h1 := and(shr(8, mul(id, 65303)), 0xFF)
      let h2 := and(shr(8, mul(id, 57935)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 5)), add(gByte(mod(h1, 5)), gByte(mod(h2, 5))))
      slot := addmod(slot, 0, 5) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1208907391448436507738155

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isOre(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..8] in one word
      function gByte(i) -> b {
        b := byte(i, 10656512041499105264260086188907376938030111411171137687072325998959656960)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 14261)), 0xFF)
      let h1 := and(shr(8, mul(id, 57329)), 0xFF)
      let h2 := and(shr(8, mul(id, 27411)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 9)), add(gByte(mod(h1, 9)), gByte(mod(h2, 9))))
      slot := addmod(slot, 0, 9) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 22300745193341099306166217502292977861787681

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isLog(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..9] in one word
      function gByte(i) -> b {
        b := byte(i, 3627337213657461937142115707151136226846698972963216681130983074704536895488)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 45595)), 0xFF)
      let h1 := and(shr(8, mul(id, 16675)), 0xFF)
      let h2 := and(shr(8, mul(id, 37663)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 10)), add(gByte(mod(h1, 10)), gByte(mod(h2, 10))))
      slot := addmod(slot, 0, 10) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1461501636990926901630387956257476049351913439297

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isLeaf(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..14] in one word
      function gByte(i) -> b {
        b := byte(i, 6351849707455009884420264545062848978040678997249469723480446843129859932160)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 14945)), 0xFF)
      let h1 := and(shr(8, mul(id, 26193)), 0xFF)
      let h2 := and(shr(8, mul(id, 63523)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 15)), add(gByte(mod(h1, 15)), gByte(mod(h2, 15))))
      slot := addmod(slot, 0, 15) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1766847064778378059282119229492879835942430191645452838232319899558477900

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isPlank(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..9] in one word
      function gByte(i) -> b {
        b := byte(i, 12368119122545990090712379808429105654012232204985129870119925677159350272)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 26613)), 0xFF)
      let h1 := and(shr(8, mul(id, 16415)), 0xFF)
      let h2 := and(shr(8, mul(id, 52547)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 10)), add(gByte(mod(h1, 10)), gByte(mod(h2, 10))))
      slot := addmod(slot, 0, 10) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1461501636991295559857257909637573630033672536193

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isSeed(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..3] in one word
      function gByte(i) -> b {
        b := byte(i, 1780677517418632607797961679482559586363059751964382271804412353350467584)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 34459)), 0xFF)
      let h1 := and(shr(8, mul(id, 8145)), 0xFF)
      let h2 := and(shr(8, mul(id, 10695)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 4)), add(gByte(mod(h1, 4)), gByte(mod(h2, 4))))
      slot := addmod(slot, 0, 4) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 18446463200037372042

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isSapling(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..9] in one word
      function gByte(i) -> b {
        b := byte(i, 2713939208168235694692784837415668337665417169240240971229142815467263492096)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 49281)), 0xFF)
      let h1 := and(shr(8, mul(id, 28797)), 0xFF)
      let h2 := and(shr(8, mul(id, 29811)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 10)), add(gByte(mod(h1, 10)), gByte(mod(h2, 10))))
      slot := addmod(slot, 0, 10) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1461501636991357869004145338814310190328119754896

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isSmartEntity(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..6] in one word
      function gByte(i) -> b {
        b := byte(i, 1809279055238355691677991523059881094120968709086426472961853059184770154496)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 27181)), 0xFF)
      let h1 := and(shr(8, mul(id, 10081)), 0xFF)
      let h2 := and(shr(8, mul(id, 4567)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 7)), add(gByte(mod(h1, 7)), gByte(mod(h2, 7))))
      slot := addmod(slot, 0, 7) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 5192296857328650425574889847521431

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isStation(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..3] in one word
      function gByte(i) -> b {
        b := byte(i, 5314344687028734116324762013953309598387353908571197647475143652325457920)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 34531)), 0xFF)
      let h1 := and(shr(8, mul(id, 15205)), 0xFF)
      let h2 := and(shr(8, mul(id, 3163)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 4)), add(gByte(mod(h1, 4)), gByte(mod(h2, 4))))
      slot := addmod(slot, 0, 4) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 18446463264462799002

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isPick(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..7] in one word
      function gByte(i) -> b {
        b := byte(i, 2273932200069792992810861301742390898252139108155050725518848539100352348160)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 28211)), 0xFF)
      let h1 := and(shr(8, mul(id, 11767)), 0xFF)
      let h2 := and(shr(8, mul(id, 34197)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 8)), add(gByte(mod(h1, 8)), gByte(mod(h2, 8))))
      slot := addmod(slot, 0, 8) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 340282366841904940994484957334848077982

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isAxe(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..7] in one word
      function gByte(i) -> b {
        b := byte(i, 3178592405228000500581818355950704396819431786765318781662581092269735018496)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 57899)), 0xFF)
      let h1 := and(shr(8, mul(id, 24857)), 0xFF)
      let h2 := and(shr(8, mul(id, 44439)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 8)), add(gByte(mod(h1, 8)), gByte(mod(h2, 8))))
      slot := addmod(slot, 0, 8) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 340282366841909776789998825095725056168

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isHoe(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..1] in one word
      function gByte(i) -> b {
        b := byte(i, 0)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 5751)), 0xFF)
      let h1 := and(shr(8, mul(id, 46457)), 0xFF)
      let h2 := and(shr(8, mul(id, 44467)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 2)), add(gByte(mod(h1, 2)), gByte(mod(h2, 2))))
      slot := addmod(slot, 0, 2) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 4294901932

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isWhacker(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..3] in one word
      function gByte(i) -> b {
        b := byte(i, 1360486043372049514906713945083771811238067502812170938526747100043764826112)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 59175)), 0xFF)
      let h1 := and(shr(8, mul(id, 31273)), 0xFF)
      let h2 := and(shr(8, mul(id, 12597)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 4)), add(gByte(mod(h1, 4)), gByte(mod(h2, 4))))
      slot := addmod(slot, 0, 4) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 18446463328888357035

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isOreBar(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..4] in one word
      function gByte(i) -> b {
        b := byte(i, 1809251502488789097101527379522562991336877501905896789480462008301016580096)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 887)), 0xFF)
      let h1 := and(shr(8, mul(id, 12559)), 0xFF)
      let h2 := and(shr(8, mul(id, 29975)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 5)), add(gByte(mod(h1, 5)), gByte(mod(h2, 5))))
      slot := addmod(slot, 0, 5) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 1208907421566478066778288

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isFood(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..3] in one word
      function gByte(i) -> b {
        b := byte(i, 904632598912879567310435755136236557129124206309289076944817537586045124608)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 12169)), 0xFF)
      let h1 := and(shr(8, mul(id, 9057)), 0xFF)
      let h2 := and(shr(8, mul(id, 37691)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 4)), add(gByte(mod(h1, 4)), gByte(mod(h2, 4))))
      slot := addmod(slot, 0, 4) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 18446463376133652660

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isFuel(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..1] in one word
      function gByte(i) -> b {
        b := byte(i, 0)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 62005)), 0xFF)
      let h1 := and(shr(8, mul(id, 57989)), 0xFF)
      let h2 := and(shr(8, mul(id, 5005)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 2)), add(gByte(mod(h1, 2)), gByte(mod(h2, 2))))
      slot := addmod(slot, 0, 2) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 4294901942

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isPlayer(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..1] in one word
      function gByte(i) -> b {
        b := byte(i, 0)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 49499)), 0xFF)
      let h1 := and(shr(8, mul(id, 9695)), 0xFF)
      let h2 := and(shr(8, mul(id, 37495)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 2)), add(gByte(mod(h1, 2)), gByte(mod(h2, 2))))
      slot := addmod(slot, 0, 2) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 4294901943

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function hasExtraDrops(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      function gByte(i) -> b {
        let off := and(i, 31) // idx within word
        switch shr(5, i)
          // word 0..1
        case 0 { b := byte(off, 11760135089550039445254600977187564053549231349426707298275149585207563328540) }
        case 1 { b := byte(off, 14504158713259495667629752866170850055048122198623278914947149467885622001664) }
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 49939)), 0xFF)
      let h1 := and(shr(8, mul(id, 40509)), 0xFF)
      let h2 := and(shr(8, mul(id, 61403)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 39)), add(gByte(mod(h1, 39)), gByte(mod(h2, 39))))
      slot := addmod(slot, 0, 39) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 130749486665489473308047427782494228322415813307753690869166324054694953055 }
      case 1 { w := 115790325248037028776925143150719525901128972406273603203012746550152316846180 }
      default { w := 5192296858534827628530496329220095 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function hasAxeMultiplier(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      function gByte(i) -> b {
        let off := and(i, 31) // idx within word
        switch shr(5, i)
          // word 0..1
        case 0 { b := byte(off, 1105690205424847211141004283391727110801588672735963595760834635441152) }
        case 1 { b := byte(off, 60073720748789420709773322823776498067480739937762600875663438495594053632) }
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 8655)), 0xFF)
      let h1 := and(shr(8, mul(id, 61409)), 0xFF)
      let h2 := and(shr(8, mul(id, 24371)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 51)), add(gByte(mod(h1, 51)), gByte(mod(h2, 51))))
      slot := addmod(slot, 0, 51) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 189054684918910580369645037601081869872295635562812956377565267738509246616 }
      case 1 { w := 118380586641619519059196439391103526569069078332552046793014421370381074503 }
      case 2 { w := 115792089237316195423570985008687885588595028576352080733761963979822988263498 }
      default { w := 281474976710655 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function hasPickMultiplier(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      function gByte(i) -> b {
        let off := and(i, 31) // idx within word
        switch shr(5, i)
          // word 0..1
        case 0 { b := byte(off, 18544930321606643743928591734329299274862808522273801038975799942915524598580) }
        case 1 { b := byte(off, 7772409767920030684479211373823448752408729911466445772426046560834957606912) }
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 27413)), 0xFF)
      let h1 := and(shr(8, mul(id, 42803)), 0xFF)
      let h2 := and(shr(8, mul(id, 64635)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 57)), add(gByte(mod(h1, 57)), gByte(mod(h2, 57))))
      slot := addmod(slot, 0, 57) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 272095715095832843616285400521235469924955107797037820012398116159897403525 }
      case 1 { w := 26502813826271993406626741558814342467197055333509669126180448726710026273 }
      case 2 { w := 115792089210358305950972945582495091782445466314013416072255640336758962585631 }
      default { w := 22300745198530623141535718272648361505980415 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isPassThrough(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      function gByte(i) -> b {
        let off := and(i, 31) // idx within word
        switch shr(5, i)
          // word 0..1
        case 0 { b := byte(off, 42742515760015969613707001518721370492102930437083464472115312846366904107) }
        case 1 { b := byte(off, 22243010890354258988886670783601293153040808928678678296686724293858200387584) }
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 15059)), 0xFF)
      let h1 := and(shr(8, mul(id, 37823)), 0xFF)
      let h2 := and(shr(8, mul(id, 28743)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 51)), add(gByte(mod(h1, 51)), gByte(mod(h2, 51))))
      slot := addmod(slot, 0, 51) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 173153330962933900084662030983032808002600168031617633767763600302303150192 }
      case 1 { w := 148417741630409472458196858217802031214650272879760913826548812696502599777 }
      case 2 { w := 115792089237316195423570985008687885553206088186580621027997312973068298944513 }
      default { w := 281474976710655 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isGrowable(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..13] in one word
      function gByte(i) -> b {
        b := byte(i, 2277479939908689553362182879120440772815617739113806198877562545562129006592)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 47771)), 0xFF)
      let h1 := and(shr(8, mul(id, 4099)), 0xFF)
      let h2 := and(shr(8, mul(id, 24671)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 14)), add(gByte(mod(h1, 14)), gByte(mod(h2, 14))))
      slot := addmod(slot, 0, 14) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 26959946667150544225616637436831140100204489502055291229380340285588

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isUniqueObject(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..25] in one word
      function gByte(i) -> b {
        b := byte(i, 17841311287567819656795847928944003124805419649692877805659959172253351936)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 54247)), 0xFF)
      let h1 := and(shr(8, mul(id, 5799)), 0xFF)
      let h2 := and(shr(8, mul(id, 60947)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 26)), add(gByte(mod(h1, 26)), gByte(mod(h2, 26))))
      slot := addmod(slot, 0, 26) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 296834323980643102965667306663876101216582742950427881583376826255754395819 }
      default { w := 1461501637330902918203683627055581861320505884850 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isTool(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..19] in one word
      function gByte(i) -> b {
        b := byte(i, 6784741040979598916902094215048625576941674528585235167622736123937236713472)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 43265)), 0xFF)
      let h1 := and(shr(8, mul(id, 29637)), 0xFF)
      let h2 := and(shr(8, mul(id, 32883)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 20)), add(gByte(mod(h1, 20)), gByte(mod(h2, 20))))
      slot := addmod(slot, 0, 20) // 0‥S-1

      /* slot → id table -------------------------------------- */

      let w
      switch shr(4, slot)
        // slot / 16
      case 0 { w := 302135134774445059280622057217338339497320721794262367051805622344085799082 }
      default { w := 18446744073709551615 }

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isTillable(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..2] in one word
      function gByte(i) -> b {
        b := byte(i, 454079695648044772702907457690930058567663361497034072237252793732203282432)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 47837)), 0xFF)
      let h1 := and(shr(8, mul(id, 45165)), 0xFF)
      let h2 := and(shr(8, mul(id, 42127)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 3)), add(gByte(mod(h1, 3)), gByte(mod(h2, 3))))
      slot := addmod(slot, 0, 3) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 281470683185173

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  function isMachine(ObjectType self) internal pure returns (bool _is) {
    uint16 id = ObjectType.unwrap(self); // 2-byte key

    /// @solidity memory-safe-assembly
    assembly {
      /* g[idx] ------------------------------------------------ */
      // g[0..1] in one word
      function gByte(i) -> b {
        b := byte(i, 0)
      }

      /* three 16-bit hashes ---------------------------------- */
      let h0 := and(shr(8, mul(id, 1157)), 0xFF)
      let h1 := and(shr(8, mul(id, 60967)), 0xFF)
      let h2 := and(shr(8, mul(id, 32613)), 0xFF)

      /* g look-ups + final mod ------------------------------- */
      let slot := add(gByte(mod(h0, 2)), add(gByte(mod(h1, 2)), gByte(mod(h2, 2))))
      slot := addmod(slot, 0, 2) // 0‥S-1

      /* slot → id table -------------------------------------- */
      let w := 4294901909

      let ref := and(shr(shl(4, and(slot, 15)), w), 0xFFFF) // 2-byte little-endian
      _is := eq(ref, id)
    }
  }

  // Category getters
  function getNonSolidTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water];
  }

  function getAnyTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.AnyPlank, ObjectTypes.AnyLog, ObjectTypes.AnyLeaf, ObjectTypes.AnyTerracotta];
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

  function isMineable(ObjectType self) internal pure returns (bool) { }

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
