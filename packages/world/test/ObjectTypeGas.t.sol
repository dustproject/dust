// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";

contract ObjectTypeGasTest is DustTest {
  function testCategoryCheckGas() public {
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
}
