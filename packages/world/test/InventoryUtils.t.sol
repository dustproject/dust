// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibBit } from "solady/utils/LibBit.sol";

import { DustTest, console } from "./DustTest.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

import { InventoryBitmap } from "../src/codegen/tables/InventoryBitmap.sol";
import { Math } from "../src/utils/Math.sol";

import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
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
    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 36);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bobEntity), 0);

    TestInventoryUtils.removeObjectFromSlot(aliceEntity, 1, 1);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 35);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 0);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bobEntity), 35);

    TestInventoryUtils.transferAll(bobEntity, aliceEntity);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 35);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bobEntity), 0);

    TestInventoryUtils.transferAll(aliceEntity, bobEntity);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 0);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bobEntity), 35);

    _verifyInventoryBitmapIntegrity(aliceEntity);
  }

  function testTransferEntityToEmptySlot() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(1, 0, 0));

    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.AcaciaLog, 1);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.CopperAxe);
    TestInventoryUtils.addObject(aliceEntity, ObjectTypes.FescueGrass, 1);

    TestInventoryUtils.removeObject(aliceEntity, ObjectTypes.FescueGrass, 1);

    // Transfer CopperAxe to the empty slot where FescueGrass was
    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 1, slotTo: 2, amount: 1 });

    TestInventoryUtils.transfer(aliceEntity, aliceEntity, transfers);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 2);

    _verifyInventoryBitmapIntegrity(aliceEntity);
  }

  function testReuseEmptySlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(alice, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick); // slot 1
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2, "expected two occupied slots");

    TestInventoryUtils.removeEntityFromSlot(alice, 0);
    TestInventoryUtils.removeEntityFromSlot(alice, 1);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 0, "inventory should be empty");

    // Reuse the slots - should get slot 0 first
    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(alice, ObjectTypes.NeptuniumAxe);

    // Occupied slots should be 0 and 1 again
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2, "should have 2 slots occupied");

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testSlotTransfersWithinSameInventory() public {
    (, EntityId aliceEntity) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.WoodenHoe); // slot 0
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.IronPick); // slot 1
    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 2, "expected 2 occupied slots");

    SlotTransfer[] memory transfers = new SlotTransfer[](2);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 2, amount: 1 });
    transfers[1] = SlotTransfer({ slotFrom: 1, slotTo: 3, amount: 1 });
    TestInventoryUtils.transfer(aliceEntity, aliceEntity, transfers);

    // Now the inventory holds slots 2 & 3, while slots 0 & 1 are free
    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 2, "inventory should still have 2 items");

    // Add two more items - should reuse slots 0 & 1
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(aliceEntity, ObjectTypes.NeptuniumAxe);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(aliceEntity), 4, "expected 4 occupied slots");

    _verifyInventoryBitmapIntegrity(aliceEntity);
  }

  function testTransferBetweenInventories() public {
    (, EntityId alice) = createTestPlayer(vec3(5, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(6, 0, 0));

    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Sand, 10, 5);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Snow, 20, 10);

    SlotTransfer[] memory transfers = new SlotTransfer[](2);
    transfers[0] = SlotTransfer({ slotFrom: 5, slotTo: 3, amount: 10 });
    transfers[1] = SlotTransfer({ slotFrom: 10, slotTo: 7, amount: 20 });

    TestInventoryUtils.transfer(alice, bob, transfers);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 0, "Alice should have empty inventory");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bob), 2, "Bob should have 2 items");

    assertEq(InventorySlot.getAmount(bob, 3), 10, "Bob should have 10 sand in slot 3");
    assertEq(InventorySlot.getAmount(bob, 7), 20, "Bob should have 20 snow in slot 7");

    _verifyInventoryBitmapIntegrity(alice);
    _verifyInventoryBitmapIntegrity(bob);
  }

  function testSwapSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.OakLog, 10, 1);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    TestInventoryUtils.transfer(alice, alice, transfers);

    // Verify the swap happened
    assertEq(InventorySlot.getObjectType(alice, 0), ObjectTypes.OakLog);
    assertEq(InventorySlot.getAmount(alice, 0), 10);
    assertEq(InventorySlot.getObjectType(alice, 1), ObjectTypes.CopperAxe);

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testSwapEntities() public {
    (, EntityId alice) = createTestPlayer(vec3(1, 1, 1));

    TestInventoryUtils.addEntity(alice, ObjectTypes.CopperAxe);
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    TestInventoryUtils.transfer(alice, alice, transfers);

    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2);

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testPartialStackAddsOneSlot() public {
    (, EntityId alice) = createTestPlayer(vec3(2, 0, 0));

    // stack size = 99, add 95 logs
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 95);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1);

    // add 10 more, slot 0 reaches 99, slot 1 holds 6
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 10);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2);

    // amounts
    uint16 a0 = InventorySlot.getAmount(alice, 0);
    uint16 a1 = InventorySlot.getAmount(alice, 1);
    assertEq(a0, 99);
    assertEq(a1, 6);

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testPartialThenFullRemoval() public {
    (, EntityId alice) = createTestPlayer(vec3(3, 0, 0));

    TestInventoryUtils.addObject(alice, ObjectTypes.Snow, 99 * 2 + 1); // stack 99, so 3 slots: 99,99,1
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 3);

    // remove 10 from slot 0, should remain occupied with 89
    TestInventoryUtils.removeObjectFromSlot(alice, 0, 10);
    assertEq(InventorySlot.getAmount(alice, 0), 89);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 3);

    // now remove the remaining 89, slot recycled, only two occupied left
    TestInventoryUtils.removeObjectFromSlot(alice, 0, 89);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2);

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testUseEmptySlotAfterGap() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // jump straight to slot 10, leaving 0-9 untouched
    TestInventoryUtils.addObjectToSlot(alice, ObjectTypes.Ice, 1, 10);

    // first fresh allocation must use slot 0 (first empty)
    TestInventoryUtils.addObject(alice, ObjectTypes.Snow, 1);

    // Snow should be in slot 0
    InventorySlotData memory slotData = InventorySlot.get(alice, 0);
    assertEq(slotData.objectType, ObjectTypes.Snow, "Snow should be in slot 0");

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testRemoveAcrossSlots() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add 250 oak logs (stackable 99), so we need 3 slots: 99,99,52
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, 250);
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 3, "Should have 3 slots");

    // Verify distribution
    assertEq(InventorySlot.getAmount(alice, 0), 99);
    assertEq(InventorySlot.getAmount(alice, 1), 99);
    assertEq(InventorySlot.getAmount(alice, 2), 52);

    // Remove 150 logs - should remove from slots 2,1,0 in that order
    TestInventoryUtils.removeObject(alice, ObjectTypes.OakLog, 150);

    // Should have 100 left: 99 in slot 0, 1 in slot 1
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 2, "Should have 2 slots");
    assertEq(InventorySlot.getAmount(alice, 0), 99);
    assertEq(InventorySlot.getAmount(alice, 1), 1);

    _verifyInventoryBitmapIntegrity(alice);
  }

  function testToolUse() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add a tool
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);
    EntityId toolId = InventorySlot.getEntityId(alice, 0);

    // Get tool data
    ToolData memory toolData = TestInventoryUtils.getToolData(alice, 0);
    assertEq(toolData.toolType, ObjectTypes.IronPick);
    assertEq(toolData.tool, toolId);

    // Use the tool partially
    uint128 initialMass = Mass.getMass(toolId);
    TestInventoryUtils.use(toolData, 100, 1);

    // Tool should still exist with reduced mass
    assertTrue(Mass.getMass(toolId) < initialMass, "Tool mass should be reduced");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1, "Tool should still be in inventory");

    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz tests

  function testFuzzAddRemoveObjects(uint16 addAmount, uint16 removeAmount) public {
    // Bound inputs
    vm.assume(addAmount > 0 && addAmount <= 999);
    vm.assume(removeAmount <= addAmount);

    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add objects
    TestInventoryUtils.addObject(alice, ObjectTypes.OakLog, addAmount);

    // Remove objects
    if (removeAmount > 0) {
      TestInventoryUtils.removeObject(alice, ObjectTypes.OakLog, removeAmount);
    }

    // Calculate expected remaining amount
    uint16 expectedRemaining = addAmount - removeAmount;

    // Calculate expected slots
    uint16 expectedSlots = expectedRemaining > 0 ? (expectedRemaining + 98) / 99 : 0;

    // Verify slot count
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), expectedSlots, "Wrong number of remaining slots");

    // Verify total amount of objects
    assertEq(
      TestInventoryUtils.countObjectsOfType(alice, ObjectTypes.OakLog), expectedRemaining, "Remaining amount mismatch"
    );

    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz test for transferring objects between slots
  function testFuzzTransferBetweenSlots(uint16 amount1, uint16 amount2, uint16 transferAmount) public {
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
    uint16 destinationSlot = InventorySlot.getAmount(alice, 1);

    // If we transferred all from slot 0, it should be recycled
    if (transferAmount == amount1) {
      assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1, "Should only have one occupied slot");
    } else {
      uint16 remainingFromSlot = InventorySlot.getAmount(alice, 0);
      assertEq(remainingFromSlot, amount1 - transferAmount, "Source slot amount mismatch");
    }

    assertEq(destinationSlot, amount2 + transferAmount, "Destination slot amount mismatch");

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz test for transferring between inventories
  function testFuzzTransferBetweenInventories(uint16 amount, uint16 transferAmount) public {
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
      assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 0, "Alice should have empty inventory");
    } else {
      uint16 aliceRemaining = InventorySlot.getAmount(alice, 0);
      assertEq(aliceRemaining, amount - transferAmount, "Alice remaining amount mismatch");
    }

    uint16 bobAmount = InventorySlot.getAmount(bob, 0);
    assertEq(bobAmount, transferAmount, "Bob received amount mismatch");

    // Verify inventory integrity for both inventories
    _verifyInventoryBitmapIntegrity(alice);
    _verifyInventoryBitmapIntegrity(bob);
  }

  // Fuzz test for entity transfers
  function testFuzzEntityTransfers(uint8 numEntities) public {
    // Bound input
    vm.assume(numEntities > 0 && numEntities <= 10);

    // Setup players
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));
    (, EntityId bob) = createTestPlayer(vec3(1, 0, 0));

    // Add entities to Alice
    EntityId[] memory entities = new EntityId[](numEntities);
    for (uint16 i = 0; i < numEntities; i++) {
      entities[i] = TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);
    }

    // Transfer all entities to Bob
    for (uint16 i = 0; i < numEntities; i++) {
      SlotTransfer[] memory transfers = new SlotTransfer[](1);
      transfers[0] = SlotTransfer({ slotFrom: i, slotTo: i, amount: 1 });

      TestInventoryUtils.transfer(alice, bob, transfers);
    }

    // Verify results
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 0, "Alice should have empty inventory");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bob), numEntities, "Bob should have all entities");

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
    _verifyInventoryBitmapIntegrity(bob);

    // Verify each entity is now in Bob's inventory
    for (uint16 i = 0; i < numEntities; i++) {
      TestInventoryUtils.findEntity(bob, entities[i]);
    }
  }

  // Fuzz test for swapping different types
  function testFuzzSwapDifferentTypes(uint16 amount1, uint16 amount2) public {
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
    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz test for transferAll between inventories with varying contents
  function testFuzzTransferAll(uint16 numObjects) public {
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
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), numObjects + numEntities, "Alice should have all items");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(bob), 0, "Bob should have empty inventory");

    // Transfer all from Alice to Bob
    TestInventoryUtils.transferAll(alice, bob);

    // Verify results
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 0, "Alice should have empty inventory");

    // Count items in Bob's inventory
    uint16 bobTotalItems = 0;
    uint256[] memory bitmap = InventoryBitmap.get(bob);
    for (uint256 i = 0; i < bitmap.length; i++) {
      uint256 word = bitmap[i];
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        uint16 slot = uint16(i * 256 + bitIndex);
        bobTotalItems += InventorySlot.getAmount(bob, slot);
      }
    }

    assertEq(bobTotalItems, totalItems, "Bob should have all items");

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
    _verifyInventoryBitmapIntegrity(bob);
  }

  function _verifyInventoryBitmapIntegrity(EntityId entity) internal {
    uint256[] memory bitmap = InventoryBitmap.get(entity);

    // After pruning, either the bitmap is empty or its last word is non-zero.
    if (bitmap.length == 0) {
      assertEq(TestInventoryUtils.getOccupiedSlotCount(entity), 0, "Bitmap empty but slots present");
      return; // nothing else to verify
    }
    assertTrue(bitmap[bitmap.length - 1] != 0, "Trailing zero word detected");

    // count set bits
    uint256 bitmapCount = 0;
    for (uint256 i = 0; i < bitmap.length; ++i) {
      bitmapCount += LibBit.popCount(bitmap[i]);
    }

    // per-slot verification
    uint256 actualCount = 0;
    for (uint256 wordIndex = 0; wordIndex < bitmap.length; ++wordIndex) {
      uint256 word = bitmap[wordIndex];
      uint256 originalWord = word;

      // every set bit -> slot MUST have data
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1; // clear LS1B

        uint16 slot = uint16(wordIndex * 256 + bitIndex);
        InventorySlotData memory slotData = InventorySlot.get(entity, slot);

        assertTrue(!slotData.objectType.isNull(), "Bit set but slot empty");
        assertTrue(slotData.amount > 0, "Slot amount is zero");
        ++actualCount;
      }

      // every slot with data -> bit MUST be set
      for (uint256 bit = 0; bit < 256; ++bit) {
        uint16 slot = uint16(wordIndex * 256 + bit);
        InventorySlotData memory slotData = InventorySlot.get(entity, slot);

        if (!slotData.objectType.isNull()) {
          bool bitIsSet = (originalWord & (uint256(1) << bit)) != 0;
          assertTrue(bitIsSet, "Slot has data but bit not set");
        }
      }
    }

    assertEq(bitmapCount, actualCount, "Bitmap count mismatch");
    assertEq(bitmapCount, TestInventoryUtils.getOccupiedSlotCount(entity), "Mismatch with utility count");
  }
}
