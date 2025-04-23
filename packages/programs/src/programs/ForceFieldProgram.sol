// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectAmount, ObjectType } from "@dust/world/src/ObjectType.sol";
import { ProgramId } from "@dust/world/src/ProgramId.sol";
import { Vec3 } from "@dust/world/src/Vec3.sol";

import {
  IAddFragmentHook,
  IBuildHook,
  IMineHook,
  IProgramValidator,
  IRemoveFragmentHook
} from "@dust/world/src/ProgramInterfaces.sol";

import { Owner } from "../codegen/tables/Owner.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

contract ForceFieldProgram is
  DefaultProgram,
  IProgramValidator,
  IAddFragmentHook,
  IRemoveFragmentHook,
  IBuildHook,
  IMineHook
{
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function validateProgram(
    EntityId caller,
    EntityId target,
    EntityId programmed,
    ProgramId program,
    bytes memory extraData
  ) external view onlyWorld {
    // Allow all programs
    // TODO: should we add a method to restrict programs?
  }

  function onAddFragment(EntityId caller, EntityId target, EntityId added, bytes memory extraData) external onlyWorld {
    require(_isAllowed(target, caller), "Only approved callers can add fragments to the force field");
  }

  function onRemoveFragment(EntityId caller, EntityId target, EntityId removed, bytes memory extraData)
    external
    onlyWorld
  {
    require(_isAllowed(target, caller), "Only approved callers can remove fragments from the force field");
  }

  function onBuild(EntityId caller, EntityId target, ObjectType objectType, Vec3 coord, bytes memory extraData)
    external
    onlyWorld
  {
    require(_isAllowed(target, caller), "Only approved callers can build in the force field");
  }

  function onMine(EntityId caller, EntityId target, ObjectType objectType, Vec3 coord, bytes memory extraData)
    external
    onlyWorld
  {
    require(_isAllowed(target, caller), "Only approved callers can mine in the force field");
  }
}
