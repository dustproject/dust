// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";
import { PerfectHashLib } from "../src/utils/PerfectHashLib.sol";

contract ObjectTypeTest is DustTest {
  function testCategoryCheck() public {
    console.log("isBlock");
    uint256 gasStart = gasleft();
    ObjectTypes.AzaleaFlower.isBlock();
    console.log(gasStart - gasleft());

    console.log("!isSmartEntity");
    gasStart = gasleft();
    ObjectTypes.AzaleaFlower.isSmartEntity();
    console.log(gasStart - gasleft());

    console.log("isSmartEntity");
    gasStart = gasleft();
    ObjectTypes.Fragment.isSmartEntity();
    console.log(gasStart - gasleft());

    console.log("isTool");
    gasStart = gasleft();
    ObjectTypes.WoodenPick.isTool();
    console.log(gasStart - gasleft());

    console.log("!isTool");
    gasStart = gasleft();
    ObjectTypes.Player.isTool();
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
      console.log(smartEntityTypes[i].unwrap());
      assertTrue(smartEntityTypes[i].isSmartEntity(), "isSmartEntity");
    }

    for (uint256 i = 0; i < logTypes.length; i++) {
      assertTrue(!logTypes[i].isPassThrough(), "isLog should not be pass through");
    }

    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      assertTrue(!passthroughTypes[i].isLog(), "isPassThrough should not be log");
    }
  }
}
