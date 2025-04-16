// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

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

  function craftWithStation(EntityId caller, bytes32 recipeId, EntityId station, SlotAmount[] memory inputs) public {
    caller.activate();
    RecipesData memory recipe = Recipes._get(recipeId);
    require(recipe.inputTypes.length > 0, "Recipe not found");

    if (!recipe.stationTypeId.isNull()) {
      require(station.exists(), "This recipe requires a station");
      require(ObjectType._get(station) == recipe.stationTypeId, "Invalid station");
      caller.requireConnected(station);
    }

    // Require that slots match the recipe inputs
    // And delete the inputs from the inventory as they are used
    uint256 currentInput = 0;
    for (uint256 i = 0; i < recipe.inputTypes.length; i++) {
      ObjectTypeId recipeType = ObjectTypeId.wrap(recipe.inputTypes[i]);

      uint16 remainingAmount = recipe.inputAmounts[i];
      while (remainingAmount > 0) {
        ObjectTypeId inputType = InventorySlot._getObjectType(caller, inputs[currentInput].slot);
        // TODO: support Any
        require(recipeType == inputType, "Input does not match recipe");
        uint16 amount = inputs[currentInput].amount;
        InventoryUtils.removeObjectFromSlot(caller, inputs[currentInput].slot, amount);
        remainingAmount -= amount;
        currentInput++;
      }

      // TODO: add a time cost to burning the coal
      if (recipeType == ObjectTypes.CoalOre) {
        recipeType.burnOre(recipe.inputAmounts[i]);
      }
    }

    // Create the crafted objects
    for (uint256 i = 0; i < recipe.outputTypes.length; i++) {
      ObjectTypeId outputType = ObjectTypeId.wrap(recipe.outputTypes[i]);
      uint16 outputAmount = recipe.outputAmounts[i];
      if (outputType.isTool()) {
        for (uint256 j = 0; j < outputAmount; j++) {
          EntityId tool = createEntity(outputType);
          InventoryUtils.addEntity(caller, tool);
        }
      } else {
        InventoryUtils.addObject(caller, outputType, outputAmount);
      }
    }

    CraftLib.transferCraftEnergyToPool(caller);

    notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
  }

  function craft(EntityId caller, bytes32 recipeId, SlotAmount[] memory inputs) public {
    craftWithStation(caller, recipeId, EntityId.wrap(bytes32(0)), inputs);
  }
}

library CraftLib {
  function transferCraftEnergyToPool(EntityId caller) public {
    transferEnergyToPool(caller, CRAFT_ENERGY_COST);
  }
}
