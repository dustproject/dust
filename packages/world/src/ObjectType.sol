// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

// 7 category bits (bits 15..9), 9 index bits (bits 8..0)
uint16 constant CATEGORY_MASK = 0xF800;
uint16 constant CATEGORY_SHIFT = 9;
uint16 constant BLOCK_CATEGORY_COUNT = 128 / 2; // 31

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  uint16 constant NONE = 0;
  // Block Categories
  uint16 constant NON_SOLID = uint16(1) << CATEGORY_SHIFT;
  uint16 constant STONE = uint16(2) << CATEGORY_SHIFT;
  uint16 constant GEMSTONE = uint16(3) << CATEGORY_SHIFT;
  uint16 constant SOIL = uint16(4) << CATEGORY_SHIFT;
  uint16 constant ORE = uint16(5) << CATEGORY_SHIFT;
  uint16 constant SAND = uint16(6) << CATEGORY_SHIFT;
  uint16 constant CLAY = uint16(7) << CATEGORY_SHIFT;
  uint16 constant LOG = uint16(8) << CATEGORY_SHIFT;
  uint16 constant LEAF = uint16(9) << CATEGORY_SHIFT;
  uint16 constant FLOWER = uint16(10) << CATEGORY_SHIFT;
  uint16 constant GREENERY = uint16(11) << CATEGORY_SHIFT;
  uint16 constant CROP = uint16(12) << CATEGORY_SHIFT;
  uint16 constant UNDERWATER_PLANT = uint16(13) << CATEGORY_SHIFT;
  uint16 constant PLANK = uint16(14) << CATEGORY_SHIFT;
  uint16 constant ORE_BLOCK = uint16(15) << CATEGORY_SHIFT;
  uint16 constant GROWABLE = uint16(16) << CATEGORY_SHIFT;
  uint16 constant STATION = uint16(17) << CATEGORY_SHIFT;
  uint16 constant SMART = uint16(18) << CATEGORY_SHIFT;
  // Non-Block Categories
  uint16 constant TOOL = uint16(65) << CATEGORY_SHIFT;
  uint16 constant OREBAR = uint16(66) << CATEGORY_SHIFT;
  uint16 constant BUCKET = uint16(67) << CATEGORY_SHIFT;
  uint16 constant FOOD = uint16(68) << CATEGORY_SHIFT;
  uint16 constant MOVABLE = uint16(69) << CATEGORY_SHIFT;
  uint16 constant MISC = uint16(70) << CATEGORY_SHIFT;
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint128; mask bit k set if raw category ID k belongs)
  uint128 constant BLOCK_MASK = uint128(type(uint64).max);
  uint128 constant HAS_ANY_MASK = (uint128(1) << (LOG >> CATEGORY_SHIFT)) | (uint128(1) << (LEAF >> CATEGORY_SHIFT))
    | (uint128(1) << (PLANK >> CATEGORY_SHIFT)) | (uint128(1) << (ORE >> CATEGORY_SHIFT));
  uint128 constant PASS_THROUGH_MASK = (uint128(1) << (NON_SOLID >> CATEGORY_SHIFT))
    | (uint128(1) << (LEAF >> CATEGORY_SHIFT)) | (uint128(1) << (FLOWER >> CATEGORY_SHIFT))
    | (uint128(1) << (GROWABLE >> CATEGORY_SHIFT)) | (uint128(1) << (GREENERY >> CATEGORY_SHIFT))
    | (uint128(1) << (CROP >> CATEGORY_SHIFT)) | (uint128(1) << (UNDERWATER_PLANT >> CATEGORY_SHIFT));
  uint128 constant MINEABLE_MASK = BLOCK_MASK & ~(uint128(1) << (NON_SOLID >> CATEGORY_SHIFT));
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
  ObjectType constant Null = ObjectType.wrap(Category.NONE | 0);
  ObjectType constant Air = ObjectType.wrap(Category.NON_SOLID | 0);
  ObjectType constant Water = ObjectType.wrap(Category.NON_SOLID | 1);
  ObjectType constant Lava = ObjectType.wrap(Category.NON_SOLID | 2);
  ObjectType constant Stone = ObjectType.wrap(Category.STONE | 0);
  ObjectType constant Bedrock = ObjectType.wrap(Category.STONE | 1);
  ObjectType constant Deepslate = ObjectType.wrap(Category.STONE | 2);
  ObjectType constant Granite = ObjectType.wrap(Category.STONE | 3);
  ObjectType constant Tuff = ObjectType.wrap(Category.STONE | 4);
  ObjectType constant Calcite = ObjectType.wrap(Category.STONE | 5);
  ObjectType constant Basalt = ObjectType.wrap(Category.STONE | 6);
  ObjectType constant SmoothBasalt = ObjectType.wrap(Category.STONE | 7);
  ObjectType constant Andesite = ObjectType.wrap(Category.STONE | 8);
  ObjectType constant Diorite = ObjectType.wrap(Category.STONE | 9);
  ObjectType constant Cobblestone = ObjectType.wrap(Category.STONE | 10);
  ObjectType constant MossyCobblestone = ObjectType.wrap(Category.STONE | 11);
  ObjectType constant Obsidian = ObjectType.wrap(Category.STONE | 12);
  ObjectType constant Dripstone = ObjectType.wrap(Category.STONE | 13);
  ObjectType constant Blackstone = ObjectType.wrap(Category.STONE | 14);
  ObjectType constant CobbledDeepslate = ObjectType.wrap(Category.STONE | 15);
  ObjectType constant Amethyst = ObjectType.wrap(Category.GEMSTONE | 0);
  ObjectType constant Glowstone = ObjectType.wrap(Category.GEMSTONE | 1);
  ObjectType constant Grass = ObjectType.wrap(Category.SOIL | 0);
  ObjectType constant Dirt = ObjectType.wrap(Category.SOIL | 1);
  ObjectType constant Moss = ObjectType.wrap(Category.SOIL | 2);
  ObjectType constant Podzol = ObjectType.wrap(Category.SOIL | 3);
  ObjectType constant DirtPath = ObjectType.wrap(Category.SOIL | 4);
  ObjectType constant Mud = ObjectType.wrap(Category.SOIL | 5);
  ObjectType constant PackedMud = ObjectType.wrap(Category.SOIL | 6);
  ObjectType constant Farmland = ObjectType.wrap(Category.SOIL | 7);
  ObjectType constant WetFarmland = ObjectType.wrap(Category.SOIL | 8);
  ObjectType constant AnyOre = ObjectType.wrap(Category.ORE | 0);
  ObjectType constant CoalOre = ObjectType.wrap(Category.ORE | 1);
  ObjectType constant CopperOre = ObjectType.wrap(Category.ORE | 2);
  ObjectType constant IronOre = ObjectType.wrap(Category.ORE | 3);
  ObjectType constant GoldOre = ObjectType.wrap(Category.ORE | 4);
  ObjectType constant DiamondOre = ObjectType.wrap(Category.ORE | 5);
  ObjectType constant NeptuniumOre = ObjectType.wrap(Category.ORE | 6);
  ObjectType constant Gravel = ObjectType.wrap(Category.SAND | 0);
  ObjectType constant Sand = ObjectType.wrap(Category.SAND | 1);
  ObjectType constant RedSand = ObjectType.wrap(Category.SAND | 2);
  ObjectType constant Sandstone = ObjectType.wrap(Category.SAND | 3);
  ObjectType constant RedSandstone = ObjectType.wrap(Category.SAND | 4);
  ObjectType constant Clay = ObjectType.wrap(Category.CLAY | 0);
  ObjectType constant Terracotta = ObjectType.wrap(Category.CLAY | 1);
  ObjectType constant BrownTerracotta = ObjectType.wrap(Category.CLAY | 2);
  ObjectType constant OrangeTerracotta = ObjectType.wrap(Category.CLAY | 3);
  ObjectType constant WhiteTerracotta = ObjectType.wrap(Category.CLAY | 4);
  ObjectType constant LightGrayTerracotta = ObjectType.wrap(Category.CLAY | 5);
  ObjectType constant YellowTerracotta = ObjectType.wrap(Category.CLAY | 6);
  ObjectType constant RedTerracotta = ObjectType.wrap(Category.CLAY | 7);
  ObjectType constant LightBlueTerracotta = ObjectType.wrap(Category.CLAY | 8);
  ObjectType constant CyanTerracotta = ObjectType.wrap(Category.CLAY | 9);
  ObjectType constant BlackTerracotta = ObjectType.wrap(Category.CLAY | 10);
  ObjectType constant PurpleTerracotta = ObjectType.wrap(Category.CLAY | 11);
  ObjectType constant BlueTerracotta = ObjectType.wrap(Category.CLAY | 12);
  ObjectType constant MagentaTerracotta = ObjectType.wrap(Category.CLAY | 13);
  ObjectType constant AnyLog = ObjectType.wrap(Category.LOG | 0);
  ObjectType constant OakLog = ObjectType.wrap(Category.LOG | 1);
  ObjectType constant BirchLog = ObjectType.wrap(Category.LOG | 2);
  ObjectType constant JungleLog = ObjectType.wrap(Category.LOG | 3);
  ObjectType constant SakuraLog = ObjectType.wrap(Category.LOG | 4);
  ObjectType constant AcaciaLog = ObjectType.wrap(Category.LOG | 5);
  ObjectType constant SpruceLog = ObjectType.wrap(Category.LOG | 6);
  ObjectType constant DarkOakLog = ObjectType.wrap(Category.LOG | 7);
  ObjectType constant MangroveLog = ObjectType.wrap(Category.LOG | 8);
  ObjectType constant AnyLeaf = ObjectType.wrap(Category.LEAF | 0);
  ObjectType constant OakLeaf = ObjectType.wrap(Category.LEAF | 1);
  ObjectType constant BirchLeaf = ObjectType.wrap(Category.LEAF | 2);
  ObjectType constant JungleLeaf = ObjectType.wrap(Category.LEAF | 3);
  ObjectType constant SakuraLeaf = ObjectType.wrap(Category.LEAF | 4);
  ObjectType constant SpruceLeaf = ObjectType.wrap(Category.LEAF | 5);
  ObjectType constant AcaciaLeaf = ObjectType.wrap(Category.LEAF | 6);
  ObjectType constant DarkOakLeaf = ObjectType.wrap(Category.LEAF | 7);
  ObjectType constant AzaleaLeaf = ObjectType.wrap(Category.LEAF | 8);
  ObjectType constant FloweringAzaleaLeaf = ObjectType.wrap(Category.LEAF | 9);
  ObjectType constant MangroveLeaf = ObjectType.wrap(Category.LEAF | 10);
  ObjectType constant MangroveRoots = ObjectType.wrap(Category.LEAF | 11);
  ObjectType constant MuddyMangroveRoots = ObjectType.wrap(Category.LEAF | 12);
  ObjectType constant AzaleaFlower = ObjectType.wrap(Category.FLOWER | 0);
  ObjectType constant BellFlower = ObjectType.wrap(Category.FLOWER | 1);
  ObjectType constant DandelionFlower = ObjectType.wrap(Category.FLOWER | 2);
  ObjectType constant DaylilyFlower = ObjectType.wrap(Category.FLOWER | 3);
  ObjectType constant LilacFlower = ObjectType.wrap(Category.FLOWER | 4);
  ObjectType constant RoseFlower = ObjectType.wrap(Category.FLOWER | 5);
  ObjectType constant FireFlower = ObjectType.wrap(Category.FLOWER | 6);
  ObjectType constant MorninggloryFlower = ObjectType.wrap(Category.FLOWER | 7);
  ObjectType constant PeonyFlower = ObjectType.wrap(Category.FLOWER | 8);
  ObjectType constant Ultraviolet = ObjectType.wrap(Category.FLOWER | 9);
  ObjectType constant SunFlower = ObjectType.wrap(Category.FLOWER | 10);
  ObjectType constant FlyTrap = ObjectType.wrap(Category.FLOWER | 11);
  ObjectType constant FescueGrass = ObjectType.wrap(Category.GREENERY | 0);
  ObjectType constant SwitchGrass = ObjectType.wrap(Category.GREENERY | 1);
  ObjectType constant CottonBush = ObjectType.wrap(Category.GREENERY | 2);
  ObjectType constant BambooBush = ObjectType.wrap(Category.GREENERY | 3);
  ObjectType constant VinesBush = ObjectType.wrap(Category.GREENERY | 4);
  ObjectType constant IvyVine = ObjectType.wrap(Category.GREENERY | 5);
  ObjectType constant HempBush = ObjectType.wrap(Category.GREENERY | 6);
  ObjectType constant GoldenMushroom = ObjectType.wrap(Category.CROP | 0);
  ObjectType constant RedMushroom = ObjectType.wrap(Category.CROP | 1);
  ObjectType constant CoffeeBush = ObjectType.wrap(Category.CROP | 2);
  ObjectType constant StrawberryBush = ObjectType.wrap(Category.CROP | 3);
  ObjectType constant RaspberryBush = ObjectType.wrap(Category.CROP | 4);
  ObjectType constant Cactus = ObjectType.wrap(Category.CROP | 5);
  ObjectType constant Pumpkin = ObjectType.wrap(Category.CROP | 6);
  ObjectType constant Melon = ObjectType.wrap(Category.CROP | 7);
  ObjectType constant RedMushroomBlock = ObjectType.wrap(Category.CROP | 8);
  ObjectType constant BrownMushroomBlock = ObjectType.wrap(Category.CROP | 9);
  ObjectType constant MushroomStem = ObjectType.wrap(Category.CROP | 10);
  ObjectType constant Wheat = ObjectType.wrap(Category.CROP | 11);
  ObjectType constant Coral = ObjectType.wrap(Category.UNDERWATER_PLANT | 0);
  ObjectType constant SeaAnemone = ObjectType.wrap(Category.UNDERWATER_PLANT | 1);
  ObjectType constant Algae = ObjectType.wrap(Category.UNDERWATER_PLANT | 2);
  ObjectType constant HornCoralBlock = ObjectType.wrap(Category.UNDERWATER_PLANT | 3);
  ObjectType constant FireCoralBlock = ObjectType.wrap(Category.UNDERWATER_PLANT | 4);
  ObjectType constant TubeCoralBlock = ObjectType.wrap(Category.UNDERWATER_PLANT | 5);
  ObjectType constant BubbleCoralBlock = ObjectType.wrap(Category.UNDERWATER_PLANT | 6);
  ObjectType constant BrainCoralBlock = ObjectType.wrap(Category.UNDERWATER_PLANT | 7);
  ObjectType constant AnyPlank = ObjectType.wrap(Category.PLANK | 0);
  ObjectType constant OakPlanks = ObjectType.wrap(Category.PLANK | 1);
  ObjectType constant BirchPlanks = ObjectType.wrap(Category.PLANK | 2);
  ObjectType constant JunglePlanks = ObjectType.wrap(Category.PLANK | 3);
  ObjectType constant SakuraPlanks = ObjectType.wrap(Category.PLANK | 4);
  ObjectType constant SprucePlanks = ObjectType.wrap(Category.PLANK | 5);
  ObjectType constant AcaciaPlanks = ObjectType.wrap(Category.PLANK | 6);
  ObjectType constant DarkOakPlanks = ObjectType.wrap(Category.PLANK | 7);
  ObjectType constant MangrovePlanks = ObjectType.wrap(Category.PLANK | 8);
  ObjectType constant CopperBlock = ObjectType.wrap(Category.ORE_BLOCK | 0);
  ObjectType constant IronBlock = ObjectType.wrap(Category.ORE_BLOCK | 1);
  ObjectType constant GoldBlock = ObjectType.wrap(Category.ORE_BLOCK | 2);
  ObjectType constant DiamondBlock = ObjectType.wrap(Category.ORE_BLOCK | 3);
  ObjectType constant NeptuniumBlock = ObjectType.wrap(Category.ORE_BLOCK | 4);
  ObjectType constant WheatSeed = ObjectType.wrap(Category.GROWABLE | 0);
  ObjectType constant PumpkinSeed = ObjectType.wrap(Category.GROWABLE | 1);
  ObjectType constant MelonSeed = ObjectType.wrap(Category.GROWABLE | 2);
  ObjectType constant OakSapling = ObjectType.wrap(Category.GROWABLE | 3);
  ObjectType constant BirchSapling = ObjectType.wrap(Category.GROWABLE | 4);
  ObjectType constant JungleSapling = ObjectType.wrap(Category.GROWABLE | 5);
  ObjectType constant SakuraSapling = ObjectType.wrap(Category.GROWABLE | 6);
  ObjectType constant AcaciaSapling = ObjectType.wrap(Category.GROWABLE | 7);
  ObjectType constant SpruceSapling = ObjectType.wrap(Category.GROWABLE | 8);
  ObjectType constant DarkOakSapling = ObjectType.wrap(Category.GROWABLE | 9);
  ObjectType constant MangroveSapling = ObjectType.wrap(Category.GROWABLE | 10);
  ObjectType constant Furnace = ObjectType.wrap(Category.STATION | 0);
  ObjectType constant Workbench = ObjectType.wrap(Category.STATION | 1);
  ObjectType constant Powerstone = ObjectType.wrap(Category.STATION | 2);
  ObjectType constant ForceField = ObjectType.wrap(Category.SMART | 0);
  ObjectType constant Chest = ObjectType.wrap(Category.SMART | 1);
  ObjectType constant SpawnTile = ObjectType.wrap(Category.SMART | 2);
  ObjectType constant Bed = ObjectType.wrap(Category.SMART | 3);
  ObjectType constant WoodenPick = ObjectType.wrap(Category.TOOL | 0);
  ObjectType constant WoodenAxe = ObjectType.wrap(Category.TOOL | 1);
  ObjectType constant WoodenWhacker = ObjectType.wrap(Category.TOOL | 2);
  ObjectType constant WoodenHoe = ObjectType.wrap(Category.TOOL | 3);
  ObjectType constant CopperPick = ObjectType.wrap(Category.TOOL | 4);
  ObjectType constant CopperAxe = ObjectType.wrap(Category.TOOL | 5);
  ObjectType constant CopperWhacker = ObjectType.wrap(Category.TOOL | 6);
  ObjectType constant IronPick = ObjectType.wrap(Category.TOOL | 7);
  ObjectType constant IronAxe = ObjectType.wrap(Category.TOOL | 8);
  ObjectType constant IronWhacker = ObjectType.wrap(Category.TOOL | 9);
  ObjectType constant GoldPick = ObjectType.wrap(Category.TOOL | 10);
  ObjectType constant GoldAxe = ObjectType.wrap(Category.TOOL | 11);
  ObjectType constant DiamondPick = ObjectType.wrap(Category.TOOL | 12);
  ObjectType constant DiamondAxe = ObjectType.wrap(Category.TOOL | 13);
  ObjectType constant NeptuniumPick = ObjectType.wrap(Category.TOOL | 14);
  ObjectType constant NeptuniumAxe = ObjectType.wrap(Category.TOOL | 15);
  ObjectType constant GoldBar = ObjectType.wrap(Category.OREBAR | 0);
  ObjectType constant IronBar = ObjectType.wrap(Category.OREBAR | 1);
  ObjectType constant Diamond = ObjectType.wrap(Category.OREBAR | 2);
  ObjectType constant NeptuniumBar = ObjectType.wrap(Category.OREBAR | 3);
  ObjectType constant Bucket = ObjectType.wrap(Category.BUCKET | 0);
  ObjectType constant WaterBucket = ObjectType.wrap(Category.BUCKET | 1);
  ObjectType constant Fuel = ObjectType.wrap(Category.FOOD | 0);
  ObjectType constant WheatSlop = ObjectType.wrap(Category.FOOD | 1);
  ObjectType constant Player = ObjectType.wrap(Category.MOVABLE | 0);
  ObjectType constant Fragment = ObjectType.wrap(Category.MISC | 0);
  ObjectType constant Snow = ObjectType.wrap(Category.MISC | 1);
  ObjectType constant Ice = ObjectType.wrap(Category.MISC | 2);
  ObjectType constant SpiderWeb = ObjectType.wrap(Category.MISC | 3);
  ObjectType constant Bone = ObjectType.wrap(Category.MISC | 4);
  ObjectType constant TextSign = ObjectType.wrap(Category.MISC | 5);
}

// ------------------------------------------------------------
library ObjectTypeLib {
  function unwrap(ObjectType self) internal pure returns (uint16) {
    return ObjectType.unwrap(self);
  }

  /// @dev Extract raw category ID from the top bits
  function category(ObjectType self) internal pure returns (uint16) {
    return self.unwrap() & CATEGORY_MASK;
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    return category(self) < BLOCK_CATEGORY_COUNT && !self.isNull();
  }

  // Direct Category Checks

  function isNon_solid(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.NON_SOLID;
  }

  function isStone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.STONE;
  }

  function isGemstone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GEMSTONE;
  }

  function isSoil(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SOIL;
  }

  function isOre(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.ORE;
  }

  function isSand(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SAND;
  }

  function isClay(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.CLAY;
  }

  function isLog(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.LOG;
  }

  function isLeaf(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.LEAF;
  }

  function isFlower(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.FLOWER;
  }

  function isGreenery(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GREENERY;
  }

  function isCrop(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.CROP;
  }

  function isUnderwater_plant(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.UNDERWATER_PLANT;
  }

  function isPlank(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.PLANK;
  }

  function isOre_block(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.ORE_BLOCK;
  }

  function isGrowable(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.GROWABLE;
  }

  function isStation(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.STATION;
  }

  function isSmart(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SMART;
  }

  function isTool(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.TOOL;
  }

  function isOrebar(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.OREBAR;
  }

  function isBucket(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.BUCKET;
  }

  function isFood(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.FOOD;
  }

  function isMovable(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MOVABLE;
  }

  function isMisc(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MISC;
  }

  // Category getters
  function getNon_solidTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water, ObjectTypes.Lava];
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
      ObjectTypes.AnyOre,
      ObjectTypes.CoalOre,
      ObjectTypes.CopperOre,
      ObjectTypes.IronOre,
      ObjectTypes.GoldOre,
      ObjectTypes.DiamondOre,
      ObjectTypes.NeptuniumOre
    ];
  }

  function getSandTypes() internal pure returns (ObjectType[5] memory) {
    return [ObjectTypes.Gravel, ObjectTypes.Sand, ObjectTypes.RedSand, ObjectTypes.Sandstone, ObjectTypes.RedSandstone];
  }

  function getClayTypes() internal pure returns (ObjectType[14] memory) {
    return [
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

  function getGreeneryTypes() internal pure returns (ObjectType[7] memory) {
    return [
      ObjectTypes.FescueGrass,
      ObjectTypes.SwitchGrass,
      ObjectTypes.CottonBush,
      ObjectTypes.BambooBush,
      ObjectTypes.VinesBush,
      ObjectTypes.IvyVine,
      ObjectTypes.HempBush
    ];
  }

  function getCropTypes() internal pure returns (ObjectType[12] memory) {
    return [
      ObjectTypes.GoldenMushroom,
      ObjectTypes.RedMushroom,
      ObjectTypes.CoffeeBush,
      ObjectTypes.StrawberryBush,
      ObjectTypes.RaspberryBush,
      ObjectTypes.Cactus,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon,
      ObjectTypes.RedMushroomBlock,
      ObjectTypes.BrownMushroomBlock,
      ObjectTypes.MushroomStem,
      ObjectTypes.Wheat
    ];
  }

  function getUnderwater_plantTypes() internal pure returns (ObjectType[8] memory) {
    return [
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

  function getOre_blockTypes() internal pure returns (ObjectType[5] memory) {
    return [
      ObjectTypes.CopperBlock,
      ObjectTypes.IronBlock,
      ObjectTypes.GoldBlock,
      ObjectTypes.DiamondBlock,
      ObjectTypes.NeptuniumBlock
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

  function getStationTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Furnace, ObjectTypes.Workbench, ObjectTypes.Powerstone];
  }

  function getSmartTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.Bed];
  }

  function getToolTypes() internal pure returns (ObjectType[16] memory) {
    return [
      ObjectTypes.WoodenPick,
      ObjectTypes.WoodenAxe,
      ObjectTypes.WoodenWhacker,
      ObjectTypes.WoodenHoe,
      ObjectTypes.CopperPick,
      ObjectTypes.CopperAxe,
      ObjectTypes.CopperWhacker,
      ObjectTypes.IronPick,
      ObjectTypes.IronAxe,
      ObjectTypes.IronWhacker,
      ObjectTypes.GoldPick,
      ObjectTypes.GoldAxe,
      ObjectTypes.DiamondPick,
      ObjectTypes.DiamondAxe,
      ObjectTypes.NeptuniumPick,
      ObjectTypes.NeptuniumAxe
    ];
  }

  function getOrebarTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.GoldBar, ObjectTypes.IronBar, ObjectTypes.Diamond, ObjectTypes.NeptuniumBar];
  }

  function getBucketTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Bucket, ObjectTypes.WaterBucket];
  }

  function getFoodTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Fuel, ObjectTypes.WheatSlop];
  }

  function getMovableTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Player];
  }

  function getMiscTypes() internal pure returns (ObjectType[6] memory) {
    return [
      ObjectTypes.Fragment,
      ObjectTypes.Snow,
      ObjectTypes.Ice,
      ObjectTypes.SpiderWeb,
      ObjectTypes.Bone,
      ObjectTypes.TextSign
    ];
  }

  // Specialized getters
  function getOreAmount(ObjectType self) internal pure returns (bool) { }

  function getTimeToGrow(ObjectType self) internal pure returns (bool) {
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

  // Meta Category Checks
  function isAny(ObjectType self) internal pure returns (bool) {
    // Check if:
    // 1. ID bits are all 0
    // 2. Category is one that supports "Any" types
    uint16 c = self.category();
    uint16 idx = self.unwrap() & ~CATEGORY_MASK;

    return idx == 0 && ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.HAS_ANY_MASK) != 0;
  }

  function isPassThrough(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.PASS_THROUGH_MASK) != 0;
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint128(1) << (c >> CATEGORY_SHIFT)) & Category.MINEABLE_MASK) != 0;
  }

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
