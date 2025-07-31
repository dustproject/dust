import { type ObjectName, objects, objectsByName } from "../objects";
import { type Recipe, recipes } from "../recipes";

// Helper function to get total mass+energy of object amounts
function getTotalMassEnergy(
  items: [ObjectName, number | bigint][],
): bigint | undefined {
  let totalMassEnergy = 0n;
  let hasValue = false;

  for (const [objName, amount] of items) {
    const obj = objectsByName[objName];
    if (!obj) {
      console.warn(`Warning: Unknown object "${objName}"`);
      continue;
    }

    if (obj.mass !== undefined) {
      hasValue = true;
      totalMassEnergy += obj.mass * BigInt(amount);
    }

    if (obj.energy !== undefined) {
      hasValue = true;
      totalMassEnergy += obj.energy * BigInt(amount);
    }
  }

  return hasValue ? totalMassEnergy : undefined;
}

// Get all objects that are used as outputs in recipes
const objectsWithRecipes = new Set<ObjectName>();
for (const recipe of recipes) {
  for (const [outputName] of recipe.outputs) {
    objectsWithRecipes.add(outputName);
  }
}

// Sort objects by ID for consistent output
const sortedObjects = [...objects].sort((a, b) => a.id - b.id);

console.info("Recipe Analysis");
console.info("===============");
console.info(`Total recipes: ${recipes.length}`);
console.info(`Total objects: ${objects.length}`);
console.info("");

// Mass+Energy conservation analysis
console.info("Mass+Energy Conservation Analysis:");
console.info("----------------------------------");
console.info(
  "(Recipes where both inputs and outputs have mass and/or energy defined)\n",
);

let conservedCount = 0;
let nonConservedCount = 0;
const massEnergyViolations: {
  recipe: Recipe;
  inputTotal: bigint;
  outputTotal: bigint;
  ratio: number;
}[] = [];

for (const recipe of recipes) {
  const inputTotal = getTotalMassEnergy(recipe.inputs);
  const outputTotal = getTotalMassEnergy(recipe.outputs);

  if (inputTotal !== undefined && outputTotal !== undefined) {
    const ratio = Number(outputTotal) / Number(inputTotal);

    if (inputTotal === outputTotal) {
      conservedCount++;
    } else {
      nonConservedCount++;
      massEnergyViolations.push({ recipe, inputTotal, outputTotal, ratio });
    }
  }
}

console.info(`Recipes with mass+energy conservation: ${conservedCount}`);
console.info(
  `Recipes violating mass+energy conservation: ${nonConservedCount}`,
);

if (massEnergyViolations.length > 0) {
  console.info("\nMass+Energy violations (sorted by ratio):");
  const sorted = massEnergyViolations.sort((a, b) => a.ratio - b.ratio);

  for (const { recipe, inputTotal, outputTotal, ratio } of sorted) {
    const inputs = recipe.inputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const outputs = recipe.outputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const station = recipe.station ? ` @ ${recipe.station}` : "";
    console.info(`  ${inputs} → ${outputs}${station}`);
    console.info(
      `    Input total: ${inputTotal}, Output total: ${outputTotal}, Ratio: ${ratio.toFixed(3)}`,
    );
  }
}

// Non-terrain objects (id > 255) without recipes
console.info("\n\nNon-terrain objects (ID > 255) without recipes:");
console.info("------------------------------------------------");

const nonTerrainWithoutRecipes: (typeof objects)[0][] = [];
for (const obj of sortedObjects) {
  if (obj.id > 255 && !objectsWithRecipes.has(obj.name)) {
    nonTerrainWithoutRecipes.push(obj);
  }
}

if (nonTerrainWithoutRecipes.length > 0) {
  for (const obj of nonTerrainWithoutRecipes) {
    console.info(`- ${obj.name} (ID: ${obj.id})`);
  }
  console.info(`Total: ${nonTerrainWithoutRecipes.length} objects`);
} else {
  console.info("None found - all non-terrain objects have recipes!");
}

// Find objects that are only inputs (never crafted)
console.info("\n\nObjects that are never crafted (only used as inputs):");
console.info("-----------------------------------------------------");

const inputOnlyObjects = new Set<ObjectName>();
for (const recipe of recipes) {
  for (const [inputName] of recipe.inputs) {
    if (!objectsWithRecipes.has(inputName)) {
      inputOnlyObjects.add(inputName);
    }
  }
}

const sortedInputOnly = Array.from(inputOnlyObjects).sort();
for (const objName of sortedInputOnly) {
  const obj = objectsByName[objName];
  if (obj) {
    console.info(`- ${objName} (ID: ${obj.id})`);
  }
}

// Recipe cycles (objects that can be converted back to themselves)
console.info("\n\nRecipe Cycles Detection:");
console.info("------------------------");

// Build a graph of what can be crafted into what
const craftingGraph = new Map<ObjectName, Set<ObjectName>>();

for (const recipe of recipes) {
  for (const [inputName] of recipe.inputs) {
    if (!craftingGraph.has(inputName)) {
      craftingGraph.set(inputName, new Set());
    }
    for (const [outputName] of recipe.outputs) {
      craftingGraph.get(inputName)!.add(outputName);
    }
  }
}

// Simple cycle detection (depth-limited to avoid infinite loops)
function findCycles(
  start: ObjectName,
  current: ObjectName,
  visited: Set<ObjectName>,
  depth: number,
): boolean {
  if (depth > 10) return false; // Limit depth to avoid deep recursion
  if (current === start && depth > 0) return true;
  if (visited.has(current)) return false;

  visited.add(current);
  const outputs = craftingGraph.get(current);
  if (outputs) {
    for (const output of outputs) {
      if (findCycles(start, output, new Set(visited), depth + 1)) {
        return true;
      }
    }
  }
  return false;
}

const objectsWithCycles = new Set<ObjectName>();
for (const obj of objects) {
  if (findCycles(obj.name, obj.name, new Set(), 0)) {
    objectsWithCycles.add(obj.name);
  }
}

if (objectsWithCycles.size > 0) {
  console.info(
    "Objects that can be cycled back to themselves through recipes:",
  );
  for (const objName of Array.from(objectsWithCycles).sort()) {
    console.info(`- ${objName}`);
  }
} else {
  console.info("No recipe cycles detected!");
}

// Recipe efficiency analysis (output/input ratio)
console.info("\n\nRecipe Efficiency (by item count):");
console.info("----------------------------------");

const efficiencyData: { recipe: Recipe; efficiency: number }[] = [];

for (const recipe of recipes) {
  const inputCount = recipe.inputs.reduce(
    (sum, [_, amt]) => sum + Number(amt),
    0,
  );
  const outputCount = recipe.outputs.reduce(
    (sum, [_, amt]) => sum + Number(amt),
    0,
  );
  const efficiency = outputCount / inputCount;
  efficiencyData.push({ recipe, efficiency });
}

// Show top 10 most efficient recipes
console.info("\nTop 10 most efficient recipes:");
const topEfficient = efficiencyData
  .sort((a, b) => b.efficiency - a.efficiency)
  .slice(0, 10);
for (const { recipe, efficiency } of topEfficient) {
  const inputs = recipe.inputs
    .map(([name, amt]) => `${amt}x ${name}`)
    .join(" + ");
  const outputs = recipe.outputs
    .map(([name, amt]) => `${amt}x ${name}`)
    .join(" + ");
  const station = recipe.station ? ` @ ${recipe.station}` : "";
  console.info(
    `- ${inputs} → ${outputs}${station} (${efficiency.toFixed(2)}x)`,
  );
}

// Stations usage statistics
console.info("\n\nCrafting Station Usage:");
console.info("-----------------------");

const stationUsage = new Map<string, number>();
stationUsage.set("Hand", 0);

for (const recipe of recipes) {
  const station = recipe.station || "Hand";
  stationUsage.set(station, (stationUsage.get(station) || 0) + 1);
}

for (const [station, count] of Array.from(stationUsage.entries()).sort(
  (a, b) => b[1] - a[1],
)) {
  const percentage = ((count / recipes.length) * 100).toFixed(1);
  console.info(`${station}: ${count} recipes (${percentage}%)`);
}

// Special category recipes
console.info("\n\nSpecial Recipe Categories:");
console.info("--------------------------");

// Recipes with multiple inputs
const multiInputRecipes = recipes.filter((r) => r.inputs.length > 1);
console.info(`\nRecipes with multiple inputs: ${multiInputRecipes.length}`);
if (multiInputRecipes.length > 0 && multiInputRecipes.length <= 20) {
  for (const recipe of multiInputRecipes) {
    const inputs = recipe.inputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const outputs = recipe.outputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const station = recipe.station ? ` @ ${recipe.station}` : "";
    console.info(`  ${inputs} → ${outputs}${station}`);
  }
}

// Recipes with multiple outputs
const multiOutputRecipes = recipes.filter((r) => r.outputs.length > 1);
console.info(`\nRecipes with multiple outputs: ${multiOutputRecipes.length}`);
if (multiOutputRecipes.length > 0 && multiOutputRecipes.length <= 20) {
  for (const recipe of multiOutputRecipes) {
    const inputs = recipe.inputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const outputs = recipe.outputs
      .map(([name, amt]) => `${amt}x ${name}`)
      .join(" + ");
    const station = recipe.station ? ` @ ${recipe.station}` : "";
    console.info(`  ${inputs} → ${outputs}${station}`);
  }
}
