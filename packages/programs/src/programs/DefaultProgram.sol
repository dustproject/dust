// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { Vec3 } from "@dust/world/src/types/Vec3.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { Fragment, FragmentData } from "@dust/world/src/codegen/tables/Fragment.sol";
import { Machine } from "@dust/world/src/codegen/tables/Machine.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { AccessGroupCount } from "../codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "../codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "../codegen/tables/EntityAccessGroup.sol";

import { createAccessGroup } from "../createAccessGroup.sol";

abstract contract DefaultProgram is Hooks.IAttachProgram, Hooks.IDetachProgram, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(Hooks.AttachProgramContext calldata ctx) external onlyWorld {
    (EntityId forceField,) = _getForceField(ctx.target);

    uint256 groupId;

    // If the force field is associated with an access group, use that groupId
    if (forceField.exists()) {
      groupId = EntityAccessGroup.get(forceField);
      // When a forcefield already exists, only members can attach programs
      require(
        ctx.target == forceField || AccessGroupMember.get(groupId, ctx.caller),
        "Only members can attach programs when forcefield exists"
      );
    }

    // If the force field is not associated with an access group, create a new one
    if (groupId == 0) {
      groupId = createAccessGroup(ctx.caller);
    }

    EntityAccessGroup.set(ctx.target, groupId);
  }

  function onDetachProgram(Hooks.DetachProgramContext calldata ctx) external onlyWorld {
    uint256 groupId = EntityAccessGroup.get(ctx.target);
    require(_isSafeCall(ctx.target) || _canDetach(ctx.caller, groupId), "Caller not authorized to detach this program");

    EntityAccessGroup.deleteRecord(ctx.target);
  }

  function _canDetach(EntityId caller, uint256 groupId) internal view virtual returns (bool) {
    return AccessGroupMember.get(groupId, caller);
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    uint256 groupId = EntityAccessGroup.get(target);
    return AccessGroupMember.get(groupId, caller);
  }

  function _isSafeCall(EntityId target) internal view returns (bool) {
    return !_isProtected(target);
  }

  // TODO: extract to utils
  function _isProtected(EntityId target) internal view returns (bool) {
    (EntityId forceField,) = _getForceField(target);
    return forceField.exists() && Energy.getEnergy(forceField) != 0;
  }

  // TODO: extract to utils
  function _getForceField(EntityId target) internal view returns (EntityId, EntityId) {
    Vec3 fragmentCoord = target.getPosition().toFragmentCoord();
    EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
    if (!fragment.exists()) return (EntityId.wrap(0), fragment);

    FragmentData memory fragmentData = Fragment.get(fragment);

    bool isActive = fragmentData.forceField.exists()
      && fragmentData.forceFieldCreatedAt == Machine.getCreatedAt(fragmentData.forceField);

    return isActive ? (fragmentData.forceField, fragment) : (EntityId.wrap(0), fragment);
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
