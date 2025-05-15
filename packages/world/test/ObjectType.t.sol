// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";

contract ObjectTypeTest is DustTest {
  function testCategories() public pure {
    ObjectType[8] memory logTypes = ObjectTypeLib.getLogTypes();
    for (uint256 i = 0; i < logTypes.length; i++) {
      assertTrue(logTypes[i].isLog(), "isLog");
    }

    ObjectType[41] memory passthroughTypes = ObjectTypeLib.getPassThroughTypes();
    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      assertTrue(passthroughTypes[i].isPassThrough(), "isPassThrough");
    }

    for (uint256 i = 0; i < logTypes.length; i++) {
      assertTrue(!logTypes[i].isPassThrough(), "isLog should not be pass through");
    }

    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      assertTrue(!passthroughTypes[i].isLog(), "isPassThrough should not be log");
    }
  }
}
