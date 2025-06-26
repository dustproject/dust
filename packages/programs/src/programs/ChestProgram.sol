// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/types/EntityId.sol";

import "@dust/world/src/ProgramHooks.sol" as Hooks;

import { DefaultProgram } from "./DefaultProgram.sol";

contract ChestProgram is Hooks.ITransfer, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onTransfer(Hooks.TransferContext calldata ctx) external view onlyWorld {
    if (_isProtected(ctx.target)) {
      (EntityId forceField,) = _getForceField(target);
      require(
        _isAllowed(forceField, ctx.caller), "Only approved callers of the force field can transfer to/from the chest"
      );
    }
  }
}
