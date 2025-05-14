import { type Hex, getAddress, toHex } from "viem";
import type { Vec3 } from "./vec3";

import { packVec3, unpackVec3 } from "./vec3";

// Types
export type EntityId = Hex; // bytes32 in Solidity
export type EntityType = number; // bytes1 in Solidity

const BYTES_32_BITS = 256n;
const ENTITY_TYPE_BITS = 8n;
const ENTITY_ID_BITS = BYTES_32_BITS - ENTITY_TYPE_BITS;
const ADDRESS_BITS = 20n * 8n;
const VEC3_BITS = 96n;

// Entity Types enum
// TODO: codegen `EntityId.sol` from this
export const EntityTypes = {
  Incremental: 0x00,
  Player: 0x01,
  Fragment: 0x02,
  Block: 0x03,
} as const;

function encode(entityType: EntityType, data: bigint): EntityId {
  return toHex((BigInt(entityType) << ENTITY_ID_BITS) | data, {
    size: 32,
  });
}

function decode(entityId: EntityId): { entityType: EntityType; data: bigint } {
  const value = BigInt(entityId);
  const entityType = Number(value >> ENTITY_ID_BITS);
  const data = value & ((1n << ENTITY_ID_BITS) - 1n);
  return { entityType, data };
}

function encodeCoord(entityType: EntityType, coord: Vec3): EntityId {
  const packedCoord = packVec3(coord);
  return encode(entityType, packedCoord << (ENTITY_ID_BITS - VEC3_BITS));
}

export function encodeBlock(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Block, coord);
}

export function encodeFragment(coord: Vec3): EntityId {
  return encodeCoord(EntityTypes.Fragment, coord);
}

export function encodePlayer(player: Hex): EntityId {
  const playerBigInt = BigInt(player);
  return encode(
    EntityTypes.Player,
    playerBigInt << (ENTITY_ID_BITS - ADDRESS_BITS),
  );
}

export function decodePosition(entityId: EntityId): Vec3 {
  const { entityType, data } = decode(entityId);
  if (entityType === EntityTypes.Block || entityType === EntityTypes.Fragment) {
    return unpackVec3(data >> (ENTITY_ID_BITS - VEC3_BITS));
  }
  throw new Error("Entity is not a block or fragment");
}

export function decodePlayer(entityId: EntityId): Hex {
  const { entityType, data } = decode(entityId);
  if (entityType !== EntityTypes.Player) {
    throw new Error("Entity is not a player");
  }
  const address = data >> (ENTITY_ID_BITS - ADDRESS_BITS);
  return getAddress(toHex(address, { size: 20 }));
}

export function decodeEntityType(entityId: EntityId): EntityType {
  const { entityType } = decode(entityId);
  return entityType;
}
