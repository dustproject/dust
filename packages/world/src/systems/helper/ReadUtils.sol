// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EnergyData } from "../../codegen/tables/Energy.sol";
import { MachineData } from "../../codegen/tables/Machine.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { EntityId } from "../../EntityId.sol";
import { ObjectType } from "../../ObjectType.sol";
import { Vec3 } from "../../Vec3.sol";
import { Direction } from "../../codegen/common.sol";

struct InventoryEntity {
  EntityId entityId;
  uint128 mass;
}

struct InventoryObject {
  ObjectType objectType;
  uint16 numObjects;
  InventoryEntity[] inventoryEntities;
}

struct PlayerEntityData {
  address playerAddress;
  EntityId bed;
  EntityData entityData;
}

struct EntityData {
  EntityId entityId;
  EntityId baseEntityId;
  ObjectType objectType;
  Vec3 position;
  Direction orientation;
  InventoryObject[] inventory;
  ResourceId programSystemId;
  uint256 mass;
  EnergyData energy;
  MachineData machine;
}
