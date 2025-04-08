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

  function _requireOwner(EntityId target) internal view returns (bytes32) {
    bytes32 smartItemId = SmartItem.get(target);
    require(Owner.get(smartItemId) == Player.get(_msgSender()), "Only the owner can call this function");
    return smartItemId;
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    return AllowedCaller.get(SmartItem.get(target), caller);
  }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    uint256 uniqueEntity = UniqueEntity.get() + 1;
    UniqueEntity.set(uniqueEntity);
    bytes32 smartItemId = bytes32(uniqueEntity);
    SmartItem.set(target, smartItemId);

    Owner.set(smartItemId, caller);
    AllowedCaller.set(smartItemId, caller, true);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    require(Owner.get(SmartItem.get(target)) == caller, "Only the owner can detach this program");
  }

  function setAllowed(EntityId target, EntityId caller, bool allowed) external {
    bytes32 smartItemId = _requireOwner(target);
    AllowedCaller.set(smartItemId, caller, allowed);
  }

  function setOwner(EntityId target, EntityId newOwner) external {
    bytes32 smartItemId = _requireOwner(target);
    Owner.set(smartItemId, newOwner);
  }
}
