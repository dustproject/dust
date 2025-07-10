import { objects } from "../objects";

interface IdRange {
  start: number;
  end: number;
  name: string;
  description: string;
}

const ID_RANGES: IdRange[] = [
  {
    start: 0,
    end: 999,
    name: "blocks",
    description: "Terrain blocks, building materials, and basic items",
  },
  {
    start: 32768,
    end: 65535,
    name: "tools",
    description: "Tools, weapons, and special items",
  },
];

export function findNextAvailableId(preferredRange?: string): number {
  const usedIds = new Set(objects.map((obj) => obj.id));

  if (preferredRange) {
    const range = ID_RANGES.find((r) => r.name === preferredRange);
    if (range) {
      for (let id = range.start; id <= range.end; id++) {
        if (!usedIds.has(id)) {
          return id;
        }
      }
    }
  }

  // Find next available in any range
  for (const range of ID_RANGES) {
    for (let id = range.start; id <= range.end; id++) {
      if (!usedIds.has(id)) {
        return id;
      }
    }
  }

  // Fallback: find next available ID after all ranges
  let id = Math.max(...ID_RANGES.map((r) => r.end)) + 1;
  while (usedIds.has(id)) {
    id++;
  }
  return id;
}

export function analyzeIdUsage(): void {
  const usedIds = objects.map((obj) => obj.id).sort((a, b) => a - b);

  for (const range of ID_RANGES) {
    const idsInRange = usedIds.filter(
      (id) => id >= range.start && id <= range.end,
    );
    const available = range.end - range.start + 1 - idsInRange.length;
    const utilization = (
      (idsInRange.length / (range.end - range.start + 1)) *
      100
    ).toFixed(1);
  }

  // Find objects outside defined ranges
  const outsideRange = usedIds.filter(
    (id) => !ID_RANGES.some((range) => id >= range.start && id <= range.end),
  );

  if (outsideRange.length > 0) {
  }
  for (const range of ID_RANGES) {
    const idsInRange = usedIds.filter(
      (id) => id >= range.start && id <= range.end,
    );
    const gaps = [];

    for (let i = range.start; i <= range.end; i++) {
      if (!idsInRange.includes(i)) {
        gaps.push(i);
      }
    }

    if (gaps.length > 0) {
      const gapRanges = [];
      let start = gaps[0];
      let end = gaps[0];

      for (let i = 1; i < gaps.length; i++) {
        if (gaps[i] === end! + 1) {
          end = gaps[i];
        } else {
          gapRanges.push(start === end ? `${start}` : `${start}-${end!}`);
          start = end = gaps[i];
        }
      }
      gapRanges.push(start === end ? `${start}` : `${start}-${end!}`);
    }
  }
}

export function suggestIdForNewObject(
  objectType: "block" | "item" | "tool",
): number {
  const rangeMap = {
    block: "blocks",
    item: "blocks",
    tool: "tools",
  };

  return findNextAvailableId(rangeMap[objectType]);
}

export function validateNewObjectId(id: number, objectName: string): string[] {
  const issues = [];
  const usedIds = new Set(objects.map((obj) => obj.id));

  if (usedIds.has(id)) {
    const existing = objects.find((obj) => obj.id === id);
    issues.push(`ID ${id} is already used by ${existing?.name}`);
  }

  if (id < 0) {
    issues.push("ID cannot be negative");
  }

  if (id > 100000) {
    issues.push("ID is very large (>100,000), check for typos");
  }

  // Check if ID is in a reasonable range
  const inValidRange = ID_RANGES.some(
    (range) => id >= range.start && id <= range.end,
  );
  if (!inValidRange) {
    issues.push(
      `ID ${id} is outside defined ranges: ${ID_RANGES.map((r) => `${r.name} (${r.start}-${r.end})`).join(", ")}`,
    );
  }

  return issues;
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const command = process.argv[2];

  switch (command) {
    case "analyze":
      analyzeIdUsage();
      break;

    case "next": {
      const range = process.argv[3];
      const nextId = findNextAvailableId(range);
      break;
    }

    case "suggest": {
      const type = process.argv[3] as "block" | "item" | "tool";
      if (!type || !["block", "item", "tool"].includes(type)) {
        process.exit(1);
      }
      const suggested = suggestIdForNewObject(type);
      break;
    }

    case "validate": {
      const idArg = process.argv[3];
      const name = process.argv[4];
      if (!idArg || !name) {
        process.exit(1);
      }
      const id = Number.parseInt(idArg);
      if (Number.isNaN(id)) {
        process.exit(1);
      }
      const issues = validateNewObjectId(id, name);
      if (issues.length === 0) {
      } else {
        for (const issue of issues) {
        }
        process.exit(1);
      }
      break;
    }

    default:
  }
}
