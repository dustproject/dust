// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { console } from "forge-std/console.sol";

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BaseEntity } from "./codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "./codegen/tables/Energy.sol";

import { EntityObjectType } from "./codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "./codegen/tables/EntityProgram.sol";
import { PlayerBed } from "./codegen/tables/PlayerBed.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "./utils/EnergyUtils.sol";
import { ForceFieldUtils } from "./utils/ForceFieldUtils.sol";
import { EntityPosition } from "./utils/Vec3Storage.sol";

import { MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "./Constants.sol";
import { ObjectType } from "./ObjectType.sol";

import { ObjectTypes } from "./ObjectType.sol";
import { ProgramId } from "./ProgramId.sol";
import { checkWorldStatus } from "./Utils.sol";
import { Vec3 } from "./Vec3.sol";

type EntityId is bytes32;

type EntityType is bytes1;

uint256 constant ENTITY_TYPE_OFFSET_BITS = 248;

library EntityTypes {
  EntityType constant Incremental = EntityType.wrap(0x00);
  EntityType constant Player = EntityType.wrap(0x01);
  EntityType constant Fragment = EntityType.wrap(0x02);
  EntityType constant Block = EntityType.wrap(0x03);

  function unwrap(EntityType self) internal pure returns (bytes1) {
    return EntityType.unwrap(self);
  }
}

library EntityIdLib {
  // We need to use this internal library function in order to obtain the msg.sig and msg.sender
  function activate(EntityId self) internal returns (EnergyData memory) {
    address caller = WorldContextConsumerLib._msgSender();
    return ActivateLib._activate(self, caller, msg.sig);
  }

  function requireCallerAllowed(EntityId self, address caller, ObjectType objectType) internal view {
    if (objectType == ObjectTypes.Player) {
      require(caller == self.getPlayerAddress(), "Caller not allowed");
    } else {
      address programAddress = self.getProgram().getAddress();
      require(caller == programAddress, "Caller not allowed");
    }
  }

  function requireCallerAllowed(EntityId self, address sender) internal view {
    requireCallerAllowed(self, sender, self.getObjectType());
  }

  function baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId _base = BaseEntity._get(self);
    return EntityId.unwrap(_base) == 0 ? self : _base;
  }

  // TODO: add pipe connections
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
    return requireAdjacentToFragment(self, fragment.getPosition());
  }

  function requireAdjacentToFragment(EntityId self, Vec3 fragmentCoord) internal view returns (Vec3, Vec3) {
    Vec3 selfFragmentCoord = self.getPosition().toFragmentCoord();
    require(selfFragmentCoord.inSurroundingCube(fragmentCoord, 1), "Fragment is too far");
    return (selfFragmentCoord, fragmentCoord);
  }

  function getPosition(EntityId self) internal view returns (Vec3) {
    return EntityPosition._get(self);
  }

  function getProgram(EntityId self) internal view returns (ProgramId) {
    return EntityProgram._get(self);
  }

  function getObjectType(EntityId self) internal view returns (ObjectType) {
    return EntityObjectType._get(self);
  }

  function exists(EntityId self) internal view returns (bool) {
    return !self.getObjectType().isNull();
  }

  function unwrap(EntityId self) internal pure returns (bytes32) {
    return EntityId.unwrap(self);
  }

  function encodeCoord(EntityType entityType, Vec3 coord) internal pure returns (EntityId) {
    return EntityId.wrap(
      bytes32((uint256(uint8(entityType.unwrap())) << ENTITY_TYPE_OFFSET_BITS) | uint256(uint96(coord.unwrap())))
    );
  }

  function encodeBlock(Vec3 coord) internal pure returns (EntityId) {
    return encodeCoord(EntityTypes.Block, coord);
  }

  function encodeFragment(Vec3 coord) internal pure returns (EntityId) {
    return encodeCoord(EntityTypes.Fragment, coord);
  }

  function encodePlayer(address player) internal pure returns (EntityId) {
    return EntityId.wrap(
      bytes32((uint256(uint8(EntityTypes.Player.unwrap())) << ENTITY_TYPE_OFFSET_BITS) | uint256(uint160(player)))
    );
  }

  function getPlayerAddress(EntityId self) internal view returns (address) {
    require(self.getObjectType() == ObjectTypes.Player, "Entity is not a player");
    return address(uint160(uint256(EntityId.unwrap(self))));
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

    ObjectType objectType = self.getObjectType();
    require(objectType.isActionAllowed(sig), "Action not allowed");

    self.requireCallerAllowed(caller, objectType);

    EnergyData memory energyData;
    if (objectType == ObjectTypes.Player) {
      require(!PlayerBed._getBedEntityId(self).exists(), "Player is sleeping");
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
using EntityTypes for EntityType global;
using { eq as ==, neq as != } for EntityId global;
