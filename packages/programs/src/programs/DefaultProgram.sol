// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityIdLib } from "@dust/world/src/EntityId.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { AccessGroupCount } from "../codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "../codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "../codegen/tables/EntityAccessGroup.sol";

abstract contract DefaultProgram is IAttachProgramHook, IDetachProgramHook, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    uint256 groupId;
    AccessGroupOwner.set(groupId, caller);
    AccessGroupMember.set(groupId, caller, true);
    EntityAccessGroup.set(target, groupId);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    uint256 groupId = EntityAccessGroup.get(target);
    require(_isSafeCall() || AccessGroupOwner.get(groupId) == caller, "Only the owner can detach this program");

    EntityAccessGroup.deleteRecord(target);
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    uint256 groupId = EntityAccessGroup.get(target);
    return AccessGroupMember.get(groupId, caller);
  }

  // TODO: implement check for when the forcefield has no energy
  function _isSafeCall() internal view returns (bool) {
    return false;
  }

  function _getForceField(EntityId target) internal view returns (EntityId) {
    // TODO: implement and extract to util
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
