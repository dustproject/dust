// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityIdLib } from "@dust/world/src/EntityId.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { AllowedCaller } from "../codegen/tables/AllowedCaller.sol";
import { Owner } from "../codegen/tables/Owner.sol";

import { SmartItem } from "../codegen/tables/SmartItem.sol";
import { UniqueEntity } from "../codegen/tables/UniqueEntity.sol";

abstract contract DefaultProgram is IAttachProgramHook, IDetachProgramHook, WorldConsumer {
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
