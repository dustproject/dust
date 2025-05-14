// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";

contract ObjectTypeTest is DustTest {
  function testCategories() public pure {
    ObjectType[8] memory logTypes = ObjectTypeLib.getLogTypes();
    for (uint256 i = 0; i < logTypes.length; i++) {
      ObjectType objectType = logTypes[i];
      assertTrue(objectType.isLog());
    }
  }
}
