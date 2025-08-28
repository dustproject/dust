// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";
import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { EntityPosition } from "../utils/Vec3Storage.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";

import { MAX_ENTITY_INFLUENCE_RADIUS } from "../Constants.sol";
import { ObjectType, ObjectTypes } from "./ObjectType.sol";

import { ProgramId } from "./ProgramId.sol";
import { Vec3, vec3 } from "./Vec3.sol";

type EntityId is bytes32;

type EntityType is bytes1;

library EntityIdLib {
  // We need to use this internal library function in order to obtain the msg.sig and msg.sender
  function activate(EntityId self) internal returns (EnergyData memory) {
    address caller = WorldContextConsumerLib._msgSender();
    return ActivateLib._activate(self, caller, msg.sig);
  }

  function _validateCaller(EntityId self, address caller, ObjectType objectType) internal view {
    if (objectType == ObjectTypes.Player) {
      require(caller == self.getPlayerAddress(), "Caller not allowed");
    } else {
      address programAddress = self._getProgram()._getAddress();
      require(caller == programAddress, "Caller not allowed");
    }
  }

  function _validateCaller(EntityId self, address sender) internal view {
    _validateCaller(self, sender, self._getObjectType());
  }

  function _validateCaller(EntityId self) internal view {
    _validateCaller(self, WorldContextConsumerLib._msgSender());
  }

  function validateCaller(EntityId self, address caller, ObjectType objectType) internal view {
    if (objectType == ObjectTypes.Player) {
      require(caller == self.getPlayerAddress(), "Caller not allowed");
    } else {
      address programAddress = self.getProgram().getAddress();
      require(caller == programAddress, "Caller not allowed");
    }
  }

  function validateCaller(EntityId self, address caller) internal view {
    validateCaller(self, caller, self.getObjectType());
  }

  function validateCaller(EntityId self) internal view {
    validateCaller(self, WorldContextConsumerLib._msgSender());
  }

  function _baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId base = BaseEntity._get(self);
    return base.unwrap() == 0 ? self : base;
  }

  function baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId base = BaseEntity.get(self);
    return base.unwrap() == 0 ? self : base;
  }

  function requireInRange(EntityId self, Vec3 otherCoord, uint256 range) internal view returns (Vec3, Vec3) {
    Vec3 selfCoord = self._getPosition();
    Vec3 coord = self._getObjectType() == ObjectTypes.Player ? selfCoord + vec3(0, 1, 0) : selfCoord;
    require(coord.inSphere(otherCoord, range), "Entity is too far");
    return (selfCoord, otherCoord);
  }

  function requireInRange(EntityId self, EntityId other, uint256 range) internal view returns (Vec3, Vec3) {
    return requireInRange(self, other._getPosition(), range);
  }

  // TODO: add pipe connections
  function requireConnected(EntityId self, EntityId other) internal view returns (Vec3, Vec3) {
    return requireConnected(self, other._getPosition());
  }

  function requireConnected(EntityId self, Vec3 otherCoord) internal view returns (Vec3, Vec3) {
    return requireInRange(self, otherCoord, MAX_ENTITY_INFLUENCE_RADIUS);
  }

  function requireAdjacentToFragment(EntityId self, EntityId fragment) internal view returns (Vec3, Vec3) {
    return requireAdjacentToFragment(self, fragment._getPosition());
  }

  function requireAdjacentToFragment(EntityId self, Vec3 fragmentCoord) internal view returns (Vec3, Vec3) {
    Vec3 selfFragmentCoord = self._getPosition().toFragmentCoord();
    require(selfFragmentCoord.inSurroundingCube(fragmentCoord, 1), "Fragment is too far");
    return (selfFragmentCoord, fragmentCoord);
  }

  function _getPosition(EntityId self) internal view returns (Vec3) {
    (EntityType entityType, Vec3 coord) = EntityTypeLib._decodeCoord(self);
    if (entityType == EntityTypes.Block || entityType == EntityTypes.Fragment) {
      return coord;
    }
    return EntityPosition._get(self);
  }

  function getPosition(EntityId self) internal view returns (Vec3) {
    (EntityType entityType, Vec3 coord) = EntityTypeLib._decodeCoord(self);
    if (entityType == EntityTypes.Block || entityType == EntityTypes.Fragment) {
      return coord;
    }
    return EntityPosition.get(self);
  }

  function _getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram._get(self);
  }

  function getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram.get(self);
  }

  function _getObjectType(EntityId self) internal view returns (ObjectType) {
    return EntityObjectType._get(self);
  }

  function getObjectType(EntityId self) internal view returns (ObjectType) {
    return EntityObjectType.get(self);
  }

  function _exists(EntityId self) internal view returns (bool) {
    return self.unwrap() != 0 && !self._getObjectType().isNull();
  }

  function exists(EntityId self) internal view returns (bool) {
    return self.unwrap() != 0 && !self.getObjectType().isNull();
  }

  function unwrap(EntityId self) internal pure returns (bytes32) {
    return EntityId.unwrap(self);
  }

  function getPlayerAddress(EntityId self) internal pure returns (address) {
    return self.decodePlayer();
  }
}

function eq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) == EntityId.unwrap(other);
}

function neq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) != EntityId.unwrap(other);
}

library ActivateLib {
  function _activate(EntityId self, address caller, bytes4 sig) public returns (EnergyData memory) {
    checkWorldStatus();

    ObjectType objectType = self._getObjectType();
    require(objectType.isActionAllowed(sig), "Action not allowed");

    self._validateCaller(caller, objectType);

    EnergyData memory energyData;
    if (objectType == ObjectTypes.Player) {
      require(!PlayerBed._getBedEntityId(self)._exists(), "Player is sleeping");
      energyData = updatePlayerEnergy(self);
    } else {
      EntityId forceField;
      if (objectType == ObjectTypes.ForceField) {
        forceField = self;
      } else {
        (forceField,) = ForceFieldUtils.getForceField(self._getPosition());
      }

      energyData = updateMachineEnergy(forceField);
    }

    require(energyData.energy > 0, "Entity has no energy");

    return energyData;
  }
}

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
    return EntityId.wrap(bytes32(self.unwrap()) | bytes32(data) >> 8);
  }

  function decode(EntityId self) internal pure returns (EntityType, bytes31) {
    bytes32 _self = self.unwrap();
    EntityType entityType = EntityType.wrap(bytes1(_self));
    return (entityType, bytes31(_self << 8));
  }

  function getEntityType(EntityId self) internal pure returns (EntityType) {
    return EntityType.wrap(bytes1(self.unwrap()));
  }

  function encodeBlock(Vec3 coord) internal pure returns (EntityId) {
    return _encodeCoord(EntityTypes.Block, coord);
  }

  function encodeFragment(Vec3 coord) internal pure returns (EntityId) {
    return _encodeCoord(EntityTypes.Fragment, coord);
  }

  function encodePlayer(address player) internal pure returns (EntityId) {
    return EntityTypes.Player.encode(bytes20(player));
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
    return entityType.encode(bytes12(coord.unwrap()));
  }

  function _decodeCoord(EntityId self) internal pure returns (EntityType, Vec3) {
    (EntityType entityType, bytes31 data) = decode(self);
    return (entityType, Vec3.wrap(uint96(uint256(bytes32(data) >> 160))));
  }
}

function typeEq(EntityType self, EntityType other) pure returns (bool) {
  return EntityType.unwrap(self) == EntityType.unwrap(other);
}

using EntityIdLib for EntityId global;
using { eq as ==, neq as != } for EntityId global;

using EntityTypeLib for EntityType;
using EntityTypeLib for EntityId;
using { typeEq as == } for EntityType global;
