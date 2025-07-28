// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext } from "@dust/world/src/ProgramHooks.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";

import { getAccessControl } from "./getGroupId.sol";

// New isAllowed that respects revertOnFailure
function isAllowed(HookContext calldata ctx, EntityId entity) view returns (bool) {
  // revertOnFailure=false is an override - always allow (for cleanup)
  if (!ctx.revertOnFailure) {
    return true;
  }

  // Get access control info
  (uint256 groupId, bool locked) = getAccessControl(entity);

  // If locked, deny access
  if (locked) {
    return false;
  }

  // If no group, allow access
  if (groupId == 0) {
    return true;
  }

  // Check group membership
  return AccessGroupMember.get(groupId, ctx.caller);
}

// Keep original isAllowed for backward compatibility
function isAllowed(EntityId target, EntityId caller) view returns (bool) {
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
