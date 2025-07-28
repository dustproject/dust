// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { DustTest } from "./DustTest.sol";

contract MockSystem is System {
  function foo() external pure { }
}

contract WorldTest is DustTest {
  function testRegisterFunctionSelector() public {
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace("someNamespace");
    world.registerNamespace(namespaceId);
    ResourceId systemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "someNamespace", "someSystem");
    world.registerSystem(systemId, new MockSystem(), true);

    vm.expectRevert("RegisterSelectorHook: Cannot register function selector in non-root namespace");
    world.registerFunctionSelector(systemId, "foo()");
  }
}
