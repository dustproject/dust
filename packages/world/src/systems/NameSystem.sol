// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { PlayerName } from "../codegen/tables/PlayerName.sol";
import { ReversePlayerName } from "../codegen/tables/ReversePlayerName.sol";
import { EntityId } from "../types/EntityId.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";
import { LibString } from "solady/utils/LibString.sol";

contract NameSystem is System {
  function setPlayerName(EntityId caller, string memory name) public {
    checkWorldStatus();
    caller._validateCaller();
    _setPlayerName(caller.getPlayerAddress(), name);
  }
}

function _setPlayerName(address player, string memory name) {
  uint128 validCharacters =
    LibString.to7BitASCIIAllowedLookup("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_");

  require(bytes(name).length > 0 && bytes(name).length <= 32, "Name must be 1-32 characters long.");
  require(LibString.is7BitASCII(name, validCharacters), "Name has invalid characters.");

  bytes32 storedName = LibString.toSmallString(name);
  require(ReversePlayerName._get(storedName) == address(0), "Name is already in use.");

  // free up previous name
  bytes32 previousName = PlayerName._get(player);
  if (previousName != bytes32(0)) {
    ReversePlayerName._deleteRecord(previousName);
  }

  ReversePlayerName._set({ player: player, name: storedName });
  PlayerName._set({ player: player, name: storedName });
}
