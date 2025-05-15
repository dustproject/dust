// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Inventory } from "../codegen/tables/Inventory.sol";
import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";

import { InventoryTypeSlots } from "../codegen/tables/InventoryTypeSlots.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { burnToolEnergy } from "../utils/EnergyUtils.sol";
import { Math } from "../utils/Math.sol";

import { EntityId } from "../EntityId.sol";
import { NatureLib } from "../NatureLib.sol";
import { ObjectAmount, ObjectType, ObjectTypes } from "../ObjectType.sol";
import { Vec3 } from "../Vec3.sol";

struct SlotTransfer {
  uint16 slotFrom;
  uint16 slotTo;
  uint16 amount; // For entities, this should always be 1
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
  function getToolData(EntityId owner, uint16 slot) internal view returns (ToolData memory) {
    EntityId tool = InventorySlot._getEntityId(owner, slot);
    if (!tool.exists()) {
      return ToolData(owner, tool, ObjectTypes.Null, slot, 0);
    }

    ObjectType toolType = tool.getObjectType();
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

    // Limit to 10% of max mass per use
    uint128 maxToolMassReduction = Math.min(toolMass / 10, toolData.massLeft);

    uint128 massReduction = Math.min(maxToolMassReduction * multiplier, massLeft);

    // Reverse operation to get the proportional tool mass reduction
    uint128 toolMassReduction = massReduction / multiplier;

    return (massReduction, toolMassReduction);
  }

  function reduceMass(ToolData memory toolData, uint128 massReduction) internal {
    if (!toolData.tool.exists()) {
      return;
    }

    require(toolData.massLeft > 0, "Tool is broken");

    if (toolData.massLeft <= massReduction) {
      // Destroy tool
      removeEntityFromSlot(toolData.owner, toolData.slot);
      NatureLib.burnOres(toolData.toolType);
      burnToolEnergy(toolData.toolType, toolData.owner.getPosition());
    } else {
      Mass._setMass(toolData.tool, toolData.massLeft - massReduction);
    }
  }

  function addEntity(EntityId owner, EntityId entityId) internal returns (uint16 slot) {
    ObjectType objectType = entityId.getObjectType();
    require(!objectType.isNull(), "Entity must exist");

    slot = _useEmptySlot(owner);
    InventorySlot._setEntityId(owner, slot, entityId);
    InventorySlot._setObjectType(owner, slot, objectType);
    InventorySlot._setAmount(owner, slot, 1);

    _addToTypeSlots(owner, objectType, slot);
  }

  function addEntityToSlot(EntityId owner, EntityId entityId, uint16 slot) internal {
    ObjectType objectType = entityId.getObjectType();
    require(!objectType.isNull(), "Entity must exist");

    _useEmptySlot(owner, slot);

    // Entities always have amount 1
    InventorySlot._setAmount(owner, slot, 1);
    InventorySlot._setEntityId(owner, slot, entityId);
    InventorySlot._setObjectType(owner, slot, objectType);

    _addToTypeSlots(owner, objectType, slot);
  }

  function addObject(EntityId owner, ObjectType objectType, uint128 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    uint16 stackable = objectType.getStackable();
    require(stackable > 0, "Object type cannot be added to inventory");

    uint128 remaining = amount;

    // First, find and fill existing slots for this object type
    uint256 numTypeSlots = InventoryTypeSlots._length(owner, objectType);
    for (uint256 i = 0; i < numTypeSlots && remaining > 0; i++) {
      uint16 slot = InventoryTypeSlots._getItem(owner, objectType, i);
      uint16 currentAmount = InventorySlot._getAmount(owner, slot);

      // Skip slots that are already full
      if (currentAmount >= stackable) continue;

      uint16 canAdd = stackable - currentAmount;
      uint16 toAdd = remaining < canAdd ? uint16(remaining) : canAdd;
      InventorySlot._setAmount(owner, slot, currentAmount + toAdd);
      remaining -= toAdd;
    }

    // If we still have objects to add, use empty slots
    while (remaining > 0) {
      uint16 slot = _useEmptySlot(owner);
      uint16 toAdd = remaining < stackable ? uint16(remaining) : stackable;

      InventorySlot._setObjectType(owner, slot, objectType);
      InventorySlot._setAmount(owner, slot, toAdd);

      _addToTypeSlots(owner, objectType, slot);

      remaining -= toAdd;
    }
  }

  function addObjectToSlot(EntityId owner, ObjectType objectType, uint16 amount, uint16 slot) internal {
    require(amount > 0, "Cannot add 0 objects to slot");
    uint16 stackable = objectType.getStackable();
    require(stackable > 0, "Object type cannot be added to inventory");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);

    if (slotData.objectType.isNull()) {
      _useEmptySlot(owner, slot);
      InventorySlot._setObjectType(owner, slot, objectType);
      _addToTypeSlots(owner, objectType, slot);
    } else {
      require(slotData.objectType == objectType, "Cannot store different object types in the same slot");
    }

    uint16 newAmount = slotData.amount + amount;
    require(newAmount <= stackable, "Object does not fit in slot");

    InventorySlot._setAmount(owner, slot, newAmount);
  }

  // IMPORTANT: this does not burn tool ores
  function removeEntity(EntityId owner, EntityId entity) internal {
    uint16[] memory slots = Inventory._getOccupiedSlots(owner);
    for (uint256 i = 0; i < slots.length; i++) {
      if (entity == InventorySlot._getEntityId(owner, slots[i])) {
        _recycleSlot(owner, slots[i]);
        Mass._deleteRecord(entity);
        return;
      }
    }

    revert("Entity not found");
  }

  function removeEntityFromSlot(EntityId owner, uint16 slot) internal {
    EntityId entity = InventorySlot._getEntityId(owner, slot);
    require(entity.exists(), "Not an entity");

    _recycleSlot(owner, slot);
    Mass._deleteRecord(entity);
  }

  function removeObject(EntityId owner, ObjectType objectType, uint16 amount) internal {
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
        _recycleSlot(owner, slot);
      } else {
        // Remove partial amount
        uint16 newAmount = currentAmount - remaining;
        InventorySlot._setAmount(owner, slot, newAmount);
        remaining = 0;
      }
    }

    require(remaining == 0, "Not enough objects of this type in inventory");
  }

  function removeObjectFromSlot(EntityId owner, uint16 slot, uint16 amount) internal returns (ObjectType) {
    require(amount > 0, "Amount must be greater than 0");

    ObjectType slotObjectType = InventorySlot._getObjectType(owner, slot);
    require(!slotObjectType.isNull(), "Empty slot");

    uint16 currentAmount = InventorySlot._getAmount(owner, slot);
    require(currentAmount >= amount, "Not enough objects in slot");

    if (currentAmount == amount) {
      // Remove entire slot contents
      _recycleSlot(owner, slot);
    } else {
      // Remove partial amount
      InventorySlot._setAmount(owner, slot, currentAmount - amount);
    }

    return slotObjectType;
  }

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

        _replaceSlot(from, slotFrom, sourceSlot.objectType, destSlot.entityId, destSlot.objectType, destSlot.amount);
        _replaceSlot(to, slotTo, destSlot.objectType, sourceSlot.entityId, sourceSlot.objectType, sourceSlot.amount);

        continue;
      }

      require(destSlot.objectType.isNull() || isSameType, "Cannot store different object types in the same slot");

      // If transferring within the same inventory, create the corresponding withdrawal
      if (from == to) {
        toSlotData[toSlotDataLength++] = SlotData(sourceSlot.entityId, sourceSlot.objectType, amount);
      }

      if (sourceSlot.entityId.exists()) {
        // Entities are unique and always have amount=1
        require(amount == 1, "Entity transfer amount should be 1");
        EntityId entityId = sourceSlot.entityId;
        _recycleSlot(from, slotFrom);
        addEntityToSlot(to, entityId, slotTo);
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

  function transferAll(EntityId from, EntityId to) public {
    require(from != to, "Cannot transfer all to self");

    // Occupied slots
    uint16[] memory slots = Inventory._getOccupiedSlots(from);

    // Inventory is empty
    if (slots.length == 0) return;

    // Iterate through all from's slots
    for (uint256 i = 0; i < slots.length; i++) {
      InventorySlotData memory slotData = InventorySlot._get(from, slots[i]);

      if (slotData.entityId.exists()) {
        // Handle entities (always amount=1)
        addEntity(to, slotData.entityId);
      } else {
        // Handle regular objects (stackable)
        addObject(to, slotData.objectType, slotData.amount);
      }

      InventorySlot._deleteRecord(from, slots[i]);

      // We only need to delete the record once per type, so we use the first slot with typeIndex 0
      if (slotData.typeIndex == 0) {
        InventoryTypeSlots._deleteRecord(from, slotData.objectType);
      }
    }

    if (InventoryTypeSlots._length(from, ObjectTypes.Null) > 0) {
      InventoryTypeSlots._deleteRecord(from, ObjectTypes.Null);
    }

    Inventory._deleteRecord(from);
  }

  function _addToOccupiedSlots(EntityId owner, uint16 slot) internal {
    InventorySlot._setOccupiedIndex(owner, slot, uint16(Inventory._lengthOccupiedSlots(owner)));
    Inventory._pushOccupiedSlots(owner, slot);
  }

  function _removeFromOccupiedSlots(EntityId owner, uint16 slot) private {
    uint16 occupiedIndex = InventorySlot._getOccupiedIndex(owner, slot);
    uint256 last = Inventory._lengthOccupiedSlots(owner) - 1;
    if (occupiedIndex < last) {
      uint16 moved = Inventory._getItemOccupiedSlots(owner, last);
      Inventory._updateOccupiedSlots(owner, occupiedIndex, moved);
      InventorySlot._setOccupiedIndex(owner, moved, occupiedIndex);
    }
    Inventory._popOccupiedSlots(owner);
  }

  // Add a slot to type slots - O(1)
  function _addToTypeSlots(EntityId owner, ObjectType objectType, uint16 slot) private {
    InventorySlot._setTypeIndex(owner, slot, uint16(InventoryTypeSlots._length(owner, objectType)));
    InventoryTypeSlots._push(owner, objectType, slot);
  }

  // Remove a slot from type slots - O(1)
  function _removeFromTypeSlots(EntityId owner, ObjectType objectType, uint16 slot) private {
    uint16 typeIndex = InventorySlot._getTypeIndex(owner, slot);
    uint256 last = InventoryTypeSlots._length(owner, objectType) - 1;

    // If not the last element, swap with the last element
    if (typeIndex < last) {
      uint16 lastSlot = InventoryTypeSlots._getItem(owner, objectType, last);
      InventoryTypeSlots._update(owner, objectType, typeIndex, lastSlot);
      InventorySlot._setTypeIndex(owner, lastSlot, typeIndex);
    }
    InventoryTypeSlots._pop(owner, objectType);
  }

  function _replaceSlot(
    EntityId owner,
    uint16 slot,
    ObjectType objectType,
    EntityId entityId,
    ObjectType newObjectType,
    uint16 amount
  ) internal {
    _removeFromTypeSlots(owner, objectType, slot);
    _addToTypeSlots(owner, newObjectType, slot);
    InventorySlot._setEntityId(owner, slot, entityId);
    InventorySlot._setObjectType(owner, slot, newObjectType);
    InventorySlot._setAmount(owner, slot, amount);
  }

  // Gets a slot to use - either reuses an empty slot or creates a new one - O(1)
  function _useEmptySlot(EntityId owner) private returns (uint16 slot) {
    uint256 nullLength = InventoryTypeSlots._length(owner, ObjectTypes.Null);

    // If there is already a null slot, use it
    if (nullLength > 0) {
      slot = InventoryTypeSlots._getItem(owner, ObjectTypes.Null, nullLength - 1);
      _removeFromTypeSlots(owner, ObjectTypes.Null, slot);
    } else {
      slot = Inventory._getNextSlot(owner);
      uint16 maxSlots = owner.getObjectType().getMaxInventorySlots();
      require(slot < maxSlots, "Inventory is full");
      Inventory._setNextSlot(owner, slot + 1);
    }

    _addToOccupiedSlots(owner, slot);
  }

  function _useEmptySlot(EntityId owner, uint16 slot) private {
    uint16 maxSlots = owner.getObjectType().getMaxInventorySlots();
    require(slot < maxSlots, "Invalid slot");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);
    require(slotData.objectType.isNull(), "Slot must be empty");

    _addToOccupiedSlots(owner, slot);

    uint16 nextSlot = Inventory._getNextSlot(owner);

    // if slot < nextSlot, this slot is already tracked
    if (slot < nextSlot) {
      _removeFromTypeSlots(owner, ObjectTypes.Null, slot);
      return;
    }

    // Fill gaps in the null type slots
    for (uint16 i = nextSlot; i < slot; i++) {
      _addToTypeSlots(owner, ObjectTypes.Null, i);
    }

    Inventory._setNextSlot(owner, slot + 1);
  }

  // Marks a slot as empty - O(1)
  function _recycleSlot(EntityId owner, uint16 slot) private {
    ObjectType objectType = InventorySlot._getObjectType(owner, slot);

    _removeFromOccupiedSlots(owner, slot);
    _removeFromTypeSlots(owner, objectType, slot);
    InventorySlot._deleteRecord(owner, slot);
    // Add to null type slots AFTER deleteRecord, so it is not overwritten
    _addToTypeSlots(owner, ObjectTypes.Null, slot);
  }
}

using InventoryUtils for ToolData global;
