// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";
import { PerfectHashLib } from "../src/utils/PerfectHashLib.sol";

contract ObjectTypeTest is DustTest {
  function testCategoryCheck() public {
    ObjectType obj = ObjectType.wrap(uint16(vm.randomUint()));
    uint256 gasStart = gasleft();
    obj.isBlock();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.isSmartEntity();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.isTool();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.isLeaf();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.isUniqueObject();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.hasExtraDrops();
    console.log(gasStart - gasleft());

    gasStart = gasleft();
    obj.hasPickMultiplier();
    console.log(gasStart - gasleft());
  }

  function testCategories() public pure {
    ObjectType[8] memory logTypes = ObjectTypeLib.getLogTypes();
    for (uint256 i = 0; i < logTypes.length; i++) {
      assertTrue(logTypes[i].isLog(), "isLog");
    }

    ObjectType[2] memory tillableTypes = ObjectTypeLib.getTillableTypes();
    for (uint256 i = 0; i < tillableTypes.length; i++) {
      assertTrue(tillableTypes[i].isTillable(), "isTillable");
    }

    ObjectType[41] memory passthroughTypes = ObjectTypeLib.getPassThroughTypes();
    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      assertTrue(passthroughTypes[i].isPassThrough(), "isPassThrough");
    }

    ObjectType[5] memory smartEntityTypes = ObjectTypeLib.getSmartEntityTypes();
    for (uint256 i = 0; i < smartEntityTypes.length; i++) {
      assertTrue(smartEntityTypes[i].isSmartEntity(), "isSmartEntity");
    }

    for (uint256 i = 0; i < logTypes.length; i++) {
      assertFalse(logTypes[i].isPassThrough(), "isLog should not be pass through");
      assertFalse(logTypes[i].isSmartEntity(), "isLog should not be smart entity");
    }

    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      assertFalse(passthroughTypes[i].isLog(), "isPassThrough should not be log");
      assertFalse(passthroughTypes[i].isSmartEntity(), "isPassThrough should not be smart entity");
    }

    for (uint256 i = 0; i < smartEntityTypes.length; i++) {
      assertFalse(smartEntityTypes[i].isLog(), "smart entity should not be log");
      assertFalse(smartEntityTypes[i].isPassThrough(), "smart entity should not be passthrough");
    }
  }
}
