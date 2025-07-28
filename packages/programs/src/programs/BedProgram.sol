// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { HookContext, ISleep, IWakeup } from "@dust/world/src/ProgramHooks.sol";

import { isAllowed } from "../isAllowed.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract BedProgram is ISleep, IWakeup, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSleep(HookContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx, ctx.target), "Only approved callers can sleep in the bed");
  }

  function onWakeup(HookContext calldata ctx) external view onlyWorld {
    // onWakeup typically has revertOnFailure=false, so isAllowed will always return true
    // But we still check it for consistency
    require(isAllowed(ctx, ctx.target), "Only approved callers can wake up from the bed");
  }
}
