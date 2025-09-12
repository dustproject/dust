// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { vm } from "./vm.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../../src/codegen/world/IWorld.sol";

struct Config {
  IWorld world;
  uint256 fromBlock;
  string indexerUrl;
}

function config() returns (Config memory) {
  Config memory cfg = _getChainConfig();
  StoreSwitch.setStoreAddress(address(cfg.world));
  return cfg;
}

function _getChainConfig() view returns (Config memory) {
  // Read worlds.json
  string memory worldsPath = string.concat(vm.projectRoot(), "/worlds.json");
  string memory worldsJson = vm.readFile(worldsPath);
  string memory chainIdStr = vm.toString(block.chainid);

  // Check if chain exists in worlds.json
  if (!vm.keyExistsJson(worldsJson, string.concat(".", chainIdStr))) {
    revert(string.concat("Chain ID ", chainIdStr, " not found in worlds.json"));
  }

  // Parse world address
  address worldAddress = vm.parseJsonAddress(worldsJson, string.concat(".", chainIdStr, ".address"));

  // Parse block number (optional)
  uint256 fromBlock = 0;
  if (vm.keyExistsJson(worldsJson, string.concat(".", chainIdStr, ".blockNumber"))) {
    fromBlock = vm.parseJsonUint(worldsJson, string.concat(".", chainIdStr, ".blockNumber"));
  }

  // Set indexer URL based on chain
  string memory indexerUrl;
  if (block.chainid == 690) {
    indexerUrl = "https://indexer.alpha.dustproject.org/q";
  } else {
    revert("Chain ID not supported for indexer URL");
  }

  return Config({ world: IWorld(worldAddress), fromBlock: fromBlock, indexerUrl: indexerUrl });
}
