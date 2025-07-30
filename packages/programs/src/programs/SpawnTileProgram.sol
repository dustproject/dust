// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { HookContext, ISpawn } from "@dust/world/src/ProgramHooks.sol";

import { hasAccess } from "../hasAccess.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract SpawnTileProgram is ISpawn, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSpawn(HookContext calldata ctx, SpawnData calldata) external view onlyWorld {
    require(hasAccess(ctx.caller, ctx.target), "Only approved callers can spawn through this tile");
  }
}
