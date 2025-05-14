// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Vec3, vec3 } from "./Vec3.sol";
import { Direction } from "./codegen/common.sol";
import { IMachineSystem } from "./codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "./codegen/world/ITransferSystem.sol";

import { PerfectHashLib } from "./utils/PerfectHashLib.sol";

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

  bytes constant NON_SOLID_TABLE = hex"010000000200";
  bytes constant STONE_TABLE = hex"11000c0012000f0008000d0000000000000000000000000000000000000000000000000000000000";
  bytes constant GEMSTONE_TABLE = hex"140013000000";
  bytes constant SOIL_TABLE = hex"000015001d001a001c00000000001b000000000000000000";
  bytes constant ORE_TABLE = hex"230000000000000000002400210000000000";
  bytes constant SAND_TABLE = hex"00002900280000002a00000000000000";
  bytes constant TERRACOTTA_TABLE = hex"330037003800320000000000360000000000000000000000000000000000000000000000";
  bytes constant LOG_TABLE = hex"3c00410040003b00000000003f0000000000000000000000";
  bytes constant LEAF_TABLE = hex"48004d004e00000000004c004b004200000000000000000000000000000000000000";
  bytes constant FLOWER_TABLE = hex"5700500000005a0053005800540059000000000000000000000000000000";
  bytes constant GREENERY_TABLE = hex"5f005c005d005e00000000000000";
  bytes constant CROP_TABLE = hex"650000000000660000000000000000000000";
  bytes constant CROP_BLOCK_TABLE = hex"000000006d00000067006b006c0000000000";
  bytes constant UNDERWATER_PLANT_TABLE = hex"70006e0000006f00";
  bytes constant UNDERWATER_BLOCK_TABLE = hex"7400750000007300000072000000";
  bytes constant MISC_BLOCK_TABLE = hex"78007b00000000000000790076000000";
  bytes constant PLANK_TABLE = hex"800000008100000084000000000000000000000000000000";
  bytes constant ORE_BLOCK_TABLE = hex"8900000087000000850000000000";
  bytes constant SEED_TABLE = hex"8c00000000008b00";
  bytes constant SAPLING_TABLE = hex"9200910093008f00940000000000000000000000";
  bytes constant SMART_ENTITY_BLOCK_TABLE = hex"96000000970000009800";
  bytes constant STATION_TABLE = hex"9b00990000009a00";
  bytes constant MISC_PASS_THROUGH_TABLE = hex"9c000000";
  bytes constant PICK_TABLE = hex"a1000000a2009f000000000000000000";
  bytes constant AXE_TABLE = hex"a80000000000a5000000000000000000";
  bytes constant HOE_TABLE = hex"ac000000";
  bytes constant WHACKER_TABLE = hex"0000a9000000ab00";
  bytes constant ORE_BAR_TABLE = hex"b00000000000ad000000";
  bytes constant BUCKET_TABLE = hex"b20000000000";
  bytes constant FOOD_TABLE = hex"b500000000000000";
  bytes constant FUEL_TABLE = hex"b6000000";
  bytes constant PLAYER_TABLE = hex"b7000000";
  bytes constant SMART_ENTITY_NON_BLOCK_TABLE = hex"b8000000";
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

  function isNonSolid(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 3, 25899, 34697, 53025, 17);
    uint16 ref =
      uint16(uint8(Category.NON_SOLID_TABLE[slot * 2])) | (uint16(uint8(Category.NON_SOLID_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isStone(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 20, 60515, 52903, 713, 833293058076);
    uint16 ref =
      uint16(uint8(Category.STONE_TABLE[slot * 2])) | (uint16(uint8(Category.STONE_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isGemstone(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 3, 63499, 51099, 28249, 34);
    uint16 ref =
      uint16(uint8(Category.GEMSTONE_TABLE[slot * 2])) | (uint16(uint8(Category.GEMSTONE_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSoil(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 12, 59395, 40229, 59647, 14681269);
    uint16 ref = uint16(uint8(Category.SOIL_TABLE[slot * 2])) | (uint16(uint8(Category.SOIL_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isOre(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 9, 30015, 14597, 58253, 197504);
    uint16 ref = uint16(uint8(Category.ORE_TABLE[slot * 2])) | (uint16(uint8(Category.ORE_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSand(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 8, 24639, 27365, 56525, 264);
    uint16 ref = uint16(uint8(Category.SAND_TABLE[slot * 2])) | (uint16(uint8(Category.SAND_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isTerracotta(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 18, 45187, 20439, 55971, 34443627540);
    uint16 ref =
      uint16(uint8(Category.TERRACOTTA_TABLE[slot * 2])) | (uint16(uint8(Category.TERRACOTTA_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isLog(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 12, 46667, 21335, 62653, 7651328);
    uint16 ref = uint16(uint8(Category.LOG_TABLE[slot * 2])) | (uint16(uint8(Category.LOG_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isLeaf(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 17, 23121, 1295, 31393, 12935497508);
    uint16 ref = uint16(uint8(Category.LEAF_TABLE[slot * 2])) | (uint16(uint8(Category.LEAF_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isFlower(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 15, 55723, 49669, 31423, 3379974);
    uint16 ref =
      uint16(uint8(Category.FLOWER_TABLE[slot * 2])) | (uint16(uint8(Category.FLOWER_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isGreenery(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 7, 11031, 60349, 22229, 96);
    uint16 ref =
      uint16(uint8(Category.GREENERY_TABLE[slot * 2])) | (uint16(uint8(Category.GREENERY_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isCrop(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 9, 43361, 16703, 44307, 48);
    uint16 ref = uint16(uint8(Category.CROP_TABLE[slot * 2])) | (uint16(uint8(Category.CROP_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isCropBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 9, 34219, 45475, 34399, 39945);
    uint16 ref =
      uint16(uint8(Category.CROP_BLOCK_TABLE[slot * 2])) | (uint16(uint8(Category.CROP_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isUnderwaterPlant(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 4, 42141, 51705, 58735, 200);
    uint16 ref = uint16(uint8(Category.UNDERWATER_PLANT_TABLE[slot * 2]))
      | (uint16(uint8(Category.UNDERWATER_PLANT_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isUnderwaterBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 7, 9173, 28889, 32039, 2063);
    uint16 ref = uint16(uint8(Category.UNDERWATER_BLOCK_TABLE[slot * 2]))
      | (uint16(uint8(Category.UNDERWATER_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isMiscBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 8, 38907, 63159, 15229, 60652);
    uint16 ref =
      uint16(uint8(Category.MISC_BLOCK_TABLE[slot * 2])) | (uint16(uint8(Category.MISC_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isPlank(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 12, 44331, 1461, 62483, 8);
    uint16 ref =
      uint16(uint8(Category.PLANK_TABLE[slot * 2])) | (uint16(uint8(Category.PLANK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isOreBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 7, 34897, 3733, 62365, 2);
    uint16 ref =
      uint16(uint8(Category.ORE_BLOCK_TABLE[slot * 2])) | (uint16(uint8(Category.ORE_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSeed(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 4, 51239, 18021, 49973, 45);
    uint16 ref = uint16(uint8(Category.SEED_TABLE[slot * 2])) | (uint16(uint8(Category.SEED_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSapling(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 10, 16433, 26977, 38719, 131873);
    uint16 ref =
      uint16(uint8(Category.SAPLING_TABLE[slot * 2])) | (uint16(uint8(Category.SAPLING_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSmartEntityBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 5, 11977, 63989, 43031, 18);
    uint16 ref = uint16(uint8(Category.SMART_ENTITY_BLOCK_TABLE[slot * 2]))
      | (uint16(uint8(Category.SMART_ENTITY_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isStation(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 4, 65431, 45793, 23811, 163);
    uint16 ref =
      uint16(uint8(Category.STATION_TABLE[slot * 2])) | (uint16(uint8(Category.STATION_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isMiscPassThrough(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 2, 21771, 58883, 7135, 0);
    uint16 ref = uint16(uint8(Category.MISC_PASS_THROUGH_TABLE[slot * 2]))
      | (uint16(uint8(Category.MISC_PASS_THROUGH_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isPick(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 8, 57105, 50375, 48315, 4225);
    uint16 ref = uint16(uint8(Category.PICK_TABLE[slot * 2])) | (uint16(uint8(Category.PICK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isAxe(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 8, 8785, 33995, 31787, 49152);
    uint16 ref = uint16(uint8(Category.AXE_TABLE[slot * 2])) | (uint16(uint8(Category.AXE_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isHoe(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 2, 11007, 49579, 58121, 0);
    uint16 ref = uint16(uint8(Category.HOE_TABLE[slot * 2])) | (uint16(uint8(Category.HOE_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isWhacker(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 4, 8839, 61323, 37211, 44);
    uint16 ref =
      uint16(uint8(Category.WHACKER_TABLE[slot * 2])) | (uint16(uint8(Category.WHACKER_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isOreBar(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 5, 2723, 64471, 56059, 12);
    uint16 ref =
      uint16(uint8(Category.ORE_BAR_TABLE[slot * 2])) | (uint16(uint8(Category.ORE_BAR_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isBucket(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 3, 11741, 41265, 61961, 0);
    uint16 ref =
      uint16(uint8(Category.BUCKET_TABLE[slot * 2])) | (uint16(uint8(Category.BUCKET_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isFood(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 4, 2781, 22611, 41139, 0);
    uint16 ref = uint16(uint8(Category.FOOD_TABLE[slot * 2])) | (uint16(uint8(Category.FOOD_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isFuel(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 2, 20125, 59095, 1449, 0);
    uint16 ref = uint16(uint8(Category.FUEL_TABLE[slot * 2])) | (uint16(uint8(Category.FUEL_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isPlayer(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 2, 43639, 58763, 11931, 1);
    uint16 ref =
      uint16(uint8(Category.PLAYER_TABLE[slot * 2])) | (uint16(uint8(Category.PLAYER_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  function isSmartEntityNonBlock(ObjectType self) internal pure returns (bool) {
    uint8 slot = PerfectHashLib.slot(self.unwrap(), 2, 53175, 5149, 23027, 0);
    uint16 ref = uint16(uint8(Category.SMART_ENTITY_NON_BLOCK_TABLE[slot * 2]))
      | (uint16(uint8(Category.SMART_ENTITY_NON_BLOCK_TABLE[slot * 2 + 1])) << 8);
    return ref == self.unwrap();
  }

  // Category getters
  function getNonSolidTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water];
  }

  function getStoneTypes() internal pure returns (ObjectType[16] memory) {
    return [
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
      ObjectTypes.CobbledDeepslate
    ];
  }

  function getGemstoneTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Amethyst, ObjectTypes.Glowstone];
  }

  function getSoilTypes() internal pure returns (ObjectType[9] memory) {
    return [
      ObjectTypes.Grass,
      ObjectTypes.Dirt,
      ObjectTypes.Moss,
      ObjectTypes.Podzol,
      ObjectTypes.DirtPath,
      ObjectTypes.Mud,
      ObjectTypes.PackedMud,
      ObjectTypes.Farmland,
      ObjectTypes.WetFarmland
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

  function getSandTypes() internal pure returns (ObjectType[6] memory) {
    return [
      ObjectTypes.Gravel,
      ObjectTypes.Sand,
      ObjectTypes.RedSand,
      ObjectTypes.Sandstone,
      ObjectTypes.RedSandstone,
      ObjectTypes.Clay
    ];
  }

  function getTerracottaTypes() internal pure returns (ObjectType[14] memory) {
    return [
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
      ObjectTypes.MagentaTerracotta
    ];
  }

  function getLogTypes() internal pure returns (ObjectType[9] memory) {
    return [
      ObjectTypes.AnyLog,
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

  function getLeafTypes() internal pure returns (ObjectType[13] memory) {
    return [
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
      ObjectTypes.MuddyMangroveRoots
    ];
  }

  function getFlowerTypes() internal pure returns (ObjectType[12] memory) {
    return [
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
      ObjectTypes.FlyTrap
    ];
  }

  function getGreeneryTypes() internal pure returns (ObjectType[5] memory) {
    return [
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.VinesBush,
      ObjectTypes.IvyVine,
      ObjectTypes.HempBush
    ];
  }

  function getCropTypes() internal pure returns (ObjectType[7] memory) {
    return [
      ObjectTypes.GoldenMushroom,
      ObjectTypes.RedMushroom,
      ObjectTypes.CoffeeBush,
      ObjectTypes.StrawberryBush,
      ObjectTypes.RaspberryBush,
      ObjectTypes.Wheat,
      ObjectTypes.CottonBush
    ];
  }

  function getCropBlockTypes() internal pure returns (ObjectType[7] memory) {
    return [
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.RedMushroomBlock,
      ObjectTypes.BrownMushroomBlock,
      ObjectTypes.MushroomStem,
      ObjectTypes.BambooBush,
      ObjectTypes.Cactus
    ];
  }

  function getUnderwaterPlantTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae];
  }

  function getUnderwaterBlockTypes() internal pure returns (ObjectType[5] memory) {
    return [
      ObjectTypes.HornCoralBlock,
      ObjectTypes.FireCoralBlock,
      ObjectTypes.TubeCoralBlock,
      ObjectTypes.BubbleCoralBlock,
      ObjectTypes.BrainCoralBlock
    ];
  }

  function getMiscBlockTypes() internal pure returns (ObjectType[6] memory) {
    return [
      ObjectTypes.Snow,
      ObjectTypes.Ice,
      ObjectTypes.Magma,
      ObjectTypes.SpiderWeb,
      ObjectTypes.Bone,
      ObjectTypes.TextSign
    ];
  }

  function getPlankTypes() internal pure returns (ObjectType[9] memory) {
    return [
      ObjectTypes.AnyPlank,
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

  function getOreBlockTypes() internal pure returns (ObjectType[5] memory) {
    return [
      ObjectTypes.CopperBlock,
      ObjectTypes.IronBlock,
      ObjectTypes.GoldBlock,
      ObjectTypes.DiamondBlock,
      ObjectTypes.NeptuniumBlock
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

  function getSmartEntityBlockTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.Bed];
  }

  function getStationTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.Furnace];
  }

  function getMiscPassThroughTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Torch];
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

  function getBucketTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Bucket, ObjectTypes.WaterBucket];
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

  function getSmartEntityNonBlockTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Fragment];
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

  function getGrowableEnergy(ObjectType self) internal pure returns (uint128) {
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
    if (self.isAny()) {
      return self.category() == other.category();
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
