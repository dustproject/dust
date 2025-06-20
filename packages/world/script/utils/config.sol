// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

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
  if (block.chainid == 690) {
    address worldAddress = 0x253eb85B3C953bFE3827CC14a151262482E7189C;
    return Config({
      world: IWorld(worldAddress),
      fromBlock: 18756337,
      indexerUrl: "https://indexer.mud.redstonechain.com/q"
    });
  } else {
    revert("Unsupported chain");
  }
}
