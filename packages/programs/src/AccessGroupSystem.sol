// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityIdLib } from "@dust/world/src/EntityId.sol";

import { AccessGroupCount } from "./codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "./codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

contract AccessGroupSystem is System {
  function newAccessGroup(EntityId owner) external returns (uint256) {
    uint256 groupCount = AccessGroupCount.get();

    // Set the owner of the access group to the caller
    AccessGroupOwner.set(groupCount, owner);

    // Grant access to the caller
    AccessGroupMember.set(groupCount, owner, true);

    // Increment the access group count
    AccessGroupCount.set(groupCount + 1);

    return groupCount;
  }

  function setMembership(EntityId caller, uint256 groupId, EntityId member, bool allowed) public {
    // TODO: check the type of caller and that member player exists
    _requireOwner(groupId, caller);
    AccessGroupMember.set(groupId, member, allowed);
  }

  function setMembership(EntityId caller, uint256 groupId, address member, bool allowed) external {
    setMembership(caller, groupId, EntityIdLib.encodePlayer(member), allowed);
  }

  function setOwner(EntityId caller, uint256 groupId, EntityId newOwner) external {
    // TODO: check the type of caller
    _requireOwner(groupId, caller);
    AccessGroupOwner.set(groupId, newOwner);
  }

  function _requireOwner(uint256 groupId, EntityId caller) private view {
    require(AccessGroupOwner.get(groupId) == caller, "Only the owner can call this function");
  }
}
