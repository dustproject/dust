// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";
import { TerrainLib } from "../systems/libraries/TerrainLib.sol";
import { EntityPosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { EntityId, EntityIdLib, EntityType } from "../EntityId.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";

import { Vec3 } from "../Vec3.sol";

library EntityUtils {
  function getUniqueEntity() internal returns (EntityId) {
    uint256 uniqueEntity = UniqueEntity._get() + 1;
    UniqueEntity._set(uniqueEntity);

    return EntityId.wrap(bytes32(uniqueEntity));
  }

  /// @notice Get the object type id at a given coordinate.
  /// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
  function getObjectTypeAt(Vec3 coord) internal view returns (ObjectType) {
    EntityId entityId = EntityIdLib.encodeBlock(coord);
    ObjectType objectType = entityId.getObjectType();

    return objectType.isNull() ? TerrainLib._getBlockType(coord) : objectType;
  }

  /// @notice Get the object type id at a given coordinate.
  /// @dev Reverts if the chunk is not explored yet.
  function safeGetObjectTypeAt(Vec3 coord) internal view returns (ObjectType) {
    ObjectType objectType = getObjectTypeAt(coord);
    require(!objectType.isNull(), "Chunk not explored yet");
    return objectType;
  }

  function getBlockAt(Vec3 coord) internal view returns (EntityId, ObjectType) {
    EntityId entityId = EntityIdLib.encodeBlock(coord);
    ObjectType objectType = safeGetObjectTypeAt(coord);

    return (entityId, objectType);
  }

  function getOrCreateBlockAt(Vec3 coord) internal returns (EntityId, ObjectType) {
    (EntityId entityId, ObjectType objectType) = getBlockAt(coord);
    if (!entityId.exists()) {
      initEntity(entityId, objectType);
      EntityPosition._set(entityId, coord);
    }

    return (entityId, objectType);
  }

  function getFragmentAt(Vec3 fragmentCoord) internal pure returns (EntityId) {
    return EntityIdLib.encodeFragment(fragmentCoord);
  }

  function getOrCreateFragmentAt(Vec3 fragmentCoord) internal returns (EntityId) {
    EntityId fragment = getFragmentAt(fragmentCoord);

    // Create a new fragment entity if needed
    if (!fragment.exists()) {
      initEntity(fragment, ObjectTypes.Fragment);
      EntityPosition._set(fragment, fragmentCoord);
    }

    return fragment;
  }

  function createPlayerEntity(address playerAddress) internal returns (EntityId) {
    EntityId entityId = EntityIdLib.encodePlayer(playerAddress);
    initEntity(entityId, ObjectTypes.Player);
    return entityId;
  }

  function createUniqueEntity(ObjectType objectType) internal returns (EntityId) {
    EntityId entityId = getUniqueEntity();
    initEntity(entityId, objectType);
    return entityId;
  }

  function initEntity(EntityId entityId, ObjectType objectType) internal {
    EntityObjectType._set(entityId, objectType);
    uint128 mass = ObjectPhysics._getMass(objectType);
    if (mass > 0) {
      Mass._setMass(entityId, mass);
    }
  }

  function getMovableEntityAt(Vec3 coord) internal view returns (EntityId) {
    return ReverseMovablePosition._get(coord);
  }

  function setMovableEntityAt(Vec3 coord, EntityId entityId) internal {
    EntityPosition._set(entityId, coord);
    ReverseMovablePosition._set(coord, entityId);
  }
}
