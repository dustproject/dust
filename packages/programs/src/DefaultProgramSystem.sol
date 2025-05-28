// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/EntityId.sol";

import { AccessGroupCount } from "./codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "./codegen/tables/AccessGroupOwner.sol";

import { ContentURI } from "./codegen/tables/ContentURI.sol";
import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

import { createAccessGroup } from "./createAccessGroup.sol";

contract DefaultProgramSystem is System {
  function newAccessGroup(EntityId owner) external returns (uint256) {
    owner.validateCaller();
    return createAccessGroup(owner);
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
    setMembership(caller, groupId, EntityTypeLib.encodePlayer(member), allowed);
  }

  function setMembership(EntityId caller, EntityId target, EntityId member, bool allowed) public {
    uint256 groupId = EntityAccessGroup.get(target);
    setMembership(caller, groupId, member, allowed);
  }

  function setMembership(EntityId caller, EntityId target, address member, bool allowed) external {
    setMembership(caller, target, EntityTypeLib.encodePlayer(member), allowed);
  }

  function setOwner(EntityId caller, uint256 groupId, EntityId newOwner) external {
    caller.validateCaller();
    _requireOwner(groupId, caller);
    AccessGroupOwner.set(groupId, newOwner);
  }

  function setContentURI(EntityId caller, EntityId target, string memory contentURI) external {
    caller.validateCaller();
    uint256 groupId = EntityAccessGroup.get(target);
    _requireMember(groupId, caller);
    ContentURI.set(target, contentURI);
  }

  function _requireMember(uint256 groupId, EntityId caller) private view {
    require(AccessGroupMember.get(groupId, caller), "Caller is not a member of the access group");
  }

  function _requireOwner(uint256 groupId, EntityId caller) private view {
    require(AccessGroupOwner.get(groupId) == caller, "Only the owner can call this function");
  }
}
