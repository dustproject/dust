import { writeFileSync } from "node:fs";
import { objects } from "../objects.js";

// Create CSV content
const csvLines: string[] = [];

// Add header
csvLines.push("id,name,mass,energy");

// Add data rows
for (const obj of objects) {
  const id = obj.id;
  const name = obj.name;
  const mass = obj.mass?.toString() || "";
  const energy = obj.energy?.toString() || "";

  // Escape name if it contains commas
  const escapedName = name.includes(",") ? `"${name}"` : name;

  csvLines.push(`${id},${escapedName},${mass},${energy}`);
}

// Write to file
const csvContent = csvLines.join("\n");
const outputPath = "objects-export.csv";
writeFileSync(outputPath, csvContent);

console.info(`Exported ${objects.length} objects to ${outputPath}`);
