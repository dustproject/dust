// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Config, config } from "../../utils/config.sol";
import { IndexerResult } from "../../utils/indexer.sol";

import { Mass } from "../../../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../../../src/codegen/tables/ObjectPhysics.sol";
import { EntityId } from "../../../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../../../src/types/ObjectType.sol";

import { Migration } from "../Migration.sol";

contract FixGrowablesMass is Migration {
  mapping(ObjectType => EntityId[]) public entitiesWithoutMass;
  mapping(bytes32 => bool) private hasMass;

  uint256 constant BATCH = 100; // page width

  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("2-fix-growables-mass");
  }

  function runMigration() internal override {
    ObjectType[21] memory growables = [
      // Trees
      ObjectTypes.OakLog,
      ObjectTypes.BirchLog,
      ObjectTypes.JungleLog,
      ObjectTypes.SakuraLog,
      ObjectTypes.AcaciaLog,
      ObjectTypes.SpruceLog,
      ObjectTypes.DarkOakLog,
      ObjectTypes.MangroveLog,
      // Leaves
      ObjectTypes.OakLeaf,
      ObjectTypes.BirchLeaf,
      ObjectTypes.JungleLeaf,
      ObjectTypes.SakuraLeaf,
      ObjectTypes.SpruceLeaf,
      ObjectTypes.AcaciaLeaf,
      ObjectTypes.DarkOakLeaf,
      ObjectTypes.AzaleaLeaf,
      ObjectTypes.FloweringAzaleaLeaf,
      ObjectTypes.MangroveLeaf,
      // Crops
      ObjectTypes.Wheat,
      ObjectTypes.Pumpkin,
      ObjectTypes.Melon
    ];

    // Build string for SQL query
    string memory growableTypes = "";
    for (uint256 i = 0; i < growables.length; i++) {
      growableTypes = string.concat(growableTypes, vm.toString(growables[i].unwrap()));
      if (i < growables.length - 1) {
        growableTypes = string.concat(growableTypes, ", ");
      }
    }
    growableTypes = string.concat("(", growableTypes, ")");

    bytes32 anchor;

    while (true) {
      IndexerResult memory page = recordingQueryNoResults(
        string.concat(
          "SELECT entityId, objectType FROM EntityObjectType WHERE objectType IN ",
          growableTypes,
          " AND entityId  > ",
          _bytea(anchor),
          "ORDER BY entityId LIMIT ",
          vm.toString(BATCH)
        ),
        "(bytes32,uint16)"
      );

      if (page.rows.length == 0) break; // done

      uint256 n = page.rows.length;

      string memory inIds = "";
      bytes32 lastId;
      for (uint256 i; i < n; ++i) {
        (bytes32 id,) = abi.decode(page.rows[i], (bytes32, ObjectType));
        inIds = string.concat(inIds, _bytea(id));
        if (i + 1 < n) inIds = string.concat(inIds, ",");
        lastId = id;
      }
      anchor = lastId; // advance cursor

      IndexerResult memory have = recordingQueryNoResults(
        string.concat("SELECT entityId FROM Mass WHERE entityId IN (", inIds, ");"), "(bytes32)"
      );

      if (n == have.rows.length) {
        console.log("All %s entities have Mass", n);
        continue; // all have Mass, skip to next page
      }

      for (uint256 i; i < have.rows.length; ++i) {
        bytes32 id = abi.decode(have.rows[i], (bytes32));
        hasMass[id] = true;
      }

      for (uint256 i; i < n; ++i) {
        (bytes32 id, ObjectType ot) = abi.decode(page.rows[i], (bytes32, ObjectType));
        if (!hasMass[id]) {
          entitiesWithoutMass[ot].push(EntityId.wrap(id));
        }
        // Clear mapping for next batch
        hasMass[id] = false;
      }
    }

    uint256 totalMissing;
    for (uint256 i; i < growables.length; ++i) {
      totalMissing += entitiesWithoutMass[growables[i]].length;
    }

    console.log("Done. Total entities missing Mass: %s", totalMissing);

    console.log("\nStarting to fix mass for entities...");
    uint256 totalFixed = 0;

    for (uint256 i; i < growables.length; ++i) {
      ObjectType objectType = growables[i];
      EntityId[] memory entities = entitiesWithoutMass[objectType];

      if (entities.length == 0) continue;

      // Get the correct mass for this object type from ObjectPhysics table
      uint128 massValue = ObjectPhysics.getMass(objectType);

      console.log("Fixing ObjectType %s: %s entities with mass %s", objectType.unwrap(), entities.length, massValue);

      // Set mass for all entities of this type
      for (uint256 j; j < entities.length; ++j) {
        Mass.set(entities[j], massValue);

        recordChange(
          string.concat("Set mass for ", vm.toString(objectType.unwrap()), " entity"),
          "Mass",
          vm.toString(EntityId.unwrap(entities[j])),
          "0",
          vm.toString(massValue)
        );

        totalFixed++;

        // Log progress every 100 entities
        if (totalFixed % 100 == 0) {
          console.log("Progress: %s entities fixed", totalFixed);
        }
      }
    }

    console.log("\nMigration complete! Fixed mass for %s entities", totalFixed);
  }

  function _bytea(bytes32 b) internal pure returns (string memory) {
    return string.concat("decode('", vm.replace(vm.toString(b), "0x", ""), "','hex')");
  }
}
