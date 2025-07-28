// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityIdLib } from "@dust/world/src/types/EntityId.sol";

import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

import { getForceField, isForceFieldProtected } from "./getForceField.sol";

using EntityIdLib for EntityId;

// Returns the effective group ID for an entity (own group or forcefield's group)
function getGroupId(EntityId target) view returns (uint256) {
  // Check entity's own group first
  uint256 targetGroupId = EntityAccessGroup.get(target);
  if (targetGroupId != 0) {
    return targetGroupId;
  }

  // Fallback to forcefield's group
  EntityId forceField = getForceField(target);
  if (forceField.exists()) {
    return EntityAccessGroup.get(forceField);
  }

  return 0;
}

// Returns access control info: group ID and whether entity is locked
function getAccessControl(EntityId target) view returns (uint256 groupId, bool locked) {
  EntityId forceField = getForceField(target);

  // Not in forcefield or forcefield not protected = not locked
  if (!isForceFieldProtected(forceField)) {
    return (0, false);
  }

  // Get the effective group ID
  groupId = getGroupId(target);

  // Protected forcefield with no group = locked
  if (groupId == 0) {
    return (0, true);
  }

  return (groupId, false);
}
