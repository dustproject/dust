// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustScript } from "../DustScript.sol";
import { Config, config } from "./config.sol";

contract SetPausedScript is DustScript {
  function run(bool paused) external {
    Config memory cfg = config();

    startBroadcast();

    if (paused) {
      cfg.world.pause();
    } else {
      cfg.world.unpause();
    }

    vm.stopBroadcast();
  }
}
