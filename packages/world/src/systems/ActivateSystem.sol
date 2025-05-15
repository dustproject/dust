// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";

import { checkWorldStatus } from "../Utils.sol";
import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";

import { EntityId, EntityIdLib } from "../EntityId.sol";

contract ActivateSystem is System {
  function activate(EntityId entityId) public {
    checkWorldStatus();

    require(entityId.exists(), "Entity does not exist");
    EntityId base = entityId.baseEntityId();
    ObjectType objectType = base.getObjectType();
    require(!objectType.isNull(), "Entity has no object type");

    if (objectType == ObjectTypes.Player) {
      updatePlayerEnergy(base);
    } else {
      // if there's no program, it'll just do nothing
      updateMachineEnergy(base);
    }
  }

  function activatePlayer(address playerAddress) public {
    EntityId player = EntityIdLib.encodePlayer(playerAddress);
    ObjectType objectType = player.getObjectType();
    require(objectType == ObjectTypes.Player, "Entity is not player");
    updatePlayerEnergy(player);
  }
}
