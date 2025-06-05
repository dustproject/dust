// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { EntityFluidLevel } from "../codegen/tables/EntityFluidLevel.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";
import { TerrainLib } from "../utils/TerrainLib.sol";
import { EntityPosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { MAX_FLUID_LEVEL } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";

import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";
import { Vec3 } from "../Vec3.sol";
import { EntityTypeLib } from "./EntityIdLib.sol";

library EntityUtils {
  /// @notice Get the object type id at a given coordinate.
  /// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
  function getObjectTypeAt(Vec3 coord) internal view returns (ObjectType) {
    EntityId entityId = EntityTypeLib.encodeBlock(coord);
    ObjectType objectType = entityId._getObjectType();

    return objectType.isNull() ? TerrainLib._getBlockType(coord) : objectType;
  }

  function getFluidLevelAt(Vec3 coord) internal view returns (uint8) {
    EntityId entityId = EntityTypeLib.encodeBlock(coord);
    ObjectType objectType = entityId._getObjectType();
    if (objectType.isNull() && TerrainLib._getBlockType(coord).spawnsWithFluid()) {
      return MAX_FLUID_LEVEL; // Default fluid level for uninitialized blocks
    }

    return EntityFluidLevel._get(entityId);
  }

  /// @notice Get the object type id at a given coordinate.
  /// @dev Reverts if the chunk is not explored yet.
  function safeGetObjectTypeAt(Vec3 coord) internal view returns (ObjectType) {
    ObjectType objectType = getObjectTypeAt(coord);
    require(!objectType.isNull(), "Chunk not explored yet");
    return objectType;
  }

  function getBlockAt(Vec3 coord) internal view returns (EntityId, ObjectType) {
    EntityId entityId = EntityTypeLib.encodeBlock(coord);
    ObjectType objectType = safeGetObjectTypeAt(coord);

    return (entityId, objectType);
  }

  function getOrCreateBlockAt(Vec3 coord) internal returns (EntityId, ObjectType) {
    (EntityId entityId, ObjectType objectType) = getBlockAt(coord);
    if (!entityId._exists()) {
      _initEntity(entityId, objectType);
      EntityPosition._set(entityId, coord);

      if (objectType.spawnsWithFluid()) {
        EntityFluidLevel._set(entityId, MAX_FLUID_LEVEL); // Initialize fluid level for new blocks
      }
    }

    return (entityId, objectType);
  }

  function getOrCreatePlayer() internal returns (EntityId) {
    address playerAddress = WorldContextConsumerLib._msgSender();
    EntityId player = EntityTypeLib.encodePlayer(playerAddress);
    if (!player._exists()) {
      _initEntity(player, ObjectTypes.Player);
    }

    return player;
  }

  function getFragmentAt(Vec3 fragmentCoord) internal pure returns (EntityId) {
    return EntityTypeLib.encodeFragment(fragmentCoord);
  }

  function getOrCreateFragmentAt(Vec3 fragmentCoord) internal returns (EntityId) {
    EntityId fragment = getFragmentAt(fragmentCoord);

    // Create a new fragment entity if needed
    if (!fragment._exists()) {
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
