// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
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

  function craftWithStation(EntityId caller, bytes32 recipeId, EntityId station, SlotAmount[] memory inputSlots) public {
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
    // uint128 totalInputObjectMass = 0;
    // uint128 totalInputObjectEnergy = 0;
    for (uint256 i = 0; i < recipeData.inputTypes.length; i++) {
      ObjectTypeId inputObjectTypeId = ObjectTypeId.wrap(recipeData.inputTypes[i]);
      // totalInputObjectMass += ObjectTypeMetadata._getMass(inputObjectTypeId);
      // totalInputObjectEnergy += ObjectTypeMetadata._getEnergy(inputObjectTypeId);

      // InventoryUtils.removeObjectFromSlot(caller, objectType, amount, slot);
      if (inputObjectTypeId.isAny()) {
        InventoryUtils.removeAny(caller, inputObjectTypeId, recipeData.inputAmounts[i]);
      } else {
        InventoryUtils.removeObject(caller, inputObjectTypeId, recipeData.inputAmounts[i]);
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

    // TODO: handle dyes

    transferEnergyToPool(caller, CRAFT_ENERGY_COST);

    notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
  }

  function craftWithSlots(EntityId caller, bytes32 recipeId, EntityId station, SlotAmount[] memory inputSlots) public {
    caller.activate();
    RecipesData memory recipeData = Recipes._get(recipeId);
    require(recipeData.inputTypes.length > 0, "Recipe not found");
    require(inputSlots.length > 0, "Input slots required");

    if (!recipeData.stationTypeId.isNull()) {
      require(station.exists(), "This recipe requires a station");
      require(ObjectType._get(station) == recipeData.stationTypeId, "Invalid station");
      caller.requireConnected(station);
    }

    // Verify that the provided slots contain the required ingredients
    // and match the recipe requirements
    validateRecipeInputs(caller, recipeData, inputSlots);

    // Remove the ingredients from the specified slots
    for (uint256 i = 0; i < inputSlots.length; i++) {
      SlotAmount memory slotAmount = inputSlots[i];
      InventorySlotData memory slotData = InventorySlot._getObjectType(caller, slotAmount.slot);

      // Remove the specified amount from this slot
      InventoryUtils.removeObjectFromSlot(caller, slotData.objectType, slotAmount.amount, slotAmount.slot);
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

    // TODO: handle dyes

    transferEnergyToPool(caller, CRAFT_ENERGY_COST);

    notify(caller, CraftNotification({ recipeId: recipeId, station: station }));
  }

  function validateRecipeInputs(EntityId caller, RecipesData memory recipeData, SlotAmount[] memory inputSlots)
    internal
    view
  {
    uint256 currentInputSlot = 0;
    uint256 currentConsumedAmount = 0;
    for (uint256 i = 0; i < recipeData.inputTypes.length; i++) {
      uint16 remainingAmount = recipeData.inputAmounts[i];
      ObjectTypeId expectedType = recipeData.inputTypes[i];

      for (uint256 j = currentInputSlot; j < inputSlots.length; j++) {
        ObjectTypeId actualType = InventorySlot._getObjectType(inputSlots[i].slot);
        require(_typeMatches(expectedType, actualType), "Input and recipe types do not match");
        // uint16 available =
        // uint16 toConsume = remainingAmount > inputSlots[i].amount ? inputSlots[i].amount : remainingAmount;
        // remainingAmount -= toConsume;
        // currentConsumedAmount = remainingAmount == 0 ? 0 : currentConsumedAmount +toConsume;
        // currentInputSlot++;
      }
    }

    // Check each provided slot against recipe requirements
    for (uint256 i = 0; i < inputSlots.length; i++) {
      SlotAmount memory slotAmount = inputSlots[i];
      InventorySlotData memory slotData = InventorySlot._get(caller, slotAmount.slot);

      require(slotData.amount >= slotAmount.amount, "Not enough items in slot");

      // Find a matching recipe input for this slot
      bool foundMatch = false;
      for (uint256 j = 0; j < recipeData.inputTypes.length; j++) {
        if (satisfiedInputs[j]) continue; // Skip already satisfied inputs

        ObjectTypeId requiredType = ObjectTypeId.wrap(recipeData.inputTypes[j]);

        // Check if this slot can satisfy this recipe input
        //     if (requiredType.isAny()) {
        //         // For ANY type, check if the slot's object type is in the list of valid types
        //         ObjectTypeId[] memory validTypes = requiredType.getObjectTypes();
        //         for (uint256 k = 0; k < validTypes.length; k++) {
        //             if (slotData.objectType == validTypes[k]) {
        //                 typeMatches = true;
        //                 break;
        //             }
        //         }
        //     } else {
        //         typeMatches = (slotData.objectType == requiredType);
        //     }
        //
        //     if (typeMatches) {
        //         // This slot can contribute to this recipe input
        //         uint16 contribution =
        //             slotAmount.amount > remainingAmounts[j] ? remainingAmounts[j] : slotAmount.amount;
        //
        //         remainingAmounts[j] -= contribution;
        //
        //         // Mark as satisfied if we've met the requirement
        //         if (remainingAmounts[j] == 0) {
        //             satisfiedInputs[j] = true;
        //         }
        //
        //         foundMatch = true;
        //         break;
        //     }
      }

      require(foundMatch, "Slot does not match any recipe input");
    }

    // Ensure all recipe inputs are satisfied
    for (uint256 i = 0; i < satisfiedInputs.length; i++) {
      require(satisfiedInputs[i], "Not all recipe inputs are satisfied");
    }
  }

  function craft(EntityId caller, bytes32 recipeId) public {
    craftWithStation(caller, recipeId, EntityId.wrap(bytes32(0)));
  }

  function _typeMatches(ObjectTypeId expectedType, ObjectTypeId actualType) private returns (bool) {
    if (expectedType == actualType) {
      return true;
    } else if (expectedType.isAny()) {
      // For ANY type, check if the other object type is in the list of valid types
      ObjectTypeId[] memory validTypes = expectedType.getObjectTypes();
      for (uint256 i = 0; i < validTypes.length; i++) {
        if (slotData.objectType == validTypes[i]) {
          return true;
        }
      }
    }

    return false;
  }
}
