// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";

import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";

import { SlotTransfer, TestInventoryUtils } from "./utils/TestUtils.sol";

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
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Battery, 10);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Wheat, 10);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.IronPick);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.NeptuniumAxe);

    // 36 as forcefields and buckets use a single slot each
    assertEq(Inventory.length(aliceEntity), 36);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.removeObjectFromSlot(aliceEntity, 1, 1);

    assertEq(Inventory.length(aliceEntity), 35);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.length(aliceEntity), 0);
    assertEq(Inventory.length(bobEntity), 35);

    TestInventoryUtils.transferAll(bobEntity, aliceEntity);

    assertEq(Inventory.length(aliceEntity), 35);
    assertEq(Inventory.length(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.length(aliceEntity), 0);
    assertEq(Inventory.length(bobEntity), 35);
  }

  function testTransferEntityToNullSlot() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(1, 0, 0));

    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.AcaciaLog, 1);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.CopperAxe);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.FescueGrass, 1);

    TestInventoryUtils.removeObject(aliceEntity, ObjectTypes.FescueGrass, 1);

    // Transfer CopperAxe to the Null slot where FescueGrass was
    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 1, slotTo: 2, amount: 1 });

    TestInventoryUtils.transfer(aliceEntity, aliceEntity, transfers);

    assertEq(Inventory.length(aliceEntity), 2);

    uint16[] memory slots = Inventory.get(aliceEntity);
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(aliceEntity, slots[i]);
      assertEq(i, slotData.occupiedIndex, "Wrong occupied index");
    }
  }

  function testDuplicateOccupiedSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick); // slot 1
    assertEq(Inventory.length(alice), 2, "expected two occupied slots");

    TestInventoryUtils.removeEntityFromSlot(alice, 0);
    TestInventoryUtils.removeEntityFromSlot(alice, 1);
    assertEq(Inventory.length(alice), 0, "inventory should be empty");
    assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 2, "expected two null slots");

    // Reuse the slots twice
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(alice, ObjectTypes.NeptuniumAxe);

    // Occupied slots should be different
    uint16[] memory slots = Inventory.get(alice);
    assertEq(slots.length, 2, "length mismatch");
    assertNotEq(slots[0], slots[1]);
  }

  function testDuplicateOccupiedSlotsWithSelfTransfers() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.IronPick); // slot 1
    assertEq(Inventory.length(aliceEntity), 2, "expected 2 occupied slots");

    SlotTransfer[] memory transfers = new SlotTransfer[](2);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 2, amount: 1 });
    transfers[1] = SlotTransfer({ slotFrom: 1, slotTo: 3, amount: 1 });
    TestInventoryUtils.transfer(aliceEntity, aliceEntity, transfers);

    // Now the inventory holds slots 2 & 3, while slots 0 & 1 sit in Null
    // (both with the same incorrect typeIndex = 0).
    assertEq(Inventory.length(aliceEntity), 2, "inventory should still have 2 items");

    // Require two fresh slots, `_useEmptySlot` will be invoked twice
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.NeptuniumAxe);

    uint16[] memory slots = Inventory.get(aliceEntity);
    assertEq(slots.length, 4, "expected 4 occupied-slot entries");

    // All slots should be unique and correct
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(aliceEntity, slots[i]);
      assertEq(i, slotData.occupiedIndex, "Wrong occupied index");
    }
  }
}
