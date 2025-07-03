// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { AccessGroupMember } from "./codegen/tables/AccessGroupMember.sol";

import { getGroupId } from "./getGroupId.sol";

function isAllowed(EntityId target, EntityId caller) view returns (bool) {
  (uint256 groupId, bool defaultDeny) = getGroupId(target);

  // No default forcefield = deny, No group = allow, Has group = check membership
  return !defaultDeny && (groupId == 0 || AccessGroupMember.get(groupId, caller));
}
