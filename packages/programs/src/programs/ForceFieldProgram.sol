// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";
import { ObjectAmount, ObjectType } from "@dust/world/src/types/ObjectType.sol";
import { ProgramId } from "@dust/world/src/types/ProgramId.sol";
import { Vec3 } from "@dust/world/src/types/Vec3.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract ForceFieldProgram is
  Hooks.IProgramValidator,
  Hooks.IAddFragment,
  Hooks.IRemoveFragment,
  Hooks.IFuel,
  Hooks.IBuild,
  Hooks.IMine,
  DefaultProgram
{
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function validateProgram(Hooks.ValidateProgramContext calldata ctx) external view onlyWorld {
    // Allow all programs
    // TODO: should we add a method to restrict programs?
  }

  function onFuel(Hooks.FuelContext calldata ctx) external view onlyWorld {
    // Allow anyone to fuel the force field
  }

  function onAddFragment(Hooks.AddFragmentContext calldata ctx) external view onlyWorld {
    require(_isAllowed(ctx.target, ctx.caller), "Only approved callers can add fragments to the force field");
  }

  function onRemoveFragment(Hooks.RemoveFragmentContext calldata ctx) external view onlyWorld {
    require(_isAllowed(ctx.target, ctx.caller), "Only approved callers can remove fragments from the force field");
  }

  function onBuild(Hooks.BuildContext calldata ctx) external view onlyWorld {
    require(_isAllowed(ctx.target, ctx.caller), "Only approved callers can build in the force field");
  }

  function onMine(Hooks.MineContext calldata ctx) external view onlyWorld {
    require(_isAllowed(ctx.target, ctx.caller), "Only approved callers can mine in the force field");
  }

  // Override the default program attachment logic to only allow the owner of the access group to detach forcefield programs
  function _canDetach(EntityId caller, EntityId target) internal view override returns (bool) {
    (uint256 groupId,) = _getGroupId(target);

    if (groupId == 0) {
      return true; // If no group, allow detachment
    }

    // Only the owner of the access group can detach
    return AccessGroupOwner.get(groupId) == caller;
  }
}
