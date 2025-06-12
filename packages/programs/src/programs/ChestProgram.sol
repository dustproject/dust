// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { DefaultProgram } from "./DefaultProgram.sol";

contract ChestProgram is Hooks.ITransfer, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onTransfer(Hooks.TransferContext calldata ctx) external view onlyWorld {
    require(_isAllowed(ctx.target, ctx.caller), "Only approved callers can transfer to/from the chest");
  }
}
