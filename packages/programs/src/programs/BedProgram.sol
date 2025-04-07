// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { ReversePlayer } from "@dust/world/src/codegen/tables/ReversePlayer.sol";

import { ISleepHook, IWakeupHook } from "@dust/world/src/ProgramInterfaces.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

/**
 * @title BedProgram
 */
contract BedProgram is DefaultProgram, ISleepHook, IWakeupHook {
  /**
   * @notice Initializes the BedProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onSleep(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    require(
      _isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can transfer to/from the chest"
    );
  }

  function onWakeup(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    require(_isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can wake up from the bed");
  }
}
