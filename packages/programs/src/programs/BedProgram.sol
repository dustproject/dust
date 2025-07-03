// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { isAllowed } from "../isAllowed.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract BedProgram is Hooks.ISleep, Hooks.IWakeup, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSleep(Hooks.SleepContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can sleep in the bed");
  }

  function onWakeup(Hooks.WakeupContext calldata ctx) external view onlyWorld {
    // TODO: should we allow anyone to wake up from the bed?
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can wake up from the bed");
  }
}
