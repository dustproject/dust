// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { PlayerName } from "../codegen/tables/PlayerName.sol";
import { ReversePlayerName } from "../codegen/tables/ReversePlayerName.sol";
import { EntityId } from "../types/EntityId.sol";

contract NameSystem is System {
  function setPlayerName(EntityId caller, bytes32 name) public {
    caller.activate();
    address player = caller.getPlayerAddress();

    require(ReversePlayerName._get(name) == address(0), "Player name is already in use.");

    // free up previous name
    // TODO: do we want to allow players to be able to change their name? if not, change this to a require/revert
    bytes32 previousName = PlayerName._get(player);
    if (previousName != "") {
      ReversePlayerName._deleteRecord(previousName);
    }

    ReversePlayerName._set({ player: player, name: name });
    PlayerName._set({ player: player, name: name });
  }
}
