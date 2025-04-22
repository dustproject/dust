export const numBlockCategories = 128 / 2;

export const blockCategories = [
  "NON_SOLID",
  "STONE",
  "GEMSTONE",
  "SOIL",
  "ORE",
  "SAND",
  "CLAY",
  "LOG",
  "LEAF",
  "FLOWER",
  "GREENERY",
  "CROP",
  "UNDERWATER_PLANT",
  "PLANK",
  "ORE_BLOCK",
  "SEED",
  "SAPLING",
  "STATION",
  "SMART_ENTITY_BLOCK",
  "MISC_BLOCK",
] as const;

export const nonBlockCategories = [
  "PICK",
  "AXE",
  "HOE",
  "WHACKER",
  "ORE_BAR",
  "BUCKET",
  "FOOD",
  "MOVABLE",
  "SMART_ENTITY_NON_BLOCK",
] as const;

export const allCategories = [
  ...blockCategories,
  ...nonBlockCategories,
] as const;

export type Category = (typeof allCategories)[number];

// Define categories that pass metadata for the template
export interface CategoryMetadata {
  name: string;
  id: number;
}

// Transform block categories into metadata objects
export const blockCategoryMetadata: CategoryMetadata[] = blockCategories.map(
  (name, index) => ({
    name,
    id: index + 1,
  }),
);

// Transform non-block categories into metadata objects
export const nonBlockCategoryMetadata: CategoryMetadata[] =
  nonBlockCategories.map((name, index) => ({
    name,
    id: numBlockCategories + index + 1, // Start after block categories
  }));

// All categories metadata for template generation
export const allCategoryMetadata: CategoryMetadata[] = [
  ...blockCategoryMetadata,
  ...nonBlockCategoryMetadata,
];

// Define object type interface
export interface ObjectType {
  id: number;
  name: string;
  category: Category;
  mass?: bigint;
  energy?: bigint;
  timeToGrow?: bigint;
  isTillable?: boolean;
  stackable?: number;
  sapling?: ObjectTypeName;
  crop?: ObjectTypeName;
  isMachine?: boolean;
  // Used for tools
  plankAmount?: number;
  oreAmount?: { objectType: ObjectTypeName; amount: number };
}

// Helper function to define objects for a category
function defineCategoryObjects(
  category: Category,
  objects: (string | Omit<ObjectType, "id" | "category">)[],
): ObjectType[] {
  return objects
    .map((obj) =>
      typeof obj === "string" ? { name: obj, category } : { ...obj, category },
    )
    .map((obj, idx) => ({
      ...obj,
      id: idx,
      mass: obj.mass ?? 0n,
      energy: obj.energy ?? 0n,
    }));
}

// Object type definitions using defineCategoryObjects
export const objects: ObjectType[] = [
  // NonSolid category
  ...defineCategoryObjects("NON_SOLID", [
    "Air",
    "Water",
    { name: "Lava", mass: 500000000000000n },
  ]),
  // Stone category
  ...defineCategoryObjects("STONE", [
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
  ]),
  // Gemstone category
  ...defineCategoryObjects("GEMSTONE", [
    { name: "Amethyst", mass: 100000000000000000n },
    { name: "Glowstone", mass: 37500000000000000n },
  ]),

  // Soil category
  ...defineCategoryObjects("SOIL", [
    { name: "Grass", mass: 3000000000000000n },
    { name: "Dirt", mass: 2400000000000000n },
    { name: "Moss", mass: 200000000000000n },
    { name: "Podzol", mass: 5000000000000000n },
    { name: "DirtPath", mass: 5000000000000000n },
    { name: "Mud", mass: 4000000000000000n },
    { name: "PackedMud", mass: 5000000000000000n },
    { name: "Farmland", mass: 3000000000000000n },
    { name: "WetFarmland", mass: 3000000000000000n },
  ]),

  // Ore category
  ...defineCategoryObjects("ORE", [
    { name: "AnyOre", mass: 10000000000000000n },
    { name: "CoalOre", mass: 540000000000000000n },
    { name: "CopperOre", mass: 675000000000000000n },
    { name: "IronOre", mass: 675000000000000000n },
    { name: "GoldOre", mass: 1600000000000000000n },
    { name: "DiamondOre", mass: 5000000000000000000n },
    { name: "NeptuniumOre", mass: 5000000000000000000n },
  ]),

  // Sand category
  ...defineCategoryObjects("SAND", [
    { name: "Gravel", mass: 2400000000000000n },
    { name: "Sand", mass: 4000000000000000n },
    { name: "RedSand", mass: 5000000000000000n },
    { name: "Sandstone", mass: 30000000000000000n },
    { name: "RedSandstone", mass: 37500000000000000n },
  ]),

  // Clay category
  ...defineCategoryObjects("CLAY", [
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
  ]),

  // Log category
  ...defineCategoryObjects("LOG", [
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
  ]),
  // Leaf category
  ...defineCategoryObjects("LEAF", [
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
  ]),

  // Flower category
  ...defineCategoryObjects("FLOWER", [
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
  ]),

  // Greenery category
  ...defineCategoryObjects("GREENERY", [
    { name: "FescueGrass", mass: 200000000000000n },
    { name: "SwitchGrass", mass: 200000000000000n },
    { name: "CottonBush", mass: 300000000000000n },
    { name: "BambooBush", mass: 200000000000000n },
    { name: "VinesBush", mass: 200000000000000n },
    { name: "IvyVine", mass: 200000000000000n },
    { name: "HempBush", mass: 200000000000000n },
  ]),

  // Crop category
  // TODO: extract non-passthrough blocks from crops
  ...defineCategoryObjects("CROP", [
    { name: "GoldenMushroom", mass: 300000000000000n },
    { name: "RedMushroom", mass: 300000000000000n },
    { name: "CoffeeBush", mass: 300000000000000n },
    { name: "StrawberryBush", mass: 300000000000000n },
    { name: "RaspberryBush", mass: 300000000000000n },
    { name: "Cactus", mass: 1300000000000000n },
    { name: "Pumpkin", mass: 1300000000000000n, energy: 16500000000000000n },
    { name: "Melon", mass: 1300000000000000n, energy: 16500000000000000n },
    { name: "RedMushroomBlock", mass: 12500000000000000n },
    { name: "BrownMushroomBlock", mass: 12500000000000000n },
    { name: "MushroomStem", mass: 12500000000000000n },
    { name: "Wheat", mass: 300000000000000n, energy: 500000000000000n },
  ]),

  // Undergraduate Plant category
  ...defineCategoryObjects("UNDERWATER_PLANT", [
    { name: "Coral", mass: 400000000000000n },
    { name: "SeaAnemone", mass: 400000000000000n },
    { name: "Algae", mass: 200000000000000n },
    { name: "HornCoralBlock", mass: 37500000000000000n },
    { name: "FireCoralBlock", mass: 37500000000000000n },
    { name: "TubeCoralBlock", mass: 37500000000000000n },
    { name: "BubbleCoralBlock", mass: 37500000000000000n },
    { name: "BrainCoralBlock", mass: 37500000000000000n },
  ]),
  // Plank category
  ...defineCategoryObjects("PLANK", [
    { name: "AnyPlank", mass: 4500000000000000n },
    { name: "OakPlanks", mass: 4500000000000000n },
    { name: "BirchPlanks", mass: 4500000000000000n },
    { name: "JunglePlanks", mass: 4500000000000000n },
    { name: "SakuraPlanks", mass: 4500000000000000n },
    { name: "SprucePlanks", mass: 4500000000000000n },
    { name: "AcaciaPlanks", mass: 4500000000000000n },
    { name: "DarkOakPlanks", mass: 4500000000000000n },
    { name: "MangrovePlanks", mass: 4500000000000000n },
  ]),
  // Ore Block category
  ...defineCategoryObjects("ORE_BLOCK", [
    { name: "CopperBlock", mass: 675000000000000000n },
    { name: "IronBlock", mass: 675000000000000000n },
    { name: "GoldBlock", mass: 14400000000000000000n },
    { name: "DiamondBlock", mass: 45000000000000000000n },
    { name: "NeptuniumBlock", mass: 45000000000000000000n },
  ]),
  ...defineCategoryObjects("SEED", [
    {
      name: "WheatSeed",
      energy: 10000000000000000n,
      timeToGrow: 900n,
      crop: "Wheat",
    },
    {
      name: "PumpkinSeed",
      energy: 10000000000000000n,
      timeToGrow: 3600n,
      crop: "Pumpkin",
    },
    {
      name: "MelonSeed",
      energy: 10000000000000000n,
      timeToGrow: 3600n,
      crop: "Melon",
    },
  ]),
  ...defineCategoryObjects("SAPLING", [
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
  ]),
  // Station category
  ...defineCategoryObjects("STATION", [
    { name: "Furnace", mass: 108000000000000000n },
    { name: "Workbench", mass: 17800000000000000n },
    { name: "Powerstone", mass: 3735000000000000000n },
  ]),
  // Smart category
  ...defineCategoryObjects("SMART_ENTITY_BLOCK", [
    { name: "ForceField", mass: 3735000000000000000n },
    { name: "Chest", mass: 35600000000000000n },
    { name: "SpawnTile", mass: 9135000000000000000n },
    { name: "Bed", mass: 13350000000000000n },
  ]),
  ...defineCategoryObjects("MISC_BLOCK", [
    { name: "Snow", mass: 4000000000000000n },
    { name: "Ice", mass: 4000000000000000n },
    { name: "SpiderWeb", mass: 100000000000000n },
    { name: "Bone", mass: 1000000000000000n },
    { name: "TextSign", mass: 17800000000000000n },
  ]),

  // NON BLOCKS

  // Tool categories
  ...defineCategoryObjects("PICK", [
    { name: "WoodenPick", mass: 22250000000000000n, plankAmount: 5 },
    {
      name: "CopperPick",
      mass: 2033900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "CopperOre", amount: 3 },
    },
    {
      name: "IronPick",
      mass: 2033900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "IronOre", amount: 3 },
    },
    {
      name: "GoldPick",
      mass: 4808900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "GoldOre", amount: 3 },
    },
    {
      name: "DiamondPick",
      mass: 15008900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "DiamondOre", amount: 3 },
    },
    {
      name: "NeptuniumPick",
      mass: 15008900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "NeptuniumOre", amount: 3 },
    },
  ]),

  ...defineCategoryObjects("AXE", [
    { name: "WoodenAxe", mass: 22250000000000000n, plankAmount: 5 },
    {
      name: "CopperAxe",
      mass: 2033900000000000002n,
      plankAmount: 2,
      oreAmount: { objectType: "CopperOre", amount: 3 },
    },
    {
      name: "IronAxe",
      mass: 2033900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "IronOre", amount: 3 },
    },
    {
      name: "GoldAxe",
      mass: 4808900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "GoldOre", amount: 3 },
    },
    {
      name: "DiamondAxe",
      mass: 15008900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "DiamondOre", amount: 3 },
    },
    {
      name: "NeptuniumAxe",
      mass: 15008900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "NeptuniumOre", amount: 3 },
    },
  ]),

  ...defineCategoryObjects("WHACKER", [
    { name: "WoodenWhacker", mass: 35600000000000000n, plankAmount: 8 },
    {
      name: "CopperWhacker",
      mass: 4058900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "CopperOre", amount: 6 },
    },
    {
      name: "IronWhacker",
      mass: 4058900000000000000n,
      plankAmount: 2,
      oreAmount: { objectType: "IronOre", amount: 6 },
    },
  ]),

  ...defineCategoryObjects("HOE", [
    { name: "WoodenHoe", mass: 17800000000000000n, plankAmount: 4 },
  ]),

  // Orebar category
  ...defineCategoryObjects("ORE_BAR", [
    { name: "GoldBar", mass: 1600000000000000000n },
    { name: "IronBar", mass: 675000000000000000n },
    { name: "Diamond", mass: 5000000000000000000n },
    { name: "NeptuniumBar", mass: 5000000000000000000n },
  ]),
  // Bucket category
  ...defineCategoryObjects("BUCKET", [
    { name: "Bucket", mass: 675000000000000000n },
    {
      name: "WaterBucket",
      mass: 675000000000000000n,
      energy: 4000000000000000n,
    },
  ]),
  // Food category
  ...defineCategoryObjects("FOOD", [
    { name: "Fuel", mass: 1000000000000000n, energy: 5000000000000000n },
    { name: "WheatSlop", mass: 1000000000000000n, energy: 5000000000000000n },
  ]),
  // Movable category
  ...defineCategoryObjects("MOVABLE", [{ name: "Player" }]),
  // Smart entities that are not blocks
  ...defineCategoryObjects("SMART_ENTITY_NON_BLOCK", [{ name: "Fragment" }]),
];

export type ObjectTypeName = (typeof objects)[number]["name"];

export type ObjectAmount = [ObjectTypeName, number];

export const objectsByName = objects.reduce(
  (acc, obj) => {
    acc[obj.name] = obj;
    return acc;
  },
  {} as Record<ObjectTypeName, ObjectType>,
);

// Meta-categories (categories that should be included in pass-through check)
export const passThroughCategories: Category[] = [
  "NON_SOLID",
  "LEAF",
  "FLOWER",
  "SEED",
  "SAPLING",
  "GREENERY",
  "CROP",
  "UNDERWATER_PLANT",
];

export const growableCategories: Category[] = ["SEED", "SAPLING"];

// TODO: adjust categories
export const uniqueObjectCategories: Category[] = [
  "PICK",
  "AXE",
  "WHACKER",
  "HOE",
  "SMART_ENTITY_BLOCK",
  "BUCKET",
];

export const toolCategories: Category[] = ["PICK", "AXE", "WHACKER", "HOE"];

export const smartEntityCategories: Category[] = [
  "SMART_ENTITY_BLOCK",
  "SMART_ENTITY_NON_BLOCK",
];

export const hasAnyCategories: Category[] = ["LOG", "LEAF", "PLANK", "ORE"];
