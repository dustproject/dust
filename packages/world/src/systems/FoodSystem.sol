// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { addEnergyToLocalPool } from "../utils/EnergyUtils.sol";

import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { MAX_PLAYER_ENERGY } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { Vec3 } from "../Vec3.sol";

contract FoodSystem is System {
  function eat(EntityId caller, ObjectType objectType, uint16 numToEat) public {
    EnergyData memory energyData = caller.activate();

    require(objectType.isFood(), "Object is not food");

    uint128 newEnergy = ObjectTypeMetadata._getEnergy(objectType) * numToEat + energyData.energy;
    if (newEnergy > MAX_PLAYER_ENERGY) {
      addEnergyToLocalPool(caller.getPosition(), newEnergy - MAX_PLAYER_ENERGY);
      newEnergy = MAX_PLAYER_ENERGY;
    }

    InventoryUtils.removeObject(caller, objectType, numToEat);

    Energy._setEnergy(caller, newEnergy);
  }
}
