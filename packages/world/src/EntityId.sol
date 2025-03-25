// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { ReversePlayer } from "./codegen/tables/ReversePlayer.sol";
import { Program } from "./codegen/tables/Program.sol";
import { ObjectType } from "./codegen/tables/ObjectType.sol";
import { BaseEntity } from "./codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "./codegen/tables/Energy.sol";

import { Position } from "./utils/Vec3Storage.sol";
import { updatePlayerEnergy } from "./utils/EnergyUtils.sol";

import { checkWorldStatus } from "./Utils.sol";
import { ObjectTypeId } from "./ObjectTypeId.sol";
import { ObjectTypes } from "./ObjectTypes.sol";
import { Vec3 } from "./Vec3.sol";
import { MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "./Constants.sol";

type EntityId is bytes32;

library EntityIdLib {
  function activate(EntityId self) public {
    checkWorldStatus();
    ObjectTypeId objectTypeId = ObjectType.get(self);

    address msgSender = WorldContextConsumerLib._msgSender();

    // TODO: do we want to support chips for players?
    EnergyData memory energyData;
    if (objectTypeId == ObjectTypes.Player) {
      require(msgSender == ReversePlayer._get(self));
      energyData = updatePlayerEnergy(self);
    } else {
      address programAddress = self.getProgramAddress();
      require(msgSender == programAddress, "Invalid caller");
    }

    require(energyData.energy > 0, "Entity has no energy");
  }

  function baseEntityId(EntityId self) internal view returns (EntityId) {
    EntityId base = BaseEntity._get(self);
    return EntityId.unwrap(base) == 0 ? self : base;
  }

  // TODO: add pipe connections
  // TODO: should non-player entities have a range > 1?
  function requireConnected(EntityId self, EntityId other) internal view {
    Vec3 selfCoord = Position.get(self);
    Vec3 otherCoord = Position.get(other);
    require(selfCoord.inSurroundingCube(otherCoord, MAX_ENTITY_INFLUENCE_HALF_WIDTH), "Entities are not connected");
  }

  function getProgramAddress(EntityId entityId) internal view returns (address) {
    ResourceId programSystemId = entityId.getProgram();
    (address programAddress, ) = Systems._get(programSystemId);
    return programAddress;
  }

  function getProgram(EntityId entityId) internal view returns (ResourceId) {
    return Program._getProgramSystemId(entityId);
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

using EntityIdLib for EntityId global;
using { eq as ==, neq as != } for EntityId global;
