// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Recipes, RecipesData } from "../codegen/tables/Recipes.sol";

import { CRAFT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";

import { Vec3 } from "../Vec3.sol";
import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { createEntity } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotAmount } from "../utils/InventoryUtils.sol";
import { CraftNotification, notify } from "../utils/NotifUtils.sol";

contract CraftSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function craftFuel(EntityId caller, EntityId powerstone, SlotAmount[] memory inputs) public {
    caller.activate();
    require(inputs.length > 0, "No inputs provided");
    require(powerstone.exists() && ObjectType._get(powerstone) == ObjectTypes.Powerstone, "Invalid powerstone");
    caller.requireConnected(powerstone);

    uint128 totalEnergy = 0;
    for (uint256 i = 0; i < inputs.length; i++) {
      ObjectTypeId inputType = InventorySlot._getObjectType(caller, inputs[i].slot);
      require(inputType.isLog() || inputType.isLeaf(), "Invalid input type");
      // we convert the mass to energy
      totalEnergy +=
        inputs[i].amount * (ObjectTypeMetadata._getEnergy(inputType) + ObjectTypeMetadata._getMass(inputType));
      InventoryUtils.removeObject(caller, inputType, inputs[i].amount);
    }
    uint128 fuelAmount = totalEnergy / ObjectTypeMetadata._getEnergy(ObjectTypes.Fuel);
    require(fuelAmount > 0 && fuelAmount <= uint128(type(uint16).max), "Invalid fuel amount");
    InventoryUtils.addObject(caller, ObjectTypes.Fuel, uint16(fuelAmount));

    transferEnergyToPool(caller, CRAFT_ENERGY_COST);

    // TODO: should we use a diff notification for fuel?
    notify(caller, CraftNotification({ recipeId: bytes32(0), station: powerstone }));
  }

  function craftWithStation(EntityId caller, bytes32 recipeId, EntityId station) public {
    caller.activate();
    RecipesData memory recipeData = Recipes._get(recipeId);
    require(recipeData.inputTypes.length > 0, "Recipe not found");

    if (!recipeData.stationTypeId.isNull()) {
      require(station.exists(), "This recipe requires a station");
      require(ObjectType._get(station) == recipeData.stationTypeId, "Invalid station");
      caller.requireConnected(station);
    }

    // Require that the entity has all the ingredients in its inventory
    // And delete the ingredients from the inventory as they are used
    for (uint256 i = 0; i < recipeData.inputTypes.length; i++) {
      ObjectTypeId inputObjectTypeId = ObjectTypeId.wrap(recipeData.inputTypes[i]);
      if (inputObjectTypeId.isAny()) {
        InventoryUtils.removeAny(caller, inputObjectTypeId, recipeData.inputAmounts[i]);
      } else {
        InventoryUtils.removeObject(caller, inputObjectTypeId, recipeData.inputAmounts[i]);
      }

      // TODO: add a time cost to burning the coal
      if (inputObjectTypeId == ObjectTypes.CoalOre) {
        inputObjectTypeId.burnOre(recipeData.inputAmounts[i]);
      }
    }

    // Create the crafted objects
    for (uint256 i = 0; i < recipeData.outputTypes.length; i++) {
      ObjectTypeId outputType = ObjectTypeId.wrap(recipeData.outputTypes[i]);
      uint16 outputAmount = recipeData.outputAmounts[i];
      if (outputType.isTool()) {
        for (uint256 j = 0; j < outputAmount; j++) {
          EntityId tool = createEntity(outputType);
          InventoryUtils.addEntity(caller, tool);
        }
      } else {
        InventoryUtils.addObject(caller, outputType, outputAmount);
      }
    }

    transferEnergyToPool(caller, CRAFT_ENERGY_COST);

    notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
  }

  function craft(EntityId caller, bytes32 recipeId) public {
    craftWithStation(caller, recipeId, EntityId.wrap(bytes32(0)));
  }
}
