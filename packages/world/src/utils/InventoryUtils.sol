// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Inventory } from "../codegen/tables/Inventory.sol";

import { InventoryTypeSlots } from "../codegen/tables/InventoryTypeSlots.sol";

import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";

import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { ObjectTypeId } from "../ObjectTypeId.sol";

import { ObjectAmount, ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { getUniqueEntity } from "../Utils.sol";

import { EntityId } from "../EntityId.sol";

using ObjectTypeLib for ObjectTypeId;

struct SlotTransfer {
  uint16 slotFrom;
  uint16 slotTo;
  uint16 amount;
}

library InventoryUtils {
  function useTool(EntityId owner, uint16 slot, uint128 useMassMax)
    public
    returns (uint128 massUsed, ObjectTypeId toolType)
  {
    EntityId tool = InventorySlot._getEntityId(owner, slot);
    if (!tool.exists()) {
      return (0, ObjectTypes.Null);
    }

    toolType = ObjectType._get(tool);
    require(toolType.isTool(), "Inventory item is not a tool");
    uint128 toolMassLeft = Mass._getMass(tool);
    require(toolMassLeft > 0, "Tool is already broken");

    uint128 maxMass = ObjectTypeMetadata._getMass(toolType);
    uint128 maxUsePerCall = maxMass / 10; // Limit to 10% of max mass per use
    massUsed = useMassMax > maxUsePerCall ? maxUsePerCall : useMassMax;

    if (toolMassLeft <= massUsed) {
      massUsed = toolMassLeft;
      // Destroy equipped item
      recycleSlot(owner, slot);
      Mass._deleteRecord(tool);
      toolType.burnOres();

      // TODO: return energy to local pool
    } else {
      Mass._setMass(tool, toolMassLeft - massUsed);
    }
  }

  function addEntity(EntityId owner, EntityId entityId, uint16 slot) internal {
    ObjectTypeId objectType = ObjectType._get(entityId);

    InventorySlot._setEntityId(owner, slot, entityId);
    InventorySlot._setObjectType(owner, slot, objectType);
    InventorySlot._setAmount(owner, slot, 1);

    addToTypeSlots(owner, objectType, slot);
  }

  function addEntity(EntityId owner, EntityId entityId) internal {
    uint16 slot = useEmptySlot(owner);
    addEntity(owner, entityId, slot);
  }

  function addObjectToSlot(EntityId owner, ObjectTypeId objectType, uint16 amount, uint16 slot) public {
    require(amount > 0, "Amount must be greater than 0");
    uint16 stackable = ObjectTypeMetadata._getStackable(objectType);
    require(stackable > 0, "Object type cannot be added to inventory");
    uint16 maxSlots = ObjectTypeMetadata._getMaxInventorySlots(ObjectType._get(owner));
    require(slot < maxSlots, "All slots used");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);
    uint16 newAmount = slotData.amount + amount;
    require(newAmount <= stackable, "Object does not fit in slot");

    if (slotData.objectType.isNull()) {
      InventorySlot._setObjectType(owner, slot, objectType);
      InventorySlot._setOccupiedIndex(owner, slot, uint16(Inventory._length(owner)));
      Inventory._push(owner, slot);
      // TODO: we should only do this if this slot was already created
      removeFromTypeSlots(owner, ObjectTypes.Null, slot);
      addToTypeSlots(owner, objectType, slot);
    } else {
      require(slotData.objectType == objectType, "Cannot store different object types in the same slot");
    }

    InventorySlot._setAmount(owner, slot, newAmount);
  }

  function addObject(EntityId owner, ObjectTypeId objectType, uint16 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    uint16 stackable = ObjectTypeMetadata._getStackable(objectType);
    require(stackable > 0, "Object type cannot be added to inventory");

    uint16 remaining = amount;

    // First, find and fill existing slots for this object type
    uint256 numTypeSlots = InventoryTypeSlots._length(owner, objectType);
    for (uint256 i = 0; i < numTypeSlots && remaining > 0; i++) {
      uint16 slot = InventoryTypeSlots._getItem(owner, objectType, i);
      uint16 currentAmount = InventorySlot._getAmount(owner, slot);

      // Skip slots that are already full
      if (currentAmount == stackable) {
        continue;
      }

      uint16 canAdd = stackable - currentAmount;
      uint16 toAdd = remaining < canAdd ? remaining : canAdd;
      InventorySlot._setAmount(owner, slot, currentAmount + toAdd);
      remaining -= toAdd;
    }

    // If we still have objects to add, try to use empty slots
    while (remaining > 0) {
      uint16 slot = useEmptySlot(owner);
      uint16 toAdd = remaining < stackable ? remaining : stackable;

      InventorySlot._setObjectType(owner, slot, objectType);
      InventorySlot._setAmount(owner, slot, toAdd);

      addToTypeSlots(owner, objectType, slot);

      remaining -= toAdd;
    }
  }

  function removeObject(EntityId owner, ObjectTypeId objectType, uint16 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    require(!objectType.isNull(), "Empty slot");

    // Check if there are any slots with this object type
    uint256 numTypeSlots = InventoryTypeSlots._length(owner, objectType);
    require(numTypeSlots > 0, "Not enough objects of this type in inventory");

    uint16 remaining = amount;

    // Iterate from end to minimize array shifts
    for (uint256 i = numTypeSlots; i > 0 && remaining > 0; i--) {
      uint16 slot = InventoryTypeSlots._getItem(owner, objectType, i - 1);
      uint16 currentAmount = InventorySlot._getAmount(owner, slot);

      if (currentAmount <= remaining) {
        // Remove entire slot contents
        remaining -= currentAmount;
        recycleSlot(owner, slot);
      } else {
        // Remove partial amount
        uint16 newAmount = currentAmount - remaining;
        InventorySlot._setAmount(owner, slot, newAmount);
        remaining = 0;
      }
    }

    require(remaining == 0, "Not enough objects of this type in inventory");
  }

  function removeObjectFromSlot(EntityId owner, ObjectTypeId objectType, uint16 amount, uint16 slot) public {
    require(amount > 0, "Amount must be greater than 0");
    require(!objectType.isNull(), "Empty slot");

    ObjectTypeId slotObjectType = InventorySlot._getObjectType(owner, slot);
    require(slotObjectType == objectType, "Slot does not contain the specified object type");

    uint16 currentAmount = InventorySlot._getAmount(owner, slot);
    require(currentAmount >= amount, "Not enough objects in slot");

    if (currentAmount == amount) {
      // Remove entire slot contents
      recycleSlot(owner, slot);
    } else {
      // Remove partial amount
      InventorySlot._setAmount(owner, slot, currentAmount - amount);
    }
  }

  function removeAny(EntityId owner, ObjectTypeId objectType, uint16 amount) public {
    require(amount > 0, "Amount must be greater than 0");

    uint16 remaining = amount;

    ObjectTypeId[] memory objectTypes = objectType.getObjectTypes();

    for (uint256 i = 0; i < objectTypes.length && remaining > 0; i++) {
      uint256 numSlots = InventoryTypeSlots._length(owner, objectTypes[i]);

      uint16 available;
      for (uint16 j = 0; j < numSlots && remaining > available; j++) {
        uint16 slot = InventoryTypeSlots._getItem(owner, objectTypes[i], j);
        available += InventorySlot._getAmount(owner, slot);
      }

      if (available > 0) {
        available = available >= remaining ? remaining : available;
        removeObject(owner, objectTypes[i], available);
        remaining -= available;
      }
    }

    require(remaining == 0, "Not enough objects of this type in inventory");
  }

  function transfer(EntityId from, EntityId to, SlotTransfer[] memory slotTransfers) public {
    // Transfer tools
    for (uint256 i = 0; i < slotTransfers.length; i++) {
      uint16 slotFrom = slotTransfers[i].slotFrom;
      uint16 slotTo = slotTransfers[i].slotTo;
      uint16 amount = slotTransfers[i].amount;

      require(amount > 0, "Amount must be greater than 0");

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      require(!sourceSlot.objectType.isNull(), "Empty slot");

      InventorySlotData memory destSlot = InventorySlot._get(to, slotTo);
      require(
        destSlot.objectType.isNull() || destSlot.objectType == sourceSlot.objectType,
        "Cannot store different object types in the same slot"
      );

      if (sourceSlot.entityId.exists()) {
        require(amount == sourceSlot.amount, "Invalid amount for entity slot");
        EntityId entityId = sourceSlot.entityId;
        recycleSlot(from, slotFrom);
        addEntity(to, entityId, slotTo);
      } else {
        require(amount <= sourceSlot.amount, "Not enough objects in slot");
        removeObjectFromSlot(from, sourceSlot.objectType, amount, slotFrom);
        addObjectToSlot(to, sourceSlot.objectType, amount, slotTo);
      }
    }
  }

  function transferAll(EntityId from, EntityId to) public {
    require(from != to, "Cannot transfer all to self");

    // Occupied slots
    uint16[] memory slots = Inventory._get(from);

    // Inventory is empty
    if (slots.length == 0) return;

    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot._get(from, slots[i]);

      if (slotData.entityId.exists()) {
        // No need to remove from owner as we will clean the whole inventory later
        addEntity(to, slotData.entityId);
      } else {
        // Transfer regular objects
        addObject(to, slotData.objectType, slotData.amount);
      }

      InventorySlot._deleteRecord(from, slots[i]);

      // We only need to delete the record once per type, so we arbitrarily select the first slot
      if (slotData.typeIndex == 0) {
        InventoryTypeSlots._deleteRecord(from, slotData.objectType);
      }
    }

    // Clean up inventory structure
    Inventory._deleteRecord(from);
  }

  // Add a slot to type slots - O(1)
  function addToTypeSlots(EntityId owner, ObjectTypeId objectType, uint16 slot) private {
    uint256 numTypeSlots = InventoryTypeSlots._length(owner, objectType);
    InventoryTypeSlots._push(owner, objectType, slot);
    InventorySlot._setTypeIndex(owner, slot, uint16(numTypeSlots));
  }

  // Remove a slot from type slots - O(1)
  function removeFromTypeSlots(EntityId owner, ObjectTypeId objectType, uint16 slot) private {
    uint16 typeIndex = InventorySlot._getTypeIndex(owner, slot);
    uint256 numTypeSlots = InventoryTypeSlots._length(owner, objectType);

    // If not the last element, swap with the last element
    if (typeIndex < numTypeSlots - 1) {
      uint16 lastSlot = InventoryTypeSlots._getItem(owner, objectType, numTypeSlots - 1);
      InventoryTypeSlots._update(owner, objectType, typeIndex, lastSlot);
      InventorySlot._setTypeIndex(owner, lastSlot, typeIndex);
    }

    // Pop the last element
    InventoryTypeSlots._pop(owner, objectType);
  }

  // Gets a slot to use - either reuses an empty slot or creates a new one - O(1)
  function useEmptySlot(EntityId owner) private returns (uint16) {
    uint256 emptyLength = InventoryTypeSlots._length(owner, ObjectTypes.Null);
    uint16 occupiedIndex = uint16(Inventory._length(owner));

    // If there is already a null slot, use it
    if (emptyLength > 0) {
      uint16 slot = InventoryTypeSlots._getItem(owner, ObjectTypes.Null, emptyLength - 1);
      removeFromTypeSlots(owner, ObjectTypes.Null, slot);
      Inventory._push(owner, slot);
      InventorySlot._setOccupiedIndex(owner, slot, occupiedIndex);
      return slot;
    }

    // Otherwise try to add a new slot
    uint16 maxSlots = ObjectTypeMetadata._getMaxInventorySlots(ObjectType._get(owner));
    require(occupiedIndex < maxSlots, "All slots used");
    Inventory._push(owner, occupiedIndex);
    InventorySlot._setOccupiedIndex(owner, occupiedIndex, occupiedIndex);
    return occupiedIndex;
  }

  // Marks a slot as empty - O(1)
  function recycleSlot(EntityId owner, uint16 slot) private {
    ObjectTypeId objectType = InventorySlot._getObjectType(owner, slot);

    // Move to null slots
    removeFromTypeSlots(owner, objectType, slot);
    addToTypeSlots(owner, ObjectTypes.Null, slot);

    // Swap and pop occupied slots to remove from active inventory
    uint16 occupiedIndex = InventorySlot._getOccupiedIndex(owner, slot);
    uint256 numOccupiedSlots = Inventory._length(owner);

    // If not the last element in occupied slots, swap with the last element
    if (occupiedIndex < numOccupiedSlots - 1) {
      uint16 lastSlot = Inventory._getItem(owner, numOccupiedSlots - 1);
      Inventory._update(owner, occupiedIndex, lastSlot);
      InventorySlot._setOccupiedIndex(owner, lastSlot, occupiedIndex);
    }

    InventorySlot._deleteRecord(owner, slot);
    Inventory._pop(owner);
  }
}
