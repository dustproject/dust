// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";
import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "./EnergyUtils.sol";
import { ForceFieldUtils } from "./ForceFieldUtils.sol";
import { EntityPosition } from "./Vec3Storage.sol";

import { MAX_ENTITY_INFLUENCE_RADIUS } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { ProgramId } from "../ProgramId.sol";
import { ObjectTypes } from "../codegen/ObjectTypes.sol";

import { checkWorldStatus } from "../Utils.sol";
import { Vec3, vec3 } from "../Vec3.sol";
import { ProgramIdLib } from "./ProgramIdLib.sol";

type EntityType is bytes1;

function eq(EntityType self, EntityType other) pure returns (bool) {
  return EntityType.unwrap(self) == EntityType.unwrap(other);
}

function neq(EntityType self, EntityType other) pure returns (bool) {
  return EntityType.unwrap(self) != EntityType.unwrap(other);
}

using { eq as ==, neq as != } for EntityType global;

library EntityIdLib {
  // Higher-order implementation functions (private)
  function _validateCallerImpl(
    EntityId self,
    address caller,
    ObjectType objectType,
    function(EntityId) internal view returns (ProgramId) getProgramFn,
    function(ProgramId) internal view returns (address) getAddressFn
  ) private view {
    if (objectType == ObjectTypes.Player) {
      require(caller == EntityTypeLib.decodePlayer(self), "Caller not allowed");
    } else {
      address programAddress = getAddressFn(getProgramFn(self));
      require(caller == programAddress, "Caller not allowed");
    }
  }

  function _getPositionImpl(EntityId self, function(EntityId) internal view returns (Vec3) getEntityPositionFn)
    private
    view
    returns (Vec3)
  {
    (EntityType entityType, Vec3 coord) = EntityTypeLib._decodeCoord(self);
    if (entityType == EntityTypes.Block || entityType == EntityTypes.Fragment) {
      return coord;
    }
    return getEntityPositionFn(self);
  }

  function _existsImpl(EntityId self, function(EntityId) internal view returns (ObjectType) getObjectTypeFn)
    private
    view
    returns (bool)
  {
    return EntityId.unwrap(self) != 0 && !getObjectTypeFn(self).isNull();
  }

  // Root (public table access) methods
  function validateCaller(EntityId self, address caller, ObjectType objectType) internal view {
    _validateCallerImpl(self, caller, objectType, getProgram, ProgramIdLib.getAddress);
  }

  function validateCaller(EntityId self, address caller) internal view {
    validateCaller(self, caller, getObjectType(self));
  }

  function validateCaller(EntityId self) internal view {
    validateCaller(self, WorldContextConsumerLib._msgSender());
  }

  function getPosition(EntityId self) internal view returns (Vec3) {
    return _getPositionImpl(self, EntityPosition.get);
  }

  function getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram.get(self);
  }

  function getObjectType(EntityId self) internal view returns (ObjectType) {
    return EntityObjectType.get(self);
  }

  function exists(EntityId self) internal view returns (bool) {
    return _existsImpl(self, getObjectType);
  }

  // Non-root (internal table access) methods
  function _validateCaller(EntityId self, address caller, ObjectType objectType) internal view {
    _validateCallerImpl(self, caller, objectType, _getProgram, ProgramIdLib._getAddress);
  }

  function _validateCaller(EntityId self, address caller) internal view {
    _validateCaller(self, caller, _getObjectType(self));
  }

  function _validateCaller(EntityId self) internal view {
    _validateCaller(self, WorldContextConsumerLib._msgSender());
  }

  function _getPosition(EntityId self) internal view returns (Vec3) {
    return _getPositionImpl(self, EntityPosition._get);
  }

  function _getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram._get(self);
  }

  function _getObjectType(EntityId self) internal view returns (ObjectType) {
    return EntityObjectType._get(self);
  }

  function _exists(EntityId self) internal view returns (bool) {
    return _existsImpl(self, _getObjectType);
  }

  // Other methods that don't have duplication
  function activate(EntityId self) internal returns (EnergyData memory) {
    address caller = WorldContextConsumerLib._msgSender();
    return ActivateLib._activate(self, caller, msg.sig);
  }

  function baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId _base = BaseEntity._get(self);
    return EntityId.unwrap(_base) == 0 ? self : _base;
  }

  function requireInRange(EntityId self, Vec3 otherCoord, uint256 range) internal view returns (Vec3, Vec3) {
    Vec3 selfCoord = _getPosition(self);
    Vec3 coord = _getObjectType(self) == ObjectTypes.Player ? selfCoord + vec3(0, 1, 0) : selfCoord;
    require(coord.inSphere(otherCoord, range), "Entity is too far");
    return (selfCoord, coord);
  }

  function requireConnected(EntityId self, EntityId other) internal view returns (Vec3, Vec3) {
    return requireConnected(self, _getPosition(other));
  }

  function requireConnected(EntityId self, Vec3 otherCoord) internal view returns (Vec3, Vec3) {
    return requireInRange(self, otherCoord, MAX_ENTITY_INFLUENCE_RADIUS);
  }

  function requireAdjacentToFragment(EntityId self, EntityId fragment) internal view returns (Vec3, Vec3) {
    return requireAdjacentToFragment(self, _getPosition(fragment));
  }

  function requireAdjacentToFragment(EntityId self, Vec3 fragmentCoord) internal view returns (Vec3, Vec3) {
    Vec3 selfFragmentCoord = _getPosition(self).toFragmentCoord();
    require(selfFragmentCoord.inSurroundingCube(fragmentCoord, 1), "Fragment is too far");
    return (selfFragmentCoord, fragmentCoord);
  }

  function unwrap(EntityId self) internal pure returns (bytes32) {
    return EntityId.unwrap(self);
  }

  function getPlayerAddress(EntityId self) internal pure returns (address) {
    return EntityTypeLib.decodePlayer(self);
  }
}

library ActivateLib {
  function _activate(EntityId self, address caller, bytes4 sig) internal returns (EnergyData memory) {
    checkWorldStatus();

    ObjectType objectType = EntityIdLib._getObjectType(self);
    require(objectType.isActionAllowed(sig), "Action not allowed");

    EntityIdLib._validateCaller(self, caller, objectType);

    EnergyData memory energyData;
    if (objectType == ObjectTypes.Player) {
      require(!EntityIdLib._exists(PlayerBed._getBedEntityId(self)), "Player is sleeping");
      energyData = updatePlayerEnergy(self);
    } else {
      EntityId forceField;
      if (objectType == ObjectTypes.ForceField) {
        forceField = self;
      } else {
        (forceField,) = ForceFieldUtils.getForceField(EntityIdLib._getPosition(self));
      }

      (energyData,) = updateMachineEnergy(forceField);
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
