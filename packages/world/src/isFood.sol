// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ObjectTypeId } from "./ObjectTypeId.sol";
import { ObjectTypes } from "./ObjectTypes.sol";

function isFood(ObjectTypeId objectTypeId) pure returns (bool) {
  if (objectTypeId == ObjectTypes.WheatSlop) {
    return true;
  }

  return false;
}
