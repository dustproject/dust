// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";

import { MAX_PICKUP_RADIUS } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";
import { Vec3 } from "../types/Vec3.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotAmount, SlotTransfer } from "../utils/InventoryUtils.sol";
import { DropNotification, PickupNotification, notify } from "../utils/NotifUtils.sol";
import { TerrainLib } from "../utils/TerrainLib.sol";

contract InventorySystem is System {
  function drop(EntityId caller, SlotAmount[] memory slots, Vec3 coord) public {
    require(slots.length > 0, "Must drop at least one object");
    caller.activate();
    caller.requireConnected(coord);

    (EntityId entityId, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isPassThrough(), "Cannot drop on a non-passable block");

    InventoryUtils.transfer(caller, entityId, slots);

    notify(caller, DropNotification({ dropCoord: coord }));
  }

  function pickup(EntityId caller, SlotTransfer[] memory slotTransfers, Vec3 coord) public {
    caller.activate();
    caller.requireInRange(coord, MAX_PICKUP_RADIUS);

    (EntityId entityId, ObjectType objectType) = EntityUtils.getBlockAt(coord);
    require(objectType.isPassThrough(), "Cannot pickup from a non-passable block");

    InventoryUtils.transfer(entityId, caller, slotTransfers);
  }

  function pickupAll(EntityId caller, Vec3 coord) public {
    caller.activate();
    caller.requireInRange(coord, MAX_PICKUP_RADIUS);

    (EntityId entityId, ObjectType objectType) = EntityUtils.getBlockAt(coord);
    require(objectType.isPassThrough(), "Cannot pickup from a non-passable block");

    InventoryUtils.transferAll(entityId, caller);

    notify(caller, PickupNotification({ pickupCoord: coord }));
  }
}
