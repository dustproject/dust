import { type ObjectName, categories, objects } from "../objects";
import { recipes } from "../recipes";

// Get all active object names from the objects array
const activeObjectNames = new Set(objects.map((obj) => obj.name));

// Create a map of object to its categories
const objectCategories: Map<ObjectName, string[]> = new Map();

// Initialize all objects with empty category arrays
for (const obj of objects) {
  objectCategories.set(obj.name, []);
}

// Go through each category and map objects to categories
for (const [categoryName, category] of Object.entries(categories)) {
  for (const objName of category.objects) {
    // Only process objects that are actually defined in the objects array
    if (activeObjectNames.has(objName as ObjectName)) {
      const cats = objectCategories.get(objName as ObjectName) || [];
      cats.push(categoryName);
      objectCategories.set(objName as ObjectName, cats);
    }
  }
}

// Sort objects by ID for consistent output
const sortedObjects = [...objects].sort((a, b) => a.id - b.id);

// Print header
console.info("Object Category Analysis");
console.info("========================");
console.info(`Total objects: ${objects.length}`);
console.info("");

// Print objects with no categories
console.info("Objects with NO categories:");
console.info("--------------------------");
let noCategoryCount = 0;
for (const obj of sortedObjects) {
  const cats = objectCategories.get(obj.name) || [];
  if (cats.length === 0) {
    console.info(`- ${obj.name} (id: ${obj.id})`);
    noCategoryCount++;
  }
}
console.info(`Total: ${noCategoryCount} objects\n`);

// Print all objects with their categories
console.info("All objects and their categories:");
console.info("---------------------------------");
for (const obj of sortedObjects) {
  const cats = objectCategories.get(obj.name) || [];
  console.info(
    `${obj.name} (id: ${obj.id}): ${cats.length > 0 ? cats.join(", ") : "NONE"}`,
  );
}

// Category statistics
console.info("\nCategory Statistics:");
console.info("-------------------");
for (const [categoryName, category] of Object.entries(categories)) {
  const activeCount = category.objects.filter((name) =>
    activeObjectNames.has(name as ObjectName),
  ).length;
  const totalCount = category.objects.length;
  console.info(
    `${categoryName}: ${activeCount} active objects (${totalCount} total in category definition)`,
  );
}

// Create a map of objects to their crafting stations
const objectToStation: Map<ObjectName, Set<ObjectName | undefined>> = new Map();

// Analyze recipes to find which station crafts each object
for (const recipe of recipes) {
  for (const [outputName, _] of recipe.outputs) {
    if (!objectToStation.has(outputName)) {
      objectToStation.set(outputName, new Set());
    }
    objectToStation.get(outputName)!.add(recipe.station);
  }
}

// Print objects and their crafting stations
console.info("\nObjects and their crafting stations:");
console.info("------------------------------------");
console.info(
  "(undefined = hand crafting, multiple = can be crafted at multiple stations)\n",
);

for (const obj of sortedObjects) {
  const stations = objectToStation.get(obj.name);
  if (stations && stations.size > 0) {
    const stationList = Array.from(stations)
      .map((s) => s || "Hand")
      .join(", ");
    console.info(`${obj.name}: ${stationList}`);
  }
}

// Check for objects that might have wrong stations
console.info("\nPotential station assignment issues:");
console.info("-----------------------------------");

// Stone items that are hand-crafted but might need stonecutter
console.info("\nStone-like items crafted by hand:");
const stoneItemKeywords = [
  "stone",
  "brick",
  "polished",
  "chiseled",
  "smooth",
  "cracked",
  "cut",
];
for (const obj of sortedObjects) {
  const stations = objectToStation.get(obj.name);
  if (stations?.has(undefined)) {
    const name = obj.name.toLowerCase();
    if (stoneItemKeywords.some((keyword) => name.includes(keyword))) {
      console.info(
        `- ${obj.name} (crafted by: ${Array.from(stations)
          .map((s) => s || "Hand")
          .join(", ")})`,
      );
    }
  }
}

// Items crafted at furnace that might be wrong
console.info("\nItems crafted at furnace:");
for (const obj of sortedObjects) {
  const stations = objectToStation.get(obj.name);
  if (stations?.has("Furnace")) {
    console.info(`- ${obj.name}`);
  }
}

// Items that require workbench
console.info("\nItems crafted at workbench:");
for (const obj of sortedObjects) {
  const stations = objectToStation.get(obj.name);
  if (stations?.has("Workbench")) {
    console.info(`- ${obj.name}`);
  }
}

// Items crafted at stonecutter
console.info("\nItems crafted at stonecutter:");
for (const obj of sortedObjects) {
  const stations = objectToStation.get(obj.name);
  if (stations?.has("Stonecutter")) {
    console.info(`- ${obj.name}`);
  }
}
