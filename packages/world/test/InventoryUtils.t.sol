// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";

import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { SlotTransfer, TestInventoryUtils, ToolData } from "./utils/TestUtils.sol";

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
    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 36);
    assertEq(Inventory.lengthOccupiedSlots(bobEntity), 0);

    TestInventoryUtils.removeObjectFromSlot(aliceEntity, 1, 1);

    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 35);
    assertEq(Inventory.lengthOccupiedSlots(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 0);
    assertEq(Inventory.lengthOccupiedSlots(bobEntity), 35);

    TestInventoryUtils.transferAll(bobEntity, aliceEntity);

    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 35);
    assertEq(Inventory.lengthOccupiedSlots(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 0);
    assertEq(Inventory.lengthOccupiedSlots(bobEntity), 35);
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

    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 2);

    uint16[] memory slots = Inventory.getOccupiedSlots(aliceEntity);
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(aliceEntity, slots[i]);
      assertEq(i, slotData.occupiedIndex, "Wrong occupied index");
    }
  }

  function testDuplicateOccupiedSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick); // slot 1
    assertEq(Inventory.lengthOccupiedSlots(alice), 2, "expected two occupied slots");

    TestInventoryUtils.removeEntityFromSlot(alice, 0);
    TestInventoryUtils.removeEntityFromSlot(alice, 1);
    assertEq(Inventory.lengthOccupiedSlots(alice), 0, "inventory should be empty");
    assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 2, "expected two null slots");

    // Reuse the slots twice
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(alice, ObjectTypes.NeptuniumAxe);

    // Occupied slots should be different
    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    assertEq(slots.length, 2, "length mismatch");
    assertNotEq(slots[0], slots[1]);
  }

  function testDuplicateOccupiedSlotsWithSelfTransfers() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.IronPick); // slot 1
    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 2, "expected 2 occupied slots");

    SlotTransfer[] memory transfers = new SlotTransfer[](2);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 2, amount: 1 });
    transfers[1] = SlotTransfer({ slotFrom: 1, slotTo: 3, amount: 1 });
    TestInventoryUtils.transfer(aliceEntity, aliceEntity, transfers);

    // Now the inventory holds slots 2 & 3, while slots 0 & 1 sit in Null
    // (both with the same incorrect typeIndex = 0).
    assertEq(Inventory.lengthOccupiedSlots(aliceEntity), 2, "inventory should still have 2 items");

    // Require two fresh slots, `_useEmptySlot` will be invoked twice
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.NeptuniumAxe);

    uint16[] memory slots = Inventory.getOccupiedSlots(aliceEntity);
    assertEq(slots.length, 4, "expected 4 occupied-slot entries");

    // All slots should be unique and correct
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(aliceEntity, slots[i]);
      assertEq(i, slotData.occupiedIndex, "Wrong occupied index");
    }
  }

  function testDuplicateOccupiedSlotsWhenUsingNonSequentialEmptySlots() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addObjectToSlot(aliceEntity, ObjectTypes.Ice, 1, 2); // slot 2

    // This will use an empty slot
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.Snow, 1);

    uint16[] memory slots = Inventory.getOccupiedSlots(aliceEntity);
    assertEq(slots.length, 3, "expected 3 occupied-slot entries");

    // All slots should be unique and correct
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(aliceEntity, slots[i]);
      assertEq(i, slotData.occupiedIndex, "Wrong occupied index");
    }
  }

  function testSlotGapSequential() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // jump straight to slot 10
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Ice, 1, 10);
    assertEq(Inventory.lengthOccupiedSlots(alice), 1);

    TestInventoryUtils.addObject(alice, ObjectTypes.Snow, 1); // slot 0
    TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenHoe); // slot 1

    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    assertEq(slots.length, 3);

    // every occupiedIndex field must match its position
    for (uint256 i; i < slots.length; ++i) {
      InventorySlotData memory sd = InventorySlot.get(alice, slots[i]);
      assertEq(i, sd.occupiedIndex, "Wrong occupiedIndex");
    }
  }

  function testSwapEntityAndObject() public {
    (, EntityId alice) = createTestPlayer(vec3(1, 1, 1));

    // slot 0 = entity, slot 1 = object
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, 10, 1);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    TestInventoryUtils.transfer(alice, alice, transfers);

    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    assertEq(slots.length, 2);
    // verify indexes were updated by _replaceSlot
    for (uint256 i; i < slots.length; ++i) {
      InventorySlotData memory sd = InventorySlot.get(alice, slots[i]);
      assertEq(i, sd.occupiedIndex, "index mismatch after swap");
    }
  }

  function testSwapEntities() public {
    (, EntityId alice) = createTestPlayer(vec3(1, 1, 1));

    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    TestInventoryUtils.transfer(alice, alice, transfers);

    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    assertEq(slots.length, 2);
    // verify indexes were updated by _replaceSlot
    for (uint256 i; i < slots.length; ++i) {
      InventorySlotData memory sd = InventorySlot.get(alice, slots[i]);
      assertEq(i, sd.occupiedIndex, "index mismatch after swap");
    }
  }

  function testPartialStackAddsOneSlot() public {
    (, EntityId alice) = createTestPlayer(vec3(2, 0, 0));

    // stack size = 99, add 95 logs
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 95);
    assertEq(Inventory.lengthOccupiedSlots(alice), 1);

    // add 10 more, slot 0 reaches 99, slot 1 holds 6
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 10);
    assertEq(Inventory.lengthOccupiedSlots(alice), 2);

    // amounts
    uint16 a0 = InventorySlot.getAmount(alice, 0);
    uint16 a1 = InventorySlot.getAmount(alice, 1);
    assertEq(a0, 99);
    assertEq(a1, 6);
  }

  function testPartialThenFullRemoval() public {
    (, EntityId alice) = createTestPlayer(vec3(3, 0, 0));

    TestInventoryUtils.addObject(alice, ObjectTypes.Snow, 99 * 2 + 1); // stack 99, so 3 slots: 99,99,1
    assertEq(Inventory.lengthOccupiedSlots(alice), 3);

    // remove 10 from slot 0, should remain occupied with 89
    TestInventoryUtils.removeObjectFromSlot(alice, 0, 10);
    assertEq(InventorySlot.getAmount(alice, 0), 89);
    assertEq(Inventory.lengthOccupiedSlots(alice), 3);

    // now remove the remaining 89, slot recycled, only two occupied left
    TestInventoryUtils.removeObjectFromSlot(alice, 0, 89);
    assertEq(Inventory.lengthOccupiedSlots(alice), 2);

    // Null list should contain exactly one new entry
    assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 1);
  }

  function testUseEmptySlotAfterGap() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // jump straight to slot 10, leaving 0-9 untouched
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Ice, 1, 10);

    // first fresh allocation must reuse slot 9 (we pop from the end of null type slots)
    TestInventoryUtils.addObject(alice, ObjectTypes.Snow, 1);
    uint16[] memory occ = Inventory.getOccupiedSlots(alice);

    assertEq(occ.length, 2, "two occupied slots expected");
    assertTrue(occ[0] != occ[1], "slots must differ");
  }

  function testRemoveAcrossSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // 150 OakLog, slots: 99 + 51
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 150);
    TestInventoryUtils.removeObject(alice, ObjectTypes.OakLog, 120); // leaves 30

    uint16[] memory occ = Inventory.getOccupiedSlots(alice);
    assertEq(occ.length, 1, "only one slot should remain");
    assertEq(InventorySlot.getAmount(alice, occ[0]), 30, "wrong remaining amount");
  }

  function testSwapDifferentTypesBetweenEntities() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(1, 0, 0));

    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 10);
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);

    TestInventoryUtils.addObject(bob, ObjectTypes.Sand, 20);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 10 }); // swap OakLog <-> Sand
    TestInventoryUtils.transfer(alice, bob, transfers);

    // indices must be consistent
    uint16[] memory aliceSlots = Inventory.getOccupiedSlots(alice);
    for (uint256 i; i < aliceSlots.length; ++i) {
      InventorySlotData memory d = InventorySlot.get(alice, aliceSlots[i]);
      assertEq(i, d.occupiedIndex, "alice index wrong");
    }
    uint16[] memory bobSlots = Inventory.getOccupiedSlots(bob);
    for (uint256 i; i < bobSlots.length; ++i) {
      InventorySlotData memory d = InventorySlot.get(bob, bobSlots[i]);
      assertEq(i, d.occupiedIndex, "bob index wrong");
    }
  }

  function testToolBreakRemovesSlot() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // manually set mass low so one use breaks it
    EntityId entityId = TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenPick);
    Mass.setMass(entityId, 1);

    // Use tool with mass reduction ≥ 1
    ToolData memory toolData = TestInventoryUtils.getToolData(alice, 0);
    TestInventoryUtils.use(toolData, 1, 5);

    assertEq(Inventory.lengthOccupiedSlots(alice), 0, "slot not recycled");
    assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 1, "slot not in Null list");
  }
}
