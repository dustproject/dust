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
export const PERMUTATIONS: Permute[] = [
  [0, 1, 2], // Original orientation
  [0, 2, 1], // Swap y and z
  [1, 0, 2], // Swap x and y
  [1, 2, 0], // Rotate x->y->z->x
  [2, 0, 1], // Rotate x->z->y->x
  [2, 1, 0], // Swap x and z
];

// 8 possible reflections
export const REFLECTIONS: Reflect[] = [
  [0, 0, 0], // No reflection
  [1, 0, 0], // Reflect x
  [0, 1, 0], // Reflect y
  [1, 1, 0], // Reflect x and y
  [0, 0, 1], // Reflect z
  [1, 0, 1], // Reflect x and z
  [0, 1, 1], // Reflect y and z
  [1, 1, 1], // Reflect all axes
];

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

  for (let permIdx = 0; permIdx < 6; ++permIdx) {
    for (let reflIdx = 0; reflIdx < 8; ++reflIdx) {
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
        return permIdx * 8 + reflIdx;
      }
    }
  }
  throw new Error("Unable to find orientation");
}

// TODO: implement
export function encodeOrientation(refl: Reflect, perm: Permute): Orientation {
  return 0;
}

export function decodeOrientation(
  orientation: Orientation,
): [Reflect, Permute] {
  const reflIdx = orientation & 8;
  const permIdx = orientation >> 3;
  return [REFLECTIONS[reflIdx]!, PERMUTATIONS[permIdx]!];
}
