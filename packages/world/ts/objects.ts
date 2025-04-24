export const numBlockCategories = 256 / 2;

export const blockCategories = [
  // terrain categories
  "NonSolid",
  "Stone",
  "Gemstone",
  "Soil",
  "Ore",
  "Sand",
  "Clay",
  "Log",
  "Leaf",
  "Flower",
  "Greenery",
  "Crop",
  "CropBlock",
  "UnderwaterPlant",
  "UnderwaterBlock",
  "MiscBlock",
  // non-terrain categories
  "Plank",
  "OreBlock",
  "Seed",
  "Sapling",
  "Station",
  "SmartEntityBlock",
] as const;

export const nonBlockCategories = [
  "Pick",
  "Axe",
  "Hoe",
  "Whacker",
  "OreBar",
  "Bucket",
  "Food",
  "Fuel",
  "Player",
  "SmartEntityNonBlock",
] as const;

export const allCategories = [
  ...blockCategories,
  ...nonBlockCategories,
] as const;

export type Category = (typeof allCategories)[number];

// Define categories that pass metadata for the template
export interface CategoryMetadata {
  name: Category;
  index: number;
}

// Transform block categories into metadata objects
export const blockCategoryMetadata: CategoryMetadata[] = blockCategories.map(
  (name, index) => ({
    name,
    index,
  }),
);

// Transform non-block categories into metadata objects
export const nonBlockCategoryMetadata: CategoryMetadata[] =
  nonBlockCategories.map((name, index) => ({
    name,
    index: numBlockCategories + index, // Start after block categories
  }));

// All categories metadata for template generation
export const allCategoryMetadata: CategoryMetadata[] = [
  ...blockCategoryMetadata,
  ...nonBlockCategoryMetadata,
];

const categoryIndex = allCategoryMetadata.reduce(
  (acc, category) => {
    acc[category.name] = category.index;
    return acc;
  },
  {} as Record<Category, number>,
);

// Meta-categories (categories that should be included in pass-through check)
export const passThroughCategories: Category[] = [
  "NonSolid",
  "Flower",
  "Seed",
  "Sapling",
  "Greenery",
  "Crop",
  "UnderwaterPlant",
];

export const growableCategories: Category[] = ["Seed", "Sapling"];

// TODO: adjust categories
export const uniqueObjectCategories: Category[] = [
  "Pick",
  "Axe",
  "Whacker",
  "Hoe",
  "Bucket",
  "SmartEntityBlock",
  "SmartEntityNonBlock",
];

export const toolCategories: Category[] = ["Pick", "Axe", "Whacker", "Hoe"];

export const smartEntityCategories: Category[] = [
  "SmartEntityBlock",
  "SmartEntityNonBlock",
];

export const hasAnyCategories: Category[] = ["Log", "Leaf", "Plank"];

export const hasExtraDropsCategories: Category[] = ["Leaf", "Crop", "Greenery"];

export const objectNames = [
  "Null",
  "Air",
  "Water",
  "Lava",
  "Stone",
  "Bedrock",
  "Deepslate",
  "Granite",
  "Tuff",
  "Calcite",
  "Basalt",
  "SmoothBasalt",
  "Andesite",
  "Diorite",
  "Cobblestone",
  "MossyCobblestone",
  "Obsidian",
  "Dripstone",
  "Blackstone",
  "CobbledDeepslate",
  "Amethyst",
  "Glowstone",
  "Grass",
  "Dirt",
  "Moss",
  "Podzol",
  "DirtPath",
  "Mud",
  "PackedMud",
  "Farmland",
  "WetFarmland",
  "Snow",
  "Ice",
  "UnrevealedOre",
  "CoalOre",
  "CopperOre",
  "IronOre",
  "GoldOre",
  "DiamondOre",
  "NeptuniumOre",
  "Gravel",
  "Sand",
  "RedSand",
  "Sandstone",
  "RedSandstone",
  "Clay",
  "Terracotta",
  "BrownTerracotta",
  "OrangeTerracotta",
  "WhiteTerracotta",
  "LightGrayTerracotta",
  "YellowTerracotta",
  "RedTerracotta",
  "LightBlueTerracotta",
  "CyanTerracotta",
  "BlackTerracotta",
  "PurpleTerracotta",
  "BlueTerracotta",
  "MagentaTerracotta",
  "AnyLog",
  "OakLog",
  "BirchLog",
  "JungleLog",
  "SakuraLog",
  "AcaciaLog",
  "SpruceLog",
  "DarkOakLog",
  "MangroveLog",
  "AnyLeaf",
  "OakLeaf",
  "BirchLeaf",
  "JungleLeaf",
  "SakuraLeaf",
  "SpruceLeaf",
  "AcaciaLeaf",
  "DarkOakLeaf",
  "AzaleaLeaf",
  "FloweringAzaleaLeaf",
  "MangroveLeaf",
  "MangroveRoots",
  "MuddyMangroveRoots",
  "AzaleaFlower",
  "BellFlower",
  "DandelionFlower",
  "DaylilyFlower",
  "LilacFlower",
  "RoseFlower",
  "FireFlower",
  "MorninggloryFlower",
  "PeonyFlower",
  "Ultraviolet",
  "SunFlower",
  "FlyTrap",
  "FescueGrass",
  "SwitchGrass",
  "VinesBush",
  "IvyVine",
  "HempBush",
  "Coral",
  "SeaAnemone",
  "Algae",
  "HornCoralBlock",
  "FireCoralBlock",
  "TubeCoralBlock",
  "BubbleCoralBlock",
  "BrainCoralBlock",
  "SpiderWeb",
  "Bone",
  "GoldenMushroom",
  "RedMushroom",
  "CoffeeBush",
  "StrawberryBush",
  "RaspberryBush",
  "Wheat",
  "CottonBush",
  "Pumpkin",
  "Melon",
  "RedMushroomBlock",
  "BrownMushroomBlock",
  "MushroomStem",
  "BambooBush",
  "Cactus",
  "AnyPlank",
  "OakPlanks",
  "BirchPlanks",
  "JunglePlanks",
  "SakuraPlanks",
  "SprucePlanks",
  "AcaciaPlanks",
  "DarkOakPlanks",
  "MangrovePlanks",
  "CopperBlock",
  "IronBlock",
  "GoldBlock",
  "DiamondBlock",
  "NeptuniumBlock",
  "WheatSeed",
  "PumpkinSeed",
  "MelonSeed",
  "CottonSeed",
  "OakSapling",
  "BirchSapling",
  "JungleSapling",
  "SakuraSapling",
  "AcaciaSapling",
  "SpruceSapling",
  "DarkOakSapling",
  "MangroveSapling",
  "Furnace",
  "Workbench",
  "Powerstone",
  "ForceField",
  "Chest",
  "SpawnTile",
  "Bed",
  "TextSign",
  "WoodenPick",
  "CopperPick",
  "IronPick",
  "GoldPick",
  "DiamondPick",
  "NeptuniumPick",
  "WoodenAxe",
  "CopperAxe",
  "IronAxe",
  "GoldAxe",
  "DiamondAxe",
  "NeptuniumAxe",
  "WoodenWhacker",
  "CopperWhacker",
  "IronWhacker",
  "WoodenHoe",
  "GoldBar",
  "IronBar",
  "Diamond",
  "NeptuniumBar",
  "Bucket",
  "WaterBucket",
  "WheatSlop",
  "Fuel",
  "Player",
  "Fragment",
] as const;

export type ObjectName = (typeof objectNames)[number];

// Define object type interface
export interface ObjectDefinition {
  name: ObjectName;
  category: Category;
  index: number;
  id: number;
  terrainId?: number;
  mass?: bigint;
  energy?: bigint;
  timeToGrow?: bigint;
  isTillable?: boolean;
  stackable?: number;
  sapling?: ObjectName;
  crop?: ObjectName;
  isMachine?: boolean;
  // Used for tools
  plankAmount?: number;
  oreAmount?: ObjectAmount;
}

export const categoryObjects: {
  [key in Category]: Omit<
    ObjectDefinition,
    "id" | "category" | "index" | "terrainId"
  >[];
} = {
  NonSolid: [
    { name: "Null" },
    { name: "Air" },
    { name: "Water" },
    { name: "Lava", mass: 500000000000000n },
  ],
  Stone: [
    { name: "Stone", mass: 12000000000000000n },
    { name: "Bedrock", mass: 1000000000000000000n },
    { name: "Deepslate", mass: 22500000000000000n },
    { name: "Granite", mass: 30000000000000000n },
    { name: "Tuff", mass: 22500000000000000n },
    { name: "Calcite", mass: 30000000000000000n },
    { name: "Basalt", mass: 22500000000000000n },
    { name: "SmoothBasalt", mass: 30000000000000000n },
    { name: "Andesite", mass: 30000000000000000n },
    { name: "Diorite", mass: 30000000000000000n },
    { name: "Cobblestone", mass: 22500000000000000n },
    { name: "MossyCobblestone", mass: 22500000000000000n },
    { name: "Obsidian", mass: 90000000000000000n },
    { name: "Dripstone", mass: 75000000000000000n },
    { name: "Blackstone", mass: 30000000000000000n },
    { name: "CobbledDeepslate", mass: 100000000000000000n },
  ],
  Gemstone: [
    { name: "Amethyst", mass: 100000000000000000n },
    { name: "Glowstone", mass: 37500000000000000n },
  ],
  Soil: [
    { name: "Grass", mass: 3000000000000000n },
    { name: "Dirt", mass: 2400000000000000n },
    { name: "Moss", mass: 200000000000000n },
    { name: "Podzol", mass: 5000000000000000n },
    { name: "DirtPath", mass: 5000000000000000n },
    { name: "Mud", mass: 4000000000000000n },
    { name: "PackedMud", mass: 5000000000000000n },
    { name: "Farmland", mass: 3000000000000000n },
    { name: "WetFarmland", mass: 3000000000000000n },
    { name: "Snow", mass: 4000000000000000n },
    { name: "Ice", mass: 4000000000000000n },
  ],
  Ore: [
    { name: "UnrevealedOre", mass: 10000000000000000n },
    { name: "CoalOre", mass: 540000000000000000n },
    { name: "CopperOre", mass: 675000000000000000n },
    { name: "IronOre", mass: 675000000000000000n },
    { name: "GoldOre", mass: 1600000000000000000n },
    { name: "DiamondOre", mass: 5000000000000000000n },
    { name: "NeptuniumOre", mass: 5000000000000000000n },
  ],
  Sand: [
    { name: "Gravel", mass: 2400000000000000n },
    { name: "Sand", mass: 4000000000000000n },
    { name: "RedSand", mass: 5000000000000000n },
    { name: "Sandstone", mass: 30000000000000000n },
    { name: "RedSandstone", mass: 37500000000000000n },
  ],
  Clay: [
    { name: "Clay", mass: 2400000000000000n },
    { name: "Terracotta", mass: 18000000000000000n },
    { name: "BrownTerracotta", mass: 22500000000000000n },
    { name: "OrangeTerracotta", mass: 30000000000000000n },
    { name: "WhiteTerracotta", mass: 22500000000000000n },
    { name: "LightGrayTerracotta", mass: 30000000000000000n },
    { name: "YellowTerracotta", mass: 30000000000000000n },
    { name: "RedTerracotta", mass: 30000000000000000n },
    { name: "LightBlueTerracotta", mass: 37500000000000000n },
    { name: "CyanTerracotta", mass: 37500000000000000n },
    { name: "BlackTerracotta", mass: 37500000000000000n },
    { name: "PurpleTerracotta", mass: 37500000000000000n },
    { name: "BlueTerracotta", mass: 37500000000000000n },
    { name: "MagentaTerracotta", mass: 37500000000000000n },
  ],
  Log: [
    { name: "AnyLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "OakLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "BirchLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "JungleLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "SakuraLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "AcaciaLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "SpruceLog", mass: 12500000000000000n, energy: 5500000000000000n },
    { name: "DarkOakLog", mass: 12500000000000000n, energy: 5500000000000000n },
    {
      name: "MangroveLog",
      mass: 12500000000000000n,
      energy: 5500000000000000n,
    },
  ],

  Leaf: [
    { name: "AnyLeaf", mass: 500000000000000n, energy: 500000000000000n },
    {
      name: "OakLeaf",
      sapling: "OakSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "BirchLeaf",
      sapling: "BirchSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "JungleLeaf",
      sapling: "JungleSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "SakuraLeaf",
      sapling: "SakuraSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "SpruceLeaf",
      sapling: "SpruceSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "AcaciaLeaf",
      sapling: "AcaciaSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    {
      name: "DarkOakLeaf",
      sapling: "DarkOakSapling",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    { name: "AzaleaLeaf", mass: 500000000000000n, energy: 500000000000000n },
    {
      name: "FloweringAzaleaLeaf",
      mass: 500000000000000n,
      energy: 500000000000000n,
    },
    { name: "MangroveLeaf", mass: 500000000000000n, energy: 500000000000000n },
    { name: "MangroveRoots", mass: 400000000000000n },
    { name: "MuddyMangroveRoots", mass: 400000000000000n },
  ],
  Flower: [
    { name: "AzaleaFlower", mass: 300000000000000n },
    { name: "BellFlower", mass: 300000000000000n },
    { name: "DandelionFlower", mass: 300000000000000n },
    { name: "DaylilyFlower", mass: 300000000000000n },
    { name: "LilacFlower", mass: 300000000000000n },
    { name: "RoseFlower", mass: 300000000000000n },
    { name: "FireFlower", mass: 300000000000000n },
    { name: "MorninggloryFlower", mass: 300000000000000n },
    { name: "PeonyFlower", mass: 300000000000000n },
    { name: "Ultraviolet", mass: 300000000000000n },
    { name: "SunFlower", mass: 300000000000000n },
    { name: "FlyTrap", mass: 300000000000000n },
  ],
  Greenery: [
    { name: "FescueGrass", mass: 200000000000000n },
    { name: "SwitchGrass", mass: 200000000000000n },
    { name: "VinesBush", mass: 200000000000000n },
    { name: "IvyVine", mass: 200000000000000n },
    { name: "HempBush", mass: 200000000000000n },
  ],
  UnderwaterPlant: [
    { name: "Coral", mass: 400000000000000n },
    { name: "SeaAnemone", mass: 400000000000000n },
    { name: "Algae", mass: 200000000000000n },
  ],
  UnderwaterBlock: [
    { name: "HornCoralBlock", mass: 37500000000000000n },
    { name: "FireCoralBlock", mass: 37500000000000000n },
    { name: "TubeCoralBlock", mass: 37500000000000000n },
    { name: "BubbleCoralBlock", mass: 37500000000000000n },
    { name: "BrainCoralBlock", mass: 37500000000000000n },
  ],
  MiscBlock: [
    { name: "SpiderWeb", mass: 100000000000000n },
    { name: "Bone", mass: 1000000000000000n },
  ],

  // NON-TERRAIN BLOCKS

  Crop: [
    { name: "GoldenMushroom", mass: 300000000000000n },
    { name: "RedMushroom", mass: 300000000000000n },
    { name: "CoffeeBush", mass: 300000000000000n },
    { name: "StrawberryBush", mass: 300000000000000n },
    { name: "RaspberryBush", mass: 300000000000000n },
    { name: "Wheat", mass: 300000000000000n, energy: 500000000000000n },
    { name: "CottonBush", mass: 300000000000000n },
  ],
  CropBlock: [
    { name: "Pumpkin", mass: 1300000000000000n, energy: 16500000000000000n },
    { name: "Melon", mass: 1300000000000000n, energy: 16500000000000000n },
    { name: "RedMushroomBlock", mass: 12500000000000000n },
    { name: "BrownMushroomBlock", mass: 12500000000000000n },
    { name: "MushroomStem", mass: 12500000000000000n },
    { name: "BambooBush", mass: 200000000000000n },
    { name: "Cactus", mass: 1300000000000000n },
  ],
  Plank: [
    { name: "AnyPlank", mass: 4500000000000000n },
    { name: "OakPlanks", mass: 4500000000000000n },
    { name: "BirchPlanks", mass: 4500000000000000n },
    { name: "JunglePlanks", mass: 4500000000000000n },
    { name: "SakuraPlanks", mass: 4500000000000000n },
    { name: "SprucePlanks", mass: 4500000000000000n },
    { name: "AcaciaPlanks", mass: 4500000000000000n },
    { name: "DarkOakPlanks", mass: 4500000000000000n },
    { name: "MangrovePlanks", mass: 4500000000000000n },
  ],
  OreBlock: [
    { name: "CopperBlock", mass: 6075000000000000000n },
    { name: "IronBlock", mass: 6075000000000000000n },
    { name: "GoldBlock", mass: 14400000000000000000n },
    { name: "DiamondBlock", mass: 45000000000000000000n },
    { name: "NeptuniumBlock", mass: 45000000000000000000n },
  ],
  Seed: [
    {
      name: "WheatSeed",
      energy: 800000000000000n,
      timeToGrow: 900n,
      crop: "Wheat",
    },
    {
      name: "PumpkinSeed",
      energy: 17800000000000000n,
      timeToGrow: 3600n,
      crop: "Pumpkin",
    },
    {
      name: "MelonSeed",
      energy: 17800000000000000n,
      timeToGrow: 3600n,
      crop: "Melon",
    },
    {
      name: "CottonSeed",
      energy: 300000000000000n,
      timeToGrow: 3600n,
      crop: "CottonBush",
    },
  ],
  Sapling: [
    { name: "OakSapling", energy: 148000000000000000n, timeToGrow: 345600n },
    { name: "BirchSapling", energy: 139000000000000000n, timeToGrow: 345600n },
    { name: "JungleSapling", energy: 300000000000000000n, timeToGrow: 345600n },
    { name: "SakuraSapling", energy: 187000000000000000n, timeToGrow: 345600n },
    { name: "AcaciaSapling", energy: 158000000000000000n, timeToGrow: 345600n },
    { name: "SpruceSapling", energy: 256000000000000000n, timeToGrow: 345600n },
    {
      name: "DarkOakSapling",
      energy: 202000000000000000n,
      timeToGrow: 345600n,
    },
    {
      name: "MangroveSapling",
      energy: 232000000000000000n,
      timeToGrow: 345600n,
    },
  ],
  Station: [
    { name: "Furnace", mass: 108000000000000000n },
    { name: "Workbench", mass: 18000000000000000n },
    { name: "Powerstone", mass: 80000000000000000n },
  ],
  SmartEntityBlock: [
    { name: "ForceField", mass: 3735000000000000000n, isMachine: true },
    { name: "Chest", mass: 36000000000000000n },
    { name: "SpawnTile", mass: 9135000000000000000n },
    { name: "Bed", mass: 13500000000000000n },
    { name: "TextSign", mass: 18000000000000000n },
  ],

  // NON BLOCKS

  Pick: [
    { name: "WoodenPick", mass: 22500000000000000n, plankAmount: 5 },
    {
      name: "CopperPick",
      mass: 2034000000000000000n,
      plankAmount: 2,
      oreAmount: ["CopperOre", 3],
    },
    {
      name: "IronPick",
      mass: 2034000000000000000n,
      plankAmount: 2,
      oreAmount: ["IronOre", 3],
    },
    {
      name: "GoldPick",
      mass: 4809000000000000000n,
      plankAmount: 2,
      oreAmount: ["GoldOre", 3],
    },
    {
      name: "DiamondPick",
      mass: 15009000000000000000n,
      plankAmount: 2,
      oreAmount: ["DiamondOre", 3],
    },
    {
      name: "NeptuniumPick",
      mass: 15009000000000000000n,
      plankAmount: 2,
      oreAmount: ["NeptuniumOre", 3],
    },
  ],
  Axe: [
    { name: "WoodenAxe", mass: 22500000000000000n, plankAmount: 5 },
    {
      name: "CopperAxe",
      mass: 2034000000000000000n,
      plankAmount: 2,
      oreAmount: ["CopperOre", 3],
    },
    {
      name: "IronAxe",
      mass: 2034000000000000000n,
      plankAmount: 2,
      oreAmount: ["IronOre", 3],
    },
    {
      name: "GoldAxe",
      mass: 4809000000000000000n,
      plankAmount: 2,
      oreAmount: ["GoldOre", 3],
    },
    {
      name: "DiamondAxe",
      mass: 15009000000000000000n,
      plankAmount: 2,
      oreAmount: ["DiamondOre", 3],
    },
    {
      name: "NeptuniumAxe",
      mass: 15009000000000000000n,
      plankAmount: 2,
      oreAmount: ["NeptuniumOre", 3],
    },
  ],
  Whacker: [
    { name: "WoodenWhacker", mass: 36000000000000000n, plankAmount: 8 },
    {
      name: "CopperWhacker",
      mass: 4059000000000000000n,
      plankAmount: 2,
      oreAmount: ["CopperOre", 6],
    },
    {
      name: "IronWhacker",
      mass: 4059000000000000000n,
      plankAmount: 2,
      oreAmount: ["IronOre", 6],
    },
  ],
  Hoe: [{ name: "WoodenHoe", mass: 18000000000000000n, plankAmount: 4 }],
  OreBar: [
    { name: "GoldBar", mass: 1600000000000000000n },
    { name: "IronBar", mass: 675000000000000000n },
    { name: "Diamond", mass: 5000000000000000000n },
    { name: "NeptuniumBar", mass: 5000000000000000000n },
  ],
  Bucket: [
    { name: "Bucket", mass: 2025000000000000000n },
    { name: "WaterBucket", mass: 2025000000000000000n },
  ],
  Food: [{ name: "WheatSlop", energy: 12800000000000000n }],
  Fuel: [{ name: "Fuel", energy: 90000000000000000n }],
  Player: [{ name: "Player" }],
  // TODO: change this category name for fragments
  SmartEntityNonBlock: [{ name: "Fragment" }],
} as const;

export const objects: ObjectDefinition[] = Object.entries(
  categoryObjects,
).flatMap(([category, objects]) => {
  const catIndex = categoryIndex[category as Category];
  return objects.map((obj, index) => ({
    ...obj,
    id: (catIndex << 8) | index,
    terrainId:
      catIndex < 16 && index < 16 ? (catIndex << 4) | index : undefined,
    categoryIndex: catIndex,
    index,
    category: category as Category,
  }));
});

export type ObjectAmount = [ObjectName, number | bigint];

export const objectsByName = objects.reduce(
  (acc, obj) => {
    acc[obj.name] = obj;
    return acc;
  },
  {} as Record<ObjectName, ObjectDefinition>,
);
