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
    inputs: [["IronBar", 9]],
    outputs: [["IronBlock", 1]],
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
    station: "Workbench",
  },
  {
    station: "Workbench",
    inputs: [["BambooBush", 1]],
    outputs: [["Paper", 1]],
  },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Paper", 3],
  //     ["Cotton", 1],
  //   ],
  //   outputs: [["Book", 1]],
  // },
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
    inputs: [
      ["Basalt", 1],
      ["CoalOre", 1],
    ],
    outputs: [["SmoothBasalt", 1]],
  },
  // Commented due to mass mismatch - Clay != Terracotta
  // {
  //   station: "Furnace",
  //   inputs: [
  //     ["Clay", 1],
  //     ["CoalOre", 1],
  //   ],
  //   outputs: [["Terracotta", 1]],
  // },
  {
    inputs: [["Brick", 4]],
    outputs: [["BrickBlock", 1]],
  },
  {
    inputs: [["AnyPlank", 1]],
    outputs: [["Stick", 2]],
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
    inputs: [["SwitchGrass", 1]],
    outputs: [["GreenDye", 1]],
  },
  {
    inputs: [["FescueGrass", 1]],
    outputs: [["GreenDye", 1]],
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
    inputs: [["BrownMushroomBlock", 1]],
    outputs: [["BrownDye", 2]],
  },
  {
    inputs: [
      ["GreenDye", 1],
      ["RedDye", 1],
    ],
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
  {
    inputs: [
      ["PurpleDye", 1],
      ["PinkDye", 1],
    ],
    outputs: [["MagentaDye", 2]],
  },
  {
    inputs: [
      ["BlueDye", 1],
      ["WhiteDye", 1],
    ],
    outputs: [["LightBlueDye", 2]],
  },
  {
    inputs: [
      ["GrayDye", 1],
      ["WhiteDye", 1],
    ],
    outputs: [["LightGrayDye", 2]],
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
      ["MagentaDye", 1],
    ],
    outputs: [["MagentaConcretePowder", 8]],
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
      ["LightBlueDye", 1],
    ],
    outputs: [["LightBlueConcretePowder", 8]],
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
      ["LightGrayDye", 1],
    ],
    outputs: [["LightGrayConcretePowder", 8]],
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
      ["MagentaConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["MagentaConcrete", 1],
      ["Bucket", 1],
    ],
  },
  {
    inputs: [
      ["LightBlueConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["LightBlueConcrete", 1],
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
      ["LightGrayConcretePowder", 1],
      ["WaterBucket", 1],
    ],
    outputs: [
      ["LightGrayConcrete", 1],
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
    station: "Stonecutter",
    inputs: [["Stone", 1]],
    outputs: [["StoneBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Tuff", 1]],
    outputs: [["TuffBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["CobbledDeepslate", 1]],
    outputs: [["DeepslateBricks", 1]],
  },
  // Note: Commented out due to mass mismatch - Sand (4000000000000000) != Sandstone (30000000000000000)
  // {
  //   inputs: [["Sand", 1]],
  //   outputs: [["Sandstone", 1]],
  // },
  // Note: Commented out due to mass mismatch - RedSand (5000000000000000) != RedSandstone (37500000000000000)
  // {
  //   inputs: [["RedSand", 1]],
  //   outputs: [["RedSandstone", 1]],
  // },
  // Polished blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["Andesite", 1]],
    outputs: [["PolishedAndesite", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Granite", 1]],
    outputs: [["PolishedGranite", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Diorite", 1]],
    outputs: [["PolishedDiorite", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Tuff", 1]],
    outputs: [["PolishedTuff", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Basalt", 1]],
    outputs: [["PolishedBasalt", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Blackstone", 1]],
    outputs: [["PolishedBlackstone", 1]],
  },
  // Chiseled blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["StoneBricks", 1]],
    outputs: [["ChiseledStoneBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["TuffBricks", 1]],
    outputs: [["ChiseledTuffBricks", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["DeepslateBricks", 1]],
    outputs: [["ChiseledDeepslate", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["PolishedBlackstone", 1]],
    outputs: [["ChiseledPolishedBlackstone", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["Sandstone", 1]],
    outputs: [["ChiseledSandstone", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["RedSandstone", 1]],
    outputs: [["ChiseledRedSandstone", 1]],
  },
  // Polished Deepslate (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["Deepslate", 1]],
    outputs: [["PolishedDeepslate", 1]],
  },
  // Polished Blackstone Bricks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["PolishedBlackstone", 1]],
    outputs: [["PolishedBlackstoneBricks", 1]],
  },
  // Cut Sandstone blocks (Stonecutter)
  {
    station: "Stonecutter",
    inputs: [["Sandstone", 1]],
    outputs: [["CutSandstone", 1]],
  },
  {
    station: "Stonecutter",
    inputs: [["RedSandstone", 1]],
    outputs: [["CutRedSandstone", 1]],
  },
  // Cracked blocks (Furnace)
  {
    station: "Furnace",
    inputs: [
      ["StoneBricks", 1],
      ["CoalOre", 1],
    ],
    outputs: [["CrackedStoneBricks", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["TuffBricks", 1],
      ["CoalOre", 1],
    ],
    outputs: [["CrackedTuffBricks", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["DeepslateBricks", 1],
      ["CoalOre", 1],
    ],
    outputs: [["CrackedDeepslateBricks", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["PolishedBlackstoneBricks", 1],
      ["CoalOre", 1],
    ],
    outputs: [["CrackedPolishedBlackstoneBricks", 1]],
  },
  // Smooth blocks (Furnace - smelting recipes)
  {
    station: "Furnace",
    inputs: [
      ["Sandstone", 1],
      ["CoalOre", 1],
    ],
    outputs: [["SmoothSandstone", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["RedSandstone", 1],
      ["CoalOre", 1],
    ],
    outputs: [["SmoothRedSandstone", 1]],
  },
  {
    station: "Furnace",
    inputs: [
      ["Stone", 1],
      ["CoalOre", 1],
    ],
    outputs: [["SmoothStone", 1]],
  },
  // Mossy blocks recipes
  {
    inputs: [
      ["StoneBricks", 1],
      ["Moss", 1],
    ],
    outputs: [["MossyStoneBricks", 1]],
  },
  // Colored cotton recipes
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["RedDye", 1],
  //   ],
  //   outputs: [["RedCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["OrangeDye", 1],
  //   ],
  //   outputs: [["OrangeCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["YellowDye", 1],
  //   ],
  //   outputs: [["YellowCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["BlueDye", 1],
  //   ],
  //   outputs: [["BlueCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["GreenDye", 1],
  //   ],
  //   outputs: [["GreenCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["WhiteDye", 1],
  //   ],
  //   outputs: [["WhiteCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["BlackDye", 1],
  //   ],
  //   outputs: [["BlackCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["BrownDye", 1],
  //   ],
  //   outputs: [["BrownCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["PinkDye", 1],
  //   ],
  //   outputs: [["PinkCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["LimeDye", 1],
  //   ],
  //   outputs: [["LimeCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["CyanDye", 1],
  //   ],
  //   outputs: [["CyanCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["GrayDye", 1],
  //   ],
  //   outputs: [["GrayCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["PurpleDye", 1],
  //   ],
  //   outputs: [["PurpleCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["MagentaDye", 1],
  //   ],
  //   outputs: [["MagentaCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["LightBlueDye", 1],
  //   ],
  //   outputs: [["LightBlueCotton", 8]],
  // },
  // {
  //   station: "Workbench",
  //   inputs: [
  //     ["Cotton", 8],
  //     ["LightGrayDye", 1],
  //   ],
  //   outputs: [["LightGrayCotton", 8]],
  // },

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
      ["MagentaDye", 1],
    ],
    outputs: [["MagentaTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["LightGrayDye", 1],
    ],
    outputs: [["LightGrayTerracotta", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Terracotta", 8],
      ["LightBlueDye", 1],
    ],
    outputs: [["LightBlueTerracotta", 8]],
  },
  // Colored glass recipes
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["WhiteDye", 1],
    ],
    outputs: [["WhiteGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["OrangeDye", 1],
    ],
    outputs: [["OrangeGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["MagentaDye", 1],
    ],
    outputs: [["MagentaGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["LightBlueDye", 1],
    ],
    outputs: [["LightBlueGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["YellowDye", 1],
    ],
    outputs: [["YellowGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["LimeDye", 1],
    ],
    outputs: [["LimeGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["PinkDye", 1],
    ],
    outputs: [["PinkGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["GrayDye", 1],
    ],
    outputs: [["GrayGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["LightGrayDye", 1],
    ],
    outputs: [["LightGrayGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["CyanDye", 1],
    ],
    outputs: [["CyanGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["PurpleDye", 1],
    ],
    outputs: [["PurpleGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["BlueDye", 1],
    ],
    outputs: [["BlueGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["BrownDye", 1],
    ],
    outputs: [["BrownGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["GreenDye", 1],
    ],
    outputs: [["GreenGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["RedDye", 1],
    ],
    outputs: [["RedGlass", 8]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Glass", 8],
      ["BlackDye", 1],
    ],
    outputs: [["BlackGlass", 8]],
  },
  // Functional objects recipes
  // {
  //   station: "Workbench",
  //   inputs: [["Glass", 3]],
  //   outputs: [["GlassPane", 8]],
  // },
  // {
  //   inputs: [["OakPlanks", 2]],
  //   outputs: [["OakDoor", 1]],
  // },
  // {
  //   inputs: [["BirchPlanks", 2]],
  //   outputs: [["BirchDoor", 1]],
  // },
  // {
  //   inputs: [["JunglePlanks", 2]],
  //   outputs: [["JungleDoor", 1]],
  // },
  // {
  //   inputs: [["SakuraPlanks", 2]],
  //   outputs: [["SakuraDoor", 1]],
  // },
  // {
  //   inputs: [["AcaciaPlanks", 2]],
  //   outputs: [["AcaciaDoor", 1]],
  // },
  // {
  //   inputs: [["SprucePlanks", 2]],
  //   outputs: [["SpruceDoor", 1]],
  // },
  // {
  //   inputs: [["DarkOakPlanks", 2]],
  //   outputs: [["DarkOakDoor", 1]],
  // },
  // {
  //   inputs: [["MangrovePlanks", 2]],
  //   outputs: [["MangroveDoor", 1]],
  // },
  // {
  //   inputs: [["IronBar", 2]],
  //   outputs: [["IronDoor", 1]],
  // },
  // {
  //   inputs: [["OakPlanks", 3]],
  //   outputs: [["OakTrapdoor", 1]],
  // },
  // {
  //   inputs: [["BirchPlanks", 3]],
  //   outputs: [["BirchTrapdoor", 1]],
  // },
  // {
  //   inputs: [["JunglePlanks", 3]],
  //   outputs: [["JungleTrapdoor", 1]],
  // },
  // {
  //   inputs: [["SakuraPlanks", 3]],
  //   outputs: [["SakuraTrapdoor", 1]],
  // },
  // {
  //   inputs: [["AcaciaPlanks", 3]],
  //   outputs: [["AcaciaTrapdoor", 1]],
  // },
  // {
  //   inputs: [["SprucePlanks", 3]],
  //   outputs: [["SpruceTrapdoor", 1]],
  // },
  // {
  //   inputs: [["DarkOakPlanks", 3]],
  //   outputs: [["DarkOakTrapdoor", 1]],
  // },
  // {
  //   inputs: [["MangrovePlanks", 3]],
  //   outputs: [["MangroveTrapdoor", 1]],
  // },
  // {
  //   inputs: [["IronBar", 4]],
  //   outputs: [["IronTrapdoor", 1]],
  // },
  // {
  //   inputs: [
  //     ["OakPlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["OakFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["BirchPlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["BirchFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["JunglePlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["JungleFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["SakuraPlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["SakuraFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["AcaciaPlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["AcaciaFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["SprucePlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["SpruceFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["DarkOakPlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["DarkOakFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["MangrovePlanks", 4],
  //     ["Stick", 2],
  //   ],
  //   outputs: [["MangroveFence", 3]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["OakPlanks", 2],
  //   ],
  //   outputs: [["OakFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["BirchPlanks", 2],
  //   ],
  //   outputs: [["BirchFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["JunglePlanks", 2],
  //   ],
  //   outputs: [["JungleFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["SakuraPlanks", 2],
  //   ],
  //   outputs: [["SakuraFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["AcaciaPlanks", 2],
  //   ],
  //   outputs: [["AcaciaFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["SprucePlanks", 2],
  //   ],
  //   outputs: [["SpruceFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["DarkOakPlanks", 2],
  //   ],
  //   outputs: [["DarkOakFenceGate", 1]],
  // },
  // {
  //   inputs: [
  //     ["Stick", 4],
  //     ["MangrovePlanks", 2],
  //   ],
  //   outputs: [["MangroveFenceGate", 1]],
  // },
  // {
  //   inputs: [["IronBar", 3]],
  //   outputs: [["IronBars", 8]],
  // },
  // {
  //   inputs: [
  //     ["IronBar", 1],
  //     ["Torch", 1],
  //   ],
  //   outputs: [["Lantern", 1]],
  // },
  // {
  //   inputs: [["Stick", 7]],
  //   outputs: [["Ladder", 3]],
  // },
  // {
  //   inputs: [
  //     ["AnyPlank", 6],
  //     ["OakPlanksSlab", 2],
  //   ],
  //   outputs: [["Barrel", 1]],
  // },
  // {
  //   inputs: [
  //     ["AnyPlank", 6],
  //     ["Book", 3],
  //   ],
  //   outputs: [["Bookshelf", 1]],
  // },
  // {
  //   inputs: [["Cotton", 2]],
  //   outputs: [["Carpet", 3]],
  // },
  {
    inputs: [["Brick", 3]],
    outputs: [["FlowerPot", 1]],
  },
  {
    inputs: [
      ["Stone", 8],
      ["IronBar", 1],
    ],
    outputs: [["Lodestone", 1]],
    station: "Workbench",
  },
  // Stairs recipes
  // {
  //   station: "Stonecutter",
  //   inputs: [["Stone", 1]],
  //   outputs: [["StoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Cobblestone", 1]],
  //   outputs: [["CobblestoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MossyCobblestone", 1]],
  //   outputs: [["MossyCobblestoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["StoneBricks", 1]],
  //   outputs: [["StoneBricksStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothStone", 1]],
  //   outputs: [["SmoothStoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Andesite", 1]],
  //   outputs: [["AndesiteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Granite", 1]],
  //   outputs: [["GraniteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Diorite", 1]],
  //   outputs: [["DioriteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Tuff", 1]],
  //   outputs: [["TuffStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Basalt", 1]],
  //   outputs: [["BasaltStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Blackstone", 1]],
  //   outputs: [["BlackstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedAndesite", 1]],
  //   outputs: [["PolishedAndesiteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedGranite", 1]],
  //   outputs: [["PolishedGraniteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedDiorite", 1]],
  //   outputs: [["PolishedDioriteStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedTuff", 1]],
  //   outputs: [["PolishedTuffStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBasalt", 1]],
  //   outputs: [["PolishedBasaltStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBlackstone", 1]],
  //   outputs: [["PolishedBlackstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Deepslate", 1]],
  //   outputs: [["DeepslateStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["CobbledDeepslate", 1]],
  //   outputs: [["CobbledDeepslateStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["DeepslateBricks", 1]],
  //   outputs: [["DeepslateBricksStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Sandstone", 1]],
  //   outputs: [["SandstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["RedSandstone", 1]],
  //   outputs: [["RedSandstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothSandstone", 1]],
  //   outputs: [["SmoothSandstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothRedSandstone", 1]],
  //   outputs: [["SmoothRedSandstoneStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["BrickBlock", 1]],
  //   outputs: [["BrickBlockStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MudBricks", 1]],
  //   outputs: [["MudBricksStairs", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["TuffBricks", 1]],
  //   outputs: [["TuffBricksStairs", 1]],
  // },
  // Wooden stairs
  // {
  //   inputs: [["OakPlanks", 1]],
  //   outputs: [["OakPlanksStairs", 1]],
  // },
  // {
  //   inputs: [["BirchPlanks", 1]],
  //   outputs: [["BirchPlanksStairs", 1]],
  // },
  // {
  //   inputs: [["JunglePlanks", 1]],
  //   outputs: [["JunglePlanksStairs", 1]],
  // },
  // {
  //   inputs: [["SakuraPlanks", 1]],
  //   outputs: [["SakuraPlanksStairs", 1]],
  // },
  // {
  //   inputs: [["AcaciaPlanks", 1]],
  //   outputs: [["AcaciaPlanksStairs", 1]],
  // },
  // {
  //   inputs: [["SprucePlanks", 1]],
  //   outputs: [["SprucePlanksStairs", 1]],
  // },
  // {
  //   inputs: [["DarkOakPlanks", 1]],
  //   outputs: [["DarkOakPlanksStairs", 1]],
  // },
  // {
  //   inputs: [["MangrovePlanks", 1]],
  //   outputs: [["MangrovePlanksStairs", 1]],
  // },
  // Slab recipes
  // {
  //   station: "Stonecutter",
  //   inputs: [["Stone", 1]],
  //   outputs: [["StoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Cobblestone", 1]],
  //   outputs: [["CobblestoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MossyCobblestone", 1]],
  //   outputs: [["MossyCobblestoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["StoneBricks", 1]],
  //   outputs: [["StoneBricksSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothStone", 1]],
  //   outputs: [["SmoothStoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Andesite", 1]],
  //   outputs: [["AndesiteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Granite", 1]],
  //   outputs: [["GraniteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Diorite", 1]],
  //   outputs: [["DioriteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Tuff", 1]],
  //   outputs: [["TuffSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Basalt", 1]],
  //   outputs: [["BasaltSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Blackstone", 1]],
  //   outputs: [["BlackstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedAndesite", 1]],
  //   outputs: [["PolishedAndesiteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedGranite", 1]],
  //   outputs: [["PolishedGraniteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedDiorite", 1]],
  //   outputs: [["PolishedDioriteSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedTuff", 1]],
  //   outputs: [["PolishedTuffSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBasalt", 1]],
  //   outputs: [["PolishedBasaltSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBlackstone", 1]],
  //   outputs: [["PolishedBlackstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Deepslate", 1]],
  //   outputs: [["DeepslateSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["CobbledDeepslate", 1]],
  //   outputs: [["CobbledDeepslateSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["DeepslateBricks", 1]],
  //   outputs: [["DeepslateBricksSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Sandstone", 1]],
  //   outputs: [["SandstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["RedSandstone", 1]],
  //   outputs: [["RedSandstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothSandstone", 1]],
  //   outputs: [["SmoothSandstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["SmoothRedSandstone", 1]],
  //   outputs: [["SmoothRedSandstoneSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["BrickBlock", 1]],
  //   outputs: [["BrickBlockSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MudBricks", 1]],
  //   outputs: [["MudBricksSlab", 2]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["TuffBricks", 1]],
  //   outputs: [["TuffBricksSlab", 2]],
  // },
  // Wooden slabs
  // {
  //   inputs: [["OakPlanks", 1]],
  //   outputs: [["OakPlanksSlab", 2]],
  // },
  // {
  //   inputs: [["BirchPlanks", 1]],
  //   outputs: [["BirchPlanksSlab", 2]],
  // },
  // {
  //   inputs: [["JunglePlanks", 1]],
  //   outputs: [["JunglePlanksSlab", 2]],
  // },
  // {
  //   inputs: [["SakuraPlanks", 1]],
  //   outputs: [["SakuraPlanksSlab", 2]],
  // },
  // {
  //   inputs: [["AcaciaPlanks", 1]],
  //   outputs: [["AcaciaPlanksSlab", 2]],
  // },
  // {
  //   inputs: [["SprucePlanks", 1]],
  //   outputs: [["SprucePlanksSlab", 2]],
  // },
  // {
  //   inputs: [["DarkOakPlanks", 1]],
  //   outputs: [["DarkOakPlanksSlab", 2]],
  // },
  // {
  //   inputs: [["MangrovePlanks", 1]],
  //   outputs: [["MangrovePlanksSlab", 2]],
  // },
  // Wall recipes
  // {
  //   station: "Stonecutter",
  //   inputs: [["Stone", 1]],
  //   outputs: [["StoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Cobblestone", 1]],
  //   outputs: [["CobblestoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MossyCobblestone", 1]],
  //   outputs: [["MossyCobblestoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["StoneBricks", 1]],
  //   outputs: [["StoneBricksWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Andesite", 1]],
  //   outputs: [["AndesiteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Granite", 1]],
  //   outputs: [["GraniteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Diorite", 1]],
  //   outputs: [["DioriteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Tuff", 1]],
  //   outputs: [["TuffWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Basalt", 1]],
  //   outputs: [["BasaltWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Blackstone", 1]],
  //   outputs: [["BlackstoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedAndesite", 1]],
  //   outputs: [["PolishedAndesiteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedGranite", 1]],
  //   outputs: [["PolishedGraniteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedDiorite", 1]],
  //   outputs: [["PolishedDioriteWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedTuff", 1]],
  //   outputs: [["PolishedTuffWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBasalt", 1]],
  //   outputs: [["PolishedBasaltWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["PolishedBlackstone", 1]],
  //   outputs: [["PolishedBlackstoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Deepslate", 1]],
  //   outputs: [["DeepslateWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["CobbledDeepslate", 1]],
  //   outputs: [["CobbledDeepslateWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["DeepslateBricks", 1]],
  //   outputs: [["DeepslateBricksWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["Sandstone", 1]],
  //   outputs: [["SandstoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["RedSandstone", 1]],
  //   outputs: [["RedSandstoneWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["BrickBlock", 1]],
  //   outputs: [["BrickBlockWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["MudBricks", 1]],
  //   outputs: [["MudBricksWall", 1]],
  // },
  // {
  //   station: "Stonecutter",
  //   inputs: [["TuffBricks", 1]],
  //   outputs: [["TuffBricksWall", 1]],
  // },
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
    objectType.endsWith("Dye"),
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
