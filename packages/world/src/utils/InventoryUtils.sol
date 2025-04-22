// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Inventory } from "../codegen/tables/Inventory.sol";
import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { InventoryTypeSlots } from "../codegen/tables/InventoryTypeSlots.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { ObjectAmount, ObjectType, ObjectTypes } from "../ObjectType.sol";

import { EntityId } from "../EntityId.sol";
import { NatureLib } from "../NatureLib.sol";
import { burnToolEnergy } from "../utils/EnergyUtils.sol";

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
  uint128 maxUseMass;
}

library InventoryUtils {
  function getToolData(EntityId owner, uint16 slot) public view returns (ToolData memory) {
    EntityId tool = InventorySlot._getEntityId(owner, slot);
    if (!tool.exists()) {
      return ToolData(owner, tool, ObjectTypes.Null, slot, 0, 0);
    }

    ObjectType toolType = EntityObjectType._get(tool);
    require(toolType.isTool(), "Inventory item is not a tool");

    uint128 maxMass = ObjectTypeMetadata._getMass(toolType);
    uint128 maxUsePerCall = maxMass / 10; // Limit to 10% of max mass per use

    return ToolData(owner, tool, toolType, slot, Mass._getMass(tool), maxUsePerCall);
  }

  function useTool(EntityId owner, Vec3 ownerCoord, uint16 slot, uint128 useMassMax)
    public
    returns (ObjectType toolType)
  {
    ToolData memory toolData = getToolData(owner, slot);

    uint128 massReduction = toolData.getMassReduction(useMassMax);
    applyMassReduction(toolData, ownerCoord, massReduction);
    return toolData.toolType;
  }

  function getMassReduction(ToolData memory toolData, uint128 useMassMax) internal pure returns (uint128) {
    uint128 massReduction = useMassMax > toolData.maxUseMass ? toolData.maxUseMass : useMassMax;
    if (toolData.massLeft <= massReduction) {
      return toolData.massLeft;
    }

    return massReduction;
  }

  function applyMassReduction(ToolData memory toolData, Vec3 ownerCoord, uint128 massReduction) public {
    if (!toolData.tool.exists()) {
      return;
    }

    require(toolData.massLeft > 0, "Tool is broken");

    if (toolData.massLeft <= massReduction) {
      // Destroy tool
      _recycleSlot(toolData.owner, toolData.slot);
      Mass._deleteRecord(toolData.tool);
      NatureLib.burnOres(toolData.toolType);
      burnToolEnergy(toolData.toolType, ownerCoord);
    } else {
      Mass._setMass(toolData.tool, toolData.massLeft - massReduction);
    }
  }

  function addEntityToSlot(EntityId owner, EntityId entityId, uint16 slot) internal {
    uint16 maxSlots = EntityObjectType._get(owner).getMaxInventorySlots();
    require(slot < maxSlots, "Invalid slot");
    require(entityId.exists(), "Entity must exist");

    ObjectType objectType = EntityObjectType._get(entityId);

    Inventory._push(owner, slot);
    InventorySlot._setEntityId(owner, slot, entityId);
    InventorySlot._setObjectType(owner, slot, objectType);
    // Entities always have amount 1
    InventorySlot._setAmount(owner, slot, 1);

    _addToTypeSlots(owner, objectType, slot);
  }

  function addEntity(EntityId owner, EntityId entityId) internal returns (uint16 slot) {
    slot = _useEmptySlot(owner);
    addEntityToSlot(owner, entityId, slot);
    return slot;
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
      if (currentAmount == stackable) {
        continue;
      }

      uint16 canAdd = stackable - currentAmount;
      uint16 toAdd = remaining < canAdd ? uint16(remaining) : canAdd;
      InventorySlot._setAmount(owner, slot, currentAmount + toAdd);
      remaining -= toAdd;
    }

    // If we still have objects to add, use empty slots
    while (remaining > 0) {
      uint16 slot = _useEmptySlot(owner);
      uint16 toAdd = remaining < stackable ? uint16(remaining) : stackable;

      Inventory._push(owner, slot);
      InventorySlot._setObjectType(owner, slot, objectType);
      InventorySlot._setAmount(owner, slot, toAdd);

      _addToTypeSlots(owner, objectType, slot);

      remaining -= toAdd;
    }
  }

  function addObjectToSlot(EntityId owner, ObjectType objectType, uint16 amount, uint16 slot) internal {
    require(amount > 0, "Amount must be greater than 0");
    uint16 stackable = objectType.getStackable();
    require(stackable > 0, "Object type cannot be added to inventory");
    uint16 maxSlots = EntityObjectType._get(owner).getMaxInventorySlots();
    require(slot < maxSlots, "Invalid slot");

    InventorySlotData memory slotData = InventorySlot._get(owner, slot);

    if (slotData.objectType.isNull()) {
      InventorySlot._setObjectType(owner, slot, objectType);
      InventorySlot._setOccupiedIndex(owner, slot, uint16(Inventory._length(owner)));
      Inventory._push(owner, slot);
      if (slotData.typeIndex < InventoryTypeSlots._length(owner, ObjectTypes.Null)) {
        uint16 nullSlot = InventoryTypeSlots._getItem(owner, ObjectTypes.Null, slotData.typeIndex);
        if (nullSlot == slot) {
          _removeFromTypeSlots(owner, ObjectTypes.Null, slot);
        }
      }
      _addToTypeSlots(owner, objectType, slot);
    } else {
      require(slotData.objectType == objectType, "Cannot store different object types in the same slot");
    }

    uint16 newAmount = slotData.amount + amount;
    require(newAmount <= stackable, "Object does not fit in slot");

    InventorySlot._setAmount(owner, slot, newAmount);
  }

  // IMPORTANT: this does not burn tool ores
  function removeEntity(EntityId owner, EntityId entity) public {
    uint16[] memory slots = Inventory._get(owner);
    for (uint256 i = 0; i < slots.length; i++) {
      if (entity == InventorySlot._getEntityId(owner, slots[i])) {
        _recycleSlot(owner, slots[i]);
        Mass._deleteRecord(entity);
        return;
      }
    }

    revert("Entity not found");
  }

  function removeObject(EntityId owner, ObjectType objectType, uint16 amount) public {
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
    SlotData[] memory tempToSlotData = new SlotData[](slotTransfers.length);

    uint256 tempIndex = 0;
    for (uint256 i = 0; i < slotTransfers.length; i++) {
      uint16 slotFrom = slotTransfers[i].slotFrom;
      uint16 slotTo = slotTransfers[i].slotTo;
      uint16 amount = slotTransfers[i].amount;

      require(amount > 0, "Amount must be greater than 0");

      InventorySlotData memory sourceSlot = InventorySlot._get(from, slotFrom);
      require(!sourceSlot.objectType.isNull(), "Empty slot");
      fromSlotData[i] = SlotData(sourceSlot.entityId, sourceSlot.objectType, sourceSlot.amount);

      InventorySlotData memory destSlot = InventorySlot._get(to, slotTo);

      // Handle slot swaps (transferring all to an existing slot with a different type)
      if (amount == sourceSlot.amount && sourceSlot.objectType != destSlot.objectType && !destSlot.objectType.isNull())
      {
        tempToSlotData[tempIndex++] = SlotData(destSlot.entityId, destSlot.objectType, destSlot.amount);

        _replaceSlot(from, slotFrom, sourceSlot.objectType, destSlot.entityId, destSlot.objectType, destSlot.amount);
        _replaceSlot(to, slotTo, destSlot.objectType, sourceSlot.entityId, sourceSlot.objectType, sourceSlot.amount);

        continue;
      }

      require(
        destSlot.objectType.isNull() || destSlot.objectType == sourceSlot.objectType,
        "Cannot store different object types in the same slot"
      );

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

    toSlotData = new SlotData[](tempIndex);
    for (uint256 i = 0; i < tempIndex; i++) {
      toSlotData[i] = tempToSlotData[i];
    }
  }

  function transferAll(EntityId from, EntityId to) public {
    require(from != to, "Cannot transfer all to self");

    // Occupied slots
    uint16[] memory slots = Inventory._get(from);

    // Inventory is empty
    if (slots.length == 0) return;

    // Group slots by object type to optimize transfers
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

    Inventory._deleteRecord(from);
  }

  function getSlotData(EntityId owner, SlotTransfer[] memory slotTransfers)
    internal
    view
    returns (EntityId[] memory entities, ObjectAmount[] memory objects)
  {
    // Count entities and objects
    uint256 entityCount = 0;
    uint256 objectCount = 0;

    for (uint256 i = 0; i < slotTransfers.length; i++) {
      SlotTransfer memory slotTransfer = slotTransfers[i];
      if (InventorySlot._getEntityId(owner, slotTransfer.slotFrom).exists()) {
        entityCount++;
      } else {
        objectCount++;
      }
    }

    entities = new EntityId[](entityCount);
    objects = new ObjectAmount[](objectCount);

    // Fill arrays
    uint256 entityIndex = 0;
    uint256 objectIndex = 0;

    for (uint256 i = 0; i < slotTransfers.length; i++) {
      SlotTransfer memory slotTransfer = slotTransfers[i];
      InventorySlotData memory slotData = InventorySlot._get(owner, slotTransfer.slotFrom);
      if (slotData.entityId.exists()) {
        entities[entityIndex++] = slotData.entityId;
      } else {
        objects[objectIndex++] = ObjectAmount(slotData.objectType, slotTransfer.amount);
      }
    }

    return (entities, objects);
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

  // Add a slot to type slots - O(1)
  function _addToTypeSlots(EntityId owner, ObjectType objectType, uint16 slot) private returns (uint16) {
    uint16 numTypeSlots = uint16(InventoryTypeSlots._length(owner, objectType));
    InventoryTypeSlots._push(owner, objectType, slot);
    InventorySlot._setTypeIndex(owner, slot, numTypeSlots);
    return numTypeSlots;
  }

  // Remove a slot from type slots - O(1)
  function _removeFromTypeSlots(EntityId owner, ObjectType objectType, uint16 slot) private {
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
  function _useEmptySlot(EntityId owner) private returns (uint16) {
    uint256 emptyLength = InventoryTypeSlots._length(owner, ObjectTypes.Null);
    uint16 occupiedIndex = uint16(Inventory._length(owner));

    // If there is already a null slot, use it
    if (emptyLength > 0) {
      uint16 slot = InventoryTypeSlots._getItem(owner, ObjectTypes.Null, emptyLength - 1);
      _removeFromTypeSlots(owner, ObjectTypes.Null, slot);
      InventorySlot._setOccupiedIndex(owner, slot, occupiedIndex);
      return slot;
    }

    uint16 maxSlots = EntityObjectType._get(owner).getMaxInventorySlots();
    require(occupiedIndex < maxSlots, "All slots used");
    InventorySlot._setOccupiedIndex(owner, occupiedIndex, occupiedIndex);
    return occupiedIndex;
  }

  // Marks a slot as empty - O(1)
  function _recycleSlot(EntityId owner, uint16 slot) private {
    ObjectType objectType = InventorySlot._getObjectType(owner, slot);

    // Move to null slots
    _removeFromTypeSlots(owner, objectType, slot);
    _addToTypeSlots(owner, ObjectTypes.Null, slot);

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

using InventoryUtils for ToolData global;
