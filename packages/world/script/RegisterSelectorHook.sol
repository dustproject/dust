// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SystemHook } from "@latticexyz/world/src/SystemHook.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/init/implementations/WorldRegistrationSystem.sol";

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

contract RegisterSelectorHook is SystemHook {
  function onBeforeCallSystem(address, ResourceId, bytes calldata callData) external pure {
    // If not root namespace and trying to register a function selector, revert
    if (bytes4(callData[:4]) == WorldRegistrationSystem.registerFunctionSelector.selector) {
      revert("RegisterSelectorHook: Cannot register function selector in non-root namespace");
    }
  }

  function onAfterCallSystem(address msgSender, ResourceId systemId, bytes memory callData) external { }
}
