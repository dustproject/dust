// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { DustScript } from "@dust/world/script/DustScript.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { BedProgram } from "../src/programs/BedProgram.sol";
import { ChestProgram } from "../src/programs/ChestProgram.sol";
import { ForceFieldProgram } from "../src/programs/ForceFieldProgram.sol";
import { SpawnTileProgram } from "../src/programs/SpawnTileProgram.sol";
import { TextSignProgram } from "../src/programs/TextSignProgram.sol";

bytes14 constant DEFAULT_NAMESPACE = "dfprograms_1";

contract PostDeploy is DustScript {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Start broadcasting transactions from the deployer account
    startBroadcast();

    IWorld world = IWorld(worldAddress);

    // Create the programs
    ResourceId ffProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "ForceFieldProgra" });
    ForceFieldProgram forceFieldProgram = new ForceFieldProgram(world);
    world.registerSystem(ffProgramId, forceFieldProgram, false);

    console.log("Registered ForceFieldProgram", address(forceFieldProgram));

    ResourceId chestProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "ChestProgram" });
    ChestProgram chestProgram = new ChestProgram(world);
    world.registerSystem(chestProgramId, chestProgram, false);

    console.log("Registered ChestProgram", address(chestProgram));

    ResourceId bedProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "BedProgram" });
    BedProgram bedProgram = new BedProgram(world);
    world.registerSystem(bedProgramId, bedProgram, false);

    console.log("Registered BedProgram", address(bedProgram));

    ResourceId spawnTileProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "SpawnTileProgram" });
    SpawnTileProgram spawnTileProgram = new SpawnTileProgram(world);
    world.registerSystem(spawnTileProgramId, spawnTileProgram, false);

    console.log("Registered SpawnTileProgram", address(spawnTileProgram));

    ResourceId textSignProgramId =
      WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: DEFAULT_NAMESPACE, name: "TextSignProgram" });
    TextSignProgram textSignProgram = new TextSignProgram(world);
    world.registerSystem(textSignProgramId, textSignProgram, false);

    console.log("Registered TextSignProgram", address(textSignProgram));

    vm.stopBroadcast();
  }
}
