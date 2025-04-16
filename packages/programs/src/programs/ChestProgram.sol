// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";

import { ITransferHook, SlotData } from "@dust/world/src/ProgramInterfaces.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

contract ChestProgram is DefaultProgram, ITransferHook {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function onTransfer(EntityId caller, EntityId target, SlotData[] memory, SlotData[] memory, bytes memory)
    external
    view
    onlyWorld
  {
    require(_isAllowed(target, caller), "Only approved callers can transfer to/from the chest");
  }
}
