// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustIsPaused } from "../Errors.sol";
import { WorldStatus } from "../codegen/tables/WorldStatus.sol";

function checkWorldStatus() view {
  if (WorldStatus._getIsPaused()) revert DustIsPaused();
}
