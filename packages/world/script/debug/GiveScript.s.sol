// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Script } from "forge-std/Script.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { EntityId, EntityTypeLib } from "../../src/types/EntityId.sol";
import { ObjectTypes } from "../../src/types/ObjectType.sol";

import { ensureDebugSystem } from "./ensureDebugSystem.sol";

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

    ensureDebugSystem(world);

    EntityId playerEntityId = EntityTypeLib.encodePlayer(playerAddress);
    world.debugAddToInventory(playerEntityId, ObjectTypes.OakLog, 99);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Chest, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.MelonSmoothie, 99);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Torch, 99);
    world.debugAddToInventory(playerEntityId, ObjectTypes.ForceField, 3);
    world.debugAddToInventory(playerEntityId, ObjectTypes.TextSign, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Workbench, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Furnace, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Powerstone, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.SpawnTile, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Bed, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Bucket, 1);
    world.debugAddToInventory(playerEntityId, ObjectTypes.WaterBucket, 3);
    world.debugAddToInventory(playerEntityId, ObjectTypes.OakSapling, 10);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Battery, 10);
    world.debugAddToInventory(playerEntityId, ObjectTypes.Wheat, 99);
    world.debugAddToolToInventory(playerEntityId, ObjectTypes.WoodenHoe);
    world.debugAddToolToInventory(playerEntityId, ObjectTypes.IronPick);
    world.debugAddToolToInventory(playerEntityId, ObjectTypes.NeptuniumAxe);

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
