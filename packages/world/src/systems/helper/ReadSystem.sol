// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectTypeId } from "../../ObjectTypeId.sol";
import { Vec3, vec3 } from "../../Vec3.sol";

import { InventorySlot, InventorySlotData } from "../../codegen/tables/InventorySlot.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { Direction } from "../../codegen/common.sol";
import { BaseEntity } from "../../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../../codegen/tables/Energy.sol";
import { EntityProgram } from "../../codegen/tables/EntityProgram.sol";
import { Inventory } from "../../codegen/tables/Inventory.sol";

import { Machine, MachineData } from "../../codegen/tables/Machine.sol";
import { Mass } from "../../codegen/tables/Mass.sol";
import { ObjectType } from "../../codegen/tables/ObjectType.sol";

import { ObjectTypeMetadata } from "../../codegen/tables/ObjectTypeMetadata.sol";
import { Orientation } from "../../codegen/tables/Orientation.sol";
import { Player } from "../../codegen/tables/Player.sol";
import { PlayerStatus } from "../../codegen/tables/PlayerStatus.sol";

import { MovablePosition, Position, ReverseMovablePosition, ReversePosition } from "../../utils/Vec3Storage.sol";

import { EntityId } from "../../EntityId.sol";
import { ObjectTypes } from "../../ObjectTypes.sol";

import { TerrainLib } from "../libraries/TerrainLib.sol";

import { EntityData, InventoryEntity, InventoryObject, PlayerEntityData } from "./ReadUtils.sol";

// Public getters so clients can read the world state more easily
contract ReadSystem is System {
  function getEntityData(EntityId entityId) public view returns (EntityData memory) {
    if (!entityId.exists()) {
      return EntityData({
        entityId: EntityId.wrap(0),
        baseEntityId: EntityId.wrap(0),
        objectTypeId: ObjectTypes.Null,
        inventory: new InventoryObject[](0),
        position: vec3(0, 0, 0),
        orientation: Direction.PositiveX,
        programSystemId: ResourceId.wrap(0),
        mass: 0,
        energy: EnergyData({ energy: 0, lastUpdatedTime: 0, drainRate: 0 }),
        machine: MachineData({ createdAt: 0, depletedTime: 0 })
      });
    }

    EntityId rawBase = BaseEntity._get(entityId);
    EntityId base = rawBase.exists() ? rawBase : entityId;

    return EntityData({
      entityId: entityId,
      baseEntityId: rawBase,
      objectTypeId: ObjectType._get(entityId),
      position: getCoordFor(entityId),
      orientation: Orientation._get(base),
      inventory: getEntityInventory(base),
      programSystemId: EntityProgram._get(base).toResourceId(),
      mass: Mass._get(base),
      energy: Energy._get(base),
      machine: Machine._get(base)
    });
  }

  function getEntityDataAtCoord(Vec3 coord) public view returns (EntityData memory) {
    EntityId entityId = ReversePosition._get(coord);
    if (!entityId.exists()) {
      return EntityData({
        entityId: EntityId.wrap(0),
        baseEntityId: EntityId.wrap(0),
        objectTypeId: TerrainLib._getBlockType(coord),
        inventory: new InventoryObject[](0),
        position: coord,
        orientation: Direction.PositiveX,
        programSystemId: ResourceId.wrap(0),
        mass: 0,
        energy: EnergyData({ energy: 0, lastUpdatedTime: 0, drainRate: 0 }),
        machine: MachineData({ createdAt: 0, depletedTime: 0 })
      });
    }

    EntityId rawBase = BaseEntity._get(entityId);
    EntityId base = rawBase.exists() ? rawBase : entityId;

    return EntityData({
      entityId: entityId,
      baseEntityId: rawBase,
      objectTypeId: ObjectType._get(entityId),
      position: coord,
      orientation: Orientation._get(base),
      inventory: getEntityInventory(base),
      programSystemId: EntityProgram._get(base).toResourceId(),
      mass: Mass._get(base),
      energy: Energy._get(base),
      machine: Machine._get(base)
    });
  }

  function getMultipleEntityData(EntityId[] memory entityIds) public view returns (EntityData[] memory) {
    EntityData[] memory entityData = new EntityData[](entityIds.length);
    for (uint256 i = 0; i < entityIds.length; i++) {
      entityData[i] = getEntityData(entityIds[i]);
    }
    return entityData;
  }

  function getMultipleEntityDataAtCoord(Vec3[] memory coord) public view returns (EntityData[] memory) {
    EntityData[] memory entityData = new EntityData[](coord.length);
    for (uint256 i = 0; i < coord.length; i++) {
      entityData[i] = getEntityDataAtCoord(coord[i]);
    }
    return entityData;
  }

  function getPlayerEntityData(address player) public view returns (PlayerEntityData memory) {
    EntityId entityId = Player._get(player);
    if (!entityId.exists()) {
      return PlayerEntityData({ playerAddress: player, bed: EntityId.wrap(0), entityData: getEntityData(entityId) });
    }

    return PlayerEntityData({
      playerAddress: player,
      bed: PlayerStatus._getBedEntityId(entityId),
      entityData: getEntityData(entityId)
    });
  }

  function getPlayersEntityData(address[] memory players) public view returns (PlayerEntityData[] memory) {
    PlayerEntityData[] memory playersEntityData = new PlayerEntityData[](players.length);
    for (uint256 i = 0; i < players.length; i++) {
      playersEntityData[i] = getPlayerEntityData(players[i]);
    }
    return playersEntityData;
  }

  function getEntityInventory(EntityId owner) internal view returns (InventoryObject[] memory) {
    uint16[] memory slots = Inventory._get(owner);

    // Count unique object types to determine array size
    uint256 uniqueTypeCount = 0;
    ObjectTypeId[] memory uniqueTypes = new ObjectTypeId[](slots.length);
    bool[] memory typeExists = new bool[](slots.length);

    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot._get(owner, uint8(i));

      bool found = false;
      for (uint256 j = 0; j < uniqueTypeCount; j++) {
        if (uniqueTypes[j] == slotData.objectType) {
          found = true;
          break;
        }
      }

      if (!found) {
        uniqueTypes[uniqueTypeCount] = slotData.objectType;
        typeExists[uniqueTypeCount] = true;
        uniqueTypeCount++;
      }
    }

    InventoryObject[] memory result = new InventoryObject[](uniqueTypeCount);

    for (uint256 i = 0; i < uniqueTypeCount; i++) {
      result[i].objectTypeId = uniqueTypes[i];
      result[i].numObjects = 0;
      result[i].inventoryEntities = new InventoryEntity[](0);
    }

    uint256[] memory entityCounts = new uint256[](uniqueTypeCount);

    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot._get(owner, uint8(i));

      // Find the index of this type in the result array
      uint256 typeIndex = 0;
      for (uint256 j = 0; j < uniqueTypeCount; j++) {
        if (uniqueTypes[j] == slotData.objectType) {
          typeIndex = j;
          break;
        }
      }

      result[typeIndex].numObjects += slotData.amount;

      entityCounts[typeIndex]++;
    }

    // Allocate entity arrays with the correct sizes
    for (uint256 i = 0; i < uniqueTypeCount; i++) {
      if (entityCounts[i] > 0) {
        result[i].inventoryEntities = new InventoryEntity[](entityCounts[i]);
      }
    }

    // Populate entity arrays
    uint256[] memory entityIndices = new uint256[](uniqueTypeCount);

    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot._get(owner, uint8(i));

      if (!slotData.entityId.exists()) continue;

      uint256 typeIndex = 0;
      for (uint256 j = 0; j < uniqueTypeCount; j++) {
        if (uniqueTypes[j] == slotData.objectType) {
          typeIndex = j;
          break;
        }
      }

      result[typeIndex].inventoryEntities[entityIndices[typeIndex]] =
        InventoryEntity({ entityId: slotData.entityId, mass: uint128(Mass._get(slotData.entityId)) });

      entityIndices[typeIndex]++;
    }

    return result;
  }

  function getCoordFor(EntityId entityId) internal view returns (Vec3) {
    ObjectTypeId objectTypeId = ObjectType._get(entityId);
    if (objectTypeId == ObjectTypes.Player) {
      EntityId bed = PlayerStatus._getBedEntityId(entityId);
      if (bed.exists()) {
        return Position._get(bed);
      } else {
        return MovablePosition._get(entityId);
      }
    } else {
      return entityId.getPosition();
    }
  }
}
