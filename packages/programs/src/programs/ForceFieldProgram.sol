// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import {
  HookContext,
  IAddFragment,
  IBuild,
  IEnergize,
  IMine,
  IProgramValidator,
  IRemoveFragment
} from "@dust/world/src/ProgramHooks.sol";

import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";

import { getGroupId } from "../getGroupId.sol";
import { isAllowed } from "../isAllowed.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract ForceFieldProgram is
  IProgramValidator,
  IAddFragment,
  IRemoveFragment,
  IEnergize,
  IBuild,
  IMine,
  DefaultProgram
{
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function validateProgram(HookContext memory ctx, ValidateData calldata program) external view onlyWorld {
    // Allow all programs
  }

  function onEnergize(HookContext memory ctx, EnergizeData calldata energize) external view onlyWorld {
    // Allow anyone to fuel the force field
  }

  function onAddFragment(Hooks.AddFragmentContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can add fragments to the force field");
  }

  function onRemoveFragment(Hooks.RemoveFragmentContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can remove fragments from the force field");
  }

  function onBuild(Hooks.BuildContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can build in the force field");
  }

  function onMine(Hooks.MineContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can mine in the force field");
  }

  // Override the default program attachment logic to only allow the owner of the access group to detach forcefield programs
  function _canDetach(EntityId caller, EntityId target) internal view override returns (bool) {
    (uint256 groupId,) = getGroupId(target);

    if (groupId == 0) {
      return true; // If no group, allow detachment
    }

    // Only the owner of the access group can detach
    return AccessGroupOwner.get(groupId) == caller;
  }
}
