// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { Vec3 } from "../types/Vec3.sol";

import { burnToolEnergy } from "./EnergyUtils.sol";
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
    (uint128 actionMassReduction, uint128 toolMassReduction) =
      getMassReduction(toolData, useMassMax, actionModifier, specialized);
    reduceMass(toolData, toolMassReduction);
    return actionMassReduction;
  }

  function getMassReduction(ToolData memory toolData, uint128 massLeft, uint128 actionModifier, bool specialized)
    internal
    view
    returns (uint128, uint128)
  {
    if (toolData.toolType.isNull()) {
      return (0, 0);
    }

    uint128 toolMass = ObjectPhysics._getMass(toolData.toolType);
    uint128 maxToolMassReduction = Math.min(toolMass / 10, toolData.massLeft);

    uint128 baseMultiplier =
      toolData.toolType.isWoodenTool() ? Constants.WOODEN_TOOL_BASE_MULTIPLIER : Constants.ORE_TOOL_BASE_MULTIPLIER;

    uint128 specializationMultiplier = specialized ? Constants.SPECIALIZATION_MULTIPLIER : 1;

    uint128 multiplier = baseMultiplier * specializationMultiplier * actionModifier;

    uint128 potentialMassReduction = maxToolMassReduction * multiplier / Constants.ACTION_MODIFIER_DENOMINATOR;

    if (potentialMassReduction <= massLeft) {
      // Tool capacity is the limiting factor - use exact tool mass reduction
      return (potentialMassReduction, maxToolMassReduction);
    } else {
      // massLeft is the limiting factor - calculate tool mass reduction that produces exactly massLeft
      // We need: toolMassReduction * multiplier / ACTION_MODIFIER_DENOMINATOR = massLeft
      // So: toolMassReduction = massLeft * ACTION_MODIFIER_DENOMINATOR / multiplier
      // But we need to round up to ensure we get at least massLeft when we multiply back
      uint128 toolMassReduction = (massLeft * Constants.ACTION_MODIFIER_DENOMINATOR + multiplier - 1) / multiplier;

      // Ensure we don't exceed the max tool mass reduction
      toolMassReduction = Math.min(toolMassReduction, maxToolMassReduction);

      // Recalculate the actual mass reduction with the rounded tool mass reduction
      uint128 actualMassReduction = toolMassReduction * multiplier / Constants.ACTION_MODIFIER_DENOMINATOR;

      return (actualMassReduction, toolMassReduction);
    }
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
}

using ToolUtils for ToolData global;
