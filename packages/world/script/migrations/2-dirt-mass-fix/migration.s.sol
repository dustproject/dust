// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Config, config } from "../../utils/config.sol";

import { ObjectPhysics, ObjectPhysicsData } from "../../../src/codegen/tables/ObjectPhysics.sol";
import { ObjectType, ObjectTypes } from "../../../src/types/ObjectType.sol";

import { Migration } from "../Migration.sol";

contract DirtMassFix is Migration {
  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("2-dirt-mass-fix");
  }

  function runMigration() internal override {
    console.log("\nFixing Dirt mass to match Grass mass");

    // Get current values
    ObjectPhysicsData memory grassPhysics = ObjectPhysics.get(ObjectTypes.Grass);
    ObjectPhysicsData memory dirtPhysics = ObjectPhysics.get(ObjectTypes.Dirt);

    console.log("Current Grass mass:", grassPhysics.mass);
    console.log("Current Dirt mass:", dirtPhysics.mass);

    // Check if update is needed
    if (dirtPhysics.mass != grassPhysics.mass) {
      console.log("Updating Dirt mass to match Grass mass");

      // Record the change
      recordChange(
        "Update Dirt mass to match Grass",
        "ObjectPhysics",
        ObjectTypes.Dirt.unwrap(),
        dirtPhysics.mass,
        grassPhysics.mass
      );

      // Update the Dirt mass to match Grass
      ObjectPhysics.set(ObjectTypes.Dirt, grassPhysics);

      console.log("Dirt mass updated from %s to %s", dirtPhysics.mass, grassPhysics.mass);
    } else {
      console.log("Dirt mass already matches Grass mass, no update needed");
    }

    console.log("\nMigration Complete!");
  }
}
