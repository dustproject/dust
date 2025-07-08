// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";

import { AccessGroupCount } from "./codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "./codegen/tables/AccessGroupOwner.sol";

import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";
import { TextSignContent } from "./codegen/tables/TextSignContent.sol";

import { createAccessGroup } from "./createAccessGroup.sol";
import { getGroupId } from "./getGroupId.sol";
import { isAllowed } from "./isAllowed.sol";

contract DefaultProgramSystem is System {
  function newAccessGroup(EntityId owner) external returns (uint256) {
    owner.validateCaller();
    return createAccessGroup(owner);
  }

  function setAccessGroup(EntityId caller, EntityId target, uint256 groupId) public {
    caller.validateCaller();
    (uint256 currentGroupId,) = getGroupId(target);
    _requireOwner(currentGroupId, caller);
    EntityAccessGroup.set(target, groupId);
  }

  /// @dev This function can be called by other entities to get a new access group assigned to themselves
  function setAccessGroup(EntityId caller, address groupOwner) external {
    caller.validateCaller();
    require(caller.getObjectType().isSmartEntity(), "Target must be a smart entity");
    (uint256 currentGroupId,) = getGroupId(caller);
    require(currentGroupId == 0, "Target entity already has an access group");
    uint256 groupId = createAccessGroup(EntityTypeLib.encodePlayer(groupOwner));
    EntityAccessGroup.set(caller, groupId);
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
    (uint256 groupId,) = getGroupId(target);
    require(groupId != 0, "Target entity has no access group");
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

  function setTextSignContent(EntityId caller, EntityId target, string memory content) external {
    caller.validateCaller();
    _requireMember(caller, target);
    TextSignContent.set(target, content);
  }

  function getEntityGroupId(EntityId target) external view returns (uint256 groupId, bool defaultDeny) {
    return getGroupId(target);
  }

  function _requireMember(EntityId caller, EntityId target) private view {
    require(isAllowed(target, caller), "Caller is not a member of the access group");
  }

  function _requireOwner(uint256 groupId, EntityId caller) private view {
    require(AccessGroupOwner.get(groupId) == caller, "Only the owner of the access group can call this function");
  }
}
