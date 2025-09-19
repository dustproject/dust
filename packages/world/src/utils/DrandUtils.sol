// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { DrandBeacon } from "../codegen/tables/DrandBeacon.sol";
import { IDrandBeacon } from "./IDrandBeacon.sol";

struct DrandData {
  uint256[2] signature;
  uint256 roundNumber;
}

library DrandUtils {
  function verifyWithinTimeRange(DrandData calldata drand, uint256 startTime, uint256 timeRange) internal {
    address beacon = DrandBeacon._getBeacon();
    require(beacon != address(0), "Drand beacon not set");
    uint256 roundTimestamp = IDrandBeacon(beacon).genesisTimestamp() + IDrandBeacon(beacon).period() * drand.roundNumber;
    require(startTime > roundTimestamp && startTime - roundTimestamp <= timeRange, "Drand round not within time range");

    IDrandBeacon(beacon).verifyBeaconRound(drand.roundNumber, drand.signature);
  }

  function getRandomness(DrandData calldata drand) internal view returns (uint256) {
    return uint256(
      keccak256(
        abi.encode(
          drand.signature[0], // entropy
          drand.signature[1], // entropy
          block.chainid, // domain separator
          drand.roundNumber, // salt
          WorldContextConsumerLib._msgSender() // salt
        )
      )
    );
  }
}

using DrandUtils for DrandData global;
