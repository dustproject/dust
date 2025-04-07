// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";

import { IAttachProgramHook, IDetachProgramHook, ITransferHook } from "@dust/world/src/ProgramInterfaces.sol";

/**
 * @title ChestProgram
 * @notice Handles chest functionality for storing items
 */
contract ChestProgram is IAttachProgramHook, IDetachProgramHook, ITransferHook, WorldConsumer {
  /**
   * @notice Initializes the ChestProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld { }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld { }

  function onTransfer(
    EntityId caller,
    EntityId target,
    EntityId from,
    EntityId to,
    ObjectAmount[] memory objectAmounts,
    EntityId[] memory toolEntities,
    bytes memory extraData
  ) external onlyWorld { }
}
