import type { Vec3 } from "./vec3";

import { packVec3 } from "./vec3";

// Types
export type EntityId = string; // bytes32 in Solidity
export type EntityType = number; // bytes1 in Solidity

// Constants
const ENTITY_TYPE_OFFSET_BITS = 248n;
const COORD_MASK_96 = (1n << 96n) - 1n; // lower‑96‑bit mask
const BYTE_MASK = 0xffn; // lower‑8‑bit mask

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

function encodeCoord(entityType: EntityType, coord: Vec3): EntityId {
  const typeByte = (BigInt(entityType) & BYTE_MASK) << ENTITY_TYPE_OFFSET_BITS;
  const coordBits = packVec3(coord) << 160n;
  return toBytes32Hex(typeByte | coordBits);
}

export function encodeBlock(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Block, coord);
}

export function encodeFragment(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Fragment, coord);
}

export function encodePlayer(player: string): EntityId {
  const typeByte =
    (BigInt(EntityTypes.Player) & BYTE_MASK) << ENTITY_TYPE_OFFSET_BITS;
  const playerBits = BigInt(player);
  return toBytes32Hex(typeByte | playerBits);
}
