// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Config, config } from "../../utils/config.sol";
import { IndexerResult } from "../../utils/indexer.sol";

import { EntityObjectType } from "../../../src/codegen/tables/EntityObjectType.sol";
import { Mass } from "../../../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../../../src/codegen/tables/ObjectPhysics.sol";
import { EntityId } from "../../../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../../../src/types/ObjectType.sol";

import { Migration } from "../Migration.sol";

contract FixGrowablesMass is Migration {
  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("2-fix-growables-mass");
  }

  function runMigration() internal override {
    console.log("Reading entities data from JSON file...");

    // Read the JSON file
    string memory json = vm.readFile("script/migrations/2-fix-growables-mass/data.json");

    // Get metadata
    console.log("Data from block: %s", vm.parseJsonUint(json, ".blockNumber"));
    console.log("Total entities to process: %s", vm.parseJsonUint(json, ".totalEntities"));

    // Get all object type keys
    string[] memory objectTypeKeys = vm.parseJsonKeys(json, ".entitiesWithoutMass");

    uint256 totalFixed = 0;

    // Process each object type
    for (uint256 i = 0; i < objectTypeKeys.length; i++) {
      totalFixed += _processObjectType(json, objectTypeKeys[i], totalFixed);
    }

    console.log("\nMigration complete! Total fixed: %s", totalFixed);
  }

  function _processObjectType(string memory json, string memory objectTypeKey, uint256 currentTotalFixed)
    internal
    returns (uint256)
  {
    uint16 objectTypeValue = uint16(vm.parseUint(objectTypeKey));

    console.log("\nProcessing ObjectType %s", objectTypeValue);

    // Get mass from ObjectPhysics table
    ObjectType objectType = ObjectType.wrap(objectTypeValue);
    uint128 massValue = ObjectPhysics.getMass(objectType);

    // Get entity IDs from JSON
    string memory typePath = string.concat(".entitiesWithoutMass.", objectTypeKey);
    bytes32[] memory entityIds = vm.parseJsonBytes32Array(json, string.concat(typePath, ".entities"));

    console.log("Expected mass: %s, Entity count: %s", massValue, entityIds.length);

    uint256 fixedCount = 0;
    uint256 skippedCount = 0;

    // Process entities
    for (uint256 i = 0; i < entityIds.length; i++) {
      if (_fixEntity(EntityId.wrap(entityIds[i]), objectTypeValue, massValue)) {
        fixedCount++;

        // Log progress
        if ((currentTotalFixed + fixedCount) % 100 == 0) {
          console.log("Progress: %s entities fixed", currentTotalFixed + fixedCount);
        }
      } else {
        skippedCount++;
      }
    }

    console.log("Batch complete: fixed %s, skipped %s", fixedCount, skippedCount);
    return fixedCount;
  }

  function _fixEntity(EntityId entityId, uint16 objectTypeValue, uint128 massValue) internal returns (bool) {
    // Verify entity still has the same object type
    if (EntityObjectType.getObjectType(entityId).unwrap() != objectTypeValue) {
      return false;
    }

    // Check current mass
    if (Mass.get(entityId) != 0) {
      return false;
    }

    // Set the mass
    Mass.set(entityId, massValue);

    recordChange(
      string.concat("Set mass for ObjectType ", vm.toString(objectTypeValue)),
      "Mass",
      vm.toString(entityId.unwrap()),
      "0",
      vm.toString(massValue)
    );

    return true;
  }
}
