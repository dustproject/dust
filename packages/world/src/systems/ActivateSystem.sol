// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityDoesNotExist, EntityHasNoObjectType, EntityIsNotPlayer } from "../Errors.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import { updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";

import { EntityId, EntityTypeLib } from "../types/EntityId.sol";

contract ActivateSystem is System {
  function activate(EntityId entityId) public {
    checkWorldStatus();

    if (!entityId._exists()) revert EntityDoesNotExist(entityId);
    EntityId base = entityId.baseEntityId();
    ObjectType objectType = base._getObjectType();
    if (objectType.isNull()) revert EntityHasNoObjectType(base);

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
    if (objectType != ObjectTypes.Player) revert EntityIsNotPlayer(player);
    updatePlayerEnergy(player);
  }
}
