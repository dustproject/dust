// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { IDisplay } from "../ClientProgramInterfaces.sol";
import { ContentURI } from "../codegen/tables/ContentURI.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

contract TextSignProgram is IDisplay, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function getContentURI(EntityId, EntityId target, bytes memory) external view returns (string memory) {
    return ContentURI.get(target);
  }
}
