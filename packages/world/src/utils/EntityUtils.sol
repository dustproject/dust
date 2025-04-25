// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";
import { TerrainLib } from "../systems/libraries/TerrainLib.sol";
import { MovablePosition, Position, ReverseMovablePosition, ReversePosition } from "../utils/Vec3Storage.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { Vec3 } from "../Vec3.sol";

function getUniqueEntity() returns (EntityId) {
  uint256 uniqueEntity = UniqueEntity._get() + 1;
  UniqueEntity._set(uniqueEntity);

  return EntityId.wrap(bytes32(uniqueEntity));
}

/// @notice Get the object type id at a given coordinate.
/// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
function getObjectTypeAt(Vec3 coord) view returns (ObjectType) {
  EntityId entityId = ReversePosition._get(coord);
  return entityId.exists() ? EntityObjectType._get(entityId) : TerrainLib._getBlockType(coord);
}

/// @notice Get the object type id at a given coordinate.
/// @dev Reverts if the chunk is not explored yet.
function safeGetObjectTypeAt(Vec3 coord) view returns (ObjectType) {
  ObjectType objectType = getObjectTypeAt(coord);
  require(!objectType.isNull(), "Chunk not explored yet");
  return objectType;
}

function getEntityAt(Vec3 coord) view returns (EntityId, ObjectType) {
  EntityId entityId = ReversePosition._get(coord);
  ObjectType objectType;
  if (!entityId.exists()) {
    objectType = TerrainLib._getBlockType(coord);
    require(!objectType.isNull(), "Chunk not explored yet");
  } else {
    objectType = EntityObjectType._get(entityId);
  }

  return (entityId, objectType);
}

function getOrCreateEntityAt(Vec3 coord) returns (EntityId, ObjectType) {
  (EntityId entityId, ObjectType objectType) = getEntityAt(coord);
  if (!entityId.exists()) {
    entityId = createEntityAt(coord, objectType);
  }

  return (entityId, objectType);
}

function createEntityAt(Vec3 coord, ObjectType objectType) returns (EntityId) {
  EntityId entityId = createEntity(objectType);
  Position._set(entityId, coord);
  ReversePosition._set(coord, entityId);
  return entityId;
}

function createEntity(ObjectType objectType) returns (EntityId) {
  EntityId entityId = getUniqueEntity();
  EntityObjectType._set(entityId, objectType);
  uint128 mass = ObjectPhysics._getMass(objectType);
  if (mass > 0) {
    Mass._setMass(entityId, mass);
  }

  return entityId;
}

function getMovableEntityAt(Vec3 coord) view returns (EntityId) {
  return ReverseMovablePosition._get(coord);
}

function setMovableEntityAt(Vec3 coord, EntityId entityId) {
  MovablePosition._set(entityId, coord);
  ReverseMovablePosition._set(coord, entityId);
}
