// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";

contract ObjectTypeGasTest is DustTest {
  function testCategoryCheckGas() public {
    ObjectType obj = ObjectType.wrap(uint16(vm.randomUint()));
    bool ok;
    uint256 gasStart = gasleft();
    ok = obj.isBlock();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.isSmartEntity();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.isTool();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.isLeaf();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.isUniqueObject();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.hasExtraDrops();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.hasPickMultiplier();
    console.log(gasStart - gasleft());
    console.log(ok);

    gasStart = gasleft();
    ok = obj.isAny();
    console.log(gasStart - gasleft());
    console.log(ok);
  }
}
