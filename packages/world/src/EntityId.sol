// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ActivateLib, EntityIdLib, EntityType, EntityTypeLib, EntityTypes } from "./utils/EntityIdLib.sol";

type EntityId is bytes32;

function eq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) == EntityId.unwrap(other);
}

function neq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) != EntityId.unwrap(other);
}

using EntityIdLib for EntityId global;
using { eq as ==, neq as != } for EntityId global;

using EntityTypeLib for EntityType;
using EntityTypeLib for EntityId;
