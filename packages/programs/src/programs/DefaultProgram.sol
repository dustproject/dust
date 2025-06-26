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
      uint256 groupId = createAccessGroup(ctx.caller);
      EntityAccessGroup.set(ctx.target, groupId);
    } else {
      require(_isAllowed(ctx.target, ctx.caller), "Only force field members can attach program");
    }
  }

  function onDetachProgram(Hooks.DetachProgramContext calldata ctx) external onlyWorld {
    uint256 groupId = _getGroupId(ctx.target);
    require(_isSafeCall(ctx.target) || _canDetach(ctx.caller, groupId), "Caller not authorized to detach this program");

    EntityAccessGroup.deleteRecord(ctx.target);
  }

  function _canDetach(EntityId caller, uint256 groupId) internal view virtual returns (bool) {
    return AccessGroupMember.get(groupId, caller);
  }

  function _getGroupId(EntityId target) internal view returns (uint256 groupId) {
    groupId = EntityAccessGroup.get(target);
    if (groupId == 0) {
      (EntityId forceField,) = _getForceField(target);
      if (forceField.exists()) {
        groupId = EntityAccessGroup.get(forceField);
      }
    }
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    return AccessGroupMember.get(_getGroupId(target), caller);
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
