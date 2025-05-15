// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { metadataSystem } from
  "@latticexyz/world-module-metadata/src/codegen/experimental/systems/MetadataSystemLib.sol";
import { ResourceId, WorldResourceIdInstance, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "@dust/world/src/codegen/world/IWorld.sol";

contract RegisterApp is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    ResourceId appNamespaceId = WorldResourceIdLib.encodeNamespace("pos-hud");

    world.registerNamespace(appNamespaceId);
    metadataSystem.setResourceTag(appNamespaceId, "dust.appConfigUrl", bytes("http://localhost:5501/dust-app.json"));

    vm.stopBroadcast();
  }
}
