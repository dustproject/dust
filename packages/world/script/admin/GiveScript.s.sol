// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { EntityId, EntityTypeLib } from "../../src/EntityId.sol";
import { ObjectTypes } from "../../src/codegen/ObjectTypes.sol";

import { ensureAdminSystem } from "./ensureAdminSystem.sol";

contract GiveScript is Script {
  function run(address worldAddress, address playerAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    IWorld world = IWorld(worldAddress);
    require(isContract(worldAddress), "Invalid world address provided");

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    ensureAdminSystem(world);

    EntityId playerEntityId = EntityTypeLib.encodePlayer(playerAddress);
    world.adminAddToInventory(playerEntityId, ObjectTypes.OakLog, 99);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Chest, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.MelonSmoothie, 99);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Torch, 99);
    world.adminAddToInventory(playerEntityId, ObjectTypes.ForceField, 3);
    world.adminAddToInventory(playerEntityId, ObjectTypes.TextSign, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Workbench, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Furnace, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Powerstone, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.SpawnTile, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Bed, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Bucket, 1);
    world.adminAddToInventory(playerEntityId, ObjectTypes.WaterBucket, 3);
    world.adminAddToInventory(playerEntityId, ObjectTypes.OakSapling, 10);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Battery, 10);
    world.adminAddToInventory(playerEntityId, ObjectTypes.Wheat, 99);
    world.adminAddToolToInventory(playerEntityId, ObjectTypes.WoodenHoe);
    world.adminAddToolToInventory(playerEntityId, ObjectTypes.IronPick);
    world.adminAddToolToInventory(playerEntityId, ObjectTypes.NeptuniumAxe);

    vm.stopBroadcast();
  }

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }
}
