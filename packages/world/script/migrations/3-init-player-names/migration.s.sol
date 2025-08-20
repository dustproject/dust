// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PlayerName } from "../../../src/codegen/tables/PlayerName.sol";
import { ReversePlayerName } from "../../../src/codegen/tables/ReversePlayerName.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";
import { LibString } from "solady/utils/LibString.sol";

import { DustScript } from "../../DustScript.sol";

struct PlayerInfo {
  address ethereum_address;
  string username;
}

contract InitPlayerNames is DustScript {
  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);

    // Resume broadcasting for migration
    startBroadcast();

    // Run the migration
    console.log("Running migration...");
    runMigration();

    vm.stopBroadcast();
  }

  function runMigration() internal {
    console.log("\nInitializing Player Names");

    string memory root = vm.projectRoot();
    string memory path = string.concat(root, "/script/migrations/3-init-player-names/names.json");
    string memory json = vm.readFile(path);

    bytes memory data = vm.parseJson(json, ".names");
    PlayerInfo[] memory playerInfo = abi.decode(data, (PlayerInfo[]));

    for (uint256 i = 0; i < playerInfo.length; i++) {
      PlayerInfo memory player = playerInfo[i];
      console.log("Player %s has address %s", player.username, player.ethereum_address);
      _setPlayerName(player.ethereum_address, player.username);
    }

    console.log("\nMigration Complete!");
  }
}

function _setPlayerName(address player, string memory name) {
  uint128 validCharacters =
    LibString.to7BitASCIIAllowedLookup("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_");

  require(bytes(name).length > 0 && bytes(name).length <= 32, "Name must be 1-32 characters long.");
  require(LibString.is7BitASCII(name, validCharacters), "Name has invalid characters.");

  bytes32 storedName = LibString.toSmallString(name);
  require(ReversePlayerName.get(storedName) == address(0), "Name is already in use.");

  // free up previous name
  bytes32 previousName = PlayerName.get(player);
  if (previousName != bytes32(0)) {
    ReversePlayerName.deleteRecord(previousName);
  }

  ReversePlayerName.set({ player: player, name: storedName });
  PlayerName.set({ player: player, name: storedName });
}
