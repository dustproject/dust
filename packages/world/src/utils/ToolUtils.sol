// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { Vec3 } from "../types/Vec3.sol";

import { addEnergyToLocalPool, burnToolEnergy, decreasePlayerEnergy, updatePlayerEnergy } from "./EnergyUtils.sol";
import { InventoryUtils } from "./InventoryUtils.sol";
import { Math } from "./Math.sol";
import { OreLib } from "./OreLib.sol";

import "../Constants.sol" as Constants;

struct ToolData {
  EntityId owner;
  EntityId tool;
  ObjectType toolType;
  uint16 slot;
  uint128 massLeft;
}

library ToolUtils {
  function getToolData(EntityId owner, uint16 slot) internal view returns (ToolData memory) {
    EntityId tool = InventorySlot._getEntityId(owner, slot);
    if (!tool._exists()) {
      return ToolData(owner, tool, ObjectTypes.Null, slot, 0);
    }

    ObjectType toolType = tool._getObjectType();
    require(toolType.isTool(), "Inventory item is not a tool");

    return ToolData(owner, tool, toolType, slot, Mass._getMass(tool));
  }

  function use(ToolData memory toolData, uint128 useMassMax) public returns (uint128) {
    return use(toolData, useMassMax, Constants.ACTION_MODIFIER_DENOMINATOR, false);
  }

  function use(ToolData memory toolData, uint128 useMassMax, uint128 actionModifier, bool specialized)
    public
    returns (uint128)
  {
    require(useMassMax != 0, "Cannot perform action with zero mass limit");

    // Get caller's current energy and position
    uint128 callerEnergy = updatePlayerEnergy(toolData.owner).energy;
    Vec3 callerCoord = toolData.owner._getPosition();

    // Calculate energy cost for this action
    uint128 energyCost = getActionEnergyCost(toolData, callerEnergy, useMassMax);

    // If there's an energy cost, apply it
    if (energyCost > 0) {
      // Transfer the player's energy to the local pool
      uint128 remainingEnergy = decreasePlayerEnergy(toolData.owner, callerCoord, energyCost);
      addEnergyToLocalPool(callerCoord, energyCost);

      // If player died, return early
      if (remainingEnergy == 0) {
        return 0;
      }
    }

    // Player survived, calculate tool damage
    (uint128 actionMassReduction, uint128 toolMassReduction) =
      getMassReduction(toolData, useMassMax - energyCost, actionModifier, specialized);
    reduceMass(toolData, toolMassReduction);

    // Return total damage (energy cost + tool damage)
    return energyCost + actionMassReduction;
  }

  function getMassReduction(ToolData memory toolData, uint128 massLeft, uint128 actionModifier, bool specialized)
    internal
    view
    returns (uint128, uint128)
  {
    if (toolData.toolType.isNull() || massLeft == 0) {
      return (0, 0);
    }

    uint128 toolMass = ObjectPhysics._getMass(toolData.toolType);
    uint128 maxToolMassReduction = Math.min(toolMass / 10, toolData.massLeft);

    uint128 baseMultiplier =
      toolData.toolType.isWoodenTool() ? Constants.WOODEN_TOOL_BASE_MULTIPLIER : Constants.ORE_TOOL_BASE_MULTIPLIER;

    uint128 specializationMultiplier = specialized ? Constants.SPECIALIZATION_MULTIPLIER : 1;

    uint256 multiplier = uint256(baseMultiplier) * specializationMultiplier * actionModifier;

    uint256 maxReductionScaled = uint256(maxToolMassReduction) * multiplier;
    uint256 massLeftScaled = uint256(massLeft) * Constants.ACTION_MODIFIER_DENOMINATOR;

    if (maxReductionScaled <= massLeftScaled) {
      // Tool capacity is the limiting factor - use exact tool mass reduction
      return (uint128(maxReductionScaled / Constants.ACTION_MODIFIER_DENOMINATOR), maxToolMassReduction);
    }

    return (massLeft, uint128(Math.divUp(massLeftScaled, multiplier)));
  }

  function reduceMass(ToolData memory toolData, uint128 massReduction) internal {
    if (!toolData.tool._exists()) {
      return;
    }

    require(toolData.massLeft > 0, "Tool is broken");

    if (toolData.massLeft <= massReduction) {
      InventoryUtils.removeEntityFromSlot(toolData.owner, toolData.slot);
      OreLib.burnOres(toolData.toolType);
      burnToolEnergy(toolData.toolType, toolData.owner._getPosition());
    } else {
      Mass._setMass(toolData.tool, toolData.massLeft - massReduction);
    }
  }

  function getActionEnergyCost(ToolData memory toolData, uint128 callerEnergy, uint128 targetCapacity)
    internal
    pure
    returns (uint128)
  {
    uint128 energyCost =
      toolData.toolType.isNull() ? Constants.BARE_HANDS_ACTION_ENERGY_COST : Constants.TOOL_ACTION_ENERGY_COST;
    uint128 maxEnergyCost = Math.min(callerEnergy, energyCost);
    return Math.min(targetCapacity, maxEnergyCost);
  }
}

using ToolUtils for ToolData global;
