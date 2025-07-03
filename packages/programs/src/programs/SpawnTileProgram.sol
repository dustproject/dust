// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { isAllowed } from "../isAllowed.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract SpawnTileProgram is Hooks.ISpawn, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSpawn(Hooks.SpawnContext calldata ctx) external view onlyWorld {
    require(isAllowed(ctx.target, ctx.caller), "Only approved callers can spawn through this tile");
  }
}
