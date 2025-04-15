// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Position } from "../codegen/tables/Position.sol";
import { ReversePosition } from "../utils/Vec3Storage.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { getUniqueEntity } from "../Utils.sol";
import { Vec3 } from "../Vec3.sol";
import { getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotTransfer } from "../utils/InventoryUtils.sol";
import { DropNotification, PickupNotification, notify } from "../utils/NotifUtils.sol";
import { TerrainLib } from "./libraries/TerrainLib.sol";

contract InventorySystem is System {
  function drop(EntityId caller, SlotTransfer[] memory slotTransfers, Vec3 coord) public {
    require(slotTransfers.length > 0, "Must drop at least one object");
    caller.activate();
    caller.requireConnected(coord);

    (EntityId entityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(coord);
    require(ObjectTypeMetadata._getCanPassThrough(objectTypeId), "Cannot drop on a non-passable block");

    InventoryUtils.transfer(caller, entityId, slotTransfers);
    notify(caller, DropNotification({ dropCoord: coord }));
  }

  function pickup(EntityId caller, SlotTransfer[] memory slotTransfers, Vec3 coord) public {
    caller.activate();
    caller.requireConnected(coord);

    EntityId entityId = ReversePosition._get(coord);
    require(entityId.exists(), "No entity at pickup location");

    ObjectTypeId objectTypeId = ObjectType._get(entityId);
    require(ObjectTypeMetadata._getCanPassThrough(objectTypeId), "Cannot pickup from a non-passable block");

    InventoryUtils.transfer(entityId, caller, slotTransfers);
  }

  function pickupAll(EntityId caller, Vec3 coord) public {
    caller.activate();
    caller.requireConnected(coord);

    EntityId entityId = ReversePosition._get(coord);
    require(entityId.exists(), "No entity at pickup location");

    ObjectTypeId objectTypeId = ObjectType._get(entityId);
    require(ObjectTypeMetadata._getCanPassThrough(objectTypeId), "Cannot pickup from a non-passable block");

    InventoryUtils.transferAll(entityId, caller);

    notify(caller, PickupNotification({ pickupCoord: coord }));
  }

  // TODO: eventually we should support a more generic swap function
  function swapSlots(EntityId caller, uint16 fromSlot, uint16 toSlot) external {
    caller.activate();
    InventoryUtils.swapSlots(caller, fromSlot, toSlot);
  }
}
