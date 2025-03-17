// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { addEnergyToLocalPool } from "../utils/EnergyUtils.sol";
import { requireValidPlayer } from "../utils/PlayerUtils.sol";
import { removeFromInventory } from "../utils/InventoryUtils.sol";

import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { EntityId } from "../EntityId.sol";
import { Vec3 } from "../Vec3.sol";
import { MAX_PLAYER_ENERGY } from "../Constants.sol";

contract FoodSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function eat(ObjectTypeId objectTypeId, uint16 numToEat) public {
    (EntityId playerEntityId, Vec3 playerCoord, EnergyData memory energyData) = requireValidPlayer(_msgSender());

    require(objectTypeId.isFood(), "Object is not food");

    uint128 newEnergy = ObjectTypeMetadata._getEnergy(objectTypeId) * numToEat + energyData.energy;
    if (newEnergy > MAX_PLAYER_ENERGY) {
      addEnergyToLocalPool(playerCoord, newEnergy - MAX_PLAYER_ENERGY);
      newEnergy = MAX_PLAYER_ENERGY;
    }

    removeFromInventory(playerEntityId, objectTypeId, numToEat);

    Energy._setEnergy(playerEntityId, newEnergy);
  }
}
