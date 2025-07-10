import { objectDef, objects } from "../objects";

// Find objects with explicit IDs
const explicitIds = objectDef.filter((obj) => obj.id !== undefined);
for (const obj of objects) {
  const index = objects.indexOf(obj);
  const original = objectDef[index];
  const hasExplicitId = original?.id !== undefined;
}

const ids = objects.map((obj) => obj.id);
const minId = Math.min(...ids);
const maxId = Math.max(...ids);
const uniqueIds = new Set(ids);

if (uniqueIds.size !== objects.length) {
  const duplicates = ids.filter((id, index) => ids.indexOf(id) !== index);
} else {
}

// Check for gaps
const gaps = [];
for (let i = minId; i <= maxId; i++) {
  if (!uniqueIds.has(i)) {
    gaps.push(i);
  }
}

if (gaps.length > 0) {
} else {
}
