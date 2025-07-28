// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";

import { getAccessControl } from "./getAccessControl.sol";

// Checks if caller has access to target entity
function hasAccess(EntityId caller, EntityId target) view returns (bool) {
  (uint256 groupId, bool locked) = getAccessControl(target);

  // If locked, deny access
  if (locked) {
    return false;
  }

  // If no group, allow access
  if (groupId == 0) {
    return true;
  }

  // Check group membership
  return AccessGroupMember.get(groupId, caller);
}
