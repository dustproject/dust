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
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    EntityId target = EntityId.wrap(0x03000000b500000040fffff62500000000000000000000000000000000000000);

    (uint256 groupId, bool dd) = getGroupId(target);

    EntityId caller = EntityId.wrap(0x01c5e51e5b42c81e37a4ef913f2dcb818d7a285b140000000000000000000000);

    console.log("Group ID:", groupId);
    console.log("dd:", dd);

    console.log("isAllowed:", isAllowed(target, caller));
  }
}
