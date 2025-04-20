// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type ObjectType is uint16;

// Categories are 7 bits, ids are 9 bits
uint16 constant CATEGORY_MASK = 0xF800;
uint16 constant NUM_BLOCKS = 2 ** 15;

// ------------------------------------------------------------
// Object Categories
// ------------------------------------------------------------
library Category {
  uint16 constant NONE = 0;

  // Block Categories
  uint16 constant NON_SOLID = 1;
  uint16 constant STONE = 2;
  uint16 constant GEMSTONE = 3;
  uint16 constant SOIL = 4;
  uint16 constant ORE = 5;
  uint16 constant SAND = 6;
  uint16 constant CLAY = 7;
  uint16 constant LOG = 8;
  uint16 constant LEAF = 9;
  uint16 constant FLOWER = 10;
  uint16 constant GREENERY = 11;
  uint16 constant CROP = 12;
  uint16 constant UNDERWATER_PLANT = 13;
  // Non-terrain
  uint16 constant PLANK = 14;
  uint16 constant ORE_BLOCK = 15;
  uint16 constant GROWABLE = 16;
  uint16 constant STATION = 17;
  uint16 constant SMART = 18;

  // Non-Block Categories
  uint16 constant TOOL = NUM_BLOCKS + 1;
  uint16 constant OREBAR = NUM_BLOCKS + 2;
  uint16 constant BUCKET = NUM_BLOCKS + 3;
  uint16 constant FOOD = NUM_BLOCKS + 4;
  uint16 constant MOVABLE = NUM_BLOCKS + 5;
  uint16 constant MISC = NUM_BLOCKS + 6;
}

library ObjectTypeLib {
  function isBlock(ObjectType self) internal pure returns (bool) {
    return !self.isNull() && ObjectType.unwrap(self) < 2 ** 15;
  }

  function isTool(ObjectType self) internal pure returns (bool) {
    return _is(self, Category.Tool);
  }

  function isLeaf(ObjectType self) internal pure returns (bool) {
    return _is(self, Category.LEAF);
  }

  function isPassThrough(ObjectType self) internal pure returns (bool) {
    return _is(self, Category.NON_SOLID) || self.isLeaf() || self.isGrowable() || self.isGreenery();
  }

  // ...

  function _is(ObjectType self, uint16 category) internal pure returns (bool) {
    return ObjectType.unwrap(self) & CATEGORY_MASK == category;
  }
}

// ------------------------------------------------------------
// Object Types
// ------------------------------------------------------------
library ObjectTypes {
  // Note: Do not use 0 as an object type, as it is reserved
  ObjectType constant Null = ObjectType.wrap(0);

  // ------------------------------------------------------------
  // Terrain Blocks (1-255 is reserved for terrain blocks)
  // ------------------------------------------------------------

  // NonSolid
  ObjectType constant Air = ObjectType.wrap(Block | 1);
  ObjectType constant Water = ObjectType.wrap(Block | 2);
  ObjectType constant Lava = ObjectType.wrap(Block | 3);

  // Stone
  ObjectType constant Stone = ObjectType.wrap(Block | 16);
  ObjectType constant Bedrock = ObjectType.wrap(Block | 17);
  ObjectType constant Deepslate = ObjectType.wrap(Block | 18);
  ObjectType constant Granite = ObjectType.wrap(Block | 19);
  ObjectType constant Tuff = ObjectType.wrap(Block | 20);
  ObjectType constant Calcite = ObjectType.wrap(Block | 21);
  ObjectType constant Basalt = ObjectType.wrap(Block | 22);
  ObjectType constant SmoothBasalt = ObjectType.wrap(Block | 23);
  ObjectType constant Andesite = ObjectType.wrap(Block | 24);
  ObjectType constant Diorite = ObjectType.wrap(Block | 25);
  ObjectType constant Cobblestone = ObjectType.wrap(Block | 26);
  ObjectType constant MossyCobblestone = ObjectType.wrap(Block | 27);
  ObjectType constant Obsidian = ObjectType.wrap(Block | 28);
  ObjectType constant Dripstone = ObjectType.wrap(Block | 29);
  ObjectType constant Blackstone = ObjectType.wrap(Block | 30);
  ObjectType constant CobbledDeepslate = ObjectType.wrap(Block | 31);

  // Gemstone
  ObjectType constant Amethyst = ObjectType.wrap(Block | 32);
  ObjectType constant Glowstone = ObjectType.wrap(Block | 33);
  ObjectType constant AnyOre = ObjectType.wrap(Block | 34);

  // Soil
  ObjectType constant Grass = ObjectType.wrap(Block | 48);
  ObjectType constant Dirt = ObjectType.wrap(Block | 49);
  ObjectType constant Moss = ObjectType.wrap(Block | 50);
  ObjectType constant Podzol = ObjectType.wrap(Block | 51);
  ObjectType constant DirtPath = ObjectType.wrap(Block | 52);
  ObjectType constant Farmland = ObjectType.wrap(Block | 53);
  ObjectType constant Mud = ObjectType.wrap(Block | 54);
  ObjectType constant PackedMud = ObjectType.wrap(Block | 55);

  // Sand
  ObjectType constant Gravel = ObjectType.wrap(Block | 64);
  ObjectType constant Sand = ObjectType.wrap(Block | 65);
  ObjectType constant RedSand = ObjectType.wrap(Block | 66);
  ObjectType constant Sandstone = ObjectType.wrap(Block | 67);
  ObjectType constant RedSandstone = ObjectType.wrap(Block | 68);

  // Clay
  ObjectType constant Clay = ObjectType.wrap(Block | 80);
  ObjectType constant Terracotta = ObjectType.wrap(Block | 81);
  ObjectType constant BrownTerracotta = ObjectType.wrap(Block | 82);
  ObjectType constant OrangeTerracotta = ObjectType.wrap(Block | 83);
  ObjectType constant WhiteTerracotta = ObjectType.wrap(Block | 84);
  ObjectType constant LightGrayTerracotta = ObjectType.wrap(Block | 85);
  ObjectType constant YellowTerracotta = ObjectType.wrap(Block | 86);
  ObjectType constant RedTerracotta = ObjectType.wrap(Block | 87);
  ObjectType constant LightBlueTerracotta = ObjectType.wrap(Block | 88);
  ObjectType constant CyanTerracotta = ObjectType.wrap(Block | 89);
  ObjectType constant BlackTerracotta = ObjectType.wrap(Block | 90);
  ObjectType constant PurpleTerracotta = ObjectType.wrap(Block | 91);
  ObjectType constant BlueTerracotta = ObjectType.wrap(Block | 92);
  ObjectType constant MagentaTerracotta = ObjectType.wrap(Block | 93);

  // Log
  ObjectType constant OakLog = ObjectType.wrap(Block | 96);
  ObjectType constant BirchLog = ObjectType.wrap(Block | 97);
  ObjectType constant JungleLog = ObjectType.wrap(Block | 98);
  ObjectType constant SakuraLog = ObjectType.wrap(Block | 99);
  ObjectType constant AcaciaLog = ObjectType.wrap(Block | 100);
  ObjectType constant SpruceLog = ObjectType.wrap(Block | 101);
  ObjectType constant DarkOakLog = ObjectType.wrap(Block | 102);
  ObjectType constant MangroveLog = ObjectType.wrap(Block | 103);

  // Leaves
  ObjectType constant OakLeaf = ObjectType.wrap(Block | 112);
  ObjectType constant BirchLeaf = ObjectType.wrap(Block | 113);
  ObjectType constant JungleLeaf = ObjectType.wrap(Block | 114);
  ObjectType constant SakuraLeaf = ObjectType.wrap(Block | 115);
  ObjectType constant SpruceLeaf = ObjectType.wrap(Block | 116);
  ObjectType constant AcaciaLeaf = ObjectType.wrap(Block | 117);
  ObjectType constant DarkOakLeaf = ObjectType.wrap(Block | 118);
  ObjectType constant MangroveLeaf = ObjectType.wrap(Block | 119);
  ObjectType constant MangroveRoots = ObjectType.wrap(Block | 120);
  ObjectType constant MuddyMangroveRoots = ObjectType.wrap(Block | 121);
  ObjectType constant AzaleaLeaf = ObjectType.wrap(Block | 122);
  ObjectType constant FloweringAzaleaLeaf = ObjectType.wrap(Block | 123);

  // Flower
  ObjectType constant AzaleaFlower = ObjectType.wrap(Block | 128);
  ObjectType constant BellFlower = ObjectType.wrap(Block | 129);
  ObjectType constant DandelionFlower = ObjectType.wrap(Block | 130);
  ObjectType constant DaylilyFlower = ObjectType.wrap(Block | 131);
  ObjectType constant LilacFlower = ObjectType.wrap(Block | 132);
  ObjectType constant RoseFlower = ObjectType.wrap(Block | 133);
  ObjectType constant FireFlower = ObjectType.wrap(Block | 134);
  ObjectType constant MorninggloryFlower = ObjectType.wrap(Block | 135);
  ObjectType constant PeonyFlower = ObjectType.wrap(Block | 136);
  ObjectType constant Ultraviolet = ObjectType.wrap(Block | 137);
  ObjectType constant SunFlower = ObjectType.wrap(Block | 138);
  ObjectType constant FlyTrap = ObjectType.wrap(Block | 139);

  // Greenery
  ObjectType constant FescueGrass = ObjectType.wrap(Block | 144);
  ObjectType constant SwitchGrass = ObjectType.wrap(Block | 145);
  ObjectType constant CottonBush = ObjectType.wrap(Block | 146);
  ObjectType constant BambooBush = ObjectType.wrap(Block | 147);
  ObjectType constant VinesBush = ObjectType.wrap(Block | 148);
  ObjectType constant IvyVine = ObjectType.wrap(Block | 149);
  ObjectType constant HempBush = ObjectType.wrap(Block | 150);

  // Edibles
  ObjectType constant GoldenMushroom = ObjectType.wrap(Block | 160);
  ObjectType constant RedMushroom = ObjectType.wrap(Block | 161);
  ObjectType constant CoffeeBush = ObjectType.wrap(Block | 162);
  ObjectType constant StrawberryBush = ObjectType.wrap(Block | 163);
  ObjectType constant RaspberryBush = ObjectType.wrap(Block | 164);
  ObjectType constant Cactus = ObjectType.wrap(Block | 165);
  ObjectType constant Pumpkin = ObjectType.wrap(Block | 166);
  ObjectType constant Melon = ObjectType.wrap(Block | 167);
  ObjectType constant RedMushroomBlock = ObjectType.wrap(Block | 168);
  ObjectType constant BrownMushroomBlock = ObjectType.wrap(Block | 169);
  ObjectType constant MushroomStem = ObjectType.wrap(Block | 170);
  ObjectType constant Wheat = ObjectType.wrap(Block | 171);

  // UnderwaterPlant
  ObjectType constant Coral = ObjectType.wrap(Block | 176);
  ObjectType constant SeaAnemone = ObjectType.wrap(Block | 177);
  ObjectType constant Algae = ObjectType.wrap(Block | 178);
  ObjectType constant HornCoralBlock = ObjectType.wrap(Block | 179);
  ObjectType constant FireCoralBlock = ObjectType.wrap(Block | 180);
  ObjectType constant TubeCoralBlock = ObjectType.wrap(Block | 181);
  ObjectType constant BubbleCoralBlock = ObjectType.wrap(Block | 182);
  ObjectType constant BrainCoralBlock = ObjectType.wrap(Block | 183);

  // Other
  ObjectType constant Snow = ObjectType.wrap(Block | 240);
  ObjectType constant Ice = ObjectType.wrap(Block | 241);
  ObjectType constant SpiderWeb = ObjectType.wrap(Block | 242);
  ObjectType constant Bone = ObjectType.wrap(Block | 243);

  // ------------------------------------------------------------
  // Non-Terrain Blocks (256 and above)
  // ------------------------------------------------------------
  ObjectType constant OakPlanks = ObjectType.wrap(Block | 256);
  ObjectType constant BirchPlanks = ObjectType.wrap(Block | 257);
  ObjectType constant JunglePlanks = ObjectType.wrap(Block | 258);
  ObjectType constant SakuraPlanks = ObjectType.wrap(Block | 259);
  ObjectType constant SprucePlanks = ObjectType.wrap(Block | 260);
  ObjectType constant AcaciaPlanks = ObjectType.wrap(Block | 261);
  ObjectType constant DarkOakPlanks = ObjectType.wrap(Block | 262);
  ObjectType constant MangrovePlanks = ObjectType.wrap(Block | 263);
  ObjectType constant Furnace = ObjectType.wrap(Block | 264);
  ObjectType constant Workbench = ObjectType.wrap(Block | 265);
  ObjectType constant Powerstone = ObjectType.wrap(Block | 266);
  ObjectType constant CoalOre = ObjectType.wrap(Block | 267);
  ObjectType constant CopperOre = ObjectType.wrap(Block | 268);
  ObjectType constant IronOre = ObjectType.wrap(Block | 269);
  ObjectType constant GoldOre = ObjectType.wrap(Block | 270);
  ObjectType constant DiamondOre = ObjectType.wrap(Block | 271);
  ObjectType constant NeptuniumOre = ObjectType.wrap(Block | 272);
  ObjectType constant CopperBlock = ObjectType.wrap(Block | 273);
  ObjectType constant IronBlock = ObjectType.wrap(Block | 274);
  ObjectType constant GoldBlock = ObjectType.wrap(Block | 275);
  ObjectType constant DiamondBlock = ObjectType.wrap(Block | 276);
  ObjectType constant NeptuniumBlock = ObjectType.wrap(Block | 277);
  ObjectType constant WetFarmland = ObjectType.wrap(Block | 278);
  ObjectType constant WheatSeed = ObjectType.wrap(Block | 279);
  ObjectType constant OakSeed = ObjectType.wrap(Block | 280);
  ObjectType constant SpruceSeed = ObjectType.wrap(Block | 281);
  ObjectType constant ForceField = ObjectType.wrap(Block | 600);
  ObjectType constant Chest = ObjectType.wrap(Block | 601);
  ObjectType constant TextSign = ObjectType.wrap(Block | 602);
  ObjectType constant SpawnTile = ObjectType.wrap(Block | 603);
  ObjectType constant Bed = ObjectType.wrap(Block | 604);

  // ------------------------------------------------------------
  // Tool
  // ------------------------------------------------------------
  ObjectType constant WoodenPick = ObjectType.wrap(Tool | 0);
  ObjectType constant WoodenAxe = ObjectType.wrap(Tool | 1);
  ObjectType constant WoodenWhacker = ObjectType.wrap(Tool | 2);
  ObjectType constant WoodenHoe = ObjectType.wrap(Tool | 3);
  ObjectType constant CopperPick = ObjectType.wrap(Tool | 4);
  ObjectType constant CopperAxe = ObjectType.wrap(Tool | 5);
  ObjectType constant CopperWhacker = ObjectType.wrap(Tool | 6);
  ObjectType constant IronPick = ObjectType.wrap(Tool | 7);
  ObjectType constant IronAxe = ObjectType.wrap(Tool | 8);
  ObjectType constant IronWhacker = ObjectType.wrap(Tool | 9);
  ObjectType constant GoldPick = ObjectType.wrap(Tool | 10);
  ObjectType constant GoldAxe = ObjectType.wrap(Tool | 11);
  ObjectType constant DiamondPick = ObjectType.wrap(Tool | 12);
  ObjectType constant DiamondAxe = ObjectType.wrap(Tool | 13);
  ObjectType constant NeptuniumPick = ObjectType.wrap(Tool | 14);
  ObjectType constant NeptuniumAxe = ObjectType.wrap(Tool | 15);

  // ------------------------------------------------------------
  // Item
  // ------------------------------------------------------------
  ObjectType constant GoldBar = ObjectType.wrap(Item | 0);
  ObjectType constant IronBar = ObjectType.wrap(Item | 1);
  ObjectType constant Diamond = ObjectType.wrap(Item | 2);
  ObjectType constant NeptuniumBar = ObjectType.wrap(Item | 3);
  ObjectType constant Bucket = ObjectType.wrap(Item | 4);
  ObjectType constant WaterBucket = ObjectType.wrap(Item | 5);
  ObjectType constant Fuel = ObjectType.wrap(Item | 6);
  ObjectType constant WheatSlop = ObjectType.wrap(Item | 7);

  // ------------------------------------------------------------
  // Misc
  // ------------------------------------------------------------
  ObjectType constant Player = ObjectType.wrap(Misc | 0);
  ObjectType constant Fragment = ObjectType.wrap(Misc | 1);
  ObjectType constant AnyLog = ObjectType.wrap(Misc | 2);
  ObjectType constant AnyPlank = ObjectType.wrap(Misc | 3);
  ObjectType constant AnyLeaf = ObjectType.wrap(Misc | 4);
}
