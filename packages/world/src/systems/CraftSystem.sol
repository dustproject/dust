// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { Furnace, FurnaceData } from "../codegen/tables/Furnace.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Recipes, RecipesData } from "../codegen/tables/Recipes.sol";

import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { createEntity } from "../utils/EntityUtils.sol";
import { InventoryUtils, SlotAmount, SlotData } from "../utils/InventoryUtils.sol";
import { CraftNotification, notify } from "../utils/NotifUtils.sol";

import { CRAFT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { ITransferHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

contract CraftSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function craftWithStation(EntityId caller, EntityId station, bytes32 recipeId, SlotAmount[] memory inputs) public {
    caller.activate();
    RecipesData memory recipe = Recipes._get(recipeId);
    require(recipe.inputTypes.length > 0, "Recipe not found");

    if (!recipe.stationTypeId.isNull()) {
      require(station.exists(), "This recipe requires a station");
      require(ObjectType._get(station) == recipe.stationTypeId, "Invalid station");
      caller.requireConnected(station);
    }

    CraftLib._processEnergyReduction(caller);

    // If the recipe requires a furnace, the input slots reference the furnace
    if (recipe.stationTypeId == ObjectTypes.Furnace) {
      _beginSmelting(station, recipe, inputs);
    } else {
      _consumeRecipeInputs(caller, recipe, inputs);
      _createRecipeOutputs(caller, recipe);

      notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
    }
  }

  function craft(EntityId caller, bytes32 recipeId, SlotAmount[] memory inputs) public {
    craftWithStation(caller, EntityId.wrap(bytes32(0)), recipeId, inputs);
  }

  function finishSmelting(EntityId caller, EntityId furnace, bytes memory extraData) public {
    caller.activate();
    require(ObjectType._get(furnace) == ObjectTypes.Furnace, "Not a furnace");
    caller.requireConnected(furnace);

    FurnaceData memory furnaceData = Furnace._get(furnace);
    RecipesData memory recipe = Recipes._get(furnaceData.recipeId);
    require(recipe.inputTypes.length > 0, "Recipe not found");

    // Create the outputs
    SlotData[] memory withdrawals = _createRecipeOutputs(caller, recipe);

    // We need to notify the furnace that the outputs are being withdrawn
    bytes memory onTransfer =
      abi.encodeCall(ITransferHook.onTransfer, (caller, furnace, new SlotData[](0), withdrawals, extraData));

    furnace.getProgram().callOrRevert(onTransfer);

    notify(caller, CraftNotification({ recipeId: furnaceData.recipeId, station: furnace }));
  }

  function _validateRecipeInput(ObjectTypeId recipeType, ObjectTypeId inputType) private pure {
    if (recipeType.isAny()) {
      ObjectTypeId[] memory validTypes = recipeType.getObjectTypes();
      bool matchFound = false;

      for (uint256 j = 0; j < validTypes.length; j++) {
        if (validTypes[j] == inputType) {
          matchFound = true;
          break;
        }
      }

      require(matchFound, "Input type does not match any valid type for this recipe");
    } else {
      require(recipeType == inputType, "Input type does not match required recipe type");
    }
  }

  function _consumeRecipeInputs(EntityId caller, RecipesData memory recipe, SlotAmount[] memory inputs) private {
    uint256 currentInput = 0;

    for (uint256 i = 0; i < recipe.inputTypes.length; i++) {
      ObjectTypeId recipeType = ObjectTypeId.wrap(recipe.inputTypes[i]);
      uint16 remainingAmount = recipe.inputAmounts[i];

      while (remainingAmount > 0) {
        require(currentInput < inputs.length, "Not enough inputs for recipe");
        uint16 amount = inputs[currentInput].amount;
        require(amount > 0, "Input amount must be greater than 0");

        ObjectTypeId inputType = InventorySlot._getObjectType(caller, inputs[currentInput].slot);
        _validateRecipeInput(recipeType, inputType);

        InventoryUtils.removeObjectFromSlot(caller, inputs[currentInput].slot, amount);
        remainingAmount -= amount;
        currentInput++;
      }

      // Handle special case for ores
      if (recipeType.isOre()) {
        recipeType.burnOre(recipe.inputAmounts[i]);
      }
    }
  }

  function _createRecipeOutputs(EntityId caller, RecipesData memory recipe) private returns (SlotData[] memory) {
    // First, calculate the total length needed for the withdrawals array
    uint256 totalWithdrawals = 0;
    for (uint256 i = 0; i < recipe.outputTypes.length; i++) {
      ObjectTypeId outputType = ObjectTypeId.wrap(recipe.outputTypes[i]);
      uint16 outputAmount = recipe.outputAmounts[i];
      totalWithdrawals += outputType.isTool() ? outputAmount : 1; // Each tool needs its own slot
    }

    SlotData[] memory withdrawals = new SlotData[](totalWithdrawals);

    uint256 withdrawalIndex = 0;
    for (uint256 i = 0; i < recipe.outputTypes.length; i++) {
      ObjectTypeId outputType = ObjectTypeId.wrap(recipe.outputTypes[i]);
      uint16 outputAmount = recipe.outputAmounts[i];

      if (outputType.isTool()) {
        for (uint256 j = 0; j < outputAmount; j++) {
          EntityId tool = createEntity(outputType);
          withdrawals[withdrawalIndex] = SlotData({ entityId: tool, objectType: outputType, amount: 1 });
          InventoryUtils.addEntity(caller, tool);
          withdrawalIndex++;
        }
      } else {
        withdrawals[withdrawalIndex] =
          SlotData({ entityId: EntityId.wrap(0), objectType: outputType, amount: outputAmount });
        InventoryUtils.addObject(caller, outputType, outputAmount);
        withdrawalIndex++;
      }
    }

    return withdrawals;
  }

  function _beginSmelting(EntityId furnace, RecipesData memory recipe, SlotAmount[] memory inputs) private {
    uint256 currentInput = 0;
    for (uint256 i = 0; i < recipe.inputTypes.length; i++) {
      ObjectTypeId recipeType = ObjectTypeId.wrap(recipe.inputTypes[i]);
      uint16 remainingAmount = recipe.inputAmounts[i];

      while (remainingAmount > 0) {
        require(currentInput < inputs.length, "Not enough inputs for recipe");
        uint16 amount = inputs[currentInput].amount;
        require(amount > 0, "Input amount must be greater than 0");

        ObjectTypeId inputType = InventorySlot._getObjectType(furnace, inputs[currentInput].slot);
        _validateRecipeInput(recipeType, inputType);

        // Only burn the coal inputs so they can't be retrieved
        if (recipeType == ObjectTypes.CoalOre) {
          InventoryUtils.removeObjectFromSlot(furnace, inputs[currentInput].slot, amount);
          recipeType.burnOre(recipe.inputAmounts[i]);
        }
        remainingAmount -= amount;
        currentInput++;
      }
    }
  }
}

library CraftLib {
  function _processEnergyReduction(EntityId caller) public {
    (uint128 callerEnergy,) = transferEnergyToPool(caller, CRAFT_ENERGY_COST);
    require(callerEnergy > 0, "Not enough energy");
  }
}
