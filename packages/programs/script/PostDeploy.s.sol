// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { BedProgram } from "../src/programs/BedProgram.sol";
import { ChestProgram } from "../src/programs/ChestProgram.sol";
import { ForceFieldProgram } from "../src/programs/ForceFieldProgram.sol";
import { SpawnTileProgram } from "../src/programs/SpawnTileProgram.sol";

bytes14 constant DEFAULT_NAMESPACE = "dfprograms_1";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    // Create the programs
    ResourceId ffProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "ForceFieldProgra" });
    if (Systems.getSystem(ffProgramId) == address(0)) {
      ForceFieldProgram forceFieldProgram = new ForceFieldProgram(world);
      world.registerSystem(ffProgramId, forceFieldProgram, false);
    }

    ResourceId chestProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "ChestProgram" });
    if (Systems.getSystem(chestProgramId) == address(0)) {
      ChestProgram chestProgram = new ChestProgram(world);
      world.registerSystem(chestProgramId, chestProgram, false);
    }

    ResourceId bedProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "BedProgram" });
    if (Systems.getSystem(bedProgramId) == address(0)) {
      BedProgram bedProgram = new BedProgram(world);
      world.registerSystem(bedProgramId, bedProgram, false);
    }
    ResourceId spawnTileProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "SpawnTileProgram" });
    if (Systems.getSystem(spawnTileProgramId) == address(0)) {
      SpawnTileProgram spawnTileProgram = new SpawnTileProgram(world);
      world.registerSystem(spawnTileProgramId, spawnTileProgram, false);
    }

    vm.stopBroadcast();
  }
}
