// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldStatus } from "../codegen/tables/WorldStatus.sol";

function checkWorldStatus() view {
  require(!WorldStatus._getIsPaused(), "DUST is paused. Try again later");
}
