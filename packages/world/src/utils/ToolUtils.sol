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

import {
  ACTION_MODIFIER_DENOMINATOR,
  DEFAULT_MINE_ENERGY_COST,
  HIT_ACTION_MODIFIER,
  MINE_ACTION_MODIFIER,
  ORE_TOOL_BASE_MULTIPLIER,
  SPECIALIZATION_MULTIPLIER,
  TOOL_HIT_ENERGY_COST,
  TOOL_MINE_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../Constants.sol";

struct ToolData {
  EntityId owner;
  EntityId tool;
  ObjectType toolType;
  uint16 slot;
  uint128 massLeft;
}

enum ActionType {
  Mine,
  Hit,
  Till
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
    return use(toolData, useMassMax, ACTION_MODIFIER_DENOMINATOR);
  }

  function use(ToolData memory toolData, uint128 useMassMax, uint128 multiplier) public returns (uint128) {
    (uint128 actionMassReduction, uint128 toolMassReduction) = getMassReduction(toolData, useMassMax, multiplier);
    reduceMass(toolData, toolMassReduction);
    return actionMassReduction;
  }

  function getMassReduction(ToolData memory toolData, uint128 massLeft, uint128 multiplier)
    internal
    view
    returns (uint128, uint128)
  {
    if (toolData.toolType.isNull()) {
      return (0, 0);
    }

    uint128 toolMass = ObjectPhysics._getMass(toolData.toolType);
    uint128 maxToolMassReduction = Math.min(toolMass / 10, toolData.massLeft);
    uint128 massReduction = Math.min(maxToolMassReduction * multiplier / ACTION_MODIFIER_DENOMINATOR, massLeft);
    uint128 toolMassReduction = massReduction * ACTION_MODIFIER_DENOMINATOR / multiplier;

    return (massReduction, toolMassReduction);
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
