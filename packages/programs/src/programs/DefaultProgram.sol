// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { Player } from "@dust/world/src/codegen/tables/Player.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { AllowedCaller } from "../codegen/tables/AllowedCaller.sol";
import { Owner } from "../codegen/tables/Owner.sol";

import { SmartItem } from "../codegen/tables/SmartItem.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";

contract DefaultProgram is IAttachProgramHook, IDetachProgramHook, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    uint256 uniqueEntity = UniqueEntity.get() + 1;
    UniqueEntity.set(uniqueEntity);
    bytes32 smartItemId = bytes32(uniqueEntity);
    SmartItem.set(target, smartItemId);

    Owner.set(smartItemId, caller);
    AllowedCaller.set(smartItemId, caller, true);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    // TODO: dont call require if force field has no energy, so we can still perform the cleanup
    require(Owner.get(SmartItem.get(target)) == caller, "Only the owner can detach this program");
    SmartItem.deleteRecord(target);
  }

  function setAllowed(EntityId target, EntityId caller, bool allowed) external {
    bytes32 smartItemId = SmartItem.get(target);
    _requireOwner(smartItemId);
    AllowedCaller.set(smartItemId, caller, allowed);
  }

  function setOwner(EntityId target, EntityId newOwner) external {
    bytes32 smartItemId = SmartItem.get(target);
    _requireOwner(smartItemId);
    Owner.set(smartItemId, newOwner);
  }

  function _requireOwner(bytes32 smartItemId) internal view {
    require(Owner.get(smartItemId) == Player.get(_msgSender()), "Only the owner can call this function");
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    return AllowedCaller.get(SmartItem.get(target), caller);
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
