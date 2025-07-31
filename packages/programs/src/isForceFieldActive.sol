// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { EntityId, EntityIdLib } from "@dust/world/src/types/EntityId.sol";

using EntityIdLib for EntityId;

// Checks if a forcefield is active (has energy)
function isForceFieldActive(EntityId forceField) view returns (bool) {
  if (!forceField.exists()) return false;
  return Energy.getEnergy(forceField) != 0;
}
