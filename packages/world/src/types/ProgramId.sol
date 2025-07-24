// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HooksLib } from "../ProgramHooks.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

type ProgramId is bytes32;

library ProgramIdLib {
  function unwrap(ProgramId self) internal pure returns (bytes32) {
    return ProgramId.unwrap(self);
  }

  function exists(ProgramId self) internal pure returns (bool) {
    return self.unwrap() != 0;
  }

  function toResourceId(ProgramId self) internal pure returns (ResourceId) {
    return ResourceId.wrap(self.unwrap());
  }

  function _getAddress(ProgramId self) internal view returns (address) {
    if (!self.exists()) {
      return address(0);
    }
    (address programAddress,) = Systems._get(self.toResourceId());
    return programAddress;
  }

  function getAddress(ProgramId self) internal view returns (address) {
    if (!self.exists()) {
      return address(0);
    }
    (address programAddress,) = Systems.get(self.toResourceId());
    return programAddress;
  }
}

function eq(ProgramId a, ProgramId b) pure returns (bool) {
  return a.unwrap() == b.unwrap();
}

using { eq as == } for ProgramId global;
using ProgramIdLib for ProgramId global;
using HooksLib for ProgramId global;
