// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "./EntityId.sol";
import { Vec3 } from "./Vec3.sol";

type EntityType is bytes1;

library EntityTypes {
  EntityType constant Incremental = EntityType.wrap(0x00);
  EntityType constant Player = EntityType.wrap(0x01);
  EntityType constant Fragment = EntityType.wrap(0x02);
  EntityType constant Block = EntityType.wrap(0x03);
}

library EntityTypeLib {
  function unwrap(EntityType self) internal pure returns (bytes1) {
    return EntityType.unwrap(self);
  }

  function encode(EntityType self, bytes31 data) internal pure returns (EntityId) {
    return EntityId.wrap(bytes32(EntityType.unwrap(self)) | bytes32(data) >> 8);
  }

  function decode(EntityId self) internal pure returns (EntityType, bytes31) {
    bytes32 _self = EntityId.unwrap(self);
    EntityType entityType = EntityType.wrap(bytes1(_self));
    return (entityType, bytes31(_self << 8));
  }

  function getEntityType(EntityId self) internal pure returns (EntityType) {
    return EntityType.wrap(bytes1(EntityId.unwrap(self)));
  }

  function encodeBlock(Vec3 coord) internal pure returns (EntityId) {
    return _encodeCoord(EntityTypes.Block, coord);
  }

  function encodeFragment(Vec3 coord) internal pure returns (EntityId) {
    return _encodeCoord(EntityTypes.Fragment, coord);
  }

  function encodePlayer(address player) internal pure returns (EntityId) {
    return EntityTypeLib.encode(EntityTypes.Player, bytes20(player));
  }

  function decodeBlock(EntityId self) internal pure returns (Vec3) {
    (EntityType entityType, Vec3 coord) = _decodeCoord(self);
    require(entityType == EntityTypes.Block, "Entity is not a block");
    return coord;
  }

  function decodeFragment(EntityId self) internal pure returns (Vec3) {
    (EntityType entityType, Vec3 coord) = _decodeCoord(self);
    require(entityType == EntityTypes.Fragment, "Entity is not a fragment");
    return coord;
  }

  function decodePlayer(EntityId self) internal pure returns (address) {
    (EntityType entityType, bytes31 data) = decode(self);
    require(entityType == EntityTypes.Player, "Entity is not a player");
    return address(bytes20(data));
  }

  function _encodeCoord(EntityType entityType, Vec3 coord) private pure returns (EntityId) {
    return EntityTypeLib.encode(entityType, bytes12(coord.unwrap()));
  }

  function _decodeCoord(EntityId self) internal pure returns (EntityType, Vec3) {
    (EntityType entityType, bytes31 data) = decode(self);
    return (entityType, Vec3.wrap(uint96(uint256(bytes32(data) >> 160))));
  }
}

function eq(EntityType self, EntityType other) pure returns (bool) {
  return EntityType.unwrap(self) == EntityType.unwrap(other);
}

function neq(EntityType self, EntityType other) pure returns (bool) {
  return EntityType.unwrap(self) != EntityType.unwrap(other);
}

using { eq as ==, neq as != } for EntityType global;

using EntityTypeLib for EntityType;
using EntityTypeLib for EntityId;
