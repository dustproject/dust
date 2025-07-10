import { readFileSync, writeFileSync } from "node:fs";

// Import current objects
import { type ObjectDefinition, objects as originalObjects } from "../objects";

// Temporarily replace the objects.ts file to test the new version
const objectsFilePath =
  "/Users/vdrg/Work/dustproject/new-recipes/packages/world/ts/objects.ts";
const originalContent = readFileSync(objectsFilePath, "utf8");
const newContent = readFileSync(`${objectsFilePath}.new`, "utf8");

// Replace the file temporarily
writeFileSync(objectsFilePath, newContent);

// Clear require cache to reload the module
delete require.cache[require.resolve("../objects")];

// Import the new objects
const { objects: newObjects } = require("../objects");

// Restore the original file
writeFileSync(objectsFilePath, originalContent);

// Compare IDs
let allMatch = true;
const differences = [];

for (let i = 0; i < Math.max(originalObjects.length, newObjects.length); i++) {
  const original = originalObjects[i];
  const updated = newObjects[i];

  if (!original || !updated) {
    differences.push(
      `Index ${i}: Missing object (original: ${!!original}, new: ${!!updated})`,
    );
    allMatch = false;
    continue;
  }

  if (original.id !== updated.id || original.name !== updated.name) {
    differences.push(
      `Index ${i}: ${original.name}(${original.id}) !== ${updated.name}(${updated.id})`,
    );
    allMatch = false;
  }
}

if (allMatch) {
} else {
  for (const diff of differences.slice(0, 10)) {
  }
  if (differences.length > 10) {
  }
}
const ids = newObjects.map((obj: ObjectDefinition) => obj.id);
const minId = Math.min(...ids);
const maxId = Math.max(...ids);
const uniqueIds = new Set(ids);

if (uniqueIds.size !== newObjects.length) {
} else {
}
