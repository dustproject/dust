// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityIdLib, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { Vec3 } from "@dust/world/src/types/Vec3.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { Fragment, FragmentData } from "@dust/world/src/codegen/tables/Fragment.sol";
import { Machine } from "@dust/world/src/codegen/tables/Machine.sol";

using EntityIdLib for EntityId;

// Returns the forcefield for a target entity (if any)
function getForceField(EntityId target) view returns (EntityId) {
  Vec3 fragmentCoord = target.getPosition().toFragmentCoord();
  EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
  if (!fragment.exists()) return EntityId.wrap(0);

  FragmentData memory fragmentData = Fragment.get(fragment);

  bool isActive = fragmentData.forceField.exists()
    && fragmentData.forceFieldCreatedAt == Machine.getCreatedAt(fragmentData.forceField);

  return isActive ? fragmentData.forceField : EntityId.wrap(0);
}

// Checks if a forcefield is protected (has energy)
function isForceFieldProtected(EntityId forceField) view returns (bool) {
  if (!forceField.exists()) return false;
  return Energy.getEnergy(forceField) != 0;
}
