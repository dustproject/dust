// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { LibString } from "solady/utils/LibString.sol";

import { IDisplay } from "dustkit/IDisplay.sol";

import { TextSignContent } from "../codegen/tables/TextSignContent.sol";
import { DefaultProgram } from "./DefaultProgram.sol";

contract TextSignProgram is IDisplay, DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function contentURI(EntityId, EntityId target, bytes memory) external view returns (string memory) {
    string memory content = TextSignContent.get(target);
    if (bytes(content).length == 0) {
      return "";
    }
    return string.concat("data:text/plain;charset=utf-8,", LibString.encodeURIComponent(content));
  }
}
