// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";

import { EntityId, EntityTypeLib } from "../types/EntityId.sol";

contract ActivateSystem is System {
  function activate(EntityId entityId) public {
    checkWorldStatus();

    require(entityId._exists(), "Entity does not exist");
    EntityId base = entityId.baseEntityId();
    ObjectType objectType = base._getObjectType();
    require(!objectType.isNull(), "Entity has no object type");

    if (objectType == ObjectTypes.Player) {
      updatePlayerEnergy(base);
    } else {
      // if there's no program, it'll just do nothing
      updateMachineEnergy(base);
    }
  }

  function activatePlayer(address playerAddress) public {
    checkWorldStatus();
    EntityId player = EntityTypeLib.encodePlayer(playerAddress);
    ObjectType objectType = player._getObjectType();
    require(objectType == ObjectTypes.Player, "Entity is not player");
    updatePlayerEnergy(player);
  }
}
