import config from "../mud.config";

// Ensure Direction is the union of enum values
const directionEnum = config.enums.Direction as readonly string[];
type Direction = (typeof directionEnum)[number];

/**
 * Packs an array of directions into a single uint256 for the moveDirectionsPacked function.
 * The packed format is:
 * - Top 6 bits: count (number of directions)
 * - Bottom 250 bits: packed directions (5 bits per direction)
 *
 * @param directions Array of Direction values to pack
 * @returns BigInt representing the packed directions
 * @throws Error if more than 50 directions are provided
 */
export function packDirections(directions: Direction[]): bigint {
  if (directions.length > 50) {
    throw new Error("Too many directions: maximum 50 allowed");
  }

  let packed = BigInt(0);

  // Pack count into top 6 bits
  packed |= BigInt(directions.length) << BigInt(250);

  // Pack each direction (5 bits each)
  for (let i = 0; i < directions.length; i++) {
    const dir = directions[i];
    const directionValue = directionEnum.findIndex((d) => d === dir);
    if (directionValue === -1) {
      throw new Error(`Invalid direction: ${String(dir)}`);
    }
    packed |= BigInt(directionValue) << BigInt(i * 5);
  }

  return packed;
}

/**
 * Unpacks a uint256 into an array of directions.
 *
 * @param packed BigInt representing packed directions
 * @returns Array of Direction values
 */
export function unpackDirections(packed: bigint): Direction[] {
  // Extract count from top 6 bits
  const count = Number(packed >> BigInt(250)) & 0x3f;

  const directions: Direction[] = [];
  const mask = BigInt(0x1f); // 5 bits mask

  for (let i = 0; i < count; i++) {
    const directionIdx = Number((packed >> BigInt(i * 5)) & mask);
    if (
      directionIdx < 0 ||
      directionIdx >= directionEnum.length ||
      typeof directionEnum[directionIdx] === "undefined"
    ) {
      throw new Error(`Invalid direction value at index ${i}: ${directionIdx}`);
    }
    directions.push(directionEnum[directionIdx] as Direction);
  }

  return directions;
}
