// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityIdLib } from "@dust/world/src/types/EntityId.sol";

import { EntityAccessGroup } from "./codegen/tables/EntityAccessGroup.sol";

import { getForceField } from "./getForceField.sol";
import { getGroupId } from "./getGroupId.sol";
import { isForceFieldActive } from "./isForceFieldActive.sol";

// Returns access control info: group ID and whether entity is locked
function getAccessControl(EntityId target) view returns (uint256 groupId, bool locked) {
  EntityId forceField = getForceField(target);

  // Not in forcefield or forcefield not active = not locked
  if (!isForceFieldActive(forceField)) {
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
