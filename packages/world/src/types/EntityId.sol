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

import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { EntityPosition } from "../utils/Vec3Storage.sol";

import { MAX_ENTITY_INFLUENCE_RADIUS } from "../Constants.sol";
import { ObjectType } from "./ObjectType.sol";

import { ObjectTypes } from "./ObjectType.sol";
import { ProgramId } from "./ProgramId.sol";

import { checkWorldStatus } from "../Utils.sol";

import { EntityType, EntityTypeLib, EntityTypes } from "./EntityType.sol";
import { ProgramIdLib } from "./ProgramId.sol";
import { Vec3, vec3 } from "./Vec3.sol";

type EntityId is bytes32;

function eq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) == EntityId.unwrap(other);
}

function neq(EntityId self, EntityId other) pure returns (bool) {
  return EntityId.unwrap(self) != EntityId.unwrap(other);
}

library EntityIdLib {
  // Non-root (public table access) methods
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

  // Root (internal table access) methods
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
}

library ActivateLib {
  function _activate(EntityId self, address caller, bytes4 sig) public returns (EnergyData memory) {
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

using EntityIdLib for EntityId global;
using { eq as ==, neq as != } for EntityId global;
