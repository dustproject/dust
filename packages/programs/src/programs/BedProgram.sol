// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { HookContext, ISleep, IWakeup } from "@dust/world/src/ProgramHooks.sol";

import { hasAccess } from "../hasAccess.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract BedProgram is ISleep, IWakeup, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSleep(HookContext calldata ctx) external view onlyWorld {
    require(hasAccess(ctx.caller, ctx.target), "Only approved callers can sleep in the bed");
  }

  function onWakeup(HookContext calldata ctx) external view onlyWorld {
    // Allow anyone to wake up
  }
}
