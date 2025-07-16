import config from "../mud.config";
import type { Vec3 } from "./vec3";

// Direction is an array of strings
config.enums.Direction;

type Direction = (typeof config.enums.Direction)[number];

const SUPPORTED_DIRECTION_VECTORS: {
  [key in Direction]?: [number, number, number];
} = {
  PositiveX: [1, 0, 0],
  NegativeX: [-1, 0, 0],
  PositiveY: [0, 1, 0],
  NegativeY: [0, -1, 0],
  PositiveZ: [0, 0, 1],
  NegativeZ: [0, 0, -1],
};

type SupportedDirection = keyof typeof SUPPORTED_DIRECTION_VECTORS;

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

const CANONICAL_UP: Vec3 = [0, 1, 0];
const CANONICAL_FORWARD: Vec3 = [1, 0, 0];

export function applyOrientation(v: Vec3, perm: Permute, refl: Reflect): Vec3 {
  const out: Vec3 = [v[perm[0]]!, v[perm[1]]!, v[perm[2]]!];
  if (refl[0]) out[0] = -out[0];
  if (refl[1]) out[1] = -out[1];
  if (refl[2]) out[2] = -out[2];
  return out;
}

export function getOrientation(
  forwardDirection: SupportedDirection,
): Orientation {
  return getOrientationGeneric(forwardDirection, "PositiveY");
}

export function getOrientationGeneric(
  forwardDirection: SupportedDirection,
  upDirection: SupportedDirection,
): Orientation {
  const targetForward = SUPPORTED_DIRECTION_VECTORS[forwardDirection]!;
  const targetUp = SUPPORTED_DIRECTION_VECTORS[upDirection]!;

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
  upDirection: SupportedDirection,
): SupportedDirection {
  const [perm, refl] = decodeOrientation(orientation);
  const up = applyOrientation(CANONICAL_UP, perm, refl);
  const targetUp = SUPPORTED_DIRECTION_VECTORS[upDirection]!;

  const forward = applyOrientation(CANONICAL_FORWARD, perm, refl);

  const forwardDirection = Object.keys(SUPPORTED_DIRECTION_VECTORS).find(
    (dir) => {
      const targetForward =
        SUPPORTED_DIRECTION_VECTORS[dir as SupportedDirection]!;
      return (
        up[0] === targetUp[0] &&
        up[1] === targetUp[1] &&
        up[2] === targetUp[2] &&
        forward[0] === targetForward[0] &&
        forward[1] === targetForward[1] &&
        forward[2] === targetForward[2]
      );
    },
  );
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
  2,
  3,
  40,
  41,
  42,
  43, // 8 orientations for stairs (4 directions × 2 for upside-down)
];
export const SLAB_ORIENTATIONS: readonly Orientation[] = [0, 2]; // Bottom and top slabs
