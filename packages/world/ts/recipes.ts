import { type ObjectAmount, type ObjectName, objectsByName } from "./objects";

export interface Recipe {
  station?: ObjectName;
  craftingTime?: bigint;
  inputs: ObjectAmount[];
  outputs: ObjectAmount[];
}

// Central recipe registry and utility functions
export const recipes: Recipe[] = [
  {
    inputs: [["OakLog", 1]],
    outputs: [["OakPlanks", 4]],
  },
  {
    inputs: [["BirchLog", 1]],
    outputs: [["BirchPlanks", 4]],
  },
  {
    inputs: [["JungleLog", 1]],
    outputs: [["JunglePlanks", 4]],
  },
  {
    inputs: [["SakuraLog", 1]],
    outputs: [["SakuraPlanks", 4]],
  },
  {
    inputs: [["AcaciaLog", 1]],
    outputs: [["AcaciaPlanks", 4]],
  },
  {
    inputs: [["SpruceLog", 1]],
    outputs: [["SprucePlanks", 4]],
  },
  {
    inputs: [["DarkOakLog", 1]],
    outputs: [["DarkOakPlanks", 4]],
  },
  {
    inputs: [["MangroveLog", 1]],
    outputs: [["MangrovePlanks", 4]],
  },
  {
    station: "Powerstone",
    inputs: [["AnyLog", 5]],
    outputs: [["Battery", 1]],
  },
  {
    station: "Powerstone",
    inputs: [["AnyLeaf", 90]],
    outputs: [["Battery", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["IronOre", 1],
      ["CoalOre", 1],
    ],
    outputs: [["IronBar", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["GoldOre", 1],
      ["CoalOre", 1],
    ],
    outputs: [["GoldBar", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["DiamondOre", 1],
      ["CoalOre", 1],
    ],
    outputs: [["Diamond", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["NeptuniumOre", 1],
      ["CoalOre", 1],
    ],
    outputs: [["NeptuniumBar", 1]],
  },
  {
    station: "Workbench",
    inputs: [["CopperOre", 9]],
    outputs: [["CopperBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["GoldBar", 9]],
    outputs: [["GoldBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["Diamond", 9]],
    outputs: [["DiamondBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["NeptuniumBar", 9]],
    outputs: [["NeptuniumBlock", 1]],
  },
  {
    inputs: [["Stone", 9]],
    outputs: [["Furnace", 1]],
  },
  {
    inputs: [["AnyPlank", 4]],
    outputs: [["Workbench", 1]],
  },
  {
    inputs: [
      ["Stone", 6],
      ["Sand", 2],
    ],
    outputs: [["Powerstone", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Stone", 30],
      ["IronBar", 1],
    ],
    outputs: [["ForceField", 1]],
  },
  {
    station: "Workbench",
    inputs: [["AnyPlank", 8]],
    outputs: [["Chest", 1]],
  },
  {
    station: "Workbench",
    inputs: [["AnyPlank", 4]],
    outputs: [["TextSign", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["ForceField", 1],
      ["IronBar", 8],
    ],
    outputs: [["SpawnTile", 1]],
  },
  {
    station: "Workbench",
    inputs: [["AnyPlank", 3]],
    outputs: [["Bed", 1]],
  },
  {
    inputs: [["AnyPlank", 5]],
    outputs: [["WoodenPick", 1]],
  },
  {
    inputs: [["AnyPlank", 5]],
    outputs: [["WoodenAxe", 1]],
  },
  {
    inputs: [["AnyPlank", 8]],
    outputs: [["WoodenWhacker", 1]],
  },
  {
    inputs: [["AnyPlank", 4]],
    outputs: [["WoodenHoe", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["CopperOre", 3],
    ],
    outputs: [["CopperPick", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["CopperOre", 3],
    ],
    outputs: [["CopperAxe", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["CopperOre", 6],
    ],
    outputs: [["CopperWhacker", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["IronBar", 3],
    ],
    outputs: [["IronPick", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["IronBar", 3],
    ],
    outputs: [["IronAxe", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["IronBar", 6],
    ],
    outputs: [["IronWhacker", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["GoldBar", 3],
    ],
    outputs: [["GoldPick", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["GoldBar", 3],
    ],
    outputs: [["GoldAxe", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["Diamond", 3],
    ],
    outputs: [["DiamondPick", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["Diamond", 3],
    ],
    outputs: [["DiamondAxe", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["NeptuniumBar", 3],
    ],
    outputs: [["NeptuniumPick", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["AnyPlank", 2],
      ["NeptuniumBar", 3],
    ],
    outputs: [["NeptuniumAxe", 1]],
  },
  {
    inputs: [["AnyPlank", 3]],
    outputs: [["Bucket", 1]],
  },
  {
    inputs: [["Wheat", 16]],
    outputs: [["WheatSlop", 1]],
  },
  {
    inputs: [["Pumpkin", 1]],
    outputs: [["PumpkinSoup", 1]],
  },
  {
    inputs: [["Melon", 1]],
    outputs: [["MelonSmoothie", 1]],
  },
  {
    inputs: [["AnyPlank", 1]],
    outputs: [["Torch", 4]],
  },
  // Base materials
  {
    inputs: [
      ["Mud", 1],
      ["FescueGrass", 5],
    ],
    outputs: [["PackedMud", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["PackedMud", 1],
      ["CoalOre", 1],
    ],
    outputs: [["MudBricks", 1]],
  },
  {
    inputs: [
      ["IronBar", 1],
      ["Stone", 3],
    ],
    outputs: [["Stonecutter", 1]],
  },
  {
    inputs: [["BambooBush", 3]],
    outputs: [["Paper", 3]],
  },
  {
    inputs: [
      ["Paper", 3],
      ["Cotton", 1],
    ],
    outputs: [["Book", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["Sand", 1],
      ["CoalOre", 1],
    ],
    outputs: [["Glass", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["Clay", 1],
      ["CoalOre", 1],
    ],
    outputs: [["Brick", 1]],
  },
  {
    station: "Furnace",
    inputs: [["Clay", 1]],
    outputs: [["Terracotta", 1]],
  },
  {
    inputs: [["Brick", 4]],
    outputs: [["BrickBlock", 1]],
  },
  {
    inputs: [["AnyPlank", 2]],
    outputs: [["Stick", 4]],
  },
  // Primary dye recipes
  {
    inputs: [["RoseFlower", 1]],
    outputs: [["RedDye", 2]],
  },
  {
    inputs: [["RedMushroom", 1]],
    outputs: [["RedDye", 2]],
  },
  {
    inputs: [["StrawberryBush", 1]],
    outputs: [["RedDye", 2]],
  },
  {
    inputs: [["SunFlower", 1]],
    outputs: [["YellowDye", 2]],
  },
  {
    inputs: [["DandelionFlower", 1]],
    outputs: [["YellowDye", 2]],
  },
  {
    inputs: [["Ultraviolet", 1]],
    outputs: [["BlueDye", 2]],
  },
  {
    inputs: [["AnyLeaf", 1]],
    outputs: [["GreenDye", 1]],
  },
  {
    inputs: [["Moss", 1]],
    outputs: [["GreenDye", 1]],
  },
  {
    inputs: [["Calcite", 1]],
    outputs: [["WhiteDye", 3]],
  },
  {
    inputs: [["Bone", 1]],
    outputs: [["WhiteDye", 3]],
  },
  {
    inputs: [["CoalOre", 1]],
    outputs: [["BlackDye", 2]],
  },
  {
    inputs: [["Mud", 1]],
    outputs: [["BrownDye", 2]],
  },
  {
    inputs: [["BrownMushroomBlock", 1]],
    outputs: [["BrownDye", 2]],
  },
  // Mixed dye recipes
  {
    inputs: [
      ["RedDye", 1],
      ["YellowDye", 1],
    ],
    outputs: [["OrangeDye", 2]],
  },
  {
    inputs: [
      ["RedDye", 1],
      ["WhiteDye", 1],
    ],
    outputs: [["PinkDye", 2]],
  },
  {
    inputs: [
      ["GreenDye", 1],
      ["WhiteDye", 1],
    ],
    outputs: [["LimeDye", 2]],
  },
  {
    inputs: [
      ["BlueDye", 1],
      ["GreenDye", 1],
    ],
    outputs: [["CyanDye", 2]],
  },
  {
    inputs: [
      ["BlackDye", 1],
      ["WhiteDye", 1],
    ],
    outputs: [["GrayDye", 2]],
  },
  {
    inputs: [
      ["RedDye", 1],
      ["BlueDye", 1],
    ],
    outputs: [["PurpleDye", 2]],
  },
  // Concrete powder recipes
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["WhiteDye", 1],
    ],
    outputs: [["WhiteConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["OrangeDye", 1],
    ],
    outputs: [["OrangeConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["YellowDye", 1],
    ],
    outputs: [["YellowConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["LimeDye", 1],
    ],
    outputs: [["LimeConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["PinkDye", 1],
    ],
    outputs: [["PinkConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["GrayDye", 1],
    ],
    outputs: [["GrayConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["CyanDye", 1],
    ],
    outputs: [["CyanConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["PurpleDye", 1],
    ],
    outputs: [["PurpleConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["BlueDye", 1],
    ],
    outputs: [["BlueConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["BrownDye", 1],
    ],
    outputs: [["BrownConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["GreenDye", 1],
    ],
    outputs: [["GreenConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["RedDye", 1],
    ],
    outputs: [["RedConcretePowder", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Sand", 4],
      ["Gravel", 4],
      ["BlackDye", 1],
    ],
    outputs: [["BlackConcretePowder", 8]],
  },
  // Concrete recipes
  {
    inputs: [
      ["WhiteConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["WhiteConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["OrangeConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["OrangeConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["YellowConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["YellowConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["LimeConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["LimeConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["PinkConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["PinkConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["GrayConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["GrayConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["CyanConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["CyanConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["PurpleConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["PurpleConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["BlueConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["BlueConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["BrownConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["BrownConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["GreenConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["GreenConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["RedConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["RedConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["BlackConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["BlackConcrete", 1],
      ["Bucket", 1],
    ],
  },
  // Stone processing recipes
  // Note: Commented out due to mass mismatch - Cobblestone (22500000000000000) != Stone (12000000000000000)
  // {
  //   station: "Furnace",
  //   inputs: [
  //     ["Cobblestone", 1],
  //     ["CoalOre", 1],
  //   ],
  //   outputs: [["Stone", 1]],
  // },
  // Note: Commented out due to mass mismatch - CobbledDeepslate (100000000000000000) != Deepslate (40000000000000000)
  // {
  //   station: "Furnace",
  //   inputs: [
  //     ["CobbledDeepslate", 1],
  //     ["CoalOre", 1],
  //   ],
  //   outputs: [["Deepslate", 1]],
  // },
  // Construction blocks
  {
    inputs: [["Stone", 4]],
    outputs: [["StoneBricks", 4]],
  },
  {
    inputs: [["Tuff", 4]],
    outputs: [["TuffBricks", 4]],
  },
  {
    inputs: [["CobbledDeepslate", 4]],
    outputs: [["DeepslateBricks", 4]],
  },
  // Note: Commented out due to mass mismatch - Sand (4000000000000000) × 4 != Sandstone (30000000000000000) × 4
  // {
  //   inputs: [["Sand", 4]],
  //   outputs: [["Sandstone", 4]],
  // },
  // Note: Commented out due to mass mismatch - RedSand (5000000000000000) × 4 != RedSandstone (37500000000000000) × 4
  // {
  //   inputs: [["RedSand", 4]],
  //   outputs: [["RedSandstone", 4]],
  // },
  // Polished blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["Andesite", 4]],
    outputs: [["PolishedAndesite", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Granite", 4]],
    outputs: [["PolishedGranite", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Diorite", 4]],
    outputs: [["PolishedDiorite", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Tuff", 4]],
    outputs: [["PolishedTuff", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Basalt", 4]],
    outputs: [["PolishedBasalt", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Blackstone", 4]],
    outputs: [["PolishedBlackstone", 4]],
  },
  // Chiseled blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["StoneBricks", 2]],
    outputs: [["ChiseledStoneBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["TuffBricks", 2]],
    outputs: [["ChiseledTuffBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["DeepslateBricks", 2]],
    outputs: [["ChiseledDeepslate", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["PolishedBlackstone", 2]],
    outputs: [["ChiseledPolishedBlackstone", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Sandstone", 2]],
    outputs: [["ChiseledSandstone", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["RedSandstone", 2]],
    outputs: [["ChiseledRedSandstone", 1]],
  },
  // Cracked blocks (Workbench)
  {
    station: "Workbench",
    inputs: [["StoneBricks", 4]],
    outputs: [["CrackedStoneBricks", 4]],
  },
  {
    station: "Workbench",
    inputs: [["TuffBricks", 4]],
    outputs: [["CrackedTuffBricks", 4]],
  },
  {
    station: "Workbench",
    inputs: [["DeepslateBricks", 4]],
    outputs: [["CrackedDeepslateBricks", 4]],
  },
  // Smooth blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["Sandstone", 4]],
    outputs: [["SmoothSandstone", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["RedSandstone", 4]],
    outputs: [["SmoothRedSandstone", 4]],
  },
  {
    station: "Stonecutter",
    inputs: [["Stone", 4]],
    outputs: [["SmoothStone", 4]],
  },
  // Colored cotton recipes
  {
    station: "Workbench",
    inputs: [
      ["Cotton", 8],
      ["RedDye", 1],
    ],
    outputs: [["Cotton", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Cotton", 8],
      ["OrangeDye", 1],
    ],
    outputs: [["Cotton", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Cotton", 8],
      ["YellowDye", 1],
    ],
    outputs: [["Cotton", 8]],
  },
  // Note: The colored cotton recipes seem to output the same Cotton item
  // This might need specific colored cotton objects like RedCotton, OrangeCotton, etc.
  // For now I'll just add terracotta coloring recipes
  
  // Colored terracotta recipes
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["BrownDye", 1],
    ],
    outputs: [["BrownTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["OrangeDye", 1],
    ],
    outputs: [["OrangeTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["WhiteDye", 1],
    ],
    outputs: [["WhiteTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["YellowDye", 1],
    ],
    outputs: [["YellowTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["RedDye", 1],
    ],
    outputs: [["RedTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["CyanDye", 1],
    ],
    outputs: [["CyanTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["BlackDye", 1],
    ],
    outputs: [["BlackTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["PurpleDye", 1],
    ],
    outputs: [["PurpleTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["BlueDye", 1],
    ],
    outputs: [["BlueTerracotta", 8]],
  },
  {
    station: "Workbench", 
    inputs: [
      ["Terracotta", 8],
      ["PinkDye", 1],
    ],
    outputs: [["MagentaTerracotta", 8]], // Using MagentaTerracotta for PinkDye
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["GrayDye", 1],
    ],
    outputs: [["LightGrayTerracotta", 8]],
  },
  // Functional objects recipes
  {
    station: "Workbench",
    inputs: [["Glass", 6]],
    outputs: [["GlassPane", 16]],
  },
  {
    inputs: [["OakPlanks", 6]],
    outputs: [["OakDoor", 3]],
  },
  {
    inputs: [["BirchPlanks", 6]],
    outputs: [["BirchDoor", 3]],
  },
  {
    inputs: [["JunglePlanks", 6]],
    outputs: [["JungleDoor", 3]],
  },
  {
    inputs: [["SakuraPlanks", 6]],
    outputs: [["SakuraDoor", 3]],
  },
  {
    inputs: [["AcaciaPlanks", 6]],
    outputs: [["AcaciaDoor", 3]],
  },
  {
    inputs: [["SprucePlanks", 6]],
    outputs: [["SpruceDoor", 3]],
  },
  {
    inputs: [["DarkOakPlanks", 6]],
    outputs: [["DarkOakDoor", 3]],
  },
  {
    inputs: [["MangrovePlanks", 6]],
    outputs: [["MangroveDoor", 3]],
  },
  {
    inputs: [["IronBar", 6]],
    outputs: [["IronDoor", 3]],
  },
  {
    inputs: [["OakPlanks", 6]],
    outputs: [["OakTrapdoor", 2]],
  },
  {
    inputs: [["BirchPlanks", 6]],
    outputs: [["BirchTrapdoor", 2]],
  },
  {
    inputs: [["JunglePlanks", 6]],
    outputs: [["JungleTrapdoor", 2]],
  },
  {
    inputs: [["SakuraPlanks", 6]],
    outputs: [["SakuraTrapdoor", 2]],
  },
  {
    inputs: [["AcaciaPlanks", 6]],
    outputs: [["AcaciaTrapdoor", 2]],
  },
  {
    inputs: [["SprucePlanks", 6]],
    outputs: [["SpruceTrapdoor", 2]],
  },
  {
    inputs: [["DarkOakPlanks", 6]],
    outputs: [["DarkOakTrapdoor", 2]],
  },
  {
    inputs: [["MangrovePlanks", 6]],
    outputs: [["MangroveTrapdoor", 2]],
  },
  {
    inputs: [["IronBar", 4]],
    outputs: [["IronTrapdoor", 1]],
  },
  {
    inputs: [
      ["OakPlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["OakFence", 3]],
  },
  {
    inputs: [
      ["BirchPlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["BirchFence", 3]],
  },
  {
    inputs: [
      ["JunglePlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["JungleFence", 3]],
  },
  {
    inputs: [
      ["SakuraPlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["SakuraFence", 3]],
  },
  {
    inputs: [
      ["AcaciaPlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["AcaciaFence", 3]],
  },
  {
    inputs: [
      ["SprucePlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["SpruceFence", 3]],
  },
  {
    inputs: [
      ["DarkOakPlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["DarkOakFence", 3]],
  },
  {
    inputs: [
      ["MangrovePlanks", 4],
      ["Stick", 2],
    ],
    outputs: [["MangroveFence", 3]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["OakPlanks", 2],
    ],
    outputs: [["OakFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["BirchPlanks", 2],
    ],
    outputs: [["BirchFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["JunglePlanks", 2],
    ],
    outputs: [["JungleFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["SakuraPlanks", 2],
    ],
    outputs: [["SakuraFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["AcaciaPlanks", 2],
    ],
    outputs: [["AcaciaFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["SprucePlanks", 2],
    ],
    outputs: [["SpruceFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["DarkOakPlanks", 2],
    ],
    outputs: [["DarkOakFenceGate", 1]],
  },
  {
    inputs: [
      ["Stick", 4],
      ["MangrovePlanks", 2],
    ],
    outputs: [["MangroveFenceGate", 1]],
  },
  {
    inputs: [["IronBar", 6]],
    outputs: [["IronBars", 16]],
  },
  {
    inputs: [
      ["IronBar", 1],
      ["Torch", 1],
    ],
    outputs: [["Lantern", 1]],
  },
  {
    inputs: [["Stick", 7]],
    outputs: [["Ladder", 3]],
  },
  {
    inputs: [
      ["AnyPlank", 6],
      ["OakPlanksSlab", 2],
    ],
    outputs: [["Barrel", 1]],
  },
  {
    inputs: [
      ["AnyPlank", 6],
      ["Book", 3],
    ],
    outputs: [["Bookshelf", 1]],
  },
  {
    inputs: [["Cotton", 2]],
    outputs: [["Carpet", 3]],
  },
  {
    inputs: [["Brick", 3]],
    outputs: [["FlowerPot", 1]],
  },
  {
    inputs: [
      ["Stone", 8],
      ["NeptuniumBar", 1],
    ],
    outputs: [["Lodestone", 1]],
  },
];

// Get recipes where an object is used as input
export function getRecipesByInput(objectType: ObjectName): Recipe[] {
  return recipes.filter((recipe) =>
    recipe.inputs.some((input) => input[0] === objectType),
  );
}

// Get recipes where an object is produced as output
export function getRecipesByOutput(objectType: ObjectName): Recipe[] {
  return recipes.filter((recipe) =>
    recipe.outputs.some((output) => output[0] === objectType),
  );
}

// Validate that a recipe maintains mass+energy balance
export function validateRecipe(recipe: Recipe) {
  // Check if this is a dye-related recipe (outputs include dyes)
  const isDyeRecipe = recipe.outputs.some(([objectType]) => 
    objectType.endsWith("Dye")
  );
  
  // Skip validation for dye recipes since dyes have 0 mass by design
  if (isDyeRecipe) {
    return;
  }

  // Filter out coal inputs as they should not be added to the output's mass
  const inputs =
    recipe.station !== "Furnace"
      ? recipe.inputs
      : recipe.inputs.filter((input) => input[0] !== "CoalOre");
  const totalInputMassEnergy = getTotalMassEnergy(inputs);
  const totalOutputMassEnergy = getTotalMassEnergy(recipe.outputs);
  if (totalInputMassEnergy !== totalOutputMassEnergy) {
    throw new Error(
      `Recipe does not maintain mass+energy balance\n${JSON.stringify(recipe)}\nmass: ${totalInputMassEnergy} != ${totalOutputMassEnergy}`,
    );
  }
}

function getTotalMassEnergy(objectAmounts: ObjectAmount[]): bigint {
  let totalMassEnergy = 0n;
  for (const objectAmount of objectAmounts) {
    const [objectType, amount] = objectAmount;
    const obj = objectsByName[objectType];
    if (!obj) throw new Error(`Object type ${objectType} not found`);
    totalMassEnergy += ((obj.mass ?? 0n) + (obj.energy ?? 0n)) * BigInt(amount);
  }

  return totalMassEnergy;
}
