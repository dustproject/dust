// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {console} from "forge-std/console.sol";

import {IndexerResult, indexer} from "../utils/Indexer.sol";
import {Config, config} from "../utils/config.sol";

import {ObjectType, ObjectTypes} from "../../src/types/ObjectType.sol";
import {EntityId} from "../../src/types/EntityId.sol";
import {Mass} from "../../src/codegen/tables/Mass.sol";

import {DustScript} from "../DustScript.sol";

contract FixGrowablesMass is DustScript {
    mapping(ObjectType => uint256) private countByType;

    function run() public {
        Config memory cfg = config();

        // Define growable object types using ObjectTypes library
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

        // Query for entities with these object types
        console.log("Checking growables mass status");

        // Simple query to count growable entities by type
        console.log("Getting counts for each growable type...");
        IndexerResult memory totalCounts = indexer(cfg).query(
            string.concat(
                "SELECT objectType, COUNT(*) as count ",
                "FROM EntityObjectType ",
                "WHERE objectType IN (",
                growableTypes,
                ") ",
                "GROUP BY objectType ",
                "ORDER BY objectType;"
            ),
            "(uint16,uint256)"
        );

        console.log("Found %s growable types with entities", totalCounts.rows.length);

        // Log the counts for each type
        uint256 totalGrowables = 0;
        for (uint256 i = 0; i < totalCounts.rows.length; i++) {
            (ObjectType objectType, uint256 count) = abi.decode(totalCounts.rows[i], (ObjectType, uint256));
            countByType[objectType] = count;
            totalGrowables += count;
            console.log("ObjectType %s: %s entities", objectType.unwrap(), count);
        }

        console.log("\nTotal growable entities: %s", totalGrowables);
        console.log("\nNote: Cannot determine which entities lack mass without JOIN support");
    }
}
