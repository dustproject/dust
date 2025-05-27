// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { REGISTRATION_SYSTEM_ID } from "@latticexyz/world/src/modules/init/constants.sol";
import { BEFORE_CALL_SYSTEM } from "@latticexyz/world/src/systemHookTypes.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { RegisterSelectorHook } from "./RegisterSelectorHook.sol";
import { initObjects } from "./initObjects.sol";
import { initRecipes } from "./initRecipes.sol";
import { initTerrain } from "./initTerrain.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    postDeploy(worldAddress);

    vm.stopBroadcast();
  }

  // TODO: remove this once MUD supports PostDeploy with KMS: https://github.com/latticexyz/mud/issues/3716
  function run(address worldAddress, address deployerAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerAddress);

    postDeploy(worldAddress);

    vm.stopBroadcast();
  }

  function postDeploy(address worldAddress) internal {
    RegisterSelectorHook registerSelectorHook = new RegisterSelectorHook();
    IWorld(worldAddress).registerSystemHook(REGISTRATION_SYSTEM_ID, registerSelectorHook, BEFORE_CALL_SYSTEM);

    initTerrain();
    initObjects();
    initRecipes();
  }
}
