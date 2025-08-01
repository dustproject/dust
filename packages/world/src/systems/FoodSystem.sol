// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { ObjectPhysics, ObjectPhysicsData } from "../codegen/tables/ObjectPhysics.sol";

import { addEnergyToLocalPool } from "../utils/EnergyUtils.sol";

import { InventoryUtils, SlotAmount } from "../utils/InventoryUtils.sol";

import { MAX_PLAYER_ENERGY } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

contract FoodSystem is System {
  function eat(EntityId caller, SlotAmount memory slotAmount) public {
    EnergyData memory energyData = caller.activate();

    ObjectType objectType = InventorySlot._getObjectType(caller, slotAmount.slot);
    require(objectType.isFood(), "Object is not food");

    ObjectPhysicsData memory physicsData = ObjectPhysics._get(objectType);

    uint128 foodEnergy = (physicsData.energy + physicsData.mass) * slotAmount.amount;

    uint128 newEnergy = foodEnergy + energyData.energy;

    // Transfer overflow energy to local pool
    if (newEnergy > MAX_PLAYER_ENERGY) {
      addEnergyToLocalPool(caller._getPosition(), newEnergy - MAX_PLAYER_ENERGY);
      newEnergy = MAX_PLAYER_ENERGY;
    }

    InventoryUtils.removeObjectFromSlot(caller, slotAmount.slot, slotAmount.amount);

    Energy._setEnergy(caller, newEnergy);
  }
}
