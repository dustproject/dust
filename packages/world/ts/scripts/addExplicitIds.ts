import { readFileSync, writeFileSync } from "node:fs";
import { objectDef, objects } from "../objects";

// Create mapping of current IDs
const currentIds = new Map<string, number>();
for (const obj of objects) {
  currentIds.set(obj.name, obj.id);
}

// Read the current objects.ts file
const objectsFilePath =
  "/Users/vdrg/Work/dustproject/new-recipes/packages/world/ts/objects.ts";
const originalContent = readFileSync(objectsFilePath, "utf8");

// Simple approach: add id field to each object definition in place
let modifiedContent = originalContent;

// Find each object definition and add the id field
for (const [index, obj] of objectDef.entries()) {
  const currentId = currentIds.get(obj.name);
  if (currentId === undefined) {
    throw new Error(`Could not find current ID for object: ${obj.name}`);
  }

  // Look for the name property and add id right after it
  const namePattern = new RegExp(`{\\s*name:\\s*"${obj.name}"`, "g");
  const replacement = `{ name: "${obj.name}", id: ${currentId}`;

  const matches = modifiedContent.match(namePattern);
  if (matches && matches.length === 1) {
    modifiedContent = modifiedContent.replace(namePattern, replacement);
  } else {
    console.warn(`⚠️  Could not find unique pattern for ${obj.name}`);
  }
}

// Write the new file content
writeFileSync(`${objectsFilePath}.new`, modifiedContent);
