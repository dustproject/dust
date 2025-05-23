// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { ISleepHook, IWakeupHook } from "@dust/world/src/ProgramInterfaces.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

contract BedProgram is ISleepHook, IWakeupHook, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSleep(EntityId caller, EntityId target, bytes memory) external view onlyWorld {
    require(_isAllowed(target, caller), "Only approved callers can sleep in the bed");
  }

  function onWakeup(EntityId caller, EntityId target, bytes memory) external view onlyWorld {
    require(_isAllowed(target, caller), "Only approved callers can wake up from the bed");
  }
}
