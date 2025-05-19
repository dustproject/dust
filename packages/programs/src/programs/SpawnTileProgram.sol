// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { ISpawnHook } from "@dust/world/src/ProgramInterfaces.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

contract SpawnTileProgram is DefaultProgram, ISpawnHook {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSpawn(EntityId caller, EntityId target, uint128, bytes memory) external view onlyWorld {
    require(_isAllowed(target, caller), "Only approved callers can spawn through this tile");
  }
}
