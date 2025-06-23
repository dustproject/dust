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

struct Metadata {
  uint256 blockNumber;
  uint256 blockTimestamp;
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
    startBroadcast();

    // Run the migration
    console.log("Running migration...");
    runMigration();

    vm.stopBroadcast();

    // Write output
    _writeOutput();
  }

  // Override this in child migrations
  function runMigration() internal virtual;

  // Get output path for the migration
  // Migrations should override this to specify their output location
  function getOutputPath() internal view virtual returns (string memory);

  // Helper to construct migration output path from timestamp and name
  function getMigrationOutputPath(string memory name) internal pure returns (string memory) {
    return string.concat("script/migrations/", name, "/output.json");
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

  // Query function that only records the query, not the results
  function recordingQueryNoResults(string memory sql, string memory schema)
    internal
    returns (IndexerResult memory result)
  {
    Indexer memory idx = getIndexer();

    // Execute the query
    result = idx.query(sql, schema);

    // Record only the query metadata, not the results
    queries.push(
      QueryRecord({
        query: sql,
        blockHeight: result.blockHeight,
        columns: result.columns,
        rows: new bytes[](0) // Empty array instead of actual results
       })
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
    // Build metadata struct
    Metadata memory metadata = Metadata({ blockNumber: block.number, blockTimestamp: block.timestamp });
    string memory metadataJson =
      vm.serializeJsonType("Metadata(uint256 blockNumber,uint256 blockTimestamp)", abi.encode(metadata));

    // Serialize all parts
    string memory queriesJson;
    for (uint256 i = 0; i < queries.length; i++) {
      queriesJson = string.concat(
        queriesJson,
        vm.serializeJsonType(
          "QueryRecord(string query,uint256 blockHeight,string[] columns,bytes[] rows)", abi.encode(queries[1])
        )
      );

      if (i < queries.length - 1) queriesJson = string.concat(queriesJson, ",");
    }

    queriesJson = string.concat("[", queriesJson, "]");

    string memory changesJson;
    for (uint256 i = 0; i < changes.length; i++) {
      changesJson = string.concat(
        changesJson,
        vm.serializeJsonType(
          "ChangeRecord(string description,string tableName,string key,string oldValue,string newValue)",
          abi.encode(changes[i])
        )
      );
      if (i < changes.length - 1) changesJson = string.concat(changesJson, ",");
    }

    changesJson = string.concat("[", changesJson, "]");

    // Combine everything into the final output
    string memory output = string.concat(
      "{", '"metadata":', metadataJson, ",", '"queries":', queriesJson, ",", '"changes":', changesJson, "}"
    );

    vm.writeJson(output, getOutputPath());
    console.log("Migration output saved to:", getOutputPath());
  }
}
