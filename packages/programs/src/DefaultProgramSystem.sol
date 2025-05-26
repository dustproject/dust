// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/EntityId.sol";

import { AccessGroupCount } from "./codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "./codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

contract DefaultProgramSystem is System {
  function newAccessGroup(EntityId owner) external returns (uint256) {
    uint256 newGroupId = AccessGroupCount.get() + 1;

    // Set the owner of the access group to the caller
    AccessGroupOwner.set(newGroupId, owner);

    // Grant access to the caller
    AccessGroupMember.set(newGroupId, owner, true);

    // Increment the access group count
    AccessGroupCount.set(newGroupId);

    return newGroupId;
  }

  function setAccessGroup(EntityId caller, EntityId target, uint256 groupId) external {
    caller.validateCaller();
    uint256 currentGroupId = EntityAccessGroup.get(target);
    _requireOwner(currentGroupId, caller);
    EntityAccessGroup.set(target, groupId);
  }

  function setMembership(EntityId caller, uint256 groupId, EntityId member, bool allowed) public {
    caller.validateCaller();
    _requireOwner(groupId, caller);
    AccessGroupMember.set(groupId, member, allowed);
  }

  function setMembership(EntityId caller, uint256 groupId, address member, bool allowed) external {
    caller.validateCaller();
    setMembership(caller, groupId, EntityTypeLib.encodePlayer(member), allowed);
  }

  function setOwner(EntityId caller, uint256 groupId, EntityId newOwner) external {
    caller.validateCaller();
    _requireOwner(groupId, caller);
    AccessGroupOwner.set(groupId, newOwner);
  }

  function _requireOwner(uint256 groupId, EntityId caller) private view {
    require(AccessGroupOwner.get(groupId) == caller, "Only the owner can call this function");
  }
}
