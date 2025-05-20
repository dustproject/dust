import config from "../mud.config";
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

const PERMUTATIONS: [number, number, number][] = [
  [0, 1, 2],
  [0, 2, 1],
  [1, 0, 2],
  [1, 2, 0],
  [2, 0, 1],
  [2, 1, 0],
];

const REFLECTIONS: [number, number, number][] = [
  [0, 0, 0],
  [1, 0, 0],
  [0, 1, 0],
  [1, 1, 0],
  [0, 0, 1],
  [1, 0, 1],
  [0, 1, 1],
  [1, 1, 1],
];

const CANONICAL_UP: [number, number, number] = [0, 1, 0];
const CANONICAL_FORWARD: [number, number, number] = [1, 0, 0];

function applyOrientation(
  v: [number, number, number],
  perm: [number, number, number],
  refl: [number, number, number],
): [number, number, number] {
  const out: [number, number, number] = [v[perm[0]]!, v[perm[1]]!, v[perm[2]]!];
  if (refl[0]) out[0] = -out[0];
  if (refl[1]) out[1] = -out[1];
  if (refl[2]) out[2] = -out[2];
  return out;
}

export function getOrientation(forwardDirection: SupportedDirection): number {
  return getOrientationGeneric(forwardDirection, "PositiveY");
}

export function getOrientationGeneric(
  forwardDirection: SupportedDirection,
  upDirection: SupportedDirection,
): number {
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
