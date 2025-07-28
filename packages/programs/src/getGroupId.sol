// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityIdLib } from "@dust/world/src/types/EntityId.sol";

import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

import { getForceField } from "./getForceField.sol";

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
