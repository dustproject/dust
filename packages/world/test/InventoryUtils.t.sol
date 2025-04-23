// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectTypes } from "../src/ObjectTypes.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";

import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract InventoryUtilsTest is DustTest {
  function testMultipleTransferAll() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(1, 0, 0));
    (, EntityId bobEntity) = createTestPlayer(vec3(2, 0, 0));

    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.OakLog, 99);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Chest, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.ForceField, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.TextSign, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Workbench, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Furnace, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Powerstone, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.SpawnTile, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Bed, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Bucket, 1);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.WaterBucket, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.OakSapling, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.SpruceSapling, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Fuel, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Wheat, 10);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.IronPick);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.NeptuniumAxe);

    // 27 as forcefields use a single slot each
    assertEq(Inventory.length(aliceEntity), 27);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.removeObjectFromSlot(aliceEntity, 1, 1);

    assertEq(Inventory.length(aliceEntity), 26);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.length(aliceEntity), 0);
    assertEq(Inventory.length(bobEntity), 26);

    TestInventoryUtils.transferAll(bobEntity, aliceEntity);

    assertEq(Inventory.length(aliceEntity), 26);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.length(aliceEntity), 0);
    assertEq(Inventory.length(bobEntity), 26);
  }
}
