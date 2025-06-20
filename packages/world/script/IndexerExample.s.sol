// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { config } from "./utils/config.sol";
import { IndexerResult, indexer } from "./utils/indexer.sol";

import { ObjectType } from "../src/types/ObjectType.sol";

contract IndexerExample is Script {
  function run() public {
    IndexerResult memory result = indexer(config()).query(
      "SELECT COUNT(*), \"objectType\" FROM \"EntityObjectType\" GROUP BY \"objectType\";", "(uint256,uint16)"
    );

    uint256 totalPassThrough = 0;
    for (uint256 i = 0; i < result.rows.length; i++) {
      bytes memory row = result.rows[i];
      (uint256 count, ObjectType objectType) = abi.decode(row, (uint256, ObjectType));
      if (objectType.isPassThrough()) {
        totalPassThrough += count;
      }
    }

    console.log("Total Pass-Through objects:", totalPassThrough);
  }
}
