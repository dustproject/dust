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

// 8 category bits (bits 15..8), 8 index bits (bits 7..0)
uint16 constant OFFSET_BITS = 8;
uint16 constant CATEGORY_MASK = type(uint16).max << OFFSET_BITS;
uint16 constant BLOCK_CATEGORY_COUNT = 256 / 2; // 128

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  // Block Categories
  uint16 constant NonSolid = uint16(0) << OFFSET_BITS;
  uint16 constant Stone = uint16(1) << OFFSET_BITS;
  uint16 constant Gemstone = uint16(2) << OFFSET_BITS;
  uint16 constant Soil = uint16(3) << OFFSET_BITS;
  uint16 constant Ore = uint16(4) << OFFSET_BITS;
  uint16 constant Sand = uint16(5) << OFFSET_BITS;
  uint16 constant Terracotta = uint16(6) << OFFSET_BITS;
  uint16 constant Log = uint16(7) << OFFSET_BITS;
  uint16 constant Leaf = uint16(8) << OFFSET_BITS;
  uint16 constant Flower = uint16(9) << OFFSET_BITS;
  uint16 constant Greenery = uint16(10) << OFFSET_BITS;
  uint16 constant Crop = uint16(11) << OFFSET_BITS;
  uint16 constant CropBlock = uint16(12) << OFFSET_BITS;
  uint16 constant UnderwaterPlant = uint16(13) << OFFSET_BITS;
  uint16 constant UnderwaterBlock = uint16(14) << OFFSET_BITS;
  uint16 constant MiscBlock = uint16(15) << OFFSET_BITS;
  uint16 constant Plank = uint16(16) << OFFSET_BITS;
  uint16 constant OreBlock = uint16(17) << OFFSET_BITS;
  uint16 constant Seed = uint16(18) << OFFSET_BITS;
  uint16 constant Sapling = uint16(19) << OFFSET_BITS;
  uint16 constant SmartEntityBlock = uint16(20) << OFFSET_BITS;
  uint16 constant Station = uint16(21) << OFFSET_BITS;
  uint16 constant MiscPassThrough = uint16(22) << OFFSET_BITS;
  // Non-Block Categories
  uint16 constant Pick = uint16(128) << OFFSET_BITS;
  uint16 constant Axe = uint16(129) << OFFSET_BITS;
  uint16 constant Hoe = uint16(130) << OFFSET_BITS;
  uint16 constant Whacker = uint16(131) << OFFSET_BITS;
  uint16 constant OreBar = uint16(132) << OFFSET_BITS;
  uint16 constant Bucket = uint16(133) << OFFSET_BITS;
  uint16 constant Food = uint16(134) << OFFSET_BITS;
  uint16 constant Fuel = uint16(135) << OFFSET_BITS;
  uint16 constant Player = uint16(136) << OFFSET_BITS;
  uint16 constant SmartEntityNonBlock = uint16(137) << OFFSET_BITS;
  // ------------------------------------------------------------
  // Meta Category Masks (fits within uint256; mask bit k set if raw category ID k belongs)
  uint256 constant BLOCK_MASK = uint256(type(uint128).max);
  uint256 constant MINEABLE_MASK = BLOCK_MASK & ~(uint256(1) << (NonSolid >> OFFSET_BITS));
  uint256 constant HAS_ANY_MASK = (uint256(1) << (Log >> OFFSET_BITS)) | (uint256(1) << (Leaf >> OFFSET_BITS))
    | (uint256(1) << (Plank >> OFFSET_BITS));
  uint256 constant HAS_EXTRA_DROPS_MASK = (uint256(1) << (Leaf >> OFFSET_BITS)) | (uint256(1) << (Crop >> OFFSET_BITS))
    | (uint256(1) << (CropBlock >> OFFSET_BITS)) | (uint256(1) << (Greenery >> OFFSET_BITS));
  uint256 constant HAS_AXE_MULTIPLIER_MASK = (uint256(1) << (Log >> OFFSET_BITS))
    | (uint256(1) << (Leaf >> OFFSET_BITS)) | (uint256(1) << (Plank >> OFFSET_BITS))
    | (uint256(1) << (CropBlock >> OFFSET_BITS));
  uint256 constant HAS_PICK_MULTIPLIER_MASK = (uint256(1) << (Ore >> OFFSET_BITS))
    | (uint256(1) << (Gemstone >> OFFSET_BITS)) | (uint256(1) << (Stone >> OFFSET_BITS))
    | (uint256(1) << (Terracotta >> OFFSET_BITS)) | (uint256(1) << (OreBlock >> OFFSET_BITS));
  uint256 constant IS_PASS_THROUGH_MASK = (uint256(1) << (NonSolid >> OFFSET_BITS))
    | (uint256(1) << (Flower >> OFFSET_BITS)) | (uint256(1) << (Seed >> OFFSET_BITS))
    | (uint256(1) << (Sapling >> OFFSET_BITS)) | (uint256(1) << (Greenery >> OFFSET_BITS))
    | (uint256(1) << (Crop >> OFFSET_BITS)) | (uint256(1) << (UnderwaterPlant >> OFFSET_BITS))
    | (uint256(1) << (MiscPassThrough >> OFFSET_BITS));
  uint256 constant IS_GROWABLE_MASK = (uint256(1) << (Seed >> OFFSET_BITS)) | (uint256(1) << (Sapling >> OFFSET_BITS));
  uint256 constant IS_UNIQUE_OBJECT_MASK = (uint256(1) << (Pick >> OFFSET_BITS)) | (uint256(1) << (Axe >> OFFSET_BITS))
    | (uint256(1) << (Whacker >> OFFSET_BITS)) | (uint256(1) << (Hoe >> OFFSET_BITS))
    | (uint256(1) << (Bucket >> OFFSET_BITS));
  uint256 constant IS_SMART_ENTITY_MASK =
    (uint256(1) << (SmartEntityBlock >> OFFSET_BITS)) | (uint256(1) << (SmartEntityNonBlock >> OFFSET_BITS));
  uint256 constant IS_TOOL_MASK = (uint256(1) << (Pick >> OFFSET_BITS)) | (uint256(1) << (Axe >> OFFSET_BITS))
    | (uint256(1) << (Whacker >> OFFSET_BITS)) | (uint256(1) << (Hoe >> OFFSET_BITS));
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
  ObjectType constant Null = ObjectType.wrap(Category.NonSolid | 0);
  ObjectType constant Air = ObjectType.wrap(Category.NonSolid | 1);
  ObjectType constant Water = ObjectType.wrap(Category.NonSolid | 2);
  ObjectType constant Stone = ObjectType.wrap(Category.Stone | 0);
  ObjectType constant Bedrock = ObjectType.wrap(Category.Stone | 1);
  ObjectType constant Deepslate = ObjectType.wrap(Category.Stone | 2);
  ObjectType constant Granite = ObjectType.wrap(Category.Stone | 3);
  ObjectType constant Tuff = ObjectType.wrap(Category.Stone | 4);
  ObjectType constant Calcite = ObjectType.wrap(Category.Stone | 5);
  ObjectType constant Basalt = ObjectType.wrap(Category.Stone | 6);
  ObjectType constant SmoothBasalt = ObjectType.wrap(Category.Stone | 7);
  ObjectType constant Andesite = ObjectType.wrap(Category.Stone | 8);
  ObjectType constant Diorite = ObjectType.wrap(Category.Stone | 9);
  ObjectType constant Cobblestone = ObjectType.wrap(Category.Stone | 10);
  ObjectType constant MossyCobblestone = ObjectType.wrap(Category.Stone | 11);
  ObjectType constant Obsidian = ObjectType.wrap(Category.Stone | 12);
  ObjectType constant Dripstone = ObjectType.wrap(Category.Stone | 13);
  ObjectType constant Blackstone = ObjectType.wrap(Category.Stone | 14);
  ObjectType constant CobbledDeepslate = ObjectType.wrap(Category.Stone | 15);
  ObjectType constant Amethyst = ObjectType.wrap(Category.Gemstone | 0);
  ObjectType constant Glowstone = ObjectType.wrap(Category.Gemstone | 1);
  ObjectType constant Grass = ObjectType.wrap(Category.Soil | 0);
  ObjectType constant Dirt = ObjectType.wrap(Category.Soil | 1);
  ObjectType constant Moss = ObjectType.wrap(Category.Soil | 2);
  ObjectType constant Podzol = ObjectType.wrap(Category.Soil | 3);
  ObjectType constant DirtPath = ObjectType.wrap(Category.Soil | 4);
  ObjectType constant Mud = ObjectType.wrap(Category.Soil | 5);
  ObjectType constant PackedMud = ObjectType.wrap(Category.Soil | 6);
  ObjectType constant Farmland = ObjectType.wrap(Category.Soil | 7);
  ObjectType constant WetFarmland = ObjectType.wrap(Category.Soil | 8);
  ObjectType constant UnrevealedOre = ObjectType.wrap(Category.Ore | 0);
  ObjectType constant CoalOre = ObjectType.wrap(Category.Ore | 1);
  ObjectType constant CopperOre = ObjectType.wrap(Category.Ore | 2);
  ObjectType constant IronOre = ObjectType.wrap(Category.Ore | 3);
  ObjectType constant GoldOre = ObjectType.wrap(Category.Ore | 4);
  ObjectType constant DiamondOre = ObjectType.wrap(Category.Ore | 5);
  ObjectType constant NeptuniumOre = ObjectType.wrap(Category.Ore | 6);
  ObjectType constant Gravel = ObjectType.wrap(Category.Sand | 0);
  ObjectType constant Sand = ObjectType.wrap(Category.Sand | 1);
  ObjectType constant RedSand = ObjectType.wrap(Category.Sand | 2);
  ObjectType constant Sandstone = ObjectType.wrap(Category.Sand | 3);
  ObjectType constant RedSandstone = ObjectType.wrap(Category.Sand | 4);
  ObjectType constant Clay = ObjectType.wrap(Category.Sand | 5);
  ObjectType constant AnyTerracotta = ObjectType.wrap(Category.Terracotta | 0);
  ObjectType constant Terracotta = ObjectType.wrap(Category.Terracotta | 1);
  ObjectType constant BrownTerracotta = ObjectType.wrap(Category.Terracotta | 2);
  ObjectType constant OrangeTerracotta = ObjectType.wrap(Category.Terracotta | 3);
  ObjectType constant WhiteTerracotta = ObjectType.wrap(Category.Terracotta | 4);
  ObjectType constant LightGrayTerracotta = ObjectType.wrap(Category.Terracotta | 5);
  ObjectType constant YellowTerracotta = ObjectType.wrap(Category.Terracotta | 6);
  ObjectType constant RedTerracotta = ObjectType.wrap(Category.Terracotta | 7);
  ObjectType constant LightBlueTerracotta = ObjectType.wrap(Category.Terracotta | 8);
  ObjectType constant CyanTerracotta = ObjectType.wrap(Category.Terracotta | 9);
  ObjectType constant BlackTerracotta = ObjectType.wrap(Category.Terracotta | 10);
  ObjectType constant PurpleTerracotta = ObjectType.wrap(Category.Terracotta | 11);
  ObjectType constant BlueTerracotta = ObjectType.wrap(Category.Terracotta | 12);
  ObjectType constant MagentaTerracotta = ObjectType.wrap(Category.Terracotta | 13);
  ObjectType constant AnyLog = ObjectType.wrap(Category.Log | 0);
  ObjectType constant OakLog = ObjectType.wrap(Category.Log | 1);
  ObjectType constant BirchLog = ObjectType.wrap(Category.Log | 2);
  ObjectType constant JungleLog = ObjectType.wrap(Category.Log | 3);
  ObjectType constant SakuraLog = ObjectType.wrap(Category.Log | 4);
  ObjectType constant AcaciaLog = ObjectType.wrap(Category.Log | 5);
  ObjectType constant SpruceLog = ObjectType.wrap(Category.Log | 6);
  ObjectType constant DarkOakLog = ObjectType.wrap(Category.Log | 7);
  ObjectType constant MangroveLog = ObjectType.wrap(Category.Log | 8);
  ObjectType constant AnyLeaf = ObjectType.wrap(Category.Leaf | 0);
  ObjectType constant OakLeaf = ObjectType.wrap(Category.Leaf | 1);
  ObjectType constant BirchLeaf = ObjectType.wrap(Category.Leaf | 2);
  ObjectType constant JungleLeaf = ObjectType.wrap(Category.Leaf | 3);
  ObjectType constant SakuraLeaf = ObjectType.wrap(Category.Leaf | 4);
  ObjectType constant SpruceLeaf = ObjectType.wrap(Category.Leaf | 5);
  ObjectType constant AcaciaLeaf = ObjectType.wrap(Category.Leaf | 6);
  ObjectType constant DarkOakLeaf = ObjectType.wrap(Category.Leaf | 7);
  ObjectType constant AzaleaLeaf = ObjectType.wrap(Category.Leaf | 8);
  ObjectType constant FloweringAzaleaLeaf = ObjectType.wrap(Category.Leaf | 9);
  ObjectType constant MangroveLeaf = ObjectType.wrap(Category.Leaf | 10);
  ObjectType constant MangroveRoots = ObjectType.wrap(Category.Leaf | 11);
  ObjectType constant MuddyMangroveRoots = ObjectType.wrap(Category.Leaf | 12);
  ObjectType constant AzaleaFlower = ObjectType.wrap(Category.Flower | 0);
  ObjectType constant BellFlower = ObjectType.wrap(Category.Flower | 1);
  ObjectType constant DandelionFlower = ObjectType.wrap(Category.Flower | 2);
  ObjectType constant DaylilyFlower = ObjectType.wrap(Category.Flower | 3);
  ObjectType constant LilacFlower = ObjectType.wrap(Category.Flower | 4);
  ObjectType constant RoseFlower = ObjectType.wrap(Category.Flower | 5);
  ObjectType constant FireFlower = ObjectType.wrap(Category.Flower | 6);
  ObjectType constant MorninggloryFlower = ObjectType.wrap(Category.Flower | 7);
  ObjectType constant PeonyFlower = ObjectType.wrap(Category.Flower | 8);
  ObjectType constant Ultraviolet = ObjectType.wrap(Category.Flower | 9);
  ObjectType constant SunFlower = ObjectType.wrap(Category.Flower | 10);
  ObjectType constant FlyTrap = ObjectType.wrap(Category.Flower | 11);
  ObjectType constant FescueGrass = ObjectType.wrap(Category.Greenery | 0);
  ObjectType constant SwitchGrass = ObjectType.wrap(Category.Greenery | 1);
  ObjectType constant VinesBush = ObjectType.wrap(Category.Greenery | 2);
  ObjectType constant IvyVine = ObjectType.wrap(Category.Greenery | 3);
  ObjectType constant HempBush = ObjectType.wrap(Category.Greenery | 4);
  ObjectType constant GoldenMushroom = ObjectType.wrap(Category.Crop | 0);
  ObjectType constant RedMushroom = ObjectType.wrap(Category.Crop | 1);
  ObjectType constant CoffeeBush = ObjectType.wrap(Category.Crop | 2);
  ObjectType constant StrawberryBush = ObjectType.wrap(Category.Crop | 3);
  ObjectType constant RaspberryBush = ObjectType.wrap(Category.Crop | 4);
  ObjectType constant Wheat = ObjectType.wrap(Category.Crop | 5);
  ObjectType constant CottonBush = ObjectType.wrap(Category.Crop | 6);
  ObjectType constant Pumpkin = ObjectType.wrap(Category.CropBlock | 0);
  ObjectType constant Melon = ObjectType.wrap(Category.CropBlock | 1);
  ObjectType constant RedMushroomBlock = ObjectType.wrap(Category.CropBlock | 2);
  ObjectType constant BrownMushroomBlock = ObjectType.wrap(Category.CropBlock | 3);
  ObjectType constant MushroomStem = ObjectType.wrap(Category.CropBlock | 4);
  ObjectType constant BambooBush = ObjectType.wrap(Category.CropBlock | 5);
  ObjectType constant Cactus = ObjectType.wrap(Category.CropBlock | 6);
  ObjectType constant Coral = ObjectType.wrap(Category.UnderwaterPlant | 0);
  ObjectType constant SeaAnemone = ObjectType.wrap(Category.UnderwaterPlant | 1);
  ObjectType constant Algae = ObjectType.wrap(Category.UnderwaterPlant | 2);
  ObjectType constant HornCoralBlock = ObjectType.wrap(Category.UnderwaterBlock | 0);
  ObjectType constant FireCoralBlock = ObjectType.wrap(Category.UnderwaterBlock | 1);
  ObjectType constant TubeCoralBlock = ObjectType.wrap(Category.UnderwaterBlock | 2);
  ObjectType constant BubbleCoralBlock = ObjectType.wrap(Category.UnderwaterBlock | 3);
  ObjectType constant BrainCoralBlock = ObjectType.wrap(Category.UnderwaterBlock | 4);
  ObjectType constant Snow = ObjectType.wrap(Category.MiscBlock | 0);
  ObjectType constant Ice = ObjectType.wrap(Category.MiscBlock | 1);
  ObjectType constant Magma = ObjectType.wrap(Category.MiscBlock | 2);
  ObjectType constant SpiderWeb = ObjectType.wrap(Category.MiscBlock | 3);
  ObjectType constant Bone = ObjectType.wrap(Category.MiscBlock | 4);
  ObjectType constant TextSign = ObjectType.wrap(Category.MiscBlock | 5);
  ObjectType constant AnyPlank = ObjectType.wrap(Category.Plank | 0);
  ObjectType constant OakPlanks = ObjectType.wrap(Category.Plank | 1);
  ObjectType constant BirchPlanks = ObjectType.wrap(Category.Plank | 2);
  ObjectType constant JunglePlanks = ObjectType.wrap(Category.Plank | 3);
  ObjectType constant SakuraPlanks = ObjectType.wrap(Category.Plank | 4);
  ObjectType constant SprucePlanks = ObjectType.wrap(Category.Plank | 5);
  ObjectType constant AcaciaPlanks = ObjectType.wrap(Category.Plank | 6);
  ObjectType constant DarkOakPlanks = ObjectType.wrap(Category.Plank | 7);
  ObjectType constant MangrovePlanks = ObjectType.wrap(Category.Plank | 8);
  ObjectType constant CopperBlock = ObjectType.wrap(Category.OreBlock | 0);
  ObjectType constant IronBlock = ObjectType.wrap(Category.OreBlock | 1);
  ObjectType constant GoldBlock = ObjectType.wrap(Category.OreBlock | 2);
  ObjectType constant DiamondBlock = ObjectType.wrap(Category.OreBlock | 3);
  ObjectType constant NeptuniumBlock = ObjectType.wrap(Category.OreBlock | 4);
  ObjectType constant WheatSeed = ObjectType.wrap(Category.Seed | 0);
  ObjectType constant PumpkinSeed = ObjectType.wrap(Category.Seed | 1);
  ObjectType constant MelonSeed = ObjectType.wrap(Category.Seed | 2);
  ObjectType constant OakSapling = ObjectType.wrap(Category.Sapling | 0);
  ObjectType constant BirchSapling = ObjectType.wrap(Category.Sapling | 1);
  ObjectType constant JungleSapling = ObjectType.wrap(Category.Sapling | 2);
  ObjectType constant SakuraSapling = ObjectType.wrap(Category.Sapling | 3);
  ObjectType constant AcaciaSapling = ObjectType.wrap(Category.Sapling | 4);
  ObjectType constant SpruceSapling = ObjectType.wrap(Category.Sapling | 5);
  ObjectType constant DarkOakSapling = ObjectType.wrap(Category.Sapling | 6);
  ObjectType constant MangroveSapling = ObjectType.wrap(Category.Sapling | 7);
  ObjectType constant ForceField = ObjectType.wrap(Category.SmartEntityBlock | 0);
  ObjectType constant Chest = ObjectType.wrap(Category.SmartEntityBlock | 1);
  ObjectType constant SpawnTile = ObjectType.wrap(Category.SmartEntityBlock | 2);
  ObjectType constant Bed = ObjectType.wrap(Category.SmartEntityBlock | 3);
  ObjectType constant Workbench = ObjectType.wrap(Category.Station | 0);
  ObjectType constant Powerstone = ObjectType.wrap(Category.Station | 1);
  ObjectType constant Furnace = ObjectType.wrap(Category.Station | 2);
  ObjectType constant Torch = ObjectType.wrap(Category.MiscPassThrough | 0);
  ObjectType constant WoodenPick = ObjectType.wrap(Category.Pick | 0);
  ObjectType constant CopperPick = ObjectType.wrap(Category.Pick | 1);
  ObjectType constant IronPick = ObjectType.wrap(Category.Pick | 2);
  ObjectType constant GoldPick = ObjectType.wrap(Category.Pick | 3);
  ObjectType constant DiamondPick = ObjectType.wrap(Category.Pick | 4);
  ObjectType constant NeptuniumPick = ObjectType.wrap(Category.Pick | 5);
  ObjectType constant WoodenAxe = ObjectType.wrap(Category.Axe | 0);
  ObjectType constant CopperAxe = ObjectType.wrap(Category.Axe | 1);
  ObjectType constant IronAxe = ObjectType.wrap(Category.Axe | 2);
  ObjectType constant GoldAxe = ObjectType.wrap(Category.Axe | 3);
  ObjectType constant DiamondAxe = ObjectType.wrap(Category.Axe | 4);
  ObjectType constant NeptuniumAxe = ObjectType.wrap(Category.Axe | 5);
  ObjectType constant WoodenWhacker = ObjectType.wrap(Category.Whacker | 0);
  ObjectType constant CopperWhacker = ObjectType.wrap(Category.Whacker | 1);
  ObjectType constant IronWhacker = ObjectType.wrap(Category.Whacker | 2);
  ObjectType constant WoodenHoe = ObjectType.wrap(Category.Hoe | 0);
  ObjectType constant GoldBar = ObjectType.wrap(Category.OreBar | 0);
  ObjectType constant IronBar = ObjectType.wrap(Category.OreBar | 1);
  ObjectType constant Diamond = ObjectType.wrap(Category.OreBar | 2);
  ObjectType constant NeptuniumBar = ObjectType.wrap(Category.OreBar | 3);
  ObjectType constant Bucket = ObjectType.wrap(Category.Bucket | 0);
  ObjectType constant WaterBucket = ObjectType.wrap(Category.Bucket | 1);
  ObjectType constant WheatSlop = ObjectType.wrap(Category.Food | 0);
  ObjectType constant PumpkinSoup = ObjectType.wrap(Category.Food | 1);
  ObjectType constant MelonSmoothie = ObjectType.wrap(Category.Food | 2);
  ObjectType constant Battery = ObjectType.wrap(Category.Fuel | 0);
  ObjectType constant Player = ObjectType.wrap(Category.Player | 0);
  ObjectType constant Fragment = ObjectType.wrap(Category.SmartEntityNonBlock | 0);
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

  function index(ObjectType self) internal pure returns (uint16) {
    return self.unwrap() & ~CATEGORY_MASK;
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  /// @dev True if this is any block category
  function isBlock(ObjectType self) internal pure returns (bool) {
    return (category(self) >> OFFSET_BITS) < BLOCK_CATEGORY_COUNT && !self.isNull();
  }

  // Direct Category Checks

  function isNonSolid(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.NonSolid;
  }

  function isStone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Stone;
  }

  function isGemstone(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Gemstone;
  }

  function isSoil(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Soil;
  }

  function isOre(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Ore;
  }

  function isSand(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Sand;
  }

  function isTerracotta(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Terracotta;
  }

  function isLog(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Log;
  }

  function isLeaf(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Leaf;
  }

  function isFlower(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Flower;
  }

  function isGreenery(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Greenery;
  }

  function isCrop(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Crop;
  }

  function isCropBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.CropBlock;
  }

  function isUnderwaterPlant(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.UnderwaterPlant;
  }

  function isUnderwaterBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.UnderwaterBlock;
  }

  function isMiscBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MiscBlock;
  }

  function isPlank(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Plank;
  }

  function isOreBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.OreBlock;
  }

  function isSeed(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Seed;
  }

  function isSapling(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Sapling;
  }

  function isSmartEntityBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SmartEntityBlock;
  }

  function isStation(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Station;
  }

  function isMiscPassThrough(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.MiscPassThrough;
  }

  function isPick(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Pick;
  }

  function isAxe(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Axe;
  }

  function isHoe(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Hoe;
  }

  function isWhacker(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Whacker;
  }

  function isOreBar(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.OreBar;
  }

  function isBucket(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Bucket;
  }

  function isFood(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Food;
  }

  function isFuel(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Fuel;
  }

  function isPlayer(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.Player;
  }

  function isSmartEntityNonBlock(ObjectType self) internal pure returns (bool) {
    return category(self) == Category.SmartEntityNonBlock;
  }

  // Category getters
  function getNonSolidTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Null, ObjectTypes.Air, ObjectTypes.Water];
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

  function getSeedEnergy(ObjectType self) internal pure returns (uint128) {
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

  // Meta Category Checks
  function isAny(ObjectType self) internal pure returns (bool) {
    // Check if:
    // 1. Index bits are all 0
    // 2. Category is one that supports "Any" types
    return self.index() == 0 && applyCategoryMask(self, Category.HAS_ANY_MASK);
  }

  function isMineable(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.MINEABLE_MASK);
  }

  function hasAny(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.HAS_ANY_MASK);
  }

  function hasExtraDrops(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.HAS_EXTRA_DROPS_MASK);
  }

  function hasAxeMultiplier(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.HAS_AXE_MULTIPLIER_MASK) || self == ObjectTypes.Chest
      || self == ObjectTypes.Workbench || self == ObjectTypes.SpawnTile || self == ObjectTypes.Bed
      || self == ObjectTypes.TextSign || self == ObjectTypes.Torch;
  }

  function hasPickMultiplier(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.HAS_PICK_MULTIPLIER_MASK) || self == ObjectTypes.Powerstone
      || self == ObjectTypes.Furnace || self == ObjectTypes.ForceField;
  }

  function isPassThrough(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.IS_PASS_THROUGH_MASK);
  }

  function isGrowable(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.IS_GROWABLE_MASK);
  }

  function isUniqueObject(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.IS_UNIQUE_OBJECT_MASK) || self == ObjectTypes.ForceField
      || self == ObjectTypes.Bed || self == ObjectTypes.SpawnTile;
  }

  function isSmartEntity(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.IS_SMART_ENTITY_MASK);
  }

  function isTool(ObjectType self) internal pure returns (bool) {
    return applyCategoryMask(self, Category.IS_TOOL_MASK);
  }

  function isTillable(ObjectType self) internal pure returns (bool) {
    return self == ObjectTypes.Dirt || self == ObjectTypes.Grass;
  }

  function isMachine(ObjectType self) internal pure returns (bool) {
    return self == ObjectTypes.ForceField;
  }

  function applyCategoryMask(ObjectType self, uint256 mask) internal pure returns (bool) {
    uint16 c = category(self);
    return ((uint256(1) << (c >> OFFSET_BITS)) & mask) != 0;
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
