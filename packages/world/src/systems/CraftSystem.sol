// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { Recipes, RecipesData } from "../codegen/tables/Recipes.sol";

import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { createEntity } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotAmount, SlotData } from "../utils/InventoryUtils.sol";
import { CraftNotification, notify } from "../utils/NotifUtils.sol";

import { CRAFT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";

import { NatureLib } from "../NatureLib.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";
import { ITransferHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

contract CraftSystem is System {
  function craftWithStation(EntityId caller, EntityId station, bytes32 recipeId, SlotAmount[] memory inputs) public {
    caller.activate();
    RecipesData memory recipe = Recipes._get(recipeId);
    require(recipe.inputTypes.length > 0, "Recipe not found");

    if (!recipe.stationTypeId.isNull()) {
      require(station.exists(), "This recipe requires a station");
      require(EntityObjectType._get(station) == recipe.stationTypeId, "Invalid station");
      caller.requireConnected(station);
    }

    (uint128 callerEnergy,) = transferEnergyToPool(caller, CRAFT_ENERGY_COST);
    require(callerEnergy > 0, "Not enough energy");

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
        require(currentInput < inputs.length, "Not enough inputs for recipe");
        uint16 amount = inputs[currentInput].amount;
        require(amount > 0, "Input amount must be greater than 0");
        require(amount <= remainingAmount, "Input amount exceeds remaining amount");

        ObjectType inputType = InventorySlot._getObjectType(caller, inputs[currentInput].slot);
        require(recipeType.matches(inputType), "Input type does not match required recipe type");

        // TODO: this should be removed once craftingTime is implemented
        if (recipeType == ObjectTypes.CoalOre) {
          NatureLib.burnOre(recipeType, recipe.inputAmounts[i]);
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
          EntityId tool = createEntity(outputType);
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
