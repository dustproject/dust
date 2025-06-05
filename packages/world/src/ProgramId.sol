// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ProgramIdLib } from "./utils/ProgramIdLib.sol";

type ProgramId is bytes32;

function eq(ProgramId a, ProgramId b) pure returns (bool) {
  return ProgramId.unwrap(a) == ProgramId.unwrap(b);
}

using { eq as == } for ProgramId global;

using ProgramIdLib for ProgramId global;
