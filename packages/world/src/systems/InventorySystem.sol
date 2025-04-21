// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Position } from "../codegen/tables/Position.sol";
import { ReversePosition } from "../utils/Vec3Storage.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";
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

    (EntityId entityId, ObjectType objectType) = getOrCreateEntityAt(coord);
    require(objectType.isPassThrough(), "Cannot drop on a non-passable block");

    InventoryUtils.transfer(caller, entityId, slotTransfers);
    notify(caller, DropNotification({ dropCoord: coord }));
  }

  function pickup(EntityId caller, SlotTransfer[] memory slotTransfers, Vec3 coord) public {
    caller.activate();
    caller.requireConnected(coord);

    EntityId entityId = ReversePosition._get(coord);
    require(entityId.exists(), "No entity at pickup location");

    ObjectType objectType = EntityObjectType._get(entityId);
    require(objectType.isPassThrough(), "Cannot pickup from a non-passable block");

    InventoryUtils.transfer(entityId, caller, slotTransfers);
  }

  function pickupAll(EntityId caller, Vec3 coord) public {
    caller.activate();
    caller.requireConnected(coord);

    EntityId entityId = ReversePosition._get(coord);
    require(entityId.exists(), "No entity at pickup location");

    ObjectType objectType = EntityObjectType._get(entityId);
    require(objectType.isPassThrough(), "Cannot pickup from a non-passable block");

    InventoryUtils.transferAll(entityId, caller);

    notify(caller, PickupNotification({ pickupCoord: coord }));
  }
}
