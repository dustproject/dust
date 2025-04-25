// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Player } from "../codegen/tables/Player.sol";

import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";

import { checkWorldStatus } from "../Utils.sol";
import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";

import { EntityId } from "../EntityId.sol";

contract ActivateSystem is System {
  function activate(EntityId entityId) public {
    checkWorldStatus();

    require(entityId.exists(), "Entity does not exist");
    EntityId base = entityId.baseEntityId();
    ObjectType objectType = EntityObjectType._get(base);
    require(!objectType.isNull(), "Entity has no object type");

    if (objectType == ObjectTypes.Player) {
      updatePlayerEnergy(base);
    } else {
      // if there's no program, it'll just do nothing
      updateMachineEnergy(base);
    }
  }

  function activatePlayer(address playerAddress) public {
    EntityId player = Player._get(playerAddress);
    player = player.baseEntityId();
    require(player.exists(), "Entity does not exist");
    ObjectType objectType = EntityObjectType._get(player);
    require(objectType == ObjectTypes.Player, "Entity is not player");
    updatePlayerEnergy(player);
  }
}
