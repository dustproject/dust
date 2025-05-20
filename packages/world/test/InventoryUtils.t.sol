// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { Math } from "../src/utils/Math.sol";

import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { SlotTransfer, TestEntityUtils, TestInventoryUtils, ToolData } from "./utils/TestUtils.sol";

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

    _verifyInventorySlotIntegrity(aliceEntity);
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

    _verifyInventorySlotIntegrity(aliceEntity);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(aliceEntity);
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

    _verifyInventorySlotIntegrity(aliceEntity);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
  }

  function testRemoveAcrossSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // 150 OakLog, slots: 99 + 51
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 150);
    TestInventoryUtils.removeObject(alice, ObjectTypes.OakLog, 120); // leaves 30

    uint16[] memory occ = Inventory.getOccupiedSlots(alice);
    assertEq(occ.length, 1, "only one slot should remain");
    assertEq(InventorySlot.getAmount(alice, occ[0]), 30, "wrong remaining amount");

    _verifyInventorySlotIntegrity(alice);
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

    _verifyInventorySlotIntegrity(alice);
    _verifyInventorySlotIntegrity(bob);
  }

  function testToolBreakRemovesSlot() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // manually set mass low so one use breaks it
    EntityId entityId = TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenPick);
    Mass.setMass(entityId, 1);

    // Use tool with mass reduction ≥ 1
    ToolData memory toolData = TestInventoryUtils.getToolData(alice, 0);
    assertEq(toolData.toolType, ObjectTypes.WoodenPick, "Wrong tool type");
    TestInventoryUtils.use(toolData, 1, 1);

    assertEq(Inventory.lengthOccupiedSlots(alice), 0, "slot not recycled");
    assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 1, "slot not in Null list");

    _verifyInventorySlotIntegrity(alice);
  }

  // Fuzz test for adding objects to inventory
  function testAddObjectDifferentAmounts(uint16 amount) public {
    // Bound amount to reasonable values for test performance
    vm.assume(amount > 0 && amount < 1000);

    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects in the given amount
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, amount);

    // Calculate expected slots (OakLog has stackable=99)
    uint16 expectedSlots = (amount + 98) / 99; // Ceiling division

    // Verify slot count
    assertEq(Inventory.lengthOccupiedSlots(alice), expectedSlots, "Wrong number of occupied slots");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);

    // Verify total amount of objects
    uint16 totalAmount = 0;
    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    for (uint256 i = 0; i < slots.length; i++) {
      totalAmount += InventorySlot.getAmount(alice, slots[i]);
    }

    assertEq(totalAmount, amount, "Total object amount mismatch");
  }

  // Fuzz test for removing objects from inventory
  function testRemoveObject(uint16 addAmount, uint16 removeAmount) public {
    // Bound amounts to reasonable values
    vm.assume(addAmount > 0 && addAmount < 500);
    vm.assume(removeAmount > 0 && removeAmount <= addAmount);

    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, addAmount);

    // Remove objects
    TestInventoryUtils.removeObject(alice, ObjectTypes.OakLog, removeAmount);

    // Calculate expected remaining amount
    uint16 expectedRemaining = addAmount - removeAmount;

    // Calculate expected slots
    uint16 expectedSlots = expectedRemaining > 0 ? (expectedRemaining + 98) / 99 : 0;

    // Verify slot count
    assertEq(Inventory.lengthOccupiedSlots(alice), expectedSlots, "Wrong number of remaining slots");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);

    // Verify total amount of objects
    uint16 totalAmount = 0;
    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    for (uint256 i = 0; i < slots.length; i++) {
      totalAmount += InventorySlot.getAmount(alice, slots[i]);
    }

    assertEq(totalAmount, expectedRemaining, "Remaining amount mismatch");
  }

  // Fuzz test for transferring objects between slots
  function testTransferBetweenSlots(uint16 amount1, uint16 amount2, uint16 transferAmount) public {
    // Bound inputs to reasonable values
    vm.assume(amount1 > 0 && amount1 <= 99); // Max stack is 99
    vm.assume(amount2 > 0 && amount2 <= 99);
    vm.assume(transferAmount > 0 && transferAmount <= amount1);
    vm.assume(amount2 + transferAmount <= 99); // Ensure we don't exceed stack limit

    // Setup player
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects to two separate slots
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount1, 0);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount2, 1);

    // Transfer between slots
    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: transferAmount });

    TestInventoryUtils.transfer(alice, alice, transfers);

    // Verify amounts
    uint16 remainingFromSlot = InventorySlot.getAmount(alice, 0);
    uint16 destinationSlot = InventorySlot.getAmount(alice, 1);

    // If we transferred all from slot 0, it should be recycled
    if (transferAmount == amount1) {
      assertEq(Inventory.lengthOccupiedSlots(alice), 1, "Should only have one occupied slot");
      assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 1, "Should have one null slot");
    } else {
      assertEq(remainingFromSlot, amount1 - transferAmount, "Source slot amount mismatch");
    }

    assertEq(destinationSlot, amount2 + transferAmount, "Destination slot amount mismatch");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);
  }

  // Fuzz test for transferring between inventories
  function testTransferBetweenInventories(uint16 amount, uint16 transferAmount) public {
    // Bound inputs to reasonable values
    vm.assume(amount > 0 && amount <= 99);
    vm.assume(transferAmount > 0 && transferAmount <= amount);

    // Setup players
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(1, 0, 0));

    // Add objects to alice
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount, 0);

    // Transfer to bob
    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: transferAmount });

    TestInventoryUtils.transfer(alice, bob, transfers);

    // Verify amounts
    if (transferAmount == amount) {
      // Alice's inventory should be empty
      assertEq(Inventory.lengthOccupiedSlots(alice), 0, "Alice should have empty inventory");
      assertEq(InventoryTypeSlots.length(alice, ObjectTypes.Null), 1, "Alice should have one null slot");
    } else {
      uint16 aliceRemaining = InventorySlot.getAmount(alice, 0);
      assertEq(aliceRemaining, amount - transferAmount, "Alice remaining amount mismatch");
    }

    uint16 bobAmount = InventorySlot.getAmount(bob, 0);
    assertEq(bobAmount, transferAmount, "Bob received amount mismatch");

    // Verify inventory integrity for both inventories
    _verifyInventorySlotIntegrity(alice);
    _verifyInventorySlotIntegrity(bob);
  }

  // Fuzz test for complex self transfers across multiple slots
  function testComplexSelfTransfers(uint16 numSlots, uint16 numTransfers) public {
    // Bound inputs to reasonable values
    vm.assume(numSlots > 1 && numSlots <= 10);
    vm.assume(numTransfers > 0 && numTransfers <= 5);

    // Setup player
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects to multiple slots
    for (uint16 i = 0; i < numSlots; i++) {
      TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, 10, i);
    }

    // Create transfers between random slots
    SlotTransfer[] memory transfers = new SlotTransfer[](numTransfers);
    for (uint16 i = 0; i < numTransfers; i++) {
      uint16 fromSlot = uint16(uint256(keccak256(abi.encode(i, "from"))) % numSlots);
      uint16 toSlot = uint16(uint256(keccak256(abi.encode(i, "to"))) % numSlots);

      // Ensure different slots
      if (fromSlot == toSlot) {
        toSlot = (toSlot + 1) % numSlots;
      }

      // Transfer 1-5 items
      uint16 amount = (uint16(uint256(keccak256(abi.encode(i, "amount"))) % 5)) + 1;

      transfers[i] = SlotTransfer({ slotFrom: fromSlot, slotTo: toSlot, amount: amount });
    }

    // Perform transfers
    TestInventoryUtils.transfer(alice, alice, transfers);

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);

    // Total amount should remain the same
    uint16 totalAmount = 0;
    uint16[] memory slots = Inventory.getOccupiedSlots(alice);
    for (uint256 i = 0; i < slots.length; i++) {
      totalAmount += InventorySlot.getAmount(alice, slots[i]);
    }

    // Total amount in inventory should be unchanged
    assertEq(totalAmount, numSlots * 10, "Total amount should remain the same");
  }

  // Fuzz test for adding objects with specific slots
  function testAddObjectToSpecificSlots(uint16 slot1, uint16 slot2, uint16 amount) public {
    // Bound inputs to reasonable values
    vm.assume(slot1 < 36);
    vm.assume(slot2 < 36);
    vm.assume(slot1 != slot2);
    vm.assume(amount > 0 && amount <= 50);

    // Setup player
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects to specific slots
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount, slot1);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount, slot2);

    // Verify amounts
    assertEq(InventorySlot.getAmount(alice, slot1), amount, "Slot 1 amount mismatch");
    assertEq(InventorySlot.getAmount(alice, slot2), amount, "Slot 2 amount mismatch");

    // Verify occupied slots count
    assertEq(Inventory.lengthOccupiedSlots(alice), 2, "Should have two occupied slots");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);
  }

  // Fuzz test for transferring entities between inventories
  function testTransferEntities(uint16 numEntities) public {
    // Bound input to reasonable values
    vm.assume(numEntities > 0 && numEntities <= 5);

    // Setup players
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(1, 0, 0));

    // Add entities to Alice's inventory
    EntityId[] memory entities = new EntityId[](numEntities);
    for (uint16 i = 0; i < numEntities; i++) {
      entities[i] = TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);
    }

    // Verify Alice has all entities
    assertEq(Inventory.lengthOccupiedSlots(alice), numEntities, "Alice should have all entities");

    // Transfer each entity one by one
    for (uint16 i = 0; i < numEntities; i++) {
      // Find the slot for this entity
      uint16 slot = TestInventoryUtils.getEntitySlot(alice, entities[i]);

      // Transfer to Bob
      SlotTransfer[] memory transfers = new SlotTransfer[](1);
      transfers[0] = SlotTransfer({ slotFrom: slot, slotTo: i, amount: 1 });

      TestInventoryUtils.transfer(alice, bob, transfers);
    }

    // Verify results
    assertEq(Inventory.lengthOccupiedSlots(alice), 0, "Alice should have empty inventory");
    assertEq(Inventory.lengthOccupiedSlots(bob), numEntities, "Bob should have all entities");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);
    _verifyInventorySlotIntegrity(bob);

    // Verify each entity is now in Bob's inventory
    for (uint16 i = 0; i < numEntities; i++) {
      uint16 slot = TestInventoryUtils.getEntitySlot(bob, entities[i]);
      assertEq(InventorySlot.getEntityId(bob, slot), entities[i], "Entity should be in Bob's inventory");
    }
  }

  // Fuzz test for swapping different types
  function testSwapDifferentTypes(uint16 amount1, uint16 amount2) public {
    // Bound inputs to reasonable values
    vm.assume(amount1 > 0 && amount1 <= 99);
    vm.assume(amount2 > 0 && amount2 <= 99);

    // Setup player
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add different object types
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount1, 0);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Sand, amount2, 1);

    // Swap full slots
    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: amount1 });

    TestInventoryUtils.transfer(alice, alice, transfers);

    // Verify types and amounts have swapped
    assertEq(InventorySlot.getObjectType(alice, 0), ObjectTypes.Sand, "Slot 0 should now have Sand");
    assertEq(InventorySlot.getObjectType(alice, 1), ObjectTypes.OakLog, "Slot 1 should now have OakLog");

    assertEq(InventorySlot.getAmount(alice, 0), amount2, "Slot 0 should have amount2");
    assertEq(InventorySlot.getAmount(alice, 1), amount1, "Slot 1 should have amount1");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);
  }

  // Fuzz test for transferAll between inventories with varying contents
  function testTransferAll(uint16 numObjects) public {
    // Bound input to reasonable values
    vm.assume(numObjects > 0 && numObjects <= 10);

    // Setup players
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(1, 0, 0));

    // Add a mix of objects and entities to Alice
    uint16 totalItems = 0;

    // Add regular objects
    for (uint16 i = 0; i < numObjects; i++) {
      uint16 amount = (i % 3) + 1; // 1-3 items per slot
      TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, amount, i);
      totalItems += amount;
    }

    // Add some entities too
    uint16 numEntities = (numObjects % 3) + 1; // 1-3 entities
    for (uint16 i = 0; i < numEntities; i++) {
      TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);
      totalItems += 1;
    }

    // Verify initial state
    assertEq(Inventory.lengthOccupiedSlots(alice), numObjects + numEntities, "Alice should have all items");
    assertEq(Inventory.lengthOccupiedSlots(bob), 0, "Bob should have empty inventory");

    // Transfer all from Alice to Bob
    TestInventoryUtils.transferAll(alice, bob);

    // Verify results
    assertEq(Inventory.lengthOccupiedSlots(alice), 0, "Alice should have empty inventory");

    // Count items in Bob's inventory
    uint16 bobTotalItems = 0;
    uint16[] memory slots = Inventory.getOccupiedSlots(bob);
    for (uint256 i = 0; i < slots.length; i++) {
      bobTotalItems += InventorySlot.getAmount(bob, slots[i]);
    }

    assertEq(bobTotalItems, totalItems, "Bob should have all items");

    // Verify inventory integrity
    _verifyInventorySlotIntegrity(alice);
    _verifyInventorySlotIntegrity(bob);
  }

  // Helper function to verify the integrity of inventory slots after operations
  function _verifyInventorySlotIntegrity(EntityId entity) internal view {
    uint16[] memory slots = Inventory.getOccupiedSlots(entity);

    ObjectType[] memory objectTypes = new ObjectType[](slots.length);
    // Check that each occupied slot has correct index
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot.get(entity, slots[i]);
      objectTypes[i] = slotData.objectType;
      assertEq(i, slotData.occupiedIndex, "Occupied index mismatch");
    }

    // Verify each object type's slots are correct
    for (uint256 i = 0; i < objectTypes.length; i++) {
      if (objectTypes[i] == ObjectTypes.Null) continue;

      uint16[] memory typeSlots = InventoryTypeSlots.get(entity, objectTypes[i]);
      for (uint256 j = 0; j < typeSlots.length; j++) {
        InventorySlotData memory slotData = InventorySlot.get(entity, typeSlots[j]);
        assertEq(j, slotData.typeIndex, "Type index mismatch");
        assertEq(objectTypes[i], slotData.objectType, "Object type mismatch");
      }
    }
  }
}
