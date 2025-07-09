// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IMachineSystem } from "../codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "../codegen/world/ITransferSystem.sol";

import { Orientation } from "./Orientation.sol";
import { Vec3, vec3 } from "./Vec3.sol";

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
  ObjectType constant Null = ObjectType.wrap(0);
  ObjectType constant Air = ObjectType.wrap(1);
  ObjectType constant Water = ObjectType.wrap(2);
  ObjectType constant Bedrock = ObjectType.wrap(3);
  ObjectType constant Stone = ObjectType.wrap(4);
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
  ObjectType constant Gravel = ObjectType.wrap(31);
  ObjectType constant Sand = ObjectType.wrap(32);
  ObjectType constant RedSand = ObjectType.wrap(33);
  ObjectType constant Sandstone = ObjectType.wrap(34);
  ObjectType constant RedSandstone = ObjectType.wrap(35);
  ObjectType constant Clay = ObjectType.wrap(36);
  ObjectType constant StoneBricks = ObjectType.wrap(37);
  ObjectType constant TuffBricks = ObjectType.wrap(38);
  ObjectType constant DeepslateBricks = ObjectType.wrap(39);
  ObjectType constant PolishedAndesite = ObjectType.wrap(40);
  ObjectType constant PolishedGranite = ObjectType.wrap(41);
  ObjectType constant PolishedDiorite = ObjectType.wrap(42);
  ObjectType constant PolishedTuff = ObjectType.wrap(43);
  ObjectType constant PolishedBasalt = ObjectType.wrap(44);
  ObjectType constant PolishedBlackstone = ObjectType.wrap(45);
  ObjectType constant ChiseledStoneBricks = ObjectType.wrap(46);
  ObjectType constant ChiseledTuffBricks = ObjectType.wrap(47);
  ObjectType constant ChiseledDeepslate = ObjectType.wrap(48);
  ObjectType constant ChiseledPolishedBlackstone = ObjectType.wrap(49);
  ObjectType constant ChiseledSandstone = ObjectType.wrap(50);
  ObjectType constant ChiseledRedSandstone = ObjectType.wrap(51);
  ObjectType constant CrackedStoneBricks = ObjectType.wrap(52);
  ObjectType constant CrackedTuffBricks = ObjectType.wrap(53);
  ObjectType constant CrackedDeepslateBricks = ObjectType.wrap(54);
  ObjectType constant SmoothSandstone = ObjectType.wrap(55);
  ObjectType constant SmoothRedSandstone = ObjectType.wrap(56);
  ObjectType constant SmoothStone = ObjectType.wrap(57);
  ObjectType constant Terracotta = ObjectType.wrap(58);
  ObjectType constant BrownTerracotta = ObjectType.wrap(59);
  ObjectType constant OrangeTerracotta = ObjectType.wrap(60);
  ObjectType constant WhiteTerracotta = ObjectType.wrap(61);
  ObjectType constant LightGrayTerracotta = ObjectType.wrap(62);
  ObjectType constant YellowTerracotta = ObjectType.wrap(63);
  ObjectType constant RedTerracotta = ObjectType.wrap(64);
  ObjectType constant LightBlueTerracotta = ObjectType.wrap(65);
  ObjectType constant CyanTerracotta = ObjectType.wrap(66);
  ObjectType constant BlackTerracotta = ObjectType.wrap(67);
  ObjectType constant PurpleTerracotta = ObjectType.wrap(68);
  ObjectType constant BlueTerracotta = ObjectType.wrap(69);
  ObjectType constant MagentaTerracotta = ObjectType.wrap(70);
  ObjectType constant OakLog = ObjectType.wrap(71);
  ObjectType constant BirchLog = ObjectType.wrap(72);
  ObjectType constant JungleLog = ObjectType.wrap(73);
  ObjectType constant SakuraLog = ObjectType.wrap(74);
  ObjectType constant AcaciaLog = ObjectType.wrap(75);
  ObjectType constant SpruceLog = ObjectType.wrap(76);
  ObjectType constant DarkOakLog = ObjectType.wrap(77);
  ObjectType constant MangroveLog = ObjectType.wrap(78);
  ObjectType constant OakLeaf = ObjectType.wrap(79);
  ObjectType constant BirchLeaf = ObjectType.wrap(80);
  ObjectType constant JungleLeaf = ObjectType.wrap(81);
  ObjectType constant SakuraLeaf = ObjectType.wrap(82);
  ObjectType constant SpruceLeaf = ObjectType.wrap(83);
  ObjectType constant AcaciaLeaf = ObjectType.wrap(84);
  ObjectType constant DarkOakLeaf = ObjectType.wrap(85);
  ObjectType constant AzaleaLeaf = ObjectType.wrap(86);
  ObjectType constant FloweringAzaleaLeaf = ObjectType.wrap(87);
  ObjectType constant MangroveLeaf = ObjectType.wrap(88);
  ObjectType constant MangroveRoots = ObjectType.wrap(89);
  ObjectType constant MuddyMangroveRoots = ObjectType.wrap(90);
  ObjectType constant AzaleaFlower = ObjectType.wrap(91);
  ObjectType constant BellFlower = ObjectType.wrap(92);
  ObjectType constant DandelionFlower = ObjectType.wrap(93);
  ObjectType constant DaylilyFlower = ObjectType.wrap(94);
  ObjectType constant LilacFlower = ObjectType.wrap(95);
  ObjectType constant RoseFlower = ObjectType.wrap(96);
  ObjectType constant FireFlower = ObjectType.wrap(97);
  ObjectType constant MorninggloryFlower = ObjectType.wrap(98);
  ObjectType constant PeonyFlower = ObjectType.wrap(99);
  ObjectType constant Ultraviolet = ObjectType.wrap(100);
  ObjectType constant SunFlower = ObjectType.wrap(101);
  ObjectType constant FlyTrap = ObjectType.wrap(102);
  ObjectType constant FescueGrass = ObjectType.wrap(103);
  ObjectType constant SwitchGrass = ObjectType.wrap(104);
  ObjectType constant VinesBush = ObjectType.wrap(105);
  ObjectType constant IvyVine = ObjectType.wrap(106);
  ObjectType constant HempBush = ObjectType.wrap(107);
  ObjectType constant GoldenMushroom = ObjectType.wrap(108);
  ObjectType constant RedMushroom = ObjectType.wrap(109);
  ObjectType constant CoffeeBush = ObjectType.wrap(110);
  ObjectType constant StrawberryBush = ObjectType.wrap(111);
  ObjectType constant RaspberryBush = ObjectType.wrap(112);
  ObjectType constant Wheat = ObjectType.wrap(113);
  ObjectType constant CottonBush = ObjectType.wrap(114);
  ObjectType constant Pumpkin = ObjectType.wrap(115);
  ObjectType constant Melon = ObjectType.wrap(116);
  ObjectType constant RedMushroomBlock = ObjectType.wrap(117);
  ObjectType constant BrownMushroomBlock = ObjectType.wrap(118);
  ObjectType constant MushroomStem = ObjectType.wrap(119);
  ObjectType constant BambooBush = ObjectType.wrap(120);
  ObjectType constant Cactus = ObjectType.wrap(121);
  ObjectType constant Cotton = ObjectType.wrap(122);
  ObjectType constant CottonSeed = ObjectType.wrap(123);
  ObjectType constant Glass = ObjectType.wrap(124);
  ObjectType constant Brick = ObjectType.wrap(125);
  ObjectType constant BrickBlock = ObjectType.wrap(126);
  ObjectType constant MudBricks = ObjectType.wrap(127);
  ObjectType constant Paper = ObjectType.wrap(128);
  ObjectType constant Book = ObjectType.wrap(129);
  ObjectType constant Stick = ObjectType.wrap(130);
  ObjectType constant RedDye = ObjectType.wrap(131);
  ObjectType constant YellowDye = ObjectType.wrap(132);
  ObjectType constant BlueDye = ObjectType.wrap(133);
  ObjectType constant GreenDye = ObjectType.wrap(134);
  ObjectType constant WhiteDye = ObjectType.wrap(135);
  ObjectType constant BlackDye = ObjectType.wrap(136);
  ObjectType constant BrownDye = ObjectType.wrap(137);
  ObjectType constant OrangeDye = ObjectType.wrap(138);
  ObjectType constant PinkDye = ObjectType.wrap(139);
  ObjectType constant LimeDye = ObjectType.wrap(140);
  ObjectType constant CyanDye = ObjectType.wrap(141);
  ObjectType constant GrayDye = ObjectType.wrap(142);
  ObjectType constant PurpleDye = ObjectType.wrap(143);
  ObjectType constant WhiteConcretePowder = ObjectType.wrap(144);
  ObjectType constant OrangeConcretePowder = ObjectType.wrap(145);
  ObjectType constant MagentaConcretePowder = ObjectType.wrap(146);
  ObjectType constant LightBlueConcretePowder = ObjectType.wrap(147);
  ObjectType constant YellowConcretePowder = ObjectType.wrap(148);
  ObjectType constant LimeConcretePowder = ObjectType.wrap(149);
  ObjectType constant PinkConcretePowder = ObjectType.wrap(150);
  ObjectType constant GrayConcretePowder = ObjectType.wrap(151);
  ObjectType constant LightGrayConcretePowder = ObjectType.wrap(152);
  ObjectType constant CyanConcretePowder = ObjectType.wrap(153);
  ObjectType constant PurpleConcretePowder = ObjectType.wrap(154);
  ObjectType constant BlueConcretePowder = ObjectType.wrap(155);
  ObjectType constant BrownConcretePowder = ObjectType.wrap(156);
  ObjectType constant GreenConcretePowder = ObjectType.wrap(157);
  ObjectType constant RedConcretePowder = ObjectType.wrap(158);
  ObjectType constant BlackConcretePowder = ObjectType.wrap(159);
  ObjectType constant WhiteConcrete = ObjectType.wrap(160);
  ObjectType constant OrangeConcrete = ObjectType.wrap(161);
  ObjectType constant MagentaConcrete = ObjectType.wrap(162);
  ObjectType constant LightBlueConcrete = ObjectType.wrap(163);
  ObjectType constant YellowConcrete = ObjectType.wrap(164);
  ObjectType constant LimeConcrete = ObjectType.wrap(165);
  ObjectType constant PinkConcrete = ObjectType.wrap(166);
  ObjectType constant GrayConcrete = ObjectType.wrap(167);
  ObjectType constant LightGrayConcrete = ObjectType.wrap(168);
  ObjectType constant CyanConcrete = ObjectType.wrap(169);
  ObjectType constant PurpleConcrete = ObjectType.wrap(170);
  ObjectType constant BlueConcrete = ObjectType.wrap(171);
  ObjectType constant BrownConcrete = ObjectType.wrap(172);
  ObjectType constant GreenConcrete = ObjectType.wrap(173);
  ObjectType constant RedConcrete = ObjectType.wrap(174);
  ObjectType constant BlackConcrete = ObjectType.wrap(175);
  ObjectType constant GlassPane = ObjectType.wrap(176);
  ObjectType constant OakDoor = ObjectType.wrap(177);
  ObjectType constant BirchDoor = ObjectType.wrap(178);
  ObjectType constant JungleDoor = ObjectType.wrap(179);
  ObjectType constant SakuraDoor = ObjectType.wrap(180);
  ObjectType constant AcaciaDoor = ObjectType.wrap(181);
  ObjectType constant SpruceDoor = ObjectType.wrap(182);
  ObjectType constant DarkOakDoor = ObjectType.wrap(183);
  ObjectType constant MangroveDoor = ObjectType.wrap(184);
  ObjectType constant IronDoor = ObjectType.wrap(185);
  ObjectType constant OakTrapdoor = ObjectType.wrap(186);
  ObjectType constant BirchTrapdoor = ObjectType.wrap(187);
  ObjectType constant JungleTrapdoor = ObjectType.wrap(188);
  ObjectType constant SakuraTrapdoor = ObjectType.wrap(189);
  ObjectType constant AcaciaTrapdoor = ObjectType.wrap(190);
  ObjectType constant SpruceTrapdoor = ObjectType.wrap(191);
  ObjectType constant DarkOakTrapdoor = ObjectType.wrap(192);
  ObjectType constant MangroveTrapdoor = ObjectType.wrap(193);
  ObjectType constant IronTrapdoor = ObjectType.wrap(194);
  ObjectType constant OakFence = ObjectType.wrap(195);
  ObjectType constant BirchFence = ObjectType.wrap(196);
  ObjectType constant JungleFence = ObjectType.wrap(197);
  ObjectType constant SakuraFence = ObjectType.wrap(198);
  ObjectType constant AcaciaFence = ObjectType.wrap(199);
  ObjectType constant SpruceFence = ObjectType.wrap(200);
  ObjectType constant DarkOakFence = ObjectType.wrap(201);
  ObjectType constant MangroveFence = ObjectType.wrap(202);
  ObjectType constant OakFenceGate = ObjectType.wrap(203);
  ObjectType constant BirchFenceGate = ObjectType.wrap(204);
  ObjectType constant JungleFenceGate = ObjectType.wrap(205);
  ObjectType constant SakuraFenceGate = ObjectType.wrap(206);
  ObjectType constant AcaciaFenceGate = ObjectType.wrap(207);
  ObjectType constant SpruceFenceGate = ObjectType.wrap(208);
  ObjectType constant DarkOakFenceGate = ObjectType.wrap(209);
  ObjectType constant MangroveFenceGate = ObjectType.wrap(210);
  ObjectType constant IronBars = ObjectType.wrap(211);
  ObjectType constant Lantern = ObjectType.wrap(212);
  ObjectType constant Ladder = ObjectType.wrap(213);
  ObjectType constant Barrel = ObjectType.wrap(214);
  ObjectType constant Bookshelf = ObjectType.wrap(215);
  ObjectType constant Carpet = ObjectType.wrap(216);
  ObjectType constant FlowerPot = ObjectType.wrap(217);
  ObjectType constant Lodestone = ObjectType.wrap(218);
  ObjectType constant StoneStairs = ObjectType.wrap(219);
  ObjectType constant CobblestoneStairs = ObjectType.wrap(220);
  ObjectType constant MossyCobblestoneStairs = ObjectType.wrap(221);
  ObjectType constant StoneBricksStairs = ObjectType.wrap(222);
  ObjectType constant SmoothStoneStairs = ObjectType.wrap(223);
  ObjectType constant AndesiteStairs = ObjectType.wrap(224);
  ObjectType constant GraniteStairs = ObjectType.wrap(225);
  ObjectType constant DioriteStairs = ObjectType.wrap(226);
  ObjectType constant TuffStairs = ObjectType.wrap(227);
  ObjectType constant BasaltStairs = ObjectType.wrap(228);
  ObjectType constant BlackstoneStairs = ObjectType.wrap(229);
  ObjectType constant PolishedAndesiteStairs = ObjectType.wrap(230);
  ObjectType constant PolishedGraniteStairs = ObjectType.wrap(231);
  ObjectType constant PolishedDioriteStairs = ObjectType.wrap(232);
  ObjectType constant PolishedTuffStairs = ObjectType.wrap(233);
  ObjectType constant PolishedBasaltStairs = ObjectType.wrap(234);
  ObjectType constant PolishedBlackstoneStairs = ObjectType.wrap(235);
  ObjectType constant DeepslateStairs = ObjectType.wrap(236);
  ObjectType constant CobbledDeepslateStairs = ObjectType.wrap(237);
  ObjectType constant DeepslateBricksStairs = ObjectType.wrap(238);
  ObjectType constant SandstoneStairs = ObjectType.wrap(239);
  ObjectType constant RedSandstoneStairs = ObjectType.wrap(240);
  ObjectType constant SmoothSandstoneStairs = ObjectType.wrap(241);
  ObjectType constant SmoothRedSandstoneStairs = ObjectType.wrap(242);
  ObjectType constant BrickBlockStairs = ObjectType.wrap(243);
  ObjectType constant MudBricksStairs = ObjectType.wrap(244);
  ObjectType constant TuffBricksStairs = ObjectType.wrap(245);
  ObjectType constant OakPlanksStairs = ObjectType.wrap(246);
  ObjectType constant BirchPlanksStairs = ObjectType.wrap(247);
  ObjectType constant JunglePlanksStairs = ObjectType.wrap(248);
  ObjectType constant SakuraPlanksStairs = ObjectType.wrap(249);
  ObjectType constant AcaciaPlanksStairs = ObjectType.wrap(250);
  ObjectType constant SprucePlanksStairs = ObjectType.wrap(251);
  ObjectType constant DarkOakPlanksStairs = ObjectType.wrap(252);
  ObjectType constant MangrovePlanksStairs = ObjectType.wrap(253);
  ObjectType constant StoneSlab = ObjectType.wrap(254);
  ObjectType constant CobblestoneSlab = ObjectType.wrap(255);
  ObjectType constant MossyCobblestoneSlab = ObjectType.wrap(256);
  ObjectType constant StoneBricksSlab = ObjectType.wrap(257);
  ObjectType constant SmoothStoneSlab = ObjectType.wrap(258);
  ObjectType constant AndesiteSlab = ObjectType.wrap(259);
  ObjectType constant GraniteSlab = ObjectType.wrap(260);
  ObjectType constant DioriteSlab = ObjectType.wrap(261);
  ObjectType constant TuffSlab = ObjectType.wrap(262);
  ObjectType constant BasaltSlab = ObjectType.wrap(263);
  ObjectType constant BlackstoneSlab = ObjectType.wrap(264);
  ObjectType constant PolishedAndesiteSlab = ObjectType.wrap(265);
  ObjectType constant PolishedGraniteSlab = ObjectType.wrap(266);
  ObjectType constant PolishedDioriteSlab = ObjectType.wrap(267);
  ObjectType constant PolishedTuffSlab = ObjectType.wrap(268);
  ObjectType constant PolishedBasaltSlab = ObjectType.wrap(269);
  ObjectType constant PolishedBlackstoneSlab = ObjectType.wrap(270);
  ObjectType constant DeepslateSlab = ObjectType.wrap(271);
  ObjectType constant CobbledDeepslateSlab = ObjectType.wrap(272);
  ObjectType constant DeepslateBricksSlab = ObjectType.wrap(273);
  ObjectType constant SandstoneSlab = ObjectType.wrap(274);
  ObjectType constant RedSandstoneSlab = ObjectType.wrap(275);
  ObjectType constant SmoothSandstoneSlab = ObjectType.wrap(276);
  ObjectType constant SmoothRedSandstoneSlab = ObjectType.wrap(277);
  ObjectType constant BrickBlockSlab = ObjectType.wrap(278);
  ObjectType constant MudBricksSlab = ObjectType.wrap(279);
  ObjectType constant TuffBricksSlab = ObjectType.wrap(280);
  ObjectType constant OakPlanksSlab = ObjectType.wrap(281);
  ObjectType constant BirchPlanksSlab = ObjectType.wrap(282);
  ObjectType constant JunglePlanksSlab = ObjectType.wrap(283);
  ObjectType constant SakuraPlanksSlab = ObjectType.wrap(284);
  ObjectType constant AcaciaPlanksSlab = ObjectType.wrap(285);
  ObjectType constant SprucePlanksSlab = ObjectType.wrap(286);
  ObjectType constant DarkOakPlanksSlab = ObjectType.wrap(287);
  ObjectType constant MangrovePlanksSlab = ObjectType.wrap(288);
  ObjectType constant StoneWall = ObjectType.wrap(289);
  ObjectType constant CobblestoneWall = ObjectType.wrap(290);
  ObjectType constant MossyCobblestoneWall = ObjectType.wrap(291);
  ObjectType constant StoneBricksWall = ObjectType.wrap(292);
  ObjectType constant AndesiteWall = ObjectType.wrap(293);
  ObjectType constant GraniteWall = ObjectType.wrap(294);
  ObjectType constant DioriteWall = ObjectType.wrap(295);
  ObjectType constant TuffWall = ObjectType.wrap(296);
  ObjectType constant BasaltWall = ObjectType.wrap(297);
  ObjectType constant BlackstoneWall = ObjectType.wrap(298);
  ObjectType constant PolishedAndesiteWall = ObjectType.wrap(299);
  ObjectType constant PolishedGraniteWall = ObjectType.wrap(300);
  ObjectType constant PolishedDioriteWall = ObjectType.wrap(301);
  ObjectType constant PolishedTuffWall = ObjectType.wrap(302);
  ObjectType constant PolishedBasaltWall = ObjectType.wrap(303);
  ObjectType constant PolishedBlackstoneWall = ObjectType.wrap(304);
  ObjectType constant DeepslateWall = ObjectType.wrap(305);
  ObjectType constant CobbledDeepslateWall = ObjectType.wrap(306);
  ObjectType constant DeepslateBricksWall = ObjectType.wrap(307);
  ObjectType constant SandstoneWall = ObjectType.wrap(308);
  ObjectType constant RedSandstoneWall = ObjectType.wrap(309);
  ObjectType constant BrickBlockWall = ObjectType.wrap(310);
  ObjectType constant MudBricksWall = ObjectType.wrap(311);
  ObjectType constant TuffBricksWall = ObjectType.wrap(312);
  ObjectType constant Coral = ObjectType.wrap(313);
  ObjectType constant SeaAnemone = ObjectType.wrap(314);
  ObjectType constant Algae = ObjectType.wrap(315);
  ObjectType constant HornCoralBlock = ObjectType.wrap(316);
  ObjectType constant FireCoralBlock = ObjectType.wrap(317);
  ObjectType constant TubeCoralBlock = ObjectType.wrap(318);
  ObjectType constant BubbleCoralBlock = ObjectType.wrap(319);
  ObjectType constant BrainCoralBlock = ObjectType.wrap(320);
  ObjectType constant Snow = ObjectType.wrap(321);
  ObjectType constant Ice = ObjectType.wrap(322);
  ObjectType constant Lava = ObjectType.wrap(323);
  ObjectType constant SpiderWeb = ObjectType.wrap(324);
  ObjectType constant Bone = ObjectType.wrap(325);
  ObjectType constant CoalOre = ObjectType.wrap(326);
  ObjectType constant CopperOre = ObjectType.wrap(327);
  ObjectType constant IronOre = ObjectType.wrap(328);
  ObjectType constant GoldOre = ObjectType.wrap(329);
  ObjectType constant DiamondOre = ObjectType.wrap(330);
  ObjectType constant NeptuniumOre = ObjectType.wrap(331);
  ObjectType constant TextSign = ObjectType.wrap(332);
  ObjectType constant OakPlanks = ObjectType.wrap(333);
  ObjectType constant BirchPlanks = ObjectType.wrap(334);
  ObjectType constant JunglePlanks = ObjectType.wrap(335);
  ObjectType constant SakuraPlanks = ObjectType.wrap(336);
  ObjectType constant SprucePlanks = ObjectType.wrap(337);
  ObjectType constant AcaciaPlanks = ObjectType.wrap(338);
  ObjectType constant DarkOakPlanks = ObjectType.wrap(339);
  ObjectType constant MangrovePlanks = ObjectType.wrap(340);
  ObjectType constant CopperBlock = ObjectType.wrap(341);
  ObjectType constant IronBlock = ObjectType.wrap(342);
  ObjectType constant GoldBlock = ObjectType.wrap(343);
  ObjectType constant DiamondBlock = ObjectType.wrap(344);
  ObjectType constant NeptuniumBlock = ObjectType.wrap(345);
  ObjectType constant WheatSeed = ObjectType.wrap(346);
  ObjectType constant PumpkinSeed = ObjectType.wrap(347);
  ObjectType constant MelonSeed = ObjectType.wrap(348);
  ObjectType constant OakSapling = ObjectType.wrap(349);
  ObjectType constant BirchSapling = ObjectType.wrap(350);
  ObjectType constant JungleSapling = ObjectType.wrap(351);
  ObjectType constant SakuraSapling = ObjectType.wrap(352);
  ObjectType constant AcaciaSapling = ObjectType.wrap(353);
  ObjectType constant SpruceSapling = ObjectType.wrap(354);
  ObjectType constant DarkOakSapling = ObjectType.wrap(355);
  ObjectType constant MangroveSapling = ObjectType.wrap(356);
  ObjectType constant ForceField = ObjectType.wrap(357);
  ObjectType constant Chest = ObjectType.wrap(358);
  ObjectType constant SpawnTile = ObjectType.wrap(359);
  ObjectType constant Bed = ObjectType.wrap(360);
  ObjectType constant Workbench = ObjectType.wrap(361);
  ObjectType constant Powerstone = ObjectType.wrap(362);
  ObjectType constant Stonecutter = ObjectType.wrap(363);
  ObjectType constant Furnace = ObjectType.wrap(364);
  ObjectType constant Torch = ObjectType.wrap(365);
  ObjectType constant WoodenPick = ObjectType.wrap(32768);
  ObjectType constant CopperPick = ObjectType.wrap(32769);
  ObjectType constant IronPick = ObjectType.wrap(32770);
  ObjectType constant GoldPick = ObjectType.wrap(32771);
  ObjectType constant DiamondPick = ObjectType.wrap(32772);
  ObjectType constant NeptuniumPick = ObjectType.wrap(32773);
  ObjectType constant WoodenAxe = ObjectType.wrap(32774);
  ObjectType constant CopperAxe = ObjectType.wrap(32775);
  ObjectType constant IronAxe = ObjectType.wrap(32776);
  ObjectType constant GoldAxe = ObjectType.wrap(32777);
  ObjectType constant DiamondAxe = ObjectType.wrap(32778);
  ObjectType constant NeptuniumAxe = ObjectType.wrap(32779);
  ObjectType constant WoodenWhacker = ObjectType.wrap(32780);
  ObjectType constant CopperWhacker = ObjectType.wrap(32781);
  ObjectType constant IronWhacker = ObjectType.wrap(32782);
  ObjectType constant WoodenHoe = ObjectType.wrap(32783);
  ObjectType constant GoldBar = ObjectType.wrap(32784);
  ObjectType constant IronBar = ObjectType.wrap(32785);
  ObjectType constant Diamond = ObjectType.wrap(32786);
  ObjectType constant NeptuniumBar = ObjectType.wrap(32787);
  ObjectType constant Bucket = ObjectType.wrap(32788);
  ObjectType constant WaterBucket = ObjectType.wrap(32789);
  ObjectType constant WheatSlop = ObjectType.wrap(32790);
  ObjectType constant PumpkinSoup = ObjectType.wrap(32791);
  ObjectType constant MelonSmoothie = ObjectType.wrap(32792);
  ObjectType constant Battery = ObjectType.wrap(32793);
  ObjectType constant AnyLog = ObjectType.wrap(32794);
  ObjectType constant AnyPlank = ObjectType.wrap(32795);
  ObjectType constant AnyTerracotta = ObjectType.wrap(32796);
  ObjectType constant AnyLeaf = ObjectType.wrap(32797);
  ObjectType constant Player = ObjectType.wrap(32798);
  ObjectType constant Fragment = ObjectType.wrap(32799);
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

  function isNonSolid(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x6), 1)
        ok := bit
      }
    }
  }

  function isAny(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32794..33049]
      {
        let off := sub(self, 32794)
        let bit := and(shr(off, 0xf), 1)
        ok := bit
      }
    }
  }

  function isBlock(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x3fffffffffffffffc00001ffffffff0), 1)
        ok := bit
      }

      // IDs in [313..568]
      {
        let off := sub(self, 313)
        let bit := and(shr(off, 0x1bfffffffffbff), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isTerracotta(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x7ffc00000000000000), 1)
        ok := bit
      }
    }
  }

  function isOre(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [326..581]
      {
        let off := sub(self, 326)
        let bit := and(shr(off, 0x3f), 1)
        ok := bit
      }
    }
  }

  function isLog(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x7f800000000000000000), 1)
        ok := bit
      }
    }
  }

  function isLeaf(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1ff80000000000000000000), 1)
        ok := bit
      }
    }
  }

  function isPlank(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [333..588]
      {
        let off := sub(self, 333)
        let bit := and(shr(off, 0xff), 1)
        ok := bit
      }
    }
  }

  function isSeed(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [346..601]
      {
        let off := sub(self, 346)
        let bit := and(shr(off, 0x7), 1)
        ok := bit
      }
    }
  }

  function isSapling(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [349..604]
      {
        let off := sub(self, 349)
        let bit := and(shr(off, 0xff), 1)
        ok := bit
      }
    }
  }

  function isSmartEntity(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [177..432]
      {
        let off := sub(self, 177)
        let bit := and(shr(off, 0xf00000080000000000000000000000000000000003ffff), 1)
        ok := bit
      }

      // IDs in [32799..33054]
      {
        let off := sub(self, 32799)
        let bit := and(shr(off, 0x1), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isStation(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [361..616]
      {
        let off := sub(self, 361)
        let bit := and(shr(off, 0xf), 1)
        ok := bit
      }
    }
  }

  function isPick(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32768..33023]
      {
        let off := sub(self, 32768)
        let bit := and(shr(off, 0x3f), 1)
        ok := bit
      }
    }
  }

  function isAxe(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32774..33029]
      {
        let off := sub(self, 32774)
        let bit := and(shr(off, 0x3f), 1)
        ok := bit
      }
    }
  }

  function isHoe(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32783..33038]
      {
        let off := sub(self, 32783)
        let bit := and(shr(off, 0x1), 1)
        ok := bit
      }
    }
  }

  function isWhacker(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32780..33035]
      {
        let off := sub(self, 32780)
        let bit := and(shr(off, 0x7), 1)
        ok := bit
      }
    }
  }

  function isOreBar(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32784..33039]
      {
        let off := sub(self, 32784)
        let bit := and(shr(off, 0xf), 1)
        ok := bit
      }
    }
  }

  function isFood(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32790..33045]
      {
        let off := sub(self, 32790)
        let bit := and(shr(off, 0x7), 1)
        ok := bit
      }
    }
  }

  function isFuel(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32793..33048]
      {
        let off := sub(self, 32793)
        let bit := and(shr(off, 0x1), 1)
        ok := bit
      }
    }
  }

  function isPlayer(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32798..33053]
      {
        let off := sub(self, 32798)
        let bit := and(shr(off, 0x1), 1)
        ok := bit
      }
    }
  }

  function hasExtraDrops(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1e0180013f80000000000000000000), 1)
        ok := bit
      }
    }
  }

  function hasAxeMultiplier(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x3f8000007ffff800000000000000000), 1)
        ok := bit
      }

      // IDs in [332..587]
      {
        let off := sub(self, 332)
        let bit := and(shr(off, 0x23c0001ff), 1)
        ok := or(ok, bit)
      }
    }
  }

  function hasPickMultiplier(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x7ffc000000001ffff0), 1)
        ok := bit
      }

      // IDs in [326..581]
      {
        let off := sub(self, 326)
        let bit := and(shr(off, 0x50800f803f), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isWoodenTool(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32768..33023]
      {
        let off := sub(self, 32768)
        let bit := and(shr(off, 0x9041), 1)
        ok := bit
      }
    }
  }

  function isPassThrough(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x107fffff80000000000000000000006), 1)
        ok := bit
      }

      // IDs in [313..568]
      {
        let off := sub(self, 313)
        let bit := and(shr(off, 0x100ffe00000007), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isGrowable(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [346..601]
      {
        let off := sub(self, 346)
        let bit := and(shr(off, 0x7ff), 1)
        ok := bit
      }
    }
  }

  function isLandbound(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [113..368]
      {
        let off := sub(self, 113)
        let bit := and(shr(off, 0xffe0000000000000000000000000000000000000000000000000000000001), 1)
        ok := bit
      }
    }
  }

  function isUniqueObject(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [357..612]
      {
        let off := sub(self, 357)
        let bit := and(shr(off, 0xd), 1)
        ok := bit
      }

      // IDs in [32768..33023]
      {
        let off := sub(self, 32768)
        let bit := and(shr(off, 0x30ffff), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isTool(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [32768..33023]
      {
        let off := sub(self, 32768)
        let bit := and(shr(off, 0xffff), 1)
        ok := bit
      }
    }
  }

  function isTillable(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x600000), 1)
        ok := bit
      }
    }
  }

  function isMachine(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [357..612]
      {
        let off := sub(self, 357)
        let bit := and(shr(off, 0x1), 1)
        ok := bit
      }
    }
  }

  function spawnsWithFluid(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x4), 1)
        ok := bit
      }

      // IDs in [313..568]
      {
        let off := sub(self, 313)
        let bit := and(shr(off, 0x4ff), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isWaterloggable(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x7fffffffc00001f8dfffff0), 1)
        ok := bit
      }

      // IDs in [313..568]
      {
        let off := sub(self, 313)
        let bit := and(shr(off, 0x137001fffff2ff), 1)
        ok := or(ok, bit)
      }
    }
  }

  function isPreferredSpawn(ObjectType self) internal pure returns (bool ok) {
    /// @solidity memory-safe-assembly
    assembly {
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x100600010), 1)
        ok := bit
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

  function getBlockTypes() internal pure returns (ObjectType[148] memory) {
    return [
      ObjectTypes.Stone,
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
      ObjectTypes.TextSign,
      ObjectTypes.Torch
    ];
  }

  function getTerracottaTypes() internal pure returns (ObjectType[13] memory) {
    return [
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

  function getOreTypes() internal pure returns (ObjectType[6] memory) {
    return [
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

  function getLeafTypes() internal pure returns (ObjectType[10] memory) {
    return [
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf
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

  function getSmartEntityTypes() internal pure returns (ObjectType[24] memory) {
    return [
      ObjectTypes.ForceField,
      ObjectTypes.Chest,
      ObjectTypes.SpawnTile,
      ObjectTypes.Bed,
      ObjectTypes.Fragment,
      ObjectTypes.TextSign,
      ObjectTypes.OakDoor,
      ObjectTypes.BirchDoor,
      ObjectTypes.JungleDoor,
      ObjectTypes.SakuraDoor,
      ObjectTypes.AcaciaDoor,
      ObjectTypes.SpruceDoor,
      ObjectTypes.DarkOakDoor,
      ObjectTypes.MangroveDoor,
      ObjectTypes.IronDoor,
      ObjectTypes.OakTrapdoor,
      ObjectTypes.BirchTrapdoor,
      ObjectTypes.JungleTrapdoor,
      ObjectTypes.SakuraTrapdoor,
      ObjectTypes.AcaciaTrapdoor,
      ObjectTypes.SpruceTrapdoor,
      ObjectTypes.DarkOakTrapdoor,
      ObjectTypes.MangroveTrapdoor,
      ObjectTypes.IronTrapdoor
    ];
  }

  function getStationTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.Furnace, ObjectTypes.Stonecutter];
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

  function getExtraDropsTypes() internal pure returns (ObjectType[14] memory) {
    return [
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.MangroveLeaf,
      ObjectTypes.Wheat,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.CottonBush
    ];
  }

  function getAxeMultiplierTypes() internal pure returns (ObjectType[41] memory) {
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

  function getPickMultiplierTypes() internal pure returns (ObjectType[44] memory) {
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

  function getWoodenToolTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.WoodenPick, ObjectTypes.WoodenAxe, ObjectTypes.WoodenWhacker, ObjectTypes.WoodenHoe];
  }

  function getPassThroughTypes() internal pure returns (ObjectType[42] memory) {
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
      ObjectTypes.Torch,
      ObjectTypes.BambooBush
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

  function getLandboundTypes() internal pure returns (ObjectType[12] memory) {
    return [
      ObjectTypes.Wheat,
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

  function getSpawnsWithFluidTypes() internal pure returns (ObjectType[10] memory) {
    return [
      ObjectTypes.Lava,
      ObjectTypes.Water,
      ObjectTypes.Coral,
      ObjectTypes.SeaAnemone,
      ObjectTypes.Algae,
      ObjectTypes.HornCoralBlock,
      ObjectTypes.FireCoralBlock,
      ObjectTypes.TubeCoralBlock,
      ObjectTypes.BubbleCoralBlock,
      ObjectTypes.BrainCoralBlock
    ];
  }

  function getWaterloggableTypes() internal pure returns (ObjectType[98] memory) {
    return [
      ObjectTypes.Stone,
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
      ObjectTypes.Mud,
      ObjectTypes.PackedMud,
      ObjectTypes.Ice,
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
      ObjectTypes.Coral,
      ObjectTypes.SeaAnemone,
      ObjectTypes.Algae,
      ObjectTypes.HornCoralBlock,
      ObjectTypes.FireCoralBlock,
      ObjectTypes.TubeCoralBlock,
      ObjectTypes.BubbleCoralBlock,
      ObjectTypes.BrainCoralBlock,
      ObjectTypes.Bone,
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
      ObjectTypes.Workbench,
      ObjectTypes.Powerstone,
      ObjectTypes.ForceField,
      ObjectTypes.Chest,
      ObjectTypes.SpawnTile,
      ObjectTypes.TextSign,
      ObjectTypes.Torch
    ];
  }

  function getPreferredSpawnTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.Dirt, ObjectTypes.Grass, ObjectTypes.Sand, ObjectTypes.Stone];
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
      bedRelativePositions[0] = vec3(1, 0, 0);
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
  function getRelativeCoords(ObjectType self, Vec3 baseCoord, Orientation orientation)
    internal
    pure
    returns (Vec3[] memory)
  {
    require(isOrientationSupported(self, orientation), "Orientation not supported");

    Vec3[] memory schemaCoords = getObjectTypeSchema(self);
    Vec3[] memory coords = new Vec3[](schemaCoords.length + 1);

    coords[0] = baseCoord;

    for (uint256 i = 0; i < schemaCoords.length; i++) {
      coords[i + 1] = baseCoord + schemaCoords[i].applyOrientation(orientation);
    }

    return coords;
  }

  function isOrientationSupported(ObjectType self, Orientation orientation) internal pure returns (bool) {
    if (self == ObjectTypes.OakDoor) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.IronDoor) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.TextSign) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.ForceField) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Chest) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.SpawnTile) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Bed) {
      return orientation == Orientation.wrap(1) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Workbench) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Powerstone) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Stonecutter) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }
    if (self == ObjectTypes.Furnace) {
      return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1)
        || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
    }

    return orientation == Orientation.wrap(0);
  }

  function getRelativeCoords(ObjectType self, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(self, baseCoord, Orientation.wrap(0));
  }

  function isActionAllowed(ObjectType self, bytes4 sig) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    if (self == ObjectTypes.Chest) {
      return sig == ITransferSystem.transfer.selector || sig == ITransferSystem.transferAmounts.selector
        || sig == IMachineSystem.fuelMachine.selector;
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
    if (self == ObjectTypes.MangroveLeaf) return ObjectTypes.MangroveSapling;
    return ObjectTypes.Null;
  }

  function getTimeToGrow(ObjectType self) internal pure returns (uint128) {
    if (self == ObjectTypes.WheatSeed) return 1020;
    if (self == ObjectTypes.PumpkinSeed) return 10260;
    if (self == ObjectTypes.MelonSeed) return 10260;
    if (self == ObjectTypes.OakSapling) return 44400;
    if (self == ObjectTypes.BirchSapling) return 41700;
    if (self == ObjectTypes.JungleSapling) return 90000;
    if (self == ObjectTypes.SakuraSapling) return 66000;
    if (self == ObjectTypes.AcaciaSapling) return 47400;
    if (self == ObjectTypes.SpruceSapling) return 76800;
    if (self == ObjectTypes.DarkOakSapling) return 60600;
    if (self == ObjectTypes.MangroveSapling) return 69600;
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
      return on == ObjectTypes.Dirt || on == ObjectTypes.Grass || on == ObjectTypes.Moss;
    }
    return false;
  }

  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (!self.isAny()) return self == other;

    return (self == ObjectTypes.AnyLog && other.isLog()) || (self == ObjectTypes.AnyPlank && other.isPlank())
      || (self == ObjectTypes.AnyLeaf && other.isLeaf());
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
