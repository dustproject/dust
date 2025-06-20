// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Config, config } from "../../utils/config.sol";
import { IndexerResult } from "../../utils/indexer.sol";

import { ResourceCount } from "../../../src/codegen/tables/ResourceCount.sol";
import { ObjectType, ObjectTypes } from "../../../src/types/ObjectType.sol";

import { Migration } from "../Migration.sol";

contract FixSeedTracking is Migration {
  mapping(ObjectType => uint256) private totalCounts;

  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath(1750380758, "fix-seed-tracking");
  }

  function runMigration() internal override {
    // Define seed and sapling types using ObjectTypes library
    ObjectType[11] memory seedsAndSaplings = [
      // Seeds
      ObjectTypes.WheatSeed,
      ObjectTypes.PumpkinSeed,
      ObjectTypes.MelonSeed,
      // Saplings
      ObjectTypes.OakSapling,
      ObjectTypes.BirchSapling,
      ObjectTypes.JungleSapling,
      ObjectTypes.SakuraSapling,
      ObjectTypes.AcaciaSapling,
      ObjectTypes.SpruceSapling,
      ObjectTypes.DarkOakSapling,
      ObjectTypes.MangroveSapling
    ];

    // Build string for SQL queries
    string memory seedTypes = "";
    for (uint256 i = 0; i < seedsAndSaplings.length; i++) {
      seedTypes = string.concat(seedTypes, vm.toString(seedsAndSaplings[i].unwrap()));
      if (i < seedsAndSaplings.length - 1) {
        seedTypes = string.concat(seedTypes, ", ");
      }
    }

    // Query 1: Get planted seeds/saplings from EntityObjectType
    console.log("\nCurrent Planted tracking:");
    IndexerResult memory plantedResult = recordingQuery(
      string.concat(
        "SELECT objectType, COUNT(*) as count FROM EntityObjectType WHERE objectType IN (",
        seedTypes,
        ") GROUP BY objectType ORDER BY objectType;"
      ),
      "(uint16,uint256)"
    );

    for (uint256 i = 0; i < plantedResult.rows.length; i++) {
      bytes memory row = plantedResult.rows[i];
      (ObjectType objectType, uint256 count) = abi.decode(row, (ObjectType, uint256));
      totalCounts[objectType] = count;
      console.log("Planted - ObjectType:", objectType.unwrap(), "Count:", count);
    }

    // Query 2: Get seeds/saplings in inventories
    console.log("\nCurrent Inventory tracking:");
    IndexerResult memory inventoryResult = recordingQuery(
      string.concat(
        "SELECT objectType, SUM(amount) as count FROM InventorySlot WHERE objectType IN (",
        seedTypes,
        ") GROUP BY objectType ORDER BY objectType;"
      ),
      "(uint16,uint256)"
    );

    for (uint256 i = 0; i < inventoryResult.rows.length; i++) {
      bytes memory row = inventoryResult.rows[i];
      (ObjectType objectType, uint256 count) = abi.decode(row, (ObjectType, uint256));
      totalCounts[objectType] += count;
      console.log("Inventory - ObjectType:", objectType.unwrap(), "Count:", count);
    }

    // Query 3: Get current ResourceCount tracking
    console.log("\nCurrent ResourceCount tracking:");
    IndexerResult memory resourceCountResult = recordingQuery(
      string.concat(
        "SELECT objectType, count FROM ResourceCount WHERE objectType IN (", seedTypes, ") ORDER BY objectType;"
      ),
      "(uint16,uint256)"
    );

    for (uint256 i = 0; i < resourceCountResult.rows.length; i++) {
      bytes memory row = resourceCountResult.rows[i];
      (ObjectType objectType, uint256 count) = abi.decode(row, (ObjectType, uint256));
      console.log("ResourceCount - ObjectType:", objectType.unwrap(), "Current count:", count);
    }

    // Print final totals
    console.log("\nFinal Totals:");
    for (uint256 i = 0; i < seedsAndSaplings.length; i++) {
      ObjectType objectType = seedsAndSaplings[i];
      if (totalCounts[objectType] > 0) {
        console.log("ObjectType:", objectType.unwrap(), "Total count:", totalCounts[objectType]);
      }
    }

    // Start the migration
    console.log("\nRunning Migration");
    startBroadcast();

    // Update ResourceCount table with correct values
    console.log("\nUpdating ResourceCount table...");
    for (uint256 i = 0; i < seedsAndSaplings.length; i++) {
      ObjectType objectType = seedsAndSaplings[i];
      uint256 correctCount = totalCounts[objectType];

      // Get current count from ResourceCount table
      uint256 currentCount = ResourceCount.get(objectType);

      if (currentCount != correctCount) {
        console.log("Updating ObjectType %s: %s -> %s", objectType.unwrap(), currentCount, correctCount);
        recordChange(
          string.concat("Update ObjectType ", vm.toString(objectType.unwrap()), " count"),
          "ResourceCount",
          objectType.unwrap(),
          currentCount,
          correctCount
        );
        ResourceCount.set(objectType, correctCount);
      } else {
        console.log("ObjectType %s already correct: %s", objectType.unwrap(), currentCount);
      }
    }

    console.log("\nMigration Complete!");
  }
}
