import type { Vec3 } from "./vec3";

import { packVec3 } from "./vec3";

// Types
export type EntityId = string; // bytes32 in Solidity
export type EntityType = number; // bytes1 in Solidity

// Entity Types enum
// TODO: codegen `EntityId.sol` from this
const EntityTypes = {
  Incremental: 0x00,
  Player: 0x01,
  Fragment: 0x02,
  Block: 0x03,
} as const;

/**
 * Pads a bigint to 32‑byte (64‑hex‑char) 0x‑prefixed string.
 */
function toBytes32Hex(value: bigint): `0x${string}` {
  return `0x${value.toString(16).padStart(64, "0")}` as const;
}

function encode(entityType: EntityType, data: bigint): EntityId {
  return toBytes32Hex((BigInt(entityType) << 248n) | data);
}

function encodeCoord(entityType: EntityType, coord: Vec3): EntityId {
  // Pack Vec3 into a single bigint
  const packedCoord = packVec3(coord);
  return encode(entityType, packedCoord);
}

export function encodeBlock(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Block, coord);
}

export function encodeFragment(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Fragment, coord);
}

export function encodePlayer(player: string): EntityId {
  // Convert player address to bigint and pad to 20 bytes (40 hex chars)
  const playerBigInt = BigInt(player);
  return encode(EntityTypes.Player, playerBigInt);
}
