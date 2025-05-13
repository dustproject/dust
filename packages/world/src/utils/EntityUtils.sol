// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";
import { TerrainLib } from "../systems/libraries/TerrainLib.sol";
import { EntityPosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { EntityId, EntityIdLib } from "../EntityId.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";

import { Vec3 } from "../Vec3.sol";

library EntityUtils {
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
      _initEntity(entityId, objectType);
      EntityPosition._set(entityId, coord);
    }

    return (entityId, objectType);
  }

  function getOrCreatePlayer() internal returns (EntityId) {
    address playerAddress = WorldContextConsumerLib._msgSender();
    EntityId player = EntityIdLib.encodePlayer(playerAddress);
    if (!player.exists()) {
      _initEntity(player, ObjectTypes.Player);
    }

    return player;
  }

  function getFragmentAt(Vec3 fragmentCoord) internal pure returns (EntityId) {
    return EntityIdLib.encodeFragment(fragmentCoord);
  }

  function getOrCreateFragmentAt(Vec3 fragmentCoord) internal returns (EntityId) {
    EntityId fragment = getFragmentAt(fragmentCoord);

    // Create a new fragment entity if needed
    if (!fragment.exists()) {
      _initEntity(fragment, ObjectTypes.Fragment);
      EntityPosition._set(fragment, fragmentCoord);
    }

    return fragment;
  }

  function createUniqueEntity(ObjectType objectType) internal returns (EntityId) {
    uint256 uniqueEntity = UniqueEntity._get() + 1;
    UniqueEntity._set(uniqueEntity);

    EntityId entityId = EntityId.wrap(bytes32(uniqueEntity));
    _initEntity(entityId, objectType);
    return entityId;
  }

  function getMovableEntityAt(Vec3 coord) internal view returns (EntityId) {
    return ReverseMovablePosition._get(coord);
  }

  function setMovableEntityAt(Vec3 coord, EntityId entityId) internal {
    EntityPosition._set(entityId, coord);
    ReverseMovablePosition._set(coord, entityId);
  }

  function _initEntity(EntityId entityId, ObjectType objectType) private {
    EntityObjectType._set(entityId, objectType);
    uint128 mass = ObjectPhysics._getMass(objectType);
    if (mass > 0) {
      Mass._setMass(entityId, mass);
    }
  }
}
