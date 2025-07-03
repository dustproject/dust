// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { Vec3 } from "@dust/world/src/types/Vec3.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { Fragment, FragmentData } from "@dust/world/src/codegen/tables/Fragment.sol";
import { Machine } from "@dust/world/src/codegen/tables/Machine.sol";

function getForceField(EntityId target) view returns (EntityId, bool isProtected) {
  Vec3 fragmentCoord = target.getPosition().toFragmentCoord();
  EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
  if (!fragment.exists()) return (EntityId.wrap(0), false);

  FragmentData memory fragmentData = Fragment.get(fragment);

  bool isActive = fragmentData.forceField.exists()
    && fragmentData.forceFieldCreatedAt == Machine.getCreatedAt(fragmentData.forceField);

  return
    isActive ? (fragmentData.forceField, Energy.getEnergy(fragmentData.forceField) != 0) : (EntityId.wrap(0), false);
}
