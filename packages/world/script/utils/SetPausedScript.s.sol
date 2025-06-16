// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { DustScript } from "../DustScript.sol";

contract SetPausedScript is DustScript {
  function run(address worldAddress, bool paused) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    IWorld world = IWorld(worldAddress);
    require(isContract(worldAddress), "Invalid world address provided");

    startBroadcast();

    if (paused) {
      world.pause();
    } else {
      world.unpause();
    }

    vm.stopBroadcast();
  }
}
