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
