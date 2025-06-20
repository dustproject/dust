// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustScript } from "../DustScript.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";
import { Config, config } from "../utils/config.sol";
import { Indexer, IndexerResult, indexer } from "../utils/indexer.sol";
import { Vm, vm } from "../utils/vm.sol";

import { console } from "forge-std/console.sol";

struct QueryRecord {
  string query;
  uint256 blockHeight;
  string[] columns;
  bytes[] rows;
}

struct ChangeRecord {
  string description;
  string tableName;
  string key;
  string oldValue;
  string newValue;
}

abstract contract Migration is DustScript {
  QueryRecord[] internal queries;
  ChangeRecord[] internal changes;

  function run() public {
    // Get config
    Config memory cfg = config();

    // Wait for indexer to confirm world is paused
    Indexer memory idx = indexer(cfg);
    uint256 syncedBlock = idx.waitForWorldPause();
    console.log("Indexer synced to block:", syncedBlock);

    // Resume broadcasting for migration
    if (vm.isContext(Vm.ForgeContext.ScriptBroadcast)) {
      startBroadcast();
    }

    // Run the migration
    console.log("Running migration...");
    runMigration();

    // Stop broadcasting
    if (vm.isContext(Vm.ForgeContext.ScriptBroadcast)) {
      vm.stopBroadcast();
    }

    // Write output
    _writeOutput();
  }

  // Override this in child migrations
  function runMigration() internal virtual;

  // Get output path for the migration
  // Migrations should override this to specify their output location
  function getOutputPath() internal view virtual returns (string memory);

  // Helper to construct migration output path from timestamp and name
  function getMigrationOutputPath(uint256 timestamp, string memory name) internal pure returns (string memory) {
    return string.concat("script/migrations/", vm.toString(timestamp), "-", name, "/output.json");
  }

  // Get an indexer that records queries
  function getIndexer() internal returns (Indexer memory) {
    return indexer(config());
  }

  // Query function that records
  function recordingQuery(string memory sql, string memory schema) internal returns (IndexerResult memory result) {
    Indexer memory idx = getIndexer();

    // Execute the query
    result = idx.query(sql, schema);

    // Record it
    queries.push(
      QueryRecord({ query: sql, blockHeight: result.blockHeight, columns: result.columns, rows: result.rows })
    );

    return result;
  }

  // Record a state change
  function recordChange(
    string memory description,
    string memory tableName,
    string memory key,
    string memory oldValue,
    string memory newValue
  ) internal {
    changes.push(
      ChangeRecord({ description: description, tableName: tableName, key: key, oldValue: oldValue, newValue: newValue })
    );
  }

  // Overloaded version for uint256 values
  function recordChange(
    string memory description,
    string memory tableName,
    uint256 key,
    uint256 oldValue,
    uint256 newValue
  ) internal {
    recordChange(description, tableName, vm.toString(key), vm.toString(oldValue), vm.toString(newValue));
  }

  function _writeOutput() private {
    string memory json = "";

    // Start JSON object
    json = string.concat(json, "{\n");

    // Add queries array
    json = string.concat(json, '  "queries": [\n');
    for (uint256 i = 0; i < queries.length; i++) {
      json = string.concat(json, "    {\n");
      json = string.concat(json, '      "query": "', _escapeJson(queries[i].query), '",\n');
      json = string.concat(json, '      "blockHeight": ', vm.toString(queries[i].blockHeight), ",\n");

      // Add columns
      json = string.concat(json, '      "columns": [');
      for (uint256 j = 0; j < queries[i].columns.length; j++) {
        json = string.concat(json, '"', queries[i].columns[j], '"');
        if (j < queries[i].columns.length - 1) json = string.concat(json, ", ");
      }
      json = string.concat(json, "],\n");

      // Add rows (as hex strings)
      json = string.concat(json, '      "rows": [');
      for (uint256 j = 0; j < queries[i].rows.length; j++) {
        json = string.concat(json, '"', vm.toString(queries[i].rows[j]), '"');
        if (j < queries[i].rows.length - 1) json = string.concat(json, ", ");
      }
      json = string.concat(json, "]\n");

      json = string.concat(json, "    }");
      if (i < queries.length - 1) json = string.concat(json, ",");
      json = string.concat(json, "\n");
    }
    json = string.concat(json, "  ],\n");

    // Add changes array
    json = string.concat(json, '  "changes": [\n');
    for (uint256 i = 0; i < changes.length; i++) {
      json = string.concat(json, "    {\n");
      json = string.concat(json, '      "description": "', changes[i].description, '",\n');
      json = string.concat(json, '      "tableName": "', changes[i].tableName, '",\n');
      json = string.concat(json, '      "key": "', changes[i].key, '",\n');
      json = string.concat(json, '      "oldValue": "', changes[i].oldValue, '",\n');
      json = string.concat(json, '      "newValue": "', changes[i].newValue, '"\n');
      json = string.concat(json, "    }");
      if (i < changes.length - 1) json = string.concat(json, ",");
      json = string.concat(json, "\n");
    }
    json = string.concat(json, "  ]\n");

    // Close JSON object
    json = string.concat(json, "}\n");

    // Write to file using the path specified by the migration
    string memory outputPath = getOutputPath();
    vm.writeFile(outputPath, json);
    console.log("Migration output saved to:", outputPath);
  }

  function _escapeJson(string memory str) private pure returns (string memory) {
    // Basic JSON escaping - in production would need more comprehensive escaping
    // For now, just return the string as-is
    return str;
  }
}
