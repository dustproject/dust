// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityTypeLib } from "@dust/world/src/EntityId.sol";

import { AccessGroupCount } from "./codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "./codegen/tables/AccessGroupOwner.sol";

function createAccessGroup(EntityId owner) returns (uint256) {
  uint256 newGroupId = AccessGroupCount.get() + 1;

  // Set the owner of the access group to the caller
  AccessGroupOwner.set(newGroupId, owner);

  // Grant access to the caller
  AccessGroupMember.set(newGroupId, owner, true);

  // Increment the access group count
  AccessGroupCount.set(newGroupId);

  return newGroupId;
}
