// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldStatus } from "./codegen/tables/WorldStatus.sol";

function checkWorldStatus() view {
  require(!WorldStatus._getInMaintenance(), "DUST is in maintenance mode. Try again later");
}
