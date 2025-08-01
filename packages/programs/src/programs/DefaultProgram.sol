// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { HookContext, IAttachProgram, IDetachProgram } from "@dust/world/src/ProgramHooks.sol";

import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "../codegen/tables/EntityAccessGroup.sol";

import { createAccessGroup } from "../createAccessGroup.sol";
import { getForceField } from "../getForceField.sol";
import { hasAccess } from "../hasAccess.sol";

abstract contract DefaultProgram is IAttachProgram, IDetachProgram, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(HookContext calldata ctx) external onlyWorld {
    EntityId forceField = getForceField(ctx.target);

    // Sanity check to ensure the target's access group is not already set
    if (EntityAccessGroup.get(ctx.target) != 0) {
      EntityAccessGroup.deleteRecord(ctx.target);
    }

    if (ctx.target == forceField) {
      // Always create access group for forcefields
      _createAndSetAccessGroup(ctx.target, ctx.caller);
      return;
    }

    // For entities: don't create access groups (they'll be locked in custom forcefields anyway)
    // Access control is handled by getGroupId which locks entities in custom forcefields
  }

  function onDetachProgram(HookContext calldata ctx) external onlyWorld {
    // Check if allowed to detach
    if (ctx.revertOnFailure) {
      require(_canDetach(ctx.caller, ctx.target), "Caller not authorized to detach this program");
    }

    // Always clean up access group
    EntityAccessGroup.deleteRecord(ctx.target);
  }

  function _canDetach(EntityId caller, EntityId target) internal view virtual returns (bool) {
    return hasAccess(caller, target);
  }

  function _createAndSetAccessGroup(EntityId target, EntityId owner) internal {
    uint256 groupId = createAccessGroup(owner);
    EntityAccessGroup.set(target, groupId);
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
