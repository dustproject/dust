// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { GasReporter } from "@latticexyz/gas-report/src/GasReporter.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { LibBit } from "solady/utils/LibBit.sol";

import { Energy } from "../src/codegen/tables/Energy.sol";
import { InventoryBitmap } from "../src/codegen/tables/InventoryBitmap.sol";
import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityPosition, LocalEnergyPool, ReverseMovablePosition } from "../src/utils/Vec3Storage.sol";

import { EntityId } from "../src/types/EntityId.sol";

import { ObjectAmount, ObjectType, ObjectTypeLib } from "../src/types/ObjectType.sol";
import { ProgramId } from "../src/types/ProgramId.sol";
import { TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

abstract contract DustAssertions is MudTest, GasReporter {
  struct EnergyDataSnapshot {
    EntityId playerEntityId;
    uint128 playerEnergy;
    uint128 localPoolEnergy;
    uint128 forceFieldEnergy;
  }

  function getObjectAmount(EntityId owner, ObjectType objectType) internal returns (uint16) {
    uint256 total = TestInventoryUtils.countObjectsOfType(owner, objectType);
    return uint16(total);
  }

  function inventoryHasObjectType(EntityId ownerEntityId, ObjectType objectType) internal returns (bool) {
    return getObjectAmount(ownerEntityId, objectType) > 0;
  }

  function inventoryGetOreAmounts(EntityId owner) internal returns (ObjectAmount[] memory) {
    ObjectType[6] memory ores = ObjectTypeLib.getOreTypes();

    uint256 numOres = 0;
    for (uint256 i = 0; i < ores.length; i++) {
      if (TestInventoryUtils.hasObjectType(owner, ores[i])) numOres++;
    }

    ObjectAmount[] memory oreAmounts = new ObjectAmount[](numOres);
    uint256 index = 0;
    for (uint256 i = 0; i < ores.length; i++) {
      uint256 count = getObjectAmount(owner, ores[i]);
      if (count > 0) {
        oreAmounts[index++] = ObjectAmount(ores[i], uint16(count));
      }
    }

    return oreAmounts;
  }

  function assertInventoryHasObject(EntityId owner, ObjectType objectType, uint16 amount) internal {
    uint256 actualAmount = getObjectAmount(owner, objectType);
    assertEq(actualAmount, amount, "Inventory object amount is not correct");
  }

  function assertInventoryHasObjectInSlot(EntityId owner, ObjectType objectType, uint16 amount, uint16 slot)
    internal
    view
  {
    assertEq(InventorySlot.getObjectType(owner, slot), objectType, "Inventory object type is not correct");
    uint16 actualAmount = InventorySlot.getAmount(owner, slot);
    assertEq(actualAmount, amount, "Inventory object amount is not correct");
  }

  function assertInventoryHasEntity(EntityId owner, EntityId entityId, uint16 amount) internal {
    uint16[] memory slots = TestInventoryUtils.getSlotsWithType(owner, EntityObjectType.get(entityId));
    if (slots.length == 0) {
      assertTrue(amount == 0, "Inventory entity not found");
      return;
    }

    for (uint256 i = 0; i < slots.length; i++) {
      uint16 slot = slots[i];
      if (InventorySlot.getEntityId(owner, slot) == entityId) {
        assertTrue(amount == 1, "Inventory entity found");
        return;
      }
    }

    assertTrue(amount == 0, "Inventory entity not found");
  }

  function assertInventoryEmpty(EntityId owner) internal {
    uint256 slotCount = TestInventoryUtils.getOccupiedSlotCount(owner);
    assertEq(slotCount, 0, "Inventory is not empty");
  }

  function getEnergyDataSnapshot(EntityId playerEntityId) internal returns (EnergyDataSnapshot memory) {
    EnergyDataSnapshot memory snapshot;
    snapshot.playerEntityId = playerEntityId;
    snapshot.playerEnergy = Energy.getEnergy(playerEntityId);
    Vec3 snapshotCoord = EntityPosition.get(playerEntityId);
    Vec3 shardCoord = snapshotCoord.toLocalEnergyPoolShardCoord();
    snapshot.localPoolEnergy = LocalEnergyPool.get(shardCoord);
    (EntityId forceFieldEntityId,) = TestForceFieldUtils.getForceField(snapshotCoord);
    snapshot.forceFieldEnergy = forceFieldEntityId.exists() ? Energy.getEnergy(forceFieldEntityId) : 0;
    return snapshot;
  }

  function assertEnergyFlowedFromPlayerToLocalPool(EnergyDataSnapshot memory previousSnapshot)
    internal
    returns (uint128 playerEnergyLost)
  {
    EnergyDataSnapshot memory currentSnapshot = getEnergyDataSnapshot(previousSnapshot.playerEntityId);
    playerEnergyLost = previousSnapshot.playerEnergy - currentSnapshot.playerEnergy;
    assertGt(playerEnergyLost, 0, "Player energy did not decrease");
    uint128 localPoolEnergyGained = currentSnapshot.localPoolEnergy - previousSnapshot.localPoolEnergy;
    assertEq(localPoolEnergyGained, playerEnergyLost, "Local pool energy did not gain all the player's energy");
  }

  function assertPlayerIsDead(EntityId player, Vec3 playerCoord) internal view {
    // Check energy is zero
    assertEq(Energy.getEnergy(player), 0, "Player energy is not 0");

    // Verify the player entity is still registered to the address, but removed from the grid
    assertEq(EntityPosition.get(player), vec3(0, 0, 0), "Player position was not deleted");
    assertEq(ReverseMovablePosition.get(playerCoord), EntityId.wrap(0), "Player reverse position was not deleted");
    assertEq(
      ReverseMovablePosition.get(playerCoord + vec3(0, 1, 0)),
      EntityId.wrap(0),
      "Player reverse position at head was not deleted"
    );
  }

  function assertEq(Vec3 a, Vec3 b, string memory err) internal pure {
    assertEq(a.toString(), b.toString(), err);
  }

  function assertEq(Vec3 a, Vec3 b) internal pure {
    assertEq(a.toString(), b.toString());
  }

  function assertEq(EntityId a, EntityId b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(EntityId a, EntityId b) internal pure {
    assertTrue(a == b);
  }

  function assertNotEq(EntityId a, EntityId b) internal pure {
    assertNotEq(a, b);
  }

  function assertNotEq(EntityId a, EntityId b, string memory err) internal pure {
    assertNotEq(a.unwrap(), b.unwrap(), err);
  }

  function assertEq(ProgramId a, ProgramId b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(ProgramId a, ProgramId b) internal pure {
    assertTrue(a == b);
  }

  function assertEq(ObjectType a, ObjectType b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(ObjectType a, ObjectType b) internal pure {
    assertTrue(a == b);
  }

  function assertNotEq(ObjectType a, ObjectType b, string memory err) internal pure {
    assertTrue(a != b, err);
  }

  function assertNotEq(ObjectType a, ObjectType b) internal pure {
    assertTrue(a != b);
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

        if (slotData.objectType.isTool()) {
          assertTrue(slotData.amount == 1, "Tool slot should have amount 1");
          assertTrue(slotData.entityId != EntityId.wrap(0), "Tool slot has zero entity id");
        }

        if (slotData.entityId != EntityId.wrap(0)) {
          // if slot has an entity, it must have a valid mass
          assertTrue(Mass.getMass(slotData.entityId) > 0, "Entity in slot has zero mass");
        }

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
