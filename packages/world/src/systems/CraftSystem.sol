// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import {
  InputAmountExceedsRemaining,
  InputAmountMustBePositive,
  InputTypeDoesNotMatchRecipe,
  InvalidStation,
  NotEnoughEnergy,
  NotEnoughInputsForRecipe,
  RecipeNotFound
} from "../Errors.sol";
import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { Recipes, RecipesData } from "../codegen/tables/Recipes.sol";

import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotAmount, SlotData } from "../utils/InventoryUtils.sol";
import { CraftNotification, notify } from "../utils/NotifUtils.sol";

import { CRAFT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";

import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";

import { Vec3 } from "../types/Vec3.sol";
import { OreLib } from "../utils/OreLib.sol";

contract CraftSystem is System {
  function craftWithStation(EntityId caller, EntityId station, bytes32 recipeId, SlotAmount[] memory inputs) public {
    caller.activate();
    RecipesData memory recipe = Recipes._get(recipeId);
    if (recipe.inputTypes.length == 0) revert RecipeNotFound(ObjectType.wrap(uint16(uint256(recipeId))));

    if (!recipe.stationTypeId.isNull()) {
      if (station._getObjectType() != recipe.stationTypeId) {
        revert InvalidStation(recipe.stationTypeId, station._getObjectType());
      }
      caller.requireConnected(station);
    }

    (uint128 callerEnergy,) = transferEnergyToPool(caller, CRAFT_ENERGY_COST);
    if (callerEnergy == 0) revert NotEnoughEnergy(uint32(CRAFT_ENERGY_COST), 0);

    CraftLib._consumeRecipeInputs(caller, recipe, inputs);
    CraftLib._createRecipeOutputs(caller, recipe);

    notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
  }

  function craft(EntityId caller, bytes32 recipeId, SlotAmount[] memory inputs) public {
    craftWithStation(caller, EntityId.wrap(bytes32(0)), recipeId, inputs);
  }
}

library CraftLib {
  function _consumeRecipeInputs(EntityId caller, RecipesData memory recipe, SlotAmount[] memory inputs) public {
    uint256 currentInput = 0;

    for (uint256 i = 0; i < recipe.inputTypes.length; i++) {
      ObjectType recipeType = ObjectType.wrap(recipe.inputTypes[i]);
      uint16 remainingAmount = recipe.inputAmounts[i];

      while (remainingAmount > 0) {
        if (currentInput >= inputs.length) revert NotEnoughInputsForRecipe(recipe.inputTypes.length, currentInput);
        uint16 amount = inputs[currentInput].amount;
        if (amount == 0) revert InputAmountMustBePositive();
        if (amount > remainingAmount) revert InputAmountExceedsRemaining(amount, remainingAmount);

        ObjectType inputType = InventorySlot._getObjectType(caller, inputs[currentInput].slot);
        if (!recipeType.matches(inputType)) revert InputTypeDoesNotMatchRecipe(recipeType, inputType);

        // TODO: this should be removed once craftingTime is implemented
        if (recipeType == ObjectTypes.CoalOre) {
          OreLib.burnOre(recipeType, recipe.inputAmounts[i]);
        }

        InventoryUtils.removeObjectFromSlot(caller, inputs[currentInput].slot, amount);
        remainingAmount -= amount;
        currentInput++;
      }
    }
  }

  function _createRecipeOutputs(EntityId caller, RecipesData memory recipe) public returns (SlotData[] memory) {
    // First, calculate the total length needed for the withdrawals array
    uint256 totalWithdrawals = 0;
    for (uint256 i = 0; i < recipe.outputTypes.length; i++) {
      ObjectType outputType = ObjectType.wrap(recipe.outputTypes[i]);
      uint16 outputAmount = recipe.outputAmounts[i];
      totalWithdrawals += outputType.isTool() ? outputAmount : 1; // Each tool needs its own slot
    }

    SlotData[] memory withdrawals = new SlotData[](totalWithdrawals);

    uint256 withdrawalIndex = 0;
    for (uint256 i = 0; i < recipe.outputTypes.length; i++) {
      ObjectType outputType = ObjectType.wrap(recipe.outputTypes[i]);
      uint16 outputAmount = recipe.outputAmounts[i];

      if (outputType.isTool()) {
        for (uint256 j = 0; j < outputAmount; j++) {
          EntityId tool = EntityUtils.createUniqueEntity(outputType);
          withdrawals[withdrawalIndex++] = SlotData({ entityId: tool, objectType: outputType, amount: 1 });
          InventoryUtils.addEntity(caller, tool);
        }
      } else {
        withdrawals[withdrawalIndex++] =
          SlotData({ entityId: EntityId.wrap(0), objectType: outputType, amount: outputAmount });
        InventoryUtils.addObject(caller, outputType, outputAmount);
      }
    }

    return withdrawals;
  }
}
