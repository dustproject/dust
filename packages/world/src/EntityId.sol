// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BaseEntity } from "./codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "./codegen/tables/Energy.sol";

import { EntityObjectType } from "./codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "./codegen/tables/EntityProgram.sol";
import { PlayerStatus } from "./codegen/tables/PlayerStatus.sol";
import { ReversePlayer } from "./codegen/tables/ReversePlayer.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "./utils/EnergyUtils.sol";
import { ForceFieldUtils } from "./utils/ForceFieldUtils.sol";
import { FragmentPosition, MovablePosition, Position } from "./utils/Vec3Storage.sol";

import { MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "./Constants.sol";
import { ObjectType } from "./ObjectType.sol";

import { ObjectTypes } from "./ObjectType.sol";
import { ProgramId } from "./ProgramId.sol";
import { checkWorldStatus } from "./Utils.sol";
import { Vec3 } from "./Vec3.sol";

type EntityId is bytes32;

library EntityIdLib {
  // We need to use this internal library function in order to obtain the msg.sig and msg.sender
  function activate(EntityId self) internal returns (EnergyData memory) {
    address caller = WorldContextConsumerLib._msgSender();
    return ActivateLib._activate(self, caller, msg.sig);
  }

  function requireCallerAllowed(EntityId self, address caller, ObjectType objectType) internal view {
    if (objectType == ObjectTypes.Player) {
      require(caller == ReversePlayer._get(self), "Caller not allowed");
    } else {
      address programAddress = self.getProgram().getAddress();
      require(caller == programAddress, "Caller not allowed");
    }
  }

  function requireCallerAllowed(EntityId self, address sender) internal view {
    ObjectType objectType = EntityObjectType._get(self);
    requireCallerAllowed(self, sender, objectType);
  }

  function baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId _base = BaseEntity._get(self);
    return EntityId.unwrap(_base) == 0 ? self : _base;
  }

  // TODO: add pipe connections
  // TODO: should non-player entities have a range != to players?
  function requireConnected(EntityId self, EntityId other) internal view returns (Vec3, Vec3) {
    Vec3 otherCoord = other.getPosition();
    return requireConnected(self, otherCoord);
  }

  function requireConnected(EntityId self, Vec3 otherCoord) internal view returns (Vec3, Vec3) {
    Vec3 selfCoord = self.getPosition();
    require(selfCoord.inSurroundingCube(otherCoord, MAX_ENTITY_INFLUENCE_HALF_WIDTH), "Entity is too far");
    return (selfCoord, otherCoord);
  }

  function requireAdjacentToFragment(EntityId self, EntityId fragment) internal view returns (Vec3, Vec3) {
    Vec3 fragmentCoord = FragmentPosition.get(fragment);
    return requireAdjacentToFragment(self, fragmentCoord);
  }

  function requireAdjacentToFragment(EntityId self, Vec3 fragmentCoord) internal view returns (Vec3, Vec3) {
    Vec3 selfFragmentCoord = self.getPosition().toFragmentCoord();
    require(selfFragmentCoord.inSurroundingCube(fragmentCoord, 1), "Fragment is too far");
    return (selfFragmentCoord, fragmentCoord);
  }

  function getPosition(EntityId self) internal view returns (Vec3) {
    return EntityObjectType._get(self).isPlayer() ? MovablePosition._get(self) : Position._get(self);
  }

  function getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram._get(self);
  }

  function exists(EntityId self) internal pure returns (bool) {
    return EntityId.unwrap(self) != bytes32(0);
  }

  function unwrap(EntityId self) internal pure returns (bytes32) {
    return EntityId.unwrap(self);
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

    ObjectType objectType = EntityObjectType._get(self);
    require(objectType.isActionAllowed(sig), "Action not allowed");

    self.requireCallerAllowed(caller, objectType);

    EnergyData memory energyData;
    if (objectType == ObjectTypes.Player) {
      require(!PlayerStatus._getBedEntityId(self).exists(), "Player is sleeping");
      energyData = updatePlayerEnergy(self);
    } else {
      EntityId forceField;
      if (objectType == ObjectTypes.ForceField) {
        forceField = self;
      } else {
        (forceField,) = ForceFieldUtils.getForceField(self.getPosition());
      }

      (energyData,) = updateMachineEnergy(forceField);
    }

    require(energyData.energy > 0, "Entity has no energy");

    return energyData;
  }
}

using EntityIdLib for EntityId global;
using { eq as ==, neq as != } for EntityId global;
