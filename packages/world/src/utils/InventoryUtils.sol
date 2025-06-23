// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  AmountMustBePositive,
  CannotAdd0ObjectsToSlot,
  CannotStoreDifferentObjectTypes,
  CannotTransferAllToSelf,
  CannotTransferAmountsToSelf,
  EmptySlot,
  EntityMustExist,
  EntityTransferAmountMustBe1,
  InvalidSlot,
  InventoryIsFull,
  NotAnEntity,
  NotEnoughObjects,
  NotEnoughObjectsInSlot,
  ObjectDoesNotFitInSlot,
  ObjectTypeCannotBeAddedToInventory,
  SlotExceedsMaxInventory,
  SlotMustBeEmpty
} from "../Errors.sol";
import { InventoryBitmap } from "../codegen/tables/InventoryBitmap.sol";
import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { LibBit } from "solady/utils/LibBit.sol";

import { burnToolEnergy } from "../utils/EnergyUtils.sol";
import { Math } from "../utils/Math.sol";

import { EntityId } from "../types/EntityId.sol";

import { ACTION_MODIFIER_DENOMINATOR } from "../Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypes } from "../types/ObjectType.sol";

import { Vec3 } from "../types/Vec3.sol";
import { OreLib } from "../utils/OreLib.sol";

struct SlotTransfer {
  uint16 slotFrom;
  uint16 slotTo;
  uint16 amount;
}

struct SlotAmount {
  uint16 slot;
  uint16 amount;
}

struct SlotData {
  EntityId entityId;
  ObjectType objectType;
  uint16 amount;
}

library InventoryUtils {
  uint256 constant SLOTS_PER_WORD = 256;

  /* Bitmap operations */

  function isEmpty(EntityId owner) internal view returns (bool) {
    // Optimize
    uint256 length = InventoryBitmap._length(owner);
    for (uint256 i = 0; i < length; i++) {
      if (InventoryBitmap._getItem(owner, i) != 0) return false;
    }
    return true;
  }

  function setBit(EntityId owner, uint16 slot) internal {
    uint256 wordIndex = slot / SLOTS_PER_WORD;
    uint256 bitIndex = slot & 255; // cheaper than % 256

    _ensureWordExists(owner, wordIndex);

    uint256 word = InventoryBitmap._getItem(owner, wordIndex);
    word |= uint256(1) << bitIndex;
    InventoryBitmap._updateBitmap(owner, wordIndex, word);
  }

  function clearBit(EntityId owner, uint16 slot) internal {
    uint256 wordIndex = slot / SLOTS_PER_WORD;
    uint256 bitIndex = slot & 255;

    uint256 length = InventoryBitmap._length(owner);
    if (wordIndex >= length) return;

    uint256 word = InventoryBitmap._getItem(owner, wordIndex);
    word &= ~(uint256(1) << bitIndex);
    InventoryBitmap._updateBitmap(owner, wordIndex, word);

    // If we touched the last word and it is now zero, prune.
    if (word == 0 && wordIndex == length - 1) {
      _pruneTrailingEmptyWords(owner);
    }
  }

  function isBitSet(uint256[] memory bitmap, uint16 slot) internal pure returns (bool) {
    // TODO: optimize
    uint256 wordIndex = slot / SLOTS_PER_WORD;
    uint256 bitIndex = slot % SLOTS_PER_WORD;
    if (wordIndex >= bitmap.length) return false;
    return (bitmap[wordIndex] & (1 << bitIndex)) != 0;
  }

  function findEmptySlot(EntityId owner) internal view returns (uint16) {
    uint16 maxSlots = owner._getObjectType().getMaxInventorySlots();

    uint256 length = InventoryBitmap._length(owner);

    for (uint256 wordIndex = 0; wordIndex < length; ++wordIndex) {
      uint256 word = InventoryBitmap._getItem(owner, wordIndex);
      if (word != type(uint256).max) {
        // at least one free bit here
        uint256 bitIndex = LibBit.ffs(~word); // first zero bit
        uint16 slot = uint16(wordIndex * SLOTS_PER_WORD + bitIndex);
        if (slot < maxSlots) return slot;
      }
    }

    // No free space inside current words: next slot is at current length.
    uint16 nextSlot = uint16(length * SLOTS_PER_WORD);
    if (nextSlot >= maxSlots) revert InventoryIsFull(owner);
    return nextSlot;
  }

  /* Inventory operations */

  function addEntity(EntityId owner, EntityId entityId) internal returns (uint16 slot) {
    ObjectType objectType = entityId._getObjectType();
    if (objectType.isNull()) revert EntityMustExist(entityId);

    slot = findEmptySlot(owner);
    setBit(owner, slot);
    InventorySlot._set(owner, slot, entityId, objectType, 1);
  }

  function addEntityToSlot(EntityId owner, EntityId entityId, uint16 slot) internal {
    ObjectType objectType = entityId._getObjectType();
    if (objectType.isNull()) revert EntityMustExist(entityId);

    // Check slot is within bounds for this entity type
    uint16 maxSlots = owner._getObjectType().getMaxInventorySlots();
    if (slot >= maxSlots) revert SlotExceedsMaxInventory(slot, maxSlots);

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);
    if (!slotData.objectType.isNull()) revert SlotMustBeEmpty(slot);

    setBit(owner, slot);
    InventorySlot._set(owner, slot, entityId, objectType, 1);
  }

  function addObject(EntityId owner, ObjectType objectType, uint128 amount) public {
    if (amount == 0) revert AmountMustBePositive(amount);
    uint16 stackable = objectType.getStackable();
    if (stackable == 0) revert ObjectTypeCannotBeAddedToInventory(objectType);

    uint128 remaining = amount;
    uint256[] memory bitmap = InventoryBitmap._getBitmap(owner);

    // First, find and fill existing slots for this object type
    for (uint256 i = 0; i < bitmap.length && remaining > 0; i++) {
      uint256 word = bitmap[i];
      while (word != 0 && remaining > 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1; // Clear the bit

        uint16 slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        InventorySlotData memory data = InventorySlot._get(owner, slot);

        if (data.objectType != objectType || data.amount >= stackable) {
          continue;
        }

        uint16 canAdd = stackable - data.amount;
        uint16 toAdd = remaining < canAdd ? uint16(remaining) : canAdd;
        InventorySlot._setAmount(owner, slot, data.amount + toAdd);
        remaining -= toAdd;
      }
    }

    // If we still have objects to add, use empty slots
    while (remaining > 0) {
      uint16 slot = findEmptySlot(owner);
      setBit(owner, slot);
      uint16 toAdd = remaining < stackable ? uint16(remaining) : stackable;
      InventorySlot._set(owner, slot, EntityId.wrap(0), objectType, toAdd);
      remaining -= toAdd;
    }
  }

  function addObjectToSlot(EntityId owner, ObjectType objectType, uint16 amount, uint16 slot) internal {
    if (amount == 0) revert CannotAdd0ObjectsToSlot();
    uint16 stackable = objectType.getStackable();
    if (stackable == 0) revert ObjectTypeCannotBeAddedToInventory(objectType);

    // Check slot is within bounds for this entity type
    uint16 maxSlots = owner._getObjectType().getMaxInventorySlots();
    if (maxSlots == 0) revert InvalidSlot(slot);
    if (slot >= maxSlots) revert SlotExceedsMaxInventory(slot, maxSlots);

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);

    if (slotData.objectType.isNull()) {
      setBit(owner, slot);
      InventorySlot._set(owner, slot, EntityId.wrap(0), objectType, amount);
    } else {
      if (slotData.objectType != objectType) revert CannotStoreDifferentObjectTypes(slotData.objectType, objectType);
      uint16 newAmount = slotData.amount + amount;
      if (newAmount > stackable) revert ObjectDoesNotFitInSlot(newAmount, stackable);
      InventorySlot._setAmount(owner, slot, newAmount);
    }
  }

  function removeEntity(EntityId owner, EntityId entity) internal {
    uint16 slot = findEntity(owner, entity);
    clearBit(owner, slot);
    InventorySlot._deleteRecord(owner, slot);
    Mass._deleteRecord(entity);
  }

  function removeEntityFromSlot(EntityId owner, uint16 slot) internal {
    EntityId entity = moveEntityFromSlot(owner, slot);
    Mass._deleteRecord(entity);
  }

  function moveEntityFromSlot(EntityId owner, uint16 slot) internal returns (EntityId) {
    EntityId entity = InventorySlot._getEntityId(owner, slot);
    if (!entity._exists()) revert NotAnEntity(entity);

    clearBit(owner, slot);
    InventorySlot._deleteRecord(owner, slot);
    // Don't delete mass!
    return entity;
  }

  function removeObject(EntityId owner, ObjectType objectType, uint16 amount) internal {
    if (amount == 0) revert AmountMustBePositive(amount);
    if (objectType.isNull()) revert EmptySlot(owner, 0);

    uint16 remaining = amount;
    uint256[] memory bitmap = InventoryBitmap._getBitmap(owner);

    // walk backwards so clearing whole trailing words is cheaper
    for (uint256 wi = bitmap.length; wi > 0 && remaining > 0; wi--) {
      uint256 word = bitmap[wi - 1];

      while (word != 0 && remaining > 0) {
        uint256 bit = LibBit.fls(word);
        word &= ~(uint256(1) << bit);

        uint16 slot = uint16((wi - 1) * SLOTS_PER_WORD + bit);
        InventorySlotData memory slotData = InventorySlot._get(owner, slot);

        if (slotData.objectType != objectType) continue;

        if (slotData.amount <= remaining) {
          remaining -= slotData.amount;
          clearBit(owner, slot);
          InventorySlot._deleteRecord(owner, slot);
        } else {
          InventorySlot._setAmount(owner, slot, slotData.amount - remaining);
          remaining = 0;
        }
      }
    }

    if (remaining != 0) revert NotEnoughObjects(objectType, amount, amount - remaining);
  }

  function removeObjectFromSlot(EntityId owner, uint16 slot, uint16 amount) internal returns (ObjectType) {
    if (amount == 0) revert AmountMustBePositive(amount);

    InventorySlotData memory data = InventorySlot._get(owner, slot);
    require(!data.objectType.isNull(), "Empty slot");
    if (data.amount < amount) revert NotEnoughObjectsInSlot(slot, amount, data.amount);

    if (data.amount == amount) {
      clearBit(owner, slot);
      InventorySlot._deleteRecord(owner, slot);
    } else {
      InventorySlot._setAmount(owner, slot, data.amount - amount);
    }

    return data.objectType;
  }

  /* Transfers */

  function transfer(EntityId from, EntityId to, SlotTransfer[] memory slotTransfers)
    public
    returns (SlotData[] memory fromSlotData, SlotData[] memory toSlotData)
  {
    fromSlotData = new SlotData[](slotTransfers.length);
    toSlotData = new SlotData[](slotTransfers.length);

    uint256 toSlotDataLength = 0;
    for (uint256 i = 0; i < slotTransfers.length; i++) {
      uint16 slotFrom = slotTransfers[i].slotFrom;
      uint16 slotTo = slotTransfers[i].slotTo;
      uint16 amount = slotTransfers[i].amount;

      if (amount == 0) revert AmountMustBePositive(amount);

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      if (sourceSlot.objectType.isNull()) revert EmptySlot(from, slotFrom);
      fromSlotData[i] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);

      InventorySlotData memory destSlot = InventorySlot._get(to, slotTo);

      // Can only stack if the two slots hold the same objectType and don't go over the limit
      bool isSameType = sourceSlot.objectType == destSlot.objectType;
      bool canStack = isSameType && sourceSlot.amount + destSlot.amount <= sourceSlot.objectType.getStackable();

      // Handle slot swaps (transferring all to an existing slot)
      if (amount == sourceSlot.amount && !destSlot.objectType.isNull() && !canStack) {
        toSlotData[toSlotDataLength++] = SlotData(destSlot.entityId, destSlot.objectType, destSlot.amount);

        // Swap slots
        InventorySlot._set(from, slotFrom, destSlot.entityId, destSlot.objectType, destSlot.amount);
        InventorySlot._set(to, slotTo, sourceSlot.entityId, sourceSlot.objectType, sourceSlot.amount);
        continue;
      }

      if (!destSlot.objectType.isNull() && !isSameType) {
        revert CannotStoreDifferentObjectTypes(sourceSlot.objectType, destSlot.objectType);
      }

      // If transferring within the same inventory, create the corresponding withdrawal
      if (from == to) {
        toSlotData[toSlotDataLength++] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);
      }

      if (sourceSlot.entityId._exists()) {
        // Entities are unique and always have amount=1
        if (amount != 1) revert EntityTransferAmountMustBe1(amount);
        // Move entity without deleting mass
        moveEntityFromSlot(from, slotFrom);
        addEntityToSlot(to, sourceSlot.entityId, slotTo);
      } else {
        // Regular objects can be transferred in partial amounts
        if (amount > sourceSlot.amount) revert NotEnoughObjectsInSlot(slotFrom, amount, sourceSlot.amount);
        removeObjectFromSlot(from, slotFrom, amount);
        addObjectToSlot(to, sourceSlot.objectType, amount, slotTo);
      }
    }

    // Truncate array
    /// @solidity memory-safe-assembly
    assembly {
      mstore(toSlotData, toSlotDataLength)
    }
  }

  function transfer(EntityId from, EntityId to, SlotAmount[] memory slotAmounts)
    public
    returns (SlotData[] memory fromSlotData)
  {
    if (from == to) revert CannotTransferAmountsToSelf(from);

    fromSlotData = new SlotData[](slotAmounts.length);

    for (uint256 i = 0; i < slotAmounts.length; i++) {
      uint16 slotFrom = slotAmounts[i].slot;
      uint16 amount = slotAmounts[i].amount;

      if (amount == 0) revert AmountMustBePositive(amount);

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      if (sourceSlot.objectType.isNull()) revert EmptySlot(from, slotFrom);
      fromSlotData[i] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);

      if (sourceSlot.entityId._exists()) {
        // Entities are unique and always have amount=1
        if (amount != 1) revert EntityTransferAmountMustBe1(amount);
        moveEntityFromSlot(from, slotFrom);
        addEntity(to, sourceSlot.entityId);
      } else {
        // Regular objects can be transferred in partial amounts
        if (amount > sourceSlot.amount) revert NotEnoughObjectsInSlot(slotFrom, amount, sourceSlot.amount);
        removeObjectFromSlot(from, slotFrom, amount);
        addObject(to, sourceSlot.objectType, amount);
      }
    }
  }

  function transferAll(EntityId from, EntityId to) public {
    if (from == to) revert CannotTransferAllToSelf(from);

    uint256[] memory bitmap = InventoryBitmap._getBitmap(from);

    for (uint256 i = 0; i < bitmap.length; i++) {
      uint256 word = bitmap[i];
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        uint16 slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        InventorySlotData memory slotData = InventorySlot._get(from, slot);

        if (slotData.entityId._exists()) {
          addEntity(to, slotData.entityId);
        } else {
          addObject(to, slotData.objectType, slotData.amount);
        }

        InventorySlot._deleteRecord(from, slot);
      }
    }

    InventoryBitmap._deleteRecord(from);
  }

  /* Helpers */

  // TODO: move unused utils to TestUtils
  function getSlotsWithType(EntityId owner, ObjectType objectType) internal view returns (uint16[] memory) {
    uint256 bitmapLength = InventoryBitmap._length(owner);
    uint16[] memory tempSlots = new uint16[](256); // Max reasonable size
    uint256 count = 0;

    for (uint256 i = 0; i < bitmapLength; i++) {
      uint256 word = InventoryBitmap._getItem(owner, i);
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        uint16 slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        if (InventorySlot._getObjectType(owner, slot) == objectType) {
          tempSlots[count++] = slot;
        }
      }
    }

    // Resize array to actual count
    uint16[] memory slots = new uint16[](count);
    for (uint256 i = 0; i < count; i++) {
      slots[i] = tempSlots[i];
    }
    return slots;
  }

  function countObjectsOfType(EntityId owner, ObjectType objectType) internal view returns (uint256 total) {
    uint256 bitmapLength = InventoryBitmap._length(owner);

    for (uint256 i = 0; i < bitmapLength; i++) {
      uint256 word = InventoryBitmap._getItem(owner, i);
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        uint16 slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        InventorySlotData memory data = InventorySlot._get(owner, slot);

        if (data.objectType == objectType) {
          total += data.amount;
        }
      }
    }
  }

  function hasObjectType(EntityId owner, ObjectType objectType) internal view returns (bool) {
    return countObjectsOfType(owner, objectType) > 0;
  }

  function getOccupiedSlotCount(EntityId owner) internal view returns (uint256 count) {
    uint256[] memory bitmap = InventoryBitmap._get(owner);
    for (uint256 i = 0; i < bitmap.length; ++i) {
      count += LibBit.popCount(bitmap[i]);
    }
  }

  function findObjectType(EntityId owner, ObjectType objectType) internal view returns (uint16 slot) {
    uint256 bitmapLength = InventoryBitmap._length(owner);

    for (uint256 i = 0; i < bitmapLength; i++) {
      uint256 word = InventoryBitmap._getItem(owner, i);
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        if (objectType == InventorySlot._getObjectType(owner, slot)) {
          return slot;
        }
      }
    }

    revert("Object type not found");
  }

  function findEntity(EntityId owner, EntityId entityId) internal view returns (uint16 slot) {
    uint256 bitmapLength = InventoryBitmap._length(owner);

    for (uint256 i = 0; i < bitmapLength; i++) {
      uint256 word = InventoryBitmap._getItem(owner, i);
      while (word != 0) {
        uint256 bitIndex = LibBit.ffs(word);
        word &= word - 1;

        slot = uint16(i * SLOTS_PER_WORD + bitIndex);
        if (entityId == InventorySlot._getEntityId(owner, slot)) {
          return slot;
        }
      }
    }

    revert("Entity not found");
  }

  /// @dev Removes empty words from the end of the bitmap.
  function _pruneTrailingEmptyWords(EntityId owner) private {
    uint256 length = InventoryBitmap._length(owner);
    while (length != 0) {
      uint256 lastWord = InventoryBitmap._getItem(owner, length - 1);
      if (lastWord != 0) break;
      InventoryBitmap._popBitmap(owner);
      unchecked {
        --length;
      }
    }
  }

  /// @dev Ensures `wordIndex` exists, extending with zero words if needed.
  function _ensureWordExists(EntityId owner, uint256 wordIndex) private {
    uint256 length = InventoryBitmap._length(owner);
    while (wordIndex >= length) {
      InventoryBitmap._pushBitmap(owner, 0);
      unchecked {
        ++length;
      }
    }
  }
}
