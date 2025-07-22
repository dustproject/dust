import config from "../mud.config";
import type { Vec3 } from "./vec3";

// Direction is an array of strings
config.enums.Direction;

export type Direction = (typeof config.enums.Direction)[number];

export const CANONICAL_VECTORS = {
  PositiveX: [1, 0, 0],
  NegativeX: [-1, 0, 0],
  PositiveY: [0, 1, 0],
  NegativeY: [0, -1, 0],
  PositiveZ: [0, 0, 1],
  NegativeZ: [0, 0, -1],
  PositiveXPositiveY: [1, 1, 0],
  PositiveXNegativeY: [1, -1, 0],
  NegativeXPositiveY: [-1, 1, 0],
  NegativeXNegativeY: [-1, -1, 0],
  PositiveXPositiveZ: [1, 0, 1],
  PositiveXNegativeZ: [1, 0, -1],
  NegativeXPositiveZ: [-1, 0, 1],
  NegativeXNegativeZ: [-1, 0, -1],
  PositiveYPositiveZ: [0, 1, 1],
  PositiveYNegativeZ: [0, 1, -1],
  NegativeYPositiveZ: [0, -1, 1],
  NegativeYNegativeZ: [0, -1, -1],
  PositiveXPositiveYPositiveZ: [1, 1, 1],
  PositiveXPositiveYNegativeZ: [1, 1, -1],
  PositiveXNegativeYPositiveZ: [1, -1, 1],
  PositiveXNegativeYNegativeZ: [1, -1, -1],
  NegativeXPositiveYPositiveZ: [-1, 1, 1],
  NegativeXPositiveYNegativeZ: [-1, 1, -1],
  NegativeXNegativeYPositiveZ: [-1, -1, 1],
  NegativeXNegativeYNegativeZ: [-1, -1, -1],
} as const satisfies { [key in Direction]: Vec3 };

export const CANONICAL_UP: Vec3 = CANONICAL_VECTORS.PositiveY;
export const CANONICAL_FORWARD: Vec3 = CANONICAL_VECTORS.PositiveX;

// Full six axis directions (for general use, e.g., forward or up in orientations)
export type AxisDirection =
  | "PositiveX"
  | "NegativeX"
  | "PositiveY"
  | "NegativeY"
  | "PositiveZ"
  | "NegativeZ";

// Narrowed to four horizontal cardinals (for facing/forward in placement)
export type CardinalDirection =
  | "PositiveX"
  | "NegativeX"
  | "PositiveZ"
  | "NegativeZ";

export type SupportedDirection =
  | "PositiveX"
  | "NegativeX"
  | "PositiveY"
  | "NegativeY"
  | "PositiveZ"
  | "NegativeZ";

export type Orientation = number; // uint8 in Solidity

type Axis = 0 | 1 | 2;
export type Permute = readonly [Axis, Axis, Axis];
export type Reflect = readonly [0 | 1, 0 | 1, 0 | 1];

// 6 possible permutations
export const PERMUTATIONS: readonly [
  Permute,
  Permute,
  Permute,
  Permute,
  Permute,
  Permute,
] = [
  [0, 1, 2], // Original orientation
  [0, 2, 1], // Swap y and z
  [1, 0, 2], // Swap x and y
  [1, 2, 0], // Rotate x->y->z->x
  [2, 0, 1], // Rotate x->z->y->x
  [2, 1, 0], // Swap x and z
] as const;

// 8 possible reflections
export const REFLECTIONS: readonly [
  Reflect,
  Reflect,
  Reflect,
  Reflect,
  Reflect,
  Reflect,
  Reflect,
  Reflect,
] = [
  [0, 0, 0], // No reflection
  [1, 0, 0], // Reflect x
  [0, 1, 0], // Reflect y
  [1, 1, 0], // Reflect x and y
  [0, 0, 1], // Reflect z
  [1, 0, 1], // Reflect x and z
  [0, 1, 1], // Reflect y and z
  [1, 1, 1], // Reflect all axes
] as const;

export function applyOrientation(v: Vec3, perm: Permute, refl: Reflect): Vec3 {
  const out: Vec3 = [v[perm[0]]!, v[perm[1]]!, v[perm[2]]!];
  if (refl[0]) out[0] = -out[0];
  if (refl[1]) out[1] = -out[1];
  if (refl[2]) out[2] = -out[2];
  return out;
}

export function getOrientation(forwardDirection: AxisDirection): Orientation {
  return getOrientationGeneric(forwardDirection, "PositiveY");
}

export function getOrientationGeneric(
  forwardDirection: AxisDirection,
  upDirection: AxisDirection,
): Orientation {
  const targetForward = CANONICAL_VECTORS[forwardDirection]!;
  const targetUp = CANONICAL_VECTORS[upDirection]!;

  for (let permIdx = 0; permIdx < PERMUTATIONS.length; ++permIdx) {
    for (let reflIdx = 0; reflIdx < REFLECTIONS.length; ++reflIdx) {
      const perm = PERMUTATIONS[permIdx]!;
      const refl = REFLECTIONS[reflIdx]!;

      const up = applyOrientation(CANONICAL_UP, perm, refl);
      const forward = applyOrientation(CANONICAL_FORWARD, perm, refl);

      if (
        up[0] === targetUp[0] &&
        up[1] === targetUp[1] &&
        up[2] === targetUp[2] &&
        forward[0] === targetForward[0] &&
        forward[1] === targetForward[1] &&
        forward[2] === targetForward[2]
      ) {
        return encodeOrientation(perm, refl);
      }
    }
  }
  throw new Error("Unable to find orientation");
}

export function getDirection(orientation: Orientation): SupportedDirection {
  return getDirectionGeneric(orientation, "PositiveY");
}

export function getDirectionGeneric(
  orientation: Orientation,
  upDirection: AxisDirection,
): AxisDirection {
  const [perm, refl] = decodeOrientation(orientation);
  const up = applyOrientation(CANONICAL_UP, perm, refl);
  const targetUp = CANONICAL_VECTORS[upDirection]!;

  const forward = applyOrientation(CANONICAL_FORWARD, perm, refl);

  const forwardDirection = Object.keys(CANONICAL_VECTORS).find((dir) => {
    const targetForward = CANONICAL_VECTORS[dir as SupportedDirection]!;
    return (
      up[0] === targetUp[0] &&
      up[1] === targetUp[1] &&
      up[2] === targetUp[2] &&
      forward[0] === targetForward[0] &&
      forward[1] === targetForward[1] &&
      forward[2] === targetForward[2]
    );
  });
  if (!forwardDirection) throw new Error("Unable to find direction");
  return forwardDirection as SupportedDirection;
}

export function encodeOrientation(perm: Permute, refl: Reflect): Orientation {
  // Find the index of the permutation in PERMUTATIONS array
  const permIdx = PERMUTATIONS.findIndex(
    (p) => p[0] === perm[0] && p[1] === perm[1] && p[2] === perm[2],
  );
  if (permIdx === -1) throw new Error("Invalid permutation");

  // Find the index of the reflection in REFLECTIONS array
  const reflIdx = REFLECTIONS.findIndex(
    (r) => r[0] === refl[0] && r[1] === refl[1] && r[2] === refl[2],
  );
  if (reflIdx === -1) throw new Error("Invalid reflection");

  // Combine the indices into a single orientation number
  return (permIdx << 3) | reflIdx;
}

export function decodeOrientation(
  orientation: Orientation,
): [Permute, Reflect] {
  const permIdx = orientation >> 3;
  const reflIdx = orientation & 7;
  return [PERMUTATIONS[permIdx]!, REFLECTIONS[reflIdx]!];
}

export function isUpsideDown(orientation: Orientation): boolean {
  const [perm, refl] = decodeOrientation(orientation);
  const up = applyOrientation(CANONICAL_UP, perm, refl);
  return up[0] === 0 && up[1] === -1 && up[2] === 0;
}

// All possible orientations (0-47)
export const ALL_ORIENTATIONS: readonly Orientation[] = Array.from(
  { length: 48 },
  (_, i) => i,
);

// Common orientation sets for different object types
export const CARDINAL_ORIENTATIONS: readonly Orientation[] = [0, 1, 40, 44];
export const STAIR_ORIENTATIONS: readonly Orientation[] = [
  0,
  1,
  40,
  44,
  2,
  3,
  42,
  46, // 8 orientations for stairs (4 directions × 2 for upside-down)
];
export const SLAB_ORIENTATIONS: readonly Orientation[] = [0, 2]; // Bottom and top slabs
