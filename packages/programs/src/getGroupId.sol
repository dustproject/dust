// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

import { getForceField } from "./getForceField.sol";

function getGroupId(EntityId target) view returns (uint256 groupId, bool defaultDeny) {
  (EntityId forceField, bool isProtected) = getForceField(target);

  // Not in protected forcefield = open access
  if (!isProtected) return (0, false);

  uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);

  // Custom forcefield (no access group) - ALWAYS lock
  if (forceFieldGroupId == 0) {
    return (0, true);
  }

  // Standard forcefield - check if entity has its own group
  uint256 targetGroupId = EntityAccessGroup.get(target);

  // Use entity's group if it has one, otherwise fallback to forcefield's
  return targetGroupId != 0 ? (targetGroupId, false) : (forceFieldGroupId, false);
}
