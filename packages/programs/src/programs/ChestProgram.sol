// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";

import { ITransferHook } from "@dust/world/src/ProgramInterfaces.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

/**
 * @title ChestProgram
 */
contract ChestProgram is DefaultProgram, ITransferHook {
  /**
   * @notice Initializes the ChestProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onTransfer(
    EntityId caller,
    EntityId target,
    EntityId from,
    EntityId to,
    ObjectAmount[] memory objectAmounts,
    EntityId[] memory toolEntities,
    bytes memory extraData
  ) external onlyWorld {
    require(_isApproved(target, caller), "Only approved callers can transfer to/from the chest");
  }
}
