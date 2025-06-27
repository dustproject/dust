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

    if (ctx.target == forceField) {
      // Always create access group for forcefields
      _createAndSetAccessGroup(ctx.target, ctx.caller);
      return;
    }

    // For entities: don't create access groups (they'll be locked in custom forcefields anyway)
    // Access control is handled by _getGroupId which locks entities in custom forcefields
  }

  function onDetachProgram(Hooks.DetachProgramContext calldata ctx) external onlyWorld {
    require(_canDetach(ctx.caller, ctx.target), "Caller not authorized to detach this program");

    EntityAccessGroup.deleteRecord(ctx.target);
  }

  function _canDetach(EntityId caller, EntityId target) internal view virtual returns (bool) {
    return _isAllowed(target, caller);
  }

  function _getGroupId(EntityId target) internal view returns (uint256 groupId, bool isLocked) {
    (EntityId forceField, bool isProtected) = _getForceField(target);

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

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    (uint256 groupId, bool isLocked) = _getGroupId(target);

    // Locked = deny, No group = allow, Has group = check membership
    return !isLocked && (groupId == 0 || AccessGroupMember.get(groupId, caller));
  }

  function _createAndSetAccessGroup(EntityId target, EntityId owner) internal {
    uint256 groupId = createAccessGroup(owner);
    EntityAccessGroup.set(target, groupId);
  }

  // TODO: extract to utils
  function _getForceField(EntityId target) internal view returns (EntityId, bool isProtected) {
    Vec3 fragmentCoord = target.getPosition().toFragmentCoord();
    EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
    if (!fragment.exists()) return (EntityId.wrap(0), false);

    FragmentData memory fragmentData = Fragment.get(fragment);

    bool isActive = fragmentData.forceField.exists()
      && fragmentData.forceFieldCreatedAt == Machine.getCreatedAt(fragmentData.forceField);

    return
      isActive ? (fragmentData.forceField, Energy.getEnergy(fragmentData.forceField) != 0) : (EntityId.wrap(0), false);
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
