// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Config } from "./config.sol";
import { Vm, vm } from "./vm.sol";
import { console } from "forge-std/console.sol";

struct Indexer {
  Config config;
}

struct Row {
  bytes data;
}

struct IndexerResult {
  uint256 blockHeight;
  string[] columns;
  bytes[] rows;
}

function indexer(Config memory config) pure returns (Indexer memory) {
  return Indexer(config);
}

library IndexerLib {
  function query(Indexer memory self, string memory sql, string memory schema) internal returns (IndexerResult memory) {
    Vm.FfiResult memory response = _executeQuery(self, sql);
    return _parseResponse(response, schema);
  }

  function waitForWorldPause(Indexer memory self) internal returns (uint256 syncedBlockNumber) {
    // Skip waiting if we're just simulating
    if (!vm.isContext(Vm.ForgeContext.ScriptBroadcast)) {
      // In simulation mode, just return current block height
      IndexerResult memory result = query(self, "SELECT isPaused FROM WorldStatus", "(bool)");
      return result.blockHeight;
    }

    // In broadcast mode, wait until world is paused in the indexer
    uint256 attempts = 0;
    uint256 maxAttempts = 60; // Max 60 seconds wait

    console.log("Waiting for world pause to be indexed...");

    while (attempts < maxAttempts) {
      // Query WorldStatus table to check if paused
      IndexerResult memory result = query(self, "SELECT isPaused FROM WorldStatus", "(bool)");
      syncedBlockNumber = result.blockHeight;

      // Check if world is paused
      if (result.rows.length > 0) {
        bool isPaused = abi.decode(result.rows[0], (bool));
        if (isPaused) {
          // World is paused in indexer, we can proceed
          console.log("World pause confirmed at block:", syncedBlockNumber);
          return syncedBlockNumber;
        }
      }

      // Wait 1 second before trying again
      vm.sleep(1000);
      attempts++;
    }

    revert("Indexer sync timeout: world pause not indexed after 60 seconds");
  }

  function _executeQuery(Indexer memory self, string memory sql) private returns (Vm.FfiResult memory) {
    // Build the JSON request body using vm serialization
    string memory obj = "request";
    vm.serializeAddress(obj, "address", address(self.config.world));
    string memory queryObj = vm.serializeString(obj, "query", sql);

    // Wrap in array
    string memory requestBody = string.concat("[", queryObj, "]");

    // Execute curl command with data directly
    string[] memory inputs = new string[](11);
    inputs[0] = "curl";
    inputs[1] = "-s";
    inputs[2] = "-X";
    inputs[3] = "POST";
    inputs[4] = "-H";
    inputs[5] = "Accept: application/json";
    inputs[6] = "-H";
    inputs[7] = "Content-Type: application/json";
    inputs[8] = "-d";
    inputs[9] = requestBody;
    inputs[10] = self.config.indexerUrl;

    return vm.tryFfi(inputs);
  }

  function _parseResponse(Vm.FfiResult memory response, string memory schema)
    private
    view
    returns (IndexerResult memory result)
  {
    if (response.exitCode != 0) {
      // If the exit code is not 0, return an error
      revert(string(response.stderr));
    }

    string memory json = string(response.stdout);

    // First check if the response is valid JSON
    try vm.parseJson(json) {
      // JSON is valid, continue processing
    } catch (bytes memory e) {
      revert(string.concat("Invalid JSON response:\n", string(e)));
    }

    // Parse the result
    if (!vm.keyExistsJson(json, ".block_height")) {
      revert(string.concat("No block_height field in response.\n", json));
    }

    result.blockHeight = vm.parseJsonUint(json, ".block_height");

    if (!vm.keyExistsJson(json, ".result")) {
      revert(string.concat("No result field in response.\n", json));
    }

    // Get the first result (since we only send one query)
    if (!vm.keyExistsJson(json, ".result[0]")) {
      revert(string.concat("Empty result array.\n", json));
    }

    if (!vm.keyExistsJson(json, ".result[0][0]")) {
      return result;
    }

    result.columns = vm.parseJsonStringArray(json, ".result[0][0]");

    uint256 rowCount = 0;
    while (vm.keyExistsJson(json, _row(rowCount + 1))) {
      rowCount++;
    }

    result.rows = new bytes[](rowCount);
    for (uint256 i = 0; i < rowCount; ++i) {
      result.rows[i] = vm.parseJsonType(json, _row(i + 1), schema);
    }
  }

  function _row(uint256 idx) private pure returns (string memory) {
    return string.concat(".result[0][", vm.toString(idx), "]");
  }
}

using IndexerLib for Indexer global;
