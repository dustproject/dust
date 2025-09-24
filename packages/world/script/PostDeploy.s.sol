// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { REGISTRATION_SYSTEM_ID } from "@latticexyz/world/src/modules/init/constants.sol";
import { BEFORE_CALL_SYSTEM } from "@latticexyz/world/src/systemHookTypes.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";

import { DustScript } from "./DustScript.sol";

import { RegisterSelectorHook } from "./RegisterSelectorHook.sol";
import { initObjects } from "./initObjects.sol";
import { initRecipes } from "./initRecipes.sol";
import { initTerrain } from "./initTerrain.sol";

contract PostDeploy is DustScript {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Start broadcasting transactions from the deployer account
    startBroadcast();

    RegisterSelectorHook registerSelectorHook = new RegisterSelectorHook();
    IWorld(worldAddress).registerSystemHook(REGISTRATION_SYSTEM_ID, registerSelectorHook, BEFORE_CALL_SYSTEM);

    initTerrain();
    initObjects();
    initRecipes();

    vm.stopBroadcast();
  }
}
