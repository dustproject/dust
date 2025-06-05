// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectTypeLib } from "../codegen/ObjectTypeLib.sol";
import "../codegen/ObjectTypes.sol" as ObjectTypes;

type ObjectType is uint16;

// Structs
struct ObjectAmount {
  ObjectType objectType;
  uint16 amount;
}

function eq(ObjectType self, ObjectType other) pure returns (bool) {
  return ObjectType.unwrap(self) == ObjectType.unwrap(other);
}

function neq(ObjectType self, ObjectType other) pure returns (bool) {
  return ObjectType.unwrap(self) != ObjectType.unwrap(other);
}

using { eq as ==, neq as != } for ObjectType global;
using ObjectTypeLib for ObjectType global;
