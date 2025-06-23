// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { MustUseBucket, MustUseWaterBucket, NotFarmland, NotWater } from "../Errors.sol";
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

    if (EntityUtils.safeGetObjectTypeAt(waterCoord) != ObjectTypes.Water) {
      revert NotWater(EntityUtils.safeGetObjectTypeAt(waterCoord));
    }

    if (InventorySlot._getObjectType(caller, bucketSlot) != ObjectTypes.Bucket) {
      revert MustUseBucket(InventorySlot._getObjectType(caller, bucketSlot));
    }

    // We know buckets are not stackable, so we can directly replace the slot
    InventoryUtils.removeObjectFromSlot(caller, bucketSlot, 1);
    InventoryUtils.addObjectToSlot(caller, ObjectTypes.WaterBucket, 1, bucketSlot);
  }

  function wetFarmland(EntityId caller, Vec3 coord, uint16 bucketSlot) external {
    caller.activate();
    caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    if (objectType != ObjectTypes.Farmland) revert NotFarmland(objectType);

    if (InventorySlot._getObjectType(caller, bucketSlot) != ObjectTypes.WaterBucket) {
      revert MustUseWaterBucket(InventorySlot._getObjectType(caller, bucketSlot));
    }

    // We know buckets are not stackable, so we can directly replace the slot
    InventoryUtils.removeObjectFromSlot(caller, bucketSlot, 1);
    InventoryUtils.addObjectToSlot(caller, ObjectTypes.Bucket, 1, bucketSlot);

    EntityObjectType._set(farmland, ObjectTypes.WetFarmland);
  }
}
