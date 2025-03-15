// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Position, ReversePosition, PlayerPosition, ReversePlayerPosition } from "../utils/Vec3Storage.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { TerrainLib } from "../systems/libraries/TerrainLib.sol";

import { getUniqueEntity } from "../Utils.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { EntityId } from "../EntityId.sol";
import { Vec3 } from "../Vec3.sol";

using ObjectTypeLib for ObjectTypeId;

/// @notice Get the object type id at a given coordinate.
/// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
function getObjectTypeIdAt(Vec3 coord) view returns (ObjectTypeId) {
  EntityId entityId = ReversePosition._get(coord);
  return entityId.exists() ? ObjectType._get(entityId) : TerrainLib._getBlockType(coord);
}

/// @notice Get the object type id at a given coordinate.
/// @dev Reverts if the chunk is not explored yet.
function safeGetObjectTypeIdAt(Vec3 coord) view returns (ObjectTypeId) {
  ObjectTypeId objectTypeId = getObjectTypeIdAt(coord);
  require(!objectTypeId.isNull(), "Chunk not explored yet");
  return objectTypeId;
}

function getOrCreateEntityAt(Vec3 coord) returns (EntityId, ObjectTypeId) {
  EntityId entityId = ReversePosition._get(coord);
  ObjectTypeId objectTypeId;
  if (!entityId.exists()) {
    objectTypeId = TerrainLib._getBlockType(coord);
    require(!objectTypeId.isNull(), "Chunk not explored yet");

    entityId = createEntityAt(coord, objectTypeId);
  } else {
    objectTypeId = ObjectType._get(entityId);
  }

  return (entityId, objectTypeId);
}

function createEntityAt(Vec3 coord, ObjectTypeId objectTypeId) returns (EntityId) {
  EntityId entityId = getUniqueEntity();
  Position._set(entityId, coord);
  ReversePosition._set(coord, entityId);
  ObjectType._set(entityId, objectTypeId);
  // We assume all terrain blocks are only 1 voxel (no relative entities)
  uint32 mass = ObjectTypeMetadata._getMass(objectTypeId);
  if (mass > 0) {
    Mass._setMass(entityId, mass);
  }
  return entityId;
}

function getPlayer(Vec3 coord) view returns (EntityId) {
  return ReversePlayerPosition._get(coord);
}

function setPlayer(Vec3 coord, EntityId playerEntityId) {
  PlayerPosition._set(playerEntityId, coord);
  ReversePlayerPosition._set(coord, playerEntityId);
}
