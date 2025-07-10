import { objectDef, objects } from "../objects";

interface ValidationResult {
  success: boolean;
  errors: string[];
  warnings: string[];
}

export function validateObjectIds(): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  // 1. Check that all objects have explicit IDs
  const objectsWithoutExplicitIds = objectDef.filter(
    (obj) => obj.id === undefined,
  );
  if (objectsWithoutExplicitIds.length > 0) {
    errors.push(
      `${objectsWithoutExplicitIds.length} objects missing explicit ID: ${objectsWithoutExplicitIds.map((o) => o.name).join(", ")}`,
    );
  }

  // 2. Check for duplicate IDs
  const idCounts = new Map<number, string[]>();
  for (const obj of objects) {
    if (!idCounts.has(obj.id)) {
      idCounts.set(obj.id, []);
    }
    idCounts.get(obj.id)!.push(obj.name);
  }

  const duplicateIds = Array.from(idCounts.entries()).filter(
    ([_, names]) => names.length > 1,
  );
  for (const [id, names] of duplicateIds) {
    errors.push(`Duplicate ID ${id} used by: ${names.join(", ")}`);
  }

  // 3. Check ID ranges and gaps
  const ids = objects.map((obj) => obj.id).sort((a, b) => a - b);
  const minId = Math.min(...ids);
  const maxId = Math.max(...ids);

  // Check for negative IDs
  const negativeIds = ids.filter((id) => id < 0);
  if (negativeIds.length > 0) {
    errors.push(`Negative IDs found: ${negativeIds.join(", ")}`);
  }

  // Check for very large IDs (potential typos)
  const largeIds = ids.filter((id) => id > 100000);
  if (largeIds.length > 0) {
    warnings.push(
      `Very large IDs found (check for typos): ${largeIds.join(", ")}`,
    );
  }

  // 4. Check consistency between objectNames and objects arrays
  const objectNameSet = new Set(objects.map((obj) => obj.name));
  const missingInObjects = objects.filter(
    (obj) => !objectNameSet.has(obj.name),
  );
  if (missingInObjects.length > 0) {
    errors.push(
      `Objects missing from objectNames array: ${missingInObjects.map((o) => o.name).join(", ")}`,
    );
  }

  // 5. Check for reasonable ID progression
  const blockIds = ids.filter((id) => id < 1000); // Assume blocks are < 1000
  const toolIds = ids.filter((id) => id >= 32768); // Tools are in high range

  if (blockIds.length > 0) {
    const blockGaps = [];
    for (let i = Math.min(...blockIds); i <= Math.max(...blockIds); i++) {
      if (!blockIds.includes(i)) {
        blockGaps.push(i);
      }
    }

    if (blockGaps.length > 50) {
      warnings.push(
        `Many gaps in block ID range (${blockGaps.length} gaps), consider compacting`,
      );
    }
  }

  // 6. Validate specific ID ranges
  const reservedRanges = [
    { start: 0, end: 999, name: "blocks and items" },
    { start: 32768, end: 65535, name: "tools and special items" },
  ];

  const idsOutsideRanges = ids.filter((id) => {
    return !reservedRanges.some(
      (range) => id >= range.start && id <= range.end,
    );
  });

  if (idsOutsideRanges.length > 0) {
    warnings.push(
      `IDs outside expected ranges: ${idsOutsideRanges.join(", ")}`,
    );
  }

  if (errors.length === 0 && warnings.length === 0) {
  }

  if (warnings.length > 0) {
    for (const warning of warnings) {
    }
  }

  if (errors.length > 0) {
    for (const error of errors) {
    }
  }

  return {
    success: errors.length === 0,
    errors,
    warnings,
  };
}

// Run validation if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const result = validateObjectIds();
  process.exit(result.success ? 0 : 1);
}
