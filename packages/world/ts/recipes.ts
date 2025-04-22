import {
  type ObjectAmount,
  type ObjectTypeName,
  objectsByName,
} from "./objects";

export interface Recipe {
  station?: ObjectTypeName;
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
    outputs: [["Fuel", 1]],
  },
  {
    station: "Powerstone",
    inputs: [["AnyLeaf", 90]],
    outputs: [["Fuel", 1]],
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
    station: "Workbench",
    inputs: [["IronBar", 1]],
    outputs: [["IronOre", 1]],
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
    station: "Workbench",
    inputs: [["GoldBar", 1]],
    outputs: [["GoldOre", 1]],
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
    station: "Workbench",
    inputs: [["Diamond", 1]],
    outputs: [["DiamondOre", 1]],
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
    inputs: [["NeptuniumBar", 1]],
    outputs: [["NeptuniumOre", 1]],
  },
  {
    station: "Workbench",
    inputs: [["CopperOre", 9]],
    outputs: [["CopperBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["CopperBlock", 1]],
    outputs: [["CopperOre", 9]],
  },
  {
    station: "Workbench",
    inputs: [["IronBar", 9]],
    outputs: [["IronBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["IronBlock", 1]],
    outputs: [["IronBar", 9]],
  },
  {
    station: "Workbench",
    inputs: [["GoldBar", 9]],
    outputs: [["GoldBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["GoldBlock", 1]],
    outputs: [["GoldBar", 9]],
  },
  {
    station: "Workbench",
    inputs: [["Diamond", 9]],
    outputs: [["DiamondBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["DiamondBlock", 1]],
    outputs: [["Diamond", 9]],
  },
  {
    station: "Workbench",
    inputs: [["NeptuniumBar", 9]],
    outputs: [["NeptuniumBlock", 1]],
  },
  {
    station: "Workbench",
    inputs: [["NeptuniumBlock", 1]],
    outputs: [["NeptuniumBar", 9]],
  },
  {
    inputs: [["Stone", 9]],
    outputs: [["Furnace", 1]],
  },
  {
    inputs: [["Furnace", 1]],
    outputs: [["Stone", 9]],
  },
  {
    inputs: [["AnyPlank", 4]],
    outputs: [["Workbench", 1]],
  },
  {
    station: "Workbench",
    inputs: [
      ["Stone", 6],
      ["Sand", 2],
    ],
    outputs: [["Powerstone", 1]],
  },
  {
    station: "Workbench",
    inputs: [["Powerstone", 1]],
    outputs: [
      ["Stone", 6],
      ["Sand", 2],
    ],
  },
  {
    station: "Workbench",
    inputs: [
      ["Stone", 30],
      ["IronBar", 5],
    ],
    outputs: [["ForceField", 1]],
  },
  {
    station: "Workbench",
    inputs: [["ForceField", 1]],
    outputs: [
      ["Stone", 30],
      ["IronBar", 5],
    ],
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
    inputs: [["SpawnTile", 1]],
    outputs: [
      ["ForceField", 1],
      ["IronBar", 8],
    ],
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
    inputs: [["IronBar", 3]],
    outputs: [["Bucket", 1]],
  },
  {
    inputs: [["Bucket", 1]],
    outputs: [["IronBar", 3]],
  },
  {
    inputs: [["Wheat", 16]],
    outputs: [["WheatSlop", 1]],
  },
];

// Get recipes where an object is used as input
export function getRecipesByInput(objectType: ObjectTypeName): Recipe[] {
  return Object.values(recipes).filter((recipe) =>
    recipe.inputs.some((input) => input[0] === objectType),
  );
}

// Get recipes where an object is produced as output
export function getRecipesByOutput(objectType: ObjectTypeName): Recipe[] {
  return Object.values(recipes).filter((recipe) =>
    recipe.outputs.some((output) => output[0] === objectType),
  );
}

// Validate that a recipe maintains mass+energy balance
export function validateRecipeMassEnergy(recipe: Recipe): boolean {
  const totalInputMassEnergy = getTotalMassEnergy(recipe.inputs);
  const totalOutputMassEnergy = getTotalMassEnergy(recipe.outputs);
  if (totalInputMassEnergy !== totalOutputMassEnergy) {
    console.error(
      `Recipe validation failed: Recipe ${JSON.stringify(recipe)} has input mass+energy of ${totalInputMassEnergy} but expected ${totalOutputMassEnergy}`,
    );
    return false;
  }

  return true;
}

function getTotalMassEnergy(objectAmounts: ObjectAmount[]): bigint {
  let totalMassEnergy = 0n;
  for (const objectAmount of objectAmounts) {
    const [objectType, amount] = objectAmount;
    const obj = objectsByName[objectType];
    if (!obj) throw new Error(`Object type ${objectType} not found`);
    totalMassEnergy += (obj.mass + obj.energy) * BigInt(amount);
  }

  return totalMassEnergy;
}
