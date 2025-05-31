// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { InventoryBitmap } from "../codegen/tables/InventoryBitmap.sol";
import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { LibBit } from "solady/utils/LibBit.sol";

import { burnToolEnergy } from "../utils/EnergyUtils.sol";
import { Math } from "../utils/Math.sol";

import { EntityId } from "../EntityId.sol";

import { ObjectAmount, ObjectType, ObjectTypes } from "../ObjectType.sol";
import { OreLib } from "../OreLib.sol";
import { Vec3 } from "../Vec3.sol";

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

struct ToolData {
  EntityId owner;
  EntityId tool;
  ObjectType toolType;
  uint16 slot;
  uint128 massLeft;
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
    require(nextSlot < maxSlots, "Inventory is full");
    return nextSlot;
  }

  /* Tool operations */

  function getToolData(EntityId owner, uint16 slot) internal view returns (ToolData memory) {
    EntityId tool = InventorySlot._getEntityId(owner, slot);
    if (!tool._exists()) {
      return ToolData(owner, tool, ObjectTypes.Null, slot, 0);
    }

    ObjectType toolType = tool._getObjectType();
    require(toolType.isTool(), "Inventory item is not a tool");

    return ToolData(owner, tool, toolType, slot, Mass._getMass(tool));
  }

  function use(ToolData memory toolData, uint128 useMassMax, uint128 multiplier) public returns (uint128) {
    (uint128 actionMassReduction, uint128 toolMassReduction) = getMassReduction(toolData, useMassMax, multiplier);
    reduceMass(toolData, toolMassReduction);
    return actionMassReduction;
  }

  function getMassReduction(ToolData memory toolData, uint128 massLeft, uint128 multiplier)
    internal
    view
    returns (uint128, uint128)
  {
    if (toolData.toolType.isNull()) {
      return (0, 0);
    }

    uint128 toolMass = ObjectPhysics._getMass(toolData.toolType);
    uint128 maxToolMassReduction = Math.min(toolMass / 10, toolData.massLeft);
    uint128 massReduction = Math.min(maxToolMassReduction * multiplier, massLeft);
    uint128 toolMassReduction = massReduction / multiplier;

    return (massReduction, toolMassReduction);
  }

  function reduceMass(ToolData memory toolData, uint128 massReduction) internal {
    if (!toolData.tool._exists()) {
      return;
    }

    require(toolData.massLeft > 0, "Tool is broken");

    if (toolData.massLeft <= massReduction) {
      removeEntityFromSlot(toolData.owner, toolData.slot);
      OreLib.burnOres(toolData.toolType);
      burnToolEnergy(toolData.toolType, toolData.owner._getPosition());
    } else {
      Mass._setMass(toolData.tool, toolData.massLeft - massReduction);
    }
  }

  /* Inventory operations */

  function addEntity(EntityId owner, EntityId entityId) internal returns (uint16 slot) {
    ObjectType objectType = entityId._getObjectType();
    require(!objectType.isNull(), "Entity must exist");

    slot = findEmptySlot(owner);
    setBit(owner, slot);
    InventorySlot._set(owner, slot, entityId, objectType, 1);
  }

  function addEntityToSlot(EntityId owner, EntityId entityId, uint16 slot) internal {
    ObjectType objectType = entityId._getObjectType();
    require(!objectType.isNull(), "Entity must exist");

    // Check slot is within bounds for this entity type
    uint16 maxSlots = owner._getObjectType().getMaxInventorySlots();
    require(slot < maxSlots, "Slot exceeds entity's max inventory");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);
    require(slotData.objectType.isNull(), "Slot must be empty");

    setBit(owner, slot);
    InventorySlot._set(owner, slot, entityId, objectType, 1);
  }

  function addObject(EntityId owner, ObjectType objectType, uint128 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    uint16 stackable = objectType.getStackable();
    require(stackable > 0, "Object type cannot be added to inventory");

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
    require(amount > 0, "Cannot add 0 objects to slot");
    uint16 stackable = objectType.getStackable();
    require(stackable > 0, "Object type cannot be added to inventory");

    // Check slot is within bounds for this entity type
    uint16 maxSlots = owner._getObjectType().getMaxInventorySlots();
    require(maxSlots > 0, "Invalid slot");
    require(slot < maxSlots, "Slot exceeds entity's max inventory");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);

    if (slotData.objectType.isNull()) {
      setBit(owner, slot);
      InventorySlot._set(owner, slot, EntityId.wrap(0), objectType, amount);
    } else {
      require(slotData.objectType == objectType, "Cannot store different object types in the same slot");
      uint16 newAmount = slotData.amount + amount;
      require(newAmount <= stackable, "Object does not fit in slot");
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
    require(entity._exists(), "Not an entity");

    clearBit(owner, slot);
    InventorySlot._deleteRecord(owner, slot);
    // Don't delete mass!
    return entity;
  }

  function removeObject(EntityId owner, ObjectType objectType, uint16 amount) internal {
    require(amount > 0, "Amount must be greater than 0");
    require(!objectType.isNull(), "Empty slot");

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

    require(remaining == 0, "Not enough objects");
  }

  function removeObjectFromSlot(EntityId owner, uint16 slot, uint16 amount) internal returns (ObjectType) {
    require(amount > 0, "Amount must be greater than 0");

    InventorySlotData memory data = InventorySlot._get(owner, slot);
    require(!data.objectType.isNull(), "Empty slot");
    require(data.amount >= amount, "Not enough objects in slot");

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

      require(amount > 0, "Amount must be greater than 0");

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      require(!sourceSlot.objectType.isNull(), "Empty slot");
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

      require(destSlot.objectType.isNull() || isSameType, "Cannot store different object types in the same slot");

      // If transferring within the same inventory, create the corresponding withdrawal
      if (from == to) {
        toSlotData[toSlotDataLength++] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);
      }

      if (sourceSlot.entityId._exists()) {
        // Entities are unique and always have amount=1
        require(amount == 1, "Entity transfer amount should be 1");
        // Move entity without deleting mass
        moveEntityFromSlot(from, slotFrom);
        addEntityToSlot(to, sourceSlot.entityId, slotTo);
      } else {
        // Regular objects can be transferred in partial amounts
        require(amount <= sourceSlot.amount, "Not enough objects in slot");
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
    require(from != to, "Cannot transfer amounts to self");

    fromSlotData = new SlotData[](slotAmounts.length);

    for (uint256 i = 0; i < slotAmounts.length; i++) {
      uint16 slotFrom = slotAmounts[i].slot;
      uint16 amount = slotAmounts[i].amount;

      require(amount > 0, "Amount must be greater than 0");

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      require(!sourceSlot.objectType.isNull(), "Empty slot");
      fromSlotData[i] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);

      if (sourceSlot.entityId._exists()) {
        // Entities are unique and always have amount=1
        require(amount == 1, "Entity transfer amount should be 1");
        moveEntityFromSlot(from, slotFrom);
        addEntity(to, sourceSlot.entityId);
      } else {
        // Regular objects can be transferred in partial amounts
        require(amount <= sourceSlot.amount, "Not enough objects in slot");
        removeObjectFromSlot(from, slotFrom, amount);
        addObject(to, sourceSlot.objectType, amount);
      }
    }
  }

  function transferAll(EntityId from, EntityId to) public {
    require(from != to, "Cannot transfer all to self");

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

using InventoryUtils for ToolData global;
