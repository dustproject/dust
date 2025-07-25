// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { HookContext, ITransfer } from "@dust/world/src/ProgramHooks.sol";

import { isAllowed } from "../isAllowed.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract ChestProgram is ITransfer, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onTransfer(HookContext calldata ctx, TransferData calldata) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can transfer to/from the chest");
  }
}
