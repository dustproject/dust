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
      uint256 groupId = createAccessGroup(ctx.caller);
      EntityAccessGroup.set(ctx.target, groupId);
    } else {
      // For entities within forcefields
      bool isProtected = forceField.exists() && Energy.getEnergy(forceField) != 0;

      if (isProtected) {
        // Check if the forcefield has an access group
        uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);

        if (forceFieldGroupId == 0) {
          // Forcefield has NO access group - create one for the entity
          uint256 groupId = createAccessGroup(ctx.caller);
          EntityAccessGroup.set(ctx.target, groupId);
        }
        // If forcefield has an access group, don't create one for the entity (will fallback)
      }
      // If not in a forcefield, don't create an access group (open access)
    }
  }

  function onDetachProgram(Hooks.DetachProgramContext calldata ctx) external onlyWorld {
    require(_canDetach(ctx.caller, ctx.target), "Caller not authorized to detach this program");

    EntityAccessGroup.deleteRecord(ctx.target);
  }

  function _canDetach(EntityId caller, EntityId target) internal view virtual returns (bool) {
    return _isAllowed(target, caller);
  }

  function _getGroupId(EntityId target) internal view returns (uint256 groupId, bool isLocked) {
    (EntityId forceField,) = _getForceField(target);
    bool isProtected = forceField.exists() && Energy.getEnergy(forceField) != 0;

    // If not within a forcefield, open by default
    if (!isProtected) return (0, false);

    // If within a charged forcefield, check if the forcefield has an access group
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);

    uint256 targetGroupId = EntityAccessGroup.get(target);

    // If forcefield has NO access group
    if (forceFieldGroupId == 0) {
      // Check if entity has its own access group
      if (targetGroupId != 0) {
        return (targetGroupId, false); // Use entity's group even in custom forcefield
      }
      // No groups at all, lock completely
      return (0, true);
    }

    // Forcefield has an access group
    // Check if entity has its own group
    if (targetGroupId != 0) {
      return (targetGroupId, false); // Use entity's group
    }

    // Entity has no group, fallback to forcefield's group
    return (forceFieldGroupId, false);
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    (uint256 groupId, bool isLocked) = _getGroupId(target);

    // If locked (forcefield without access group), deny access
    if (isLocked) {
      return false;
    }

    // If no access group, allow access
    if (groupId == 0) {
      return true;
    }

    // Check if caller is member of the access group
    return AccessGroupMember.get(groupId, caller);
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
