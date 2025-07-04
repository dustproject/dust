// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { ObjectTypes } from "../types/ObjectType.sol";
import { Vec3 } from "../types/Vec3.sol";

contract BucketSystem is System {
  function fillBucket(EntityId caller, Vec3 waterCoord, uint16 bucketSlot) external {
    caller.activate();
    caller.requireConnected(waterCoord);

    require(EntityUtils.safeGetObjectTypeAt(waterCoord) == ObjectTypes.Water, "Not water");

    require(InventorySlot._getObjectType(caller, bucketSlot) == ObjectTypes.Bucket, "Must use an empty Bucket");

    // We know buckets are not stackable, so we can directly replace the slot
    InventoryUtils.removeObjectFromSlot(caller, bucketSlot, 1);
    InventoryUtils.addObjectToSlot(caller, ObjectTypes.WaterBucket, 1, bucketSlot);
  }

  function wetFarmland(EntityId caller, Vec3 coord, uint16 bucketSlot) external {
    caller.activate();
    caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType == ObjectTypes.Farmland, "Not farmland");

    require(InventorySlot._getObjectType(caller, bucketSlot) == ObjectTypes.WaterBucket, "Must use a Water Bucket");

    // We know buckets are not stackable, so we can directly replace the slot
    InventoryUtils.removeObjectFromSlot(caller, bucketSlot, 1);
    InventoryUtils.addObjectToSlot(caller, ObjectTypes.Bucket, 1, bucketSlot);

    EntityObjectType._set(farmland, ObjectTypes.WetFarmland);
  }
}
