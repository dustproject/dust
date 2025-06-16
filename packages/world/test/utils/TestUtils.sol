// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Vm } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../../src/EntityId.sol";
import { Vec3 } from "../../src/Vec3.sol";

import { Energy, EnergyData } from "../../src/codegen/tables/Energy.sol";
import { Machine } from "../../src/codegen/tables/Machine.sol";

import { EntityObjectType } from "../../src/codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../../src/codegen/tables/InventorySlot.sol";

import { ObjectType } from "../../src/ObjectType.sol";

import {
  updateMachineEnergy as _updateMachineEnergy,
  updatePlayerEnergy as _updatePlayerEnergy
} from "../../src/utils/EnergyUtils.sol";

import { EntityUtils } from "../../src/utils/EntityUtils.sol";
import { ForceFieldUtils } from "../../src/utils/ForceFieldUtils.sol";
import { InventoryUtils, SlotAmount, SlotTransfer, ToolData } from "../../src/utils/InventoryUtils.sol";
import { PlayerUtils } from "../../src/utils/PlayerUtils.sol";

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

library TestEntityUtils {
  bytes32 constant LIB_ADDRESS_SLOT = keccak256("TestUtils.TestEntityUtils");

  modifier asWorld() {
    TestUtils.asWorld(LIB_ADDRESS_SLOT);
    _;
  }

  // Hack to be able to access the library address until we figure out why mud doesn't allow it
  function init(address libAddress) public {
    TestUtils.init(LIB_ADDRESS_SLOT, libAddress);
  }

  function getObjectTypeAt(Vec3 coord) public asWorld returns (ObjectType) {
    return EntityUtils.getObjectTypeAt(coord);
  }

  function getBlockAt(Vec3 coord) public asWorld returns (EntityId, ObjectType) {
    return EntityUtils.getBlockAt(coord);
  }

  function getOrCreateFragmentAt(Vec3 fragmentCoord) public asWorld returns (EntityId) {
    return EntityUtils.getOrCreateFragmentAt(fragmentCoord);
  }

  function getFragmentAt(Vec3 fragmentCoord) public asWorld returns (EntityId) {
    return EntityUtils.getFragmentAt(fragmentCoord);
  }

  function getFluidLevelAt(Vec3 coord) public asWorld returns (uint8) {
    return EntityUtils.getFluidLevelAt(coord);
  }

  function getOrCreateBlockAt(Vec3 coord) public asWorld returns (EntityId, ObjectType) {
    return EntityUtils.getOrCreateBlockAt(coord);
  }

  function createUniqueEntity(ObjectType objectType) public asWorld returns (EntityId) {
    return EntityUtils.createUniqueEntity(objectType);
  }
}

library TestPlayerUtils {
  bytes32 constant LIB_ADDRESS_SLOT = keccak256("TestUtils.TestPlayerUtils");

  modifier asWorld() {
    TestUtils.asWorld(LIB_ADDRESS_SLOT);
    _;
  }

  // Hack to be able to access the library address until we figure out why mud doesn't allow it
  function init(address libAddress) public {
    TestUtils.init(LIB_ADDRESS_SLOT, libAddress);
  }

  function addPlayerToGrid(EntityId player, Vec3 playerCoord) public asWorld {
    PlayerUtils.addPlayerToGrid(player, playerCoord);
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
    EntityId entityId = EntityUtils.createUniqueEntity(toolObjectType);
    InventoryUtils.addEntity(ownerEntityId, entityId);
    return entityId;
  }

  function addEntityToSlot(EntityId ownerEntityId, ObjectType toolObjectType, uint16 slot)
    public
    asWorld
    returns (EntityId)
  {
    EntityId entityId = EntityUtils.createUniqueEntity(toolObjectType);
    InventoryUtils.addEntityToSlot(ownerEntityId, entityId, slot);
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

  function transfer(EntityId fromEntityId, EntityId toEntityId, SlotAmount[] memory amounts) public asWorld {
    InventoryUtils.transfer(fromEntityId, toEntityId, amounts);
  }

  function removeObjectFromSlot(EntityId ownerEntityId, uint16 slot, uint16 numObjectsToRemove) public asWorld {
    InventoryUtils.removeObjectFromSlot(ownerEntityId, slot, numObjectsToRemove);
  }

  function getToolData(EntityId owner, uint16 slot) public asWorld returns (ToolData memory) {
    return InventoryUtils.getToolData(owner, slot);
  }

  function use(ToolData memory toolData, uint128 useMassMax, uint128 multiplier) public asWorld returns (uint128) {
    return toolData.use(useMassMax, multiplier);
  }

  function findEntity(EntityId owner, EntityId entityId) public asWorld returns (uint16) {
    return InventoryUtils.findEntity(owner, entityId);
  }

  function findObjectType(EntityId owner, ObjectType objectType) public asWorld returns (uint16) {
    return InventoryUtils.findObjectType(owner, objectType);
  }

  function getOccupiedSlotCount(EntityId owner) public asWorld returns (uint256 count) {
    return InventoryUtils.getOccupiedSlotCount(owner);
  }

  function countObjectsOfType(EntityId owner, ObjectType objectType) public asWorld returns (uint256 total) {
    return InventoryUtils.countObjectsOfType(owner, objectType);
  }

  function hasObjectType(EntityId ownerEntityId, ObjectType objectType) public asWorld returns (bool) {
    return InventoryUtils.hasObjectType(ownerEntityId, objectType);
  }

  function getSlotsWithType(EntityId ownerEntityId, ObjectType objectType)
    public
    asWorld
    returns (uint16[] memory slots)
  {
    return InventoryUtils.getSlotsWithType(ownerEntityId, objectType);
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

  function updateMachineEnergy(EntityId entityId) public asWorld returns (EnergyData memory) {
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
    Energy._deleteRecord(forceField);
    Machine._deleteRecord(forceField);
  }
}
