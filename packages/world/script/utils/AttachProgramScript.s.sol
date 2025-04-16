// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { EntityId } from "../../src/EntityId.sol";

import { ObjectTypes } from "../../src/ObjectTypes.sol";
import { ProgramId } from "../../src/ProgramId.sol";
import { Player } from "../../src/codegen/tables/Player.sol";

contract AttachProgramScript is Script {
  function run(address worldAddress, address playerAddress, EntityId target, ProgramId program, bytes memory extraData)
    external
  {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    IWorld world = IWorld(worldAddress);
    require(isContract(worldAddress), "Invalid world address provided");

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    EntityId playerEntityId = Player.get(playerAddress);
    require(playerEntityId.exists(), "Player entity not found");

    world.attachProgram(playerEntityId, target, program, extraData);

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
