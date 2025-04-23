import type { ObjectTypeName } from "./objects";

interface Vec3 {
  x: number;
  y: number;
  z: number;
}

interface TreeDef {
  name: string;
  sapling: ObjectTypeName;
  log: ObjectTypeName;
  leaf: ObjectTypeName;
  trunkHeight: number;
  canopyStart: number;
  canopyEnd: number; // exclusive
  canopyWidth: number;
  stretch: number;
  centerOffset: number;
}

export const TREES: TreeDef[] = [
  {
    name: "Oak",
    sapling: "OakSapling",
    log: "OakLog",
    leaf: "OakLeaf",
    trunkHeight: 5,
    canopyStart: 3,
    canopyEnd: 7,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: -2,
  },
  {
    name: "Birch",
    sapling: "BirchSapling",
    log: "BirchLog",
    leaf: "BirchLeaf",
    trunkHeight: 7,
    canopyStart: 6,
    canopyEnd: 8,
    canopyWidth: 1,
    stretch: 2,
    centerOffset: 0,
  },
  {
    name: "Jungle",
    sapling: "JungleSapling",
    log: "JungleLog",
    leaf: "JungleLeaf",
    trunkHeight: 12,
    canopyStart: 11,
    canopyEnd: 16,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: 1,
  },
  {
    name: "Sakura",
    sapling: "SakuraSapling",
    log: "SakuraLog",
    leaf: "SakuraLeaf",
    trunkHeight: 6,
    canopyStart: 4,
    canopyEnd: 9,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: -1,
  },
  {
    name: "Acacia",
    sapling: "AcaciaSapling",
    log: "AcaciaLog",
    leaf: "AcaciaLeaf",
    trunkHeight: 6,
    canopyStart: 6,
    canopyEnd: 8,
    canopyWidth: 2,
    stretch: 3,
    centerOffset: 0,
  },
  {
    name: "Spruce",
    sapling: "SpruceSapling",
    log: "SpruceLog",
    leaf: "SpruceLeaf",
    trunkHeight: 9,
    canopyStart: 3,
    canopyEnd: 12,
    canopyWidth: 3,
    stretch: 1,
    centerOffset: -2,
  },
  {
    name: "DarkOak",
    sapling: "DarkOakSapling",
    log: "DarkOakLog",
    leaf: "DarkOakLeaf",
    trunkHeight: 6,
    canopyStart: 2,
    canopyEnd: 8,
    canopyWidth: 3,
    stretch: 1,
    centerOffset: -1,
  },
  {
    name: "Mangrove",
    sapling: "MangroveSapling",
    log: "MangroveLog",
    leaf: "MangroveLeaf",
    trunkHeight: 8,
    canopyStart: 6,
    canopyEnd: 12,
    canopyWidth: 2,
    stretch: 2,
    centerOffset: 0,
  },
];

export function classifyLeaves(tree: TreeDef): {
  fixed: Vec3[];
  random: Vec3[];
} {
  const fixed: Vec3[] = [];
  const random: Vec3[] = [];

  const centre = tree.trunkHeight + tree.centerOffset;

  for (let y = tree.canopyStart; y < tree.canopyEnd; ++y) {
    const dy = Math.abs(y - centre);
    const band = Math.floor(dy / tree.stretch);
    const radius = tree.canopyWidth - band;
    if (radius < 0) continue;

    for (let x = -radius; x <= radius; ++x) {
      for (let z = -radius; z <= radius; ++z) {
        if (x === 0 && z === 0 && y < tree.trunkHeight) continue;

        const isCorner =
          radius !== 0 && Math.abs(x) === radius && Math.abs(z) === radius;

        if (isCorner) {
          // skip all corners on duplicated‑layer indices
          if ((dy + 1) % tree.stretch === 0) continue;

          // surviving corners are subject to RNG → random set
          random.push({ x, y, z });
        } else {
          // non‑corner leaves are always present
          fixed.push({ x, y, z });
        }
      }
    }
  }
  return { fixed, random };
}
