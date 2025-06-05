// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib, WorldContextProviderLib } from "@latticexyz/world/src/WorldContext.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { EntityId } from "./EntityId.sol";
import { ObjectType } from "./ObjectType.sol";

type ProgramId is bytes32;

function eq(ProgramId a, ProgramId b) pure returns (bool) {
  return ProgramId.unwrap(a) == ProgramId.unwrap(b);
}

library ProgramIdLib {
  function unwrap(ProgramId self) internal pure returns (bytes32) {
    return ProgramId.unwrap(self);
  }

  function exists(ProgramId self) internal pure returns (bool) {
    return ProgramId.unwrap(self) != 0;
  }

  function toResourceId(ProgramId self) internal pure returns (ResourceId) {
    return ResourceId.wrap(ProgramId.unwrap(self));
  }

  function _getAddress(ProgramId self) internal view returns (address) {
    if (!exists(self)) {
      return address(0);
    }
    (address programAddress,) = Systems._get(toResourceId(self));
    return programAddress;
  }

  function getAddress(ProgramId self) internal view returns (address) {
    if (!exists(self)) {
      return address(0);
    }
    (address programAddress,) = Systems.get(toResourceId(self));
    return programAddress;
  }

  function call(ProgramId self, bytes memory hook, uint256 gas) internal returns (bool, bytes memory) {
    // If no program set, allow the call
    address programAddress = getAddress(self);
    if (programAddress == address(0)) {
      return (true, "");
    }

    return programAddress.call{ gas: gas }(_hookContext(hook));
  }

  function call(ProgramId self, bytes memory hook) internal returns (bool, bytes memory) {
    address programAddress = getAddress(self);
    if (programAddress == address(0)) {
      return (true, "");
    }

    return programAddress.call(_hookContext(hook));
  }

  function callOrRevert(ProgramId self, bytes memory callData) internal returns (bytes memory) {
    (bool success, bytes memory returnData) = call(self, callData);
    if (!success) {
      revertWithBytes(returnData);
    }
    return returnData;
  }

  function staticcall(ProgramId self, bytes memory hook) internal view returns (bool, bytes memory) {
    // If no program set, allow the call
    address programAddress = getAddress(self);
    if (programAddress == address(0)) {
      return (true, "");
    }

    // If program is set, call it and return the result
    return programAddress.staticcall(_hookContext(hook));
  }

  function staticcallOrRevert(ProgramId self, bytes memory callData) internal view returns (bytes memory) {
    (bool success, bytes memory returnData) = staticcall(self, callData);
    if (!success) {
      revertWithBytes(returnData);
    }
    return returnData;
  }

  function _hookContext(bytes memory hook) private pure returns (bytes memory) {
    return WorldContextProviderLib.appendContext({ callData: hook, msgSender: address(0), msgValue: 0 });
  }
}

using { eq as == } for ProgramId global;
using ProgramIdLib for ProgramId global;
