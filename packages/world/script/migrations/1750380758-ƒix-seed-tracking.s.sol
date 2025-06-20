// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { IndexerResult, indexer } from "../utils/Indexer.sol";
import { Config, config } from "../utils/config.sol";

import { ResourceCount } from "../../src/codegen/tables/ResourceCount.sol";
import { ObjectType } from "../../src/types/ObjectType.sol";

import { DustScript } from "../DustScript.sol";

contract FixSeedTracking is DustScript {
  mapping(ObjectType => uint256) private totalCounts;

  function run() public {
    Config memory cfg = config();

    // Query 1: Get planted seeds/saplings from EntityObjectType
    console.log("\nCurrent Planted tracking:");
    IndexerResult memory plantedResult = indexer(cfg).query(
      "SELECT \"objectType\", COUNT(*) as count FROM \"EntityObjectType\" WHERE \"objectType\" IN (134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144) GROUP BY \"objectType\" ORDER BY \"objectType\";",
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
    IndexerResult memory inventoryResult = indexer(cfg).query(
      "SELECT \"objectType\", SUM(\"amount\") as count FROM \"InventorySlot\" WHERE \"objectType\" IN (134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144) GROUP BY \"objectType\" ORDER BY \"objectType\";",
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
    IndexerResult memory resourceCountResult = indexer(cfg).query(
      "SELECT \"objectType\", \"count\" FROM \"ResourceCount\" WHERE \"objectType\" IN (134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144) ORDER BY \"objectType\";",
      "(uint16,uint256)"
    );

    for (uint256 i = 0; i < resourceCountResult.rows.length; i++) {
      bytes memory row = resourceCountResult.rows[i];
      (ObjectType objectType, uint256 count) = abi.decode(row, (ObjectType, uint256));
      console.log("ResourceCount - ObjectType:", objectType.unwrap(), "Current count:", count);
    }

    // Print final totals
    console.log("\nFinal Totals:");
    uint16[11] memory seedTypes = [uint16(134), 135, 136, 137, 138, 139, 140, 141, 142, 143, 144];
    for (uint256 i = 0; i < seedTypes.length; i++) {
      ObjectType objectType = ObjectType.wrap(seedTypes[i]);
      if (totalCounts[objectType] > 0) {
        console.log("ObjectType:", objectType.unwrap(), "Total count:", totalCounts[objectType]);
      }
    }

    // Start the migration
    console.log("\nRunning Migration");
    startBroadcast();

    // Pause the world
    console.log("Pausing world...");
    cfg.world.pause();

    // Update ResourceCount table with correct values
    console.log("\nUpdating ResourceCount table...");
    for (uint256 i = 0; i < seedTypes.length; i++) {
      ObjectType objectType = ObjectType.wrap(seedTypes[i]);
      uint256 correctCount = totalCounts[objectType];

      // Get current count from ResourceCount table
      uint256 currentCount = ResourceCount.get(objectType);

      if (currentCount != correctCount) {
        console.log("Updating ObjectType %s: %s -> %s", objectType.unwrap(), currentCount, correctCount);
        ResourceCount.set(objectType, correctCount);
      } else {
        console.log("ObjectType %s already correct: %s", objectType.unwrap(), currentCount);
      }
    }

    // Unpause the world
    console.log("\nUnpausing world...");
    cfg.world.unpause();

    vm.stopBroadcast();
    console.log("\nMigration Complete!");
  }
}
