// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { DustScript } from "@dust/world/script/DustScript.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { BedProgram } from "../src/programs/BedProgram.sol";
import { ChestProgram } from "../src/programs/ChestProgram.sol";
import { ForceFieldProgram } from "../src/programs/ForceFieldProgram.sol";
import { SpawnTileProgram } from "../src/programs/SpawnTileProgram.sol";
import { TextSignProgram } from "../src/programs/TextSignProgram.sol";

import { getGroupId } from "../src/getGroupId.sol";
import { isAllowed } from "../src/isAllowed.sol";

contract GetAccessGroup is DustScript {
  function run(address worldAddress, EntityId target) public {
    StoreSwitch.setStoreAddress(worldAddress);

    (uint256 groupId, bool dd) = getGroupId(target);

    console.log("Group ID:", groupId);
    console.log("Default Deny:", dd);
  }

  function run(address worldAddress, EntityId target, EntityId caller) external {
    run(worldAddress, target);
    console.log("isAllowed:", isAllowed(target, caller));
  }
}
