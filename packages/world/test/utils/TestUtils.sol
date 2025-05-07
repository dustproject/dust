// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Vm } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../../src/EntityId.sol";
import { Vec3 } from "../../src/Vec3.sol";

import { EnergyData } from "../../src/codegen/tables/Energy.sol";

import { EntityObjectType } from "../../src/codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../../src/codegen/tables/InventoryTypeSlots.sol";

import { ObjectType } from "../../src/ObjectType.sol";

import {
  updateMachineEnergy as _updateMachineEnergy,
  updatePlayerEnergy as _updatePlayerEnergy
} from "../../src/utils/EnergyUtils.sol";

import { createEntity } from "../../src/utils/EntityUtils.sol";
import { ForceFieldUtils } from "../../src/utils/ForceFieldUtils.sol";
import { InventoryUtils, SlotTransfer } from "../../src/utils/InventoryUtils.sol";

Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

library TestUtils {
  /// @dev Allows calling test utils in the context of world
  function asWorld(bytes32 libAddressSlot) internal {
    address world = WorldContextConsumerLib._world();
    if (address(this) != world) {
      // Next delegatecall will be from world
      vm.prank(world, true);
      (bool success, bytes memory data) = _getLibAddress(libAddressSlot).delegatecall(msg.data);
      /// @solidity memory-safe-assembly
      assembly {
        let dataOffset := add(data, 0x20)
        let dataSize := mload(data)
        switch success
        case 1 { return(dataOffset, dataSize) }
        default { revert(dataOffset, dataSize) }
      }
    }
  }

  function _getLibAddress(bytes32 libAddressSlot) private view returns (address) {
    return address(bytes20(vm.load(address(this), libAddressSlot)));
  }

  function init(bytes32 libAddressSlot, address libAddress) internal {
    vm.store(address(this), libAddressSlot, bytes32(bytes20(libAddress)));
  }
}

library TestInventoryUtils {
  bytes32 constant LIB_ADDRESS_SLOT = keccak256("TestUtils.TestInventoryUtils");

  modifier asWorld() {
    TestUtils.asWorld(LIB_ADDRESS_SLOT);
    _;
  }

  // Hack to be able to access the library address until we figure out why mud doesn't allow it
  function init(address libAddress) public {
    TestUtils.init(LIB_ADDRESS_SLOT, libAddress);
  }

  function addObject(EntityId ownerEntityId, ObjectType objectType, uint16 numObjectsToAdd) public asWorld {
    InventoryUtils.addObject(ownerEntityId, objectType, numObjectsToAdd);
  }

  function addObjectToSlot(EntityId ownerEntityId, ObjectType objectType, uint16 numObjectsToAdd, uint16 slot)
    public
    asWorld
  {
    InventoryUtils.addObjectToSlot(ownerEntityId, objectType, numObjectsToAdd, slot);
  }

  function addEntity(EntityId ownerEntityId, ObjectType toolObjectType) public asWorld returns (EntityId) {
    EntityId entityId = createEntity(toolObjectType);
    InventoryUtils.addEntity(ownerEntityId, entityId);
    return entityId;
  }

  function removeFromInventory(EntityId ownerEntityId, ObjectType objectType, uint16 numObjectsToRemove) public asWorld {
    InventoryUtils.removeObject(ownerEntityId, objectType, numObjectsToRemove);
  }

  function removeObject(EntityId ownerEntityId, ObjectType objectType, uint16 numObjectsToRemove) public asWorld {
    InventoryUtils.removeObject(ownerEntityId, objectType, numObjectsToRemove);
  }

  function removeEntityFromSlot(EntityId ownerEntityId, uint16 slot) public asWorld {
    InventoryUtils.removeEntityFromSlot(ownerEntityId, slot);
  }

  function transferAll(EntityId fromEntityId, EntityId toEntityId) public asWorld {
    InventoryUtils.transferAll(fromEntityId, toEntityId);
  }

  function transfer(EntityId fromEntityId, EntityId toEntityId, SlotTransfer[] memory transfers) public asWorld {
    InventoryUtils.transfer(fromEntityId, toEntityId, transfers);
  }

  function removeObjectFromSlot(EntityId ownerEntityId, uint16 slot, uint16 numObjectsToRemove) public asWorld {
    InventoryUtils.removeObjectFromSlot(ownerEntityId, slot, numObjectsToRemove);
  }

  function useTool(EntityId owner, uint16 slot, uint128 useMassMax) public asWorld {
    InventoryUtils.useTool(owner, slot, useMassMax);
  }

  function getEntitySlot(EntityId owner, EntityId entityId) public asWorld returns (uint16) {
    ObjectType objectType = EntityObjectType._get(entityId);
    uint16[] memory slots = InventoryTypeSlots._get(owner, objectType);
    for (uint256 i = 0; i < slots.length; i++) {
      EntityId slotEntityId = InventorySlot._getEntityId(owner, slots[i]);

      if (slotEntityId == entityId) {
        return slots[i];
      }
    }
    revert("Entity not found in owner's inventory");
  }
}

library TestEnergyUtils {
  bytes32 constant LIB_ADDRESS_SLOT = keccak256("TestUtils.TestEnergyUtils");

  modifier asWorld() {
    TestUtils.asWorld(LIB_ADDRESS_SLOT);
    _;
  }

  // Hack to be able to access the library address until we figure out why mud doesn't allow it
  function init(address libAddress) public {
    TestUtils.init(LIB_ADDRESS_SLOT, libAddress);
  }

  function updateMachineEnergy(EntityId entityId) public asWorld returns (EnergyData memory, uint128) {
    return _updateMachineEnergy(entityId);
  }

  function updatePlayerEnergy(EntityId entityId) public asWorld returns (EnergyData memory) {
    return _updatePlayerEnergy(entityId);
  }
}

library TestForceFieldUtils {
  bytes32 constant LIB_ADDRESS_SLOT = keccak256("TestUtils.TestForceFieldUtils");

  modifier asWorld() {
    TestUtils.asWorld(LIB_ADDRESS_SLOT);
    _;
  }

  // Hack to be able to access the library address until we figure out why mud doesn't allow it
  function init(address libAddress) public {
    TestUtils.init(LIB_ADDRESS_SLOT, libAddress);
  }

  function isForceFieldActive(EntityId forceField) public asWorld returns (bool) {
    return ForceFieldUtils.isForceFieldActive(forceField);
  }

  function isFragment(EntityId forceField, Vec3 fragmentCoord) public asWorld returns (bool) {
    return ForceFieldUtils.isFragment(forceField, fragmentCoord);
  }

  function getForceField(Vec3 coord) public asWorld returns (EntityId, EntityId) {
    return ForceFieldUtils.getForceField(coord);
  }

  function setupForceField(EntityId forceField, Vec3 coord) public asWorld {
    ForceFieldUtils.setupForceField(forceField, coord);
  }

  function destroyForceField(EntityId forceField) public asWorld {
    ForceFieldUtils.destroyForceField(forceField);
  }
}
