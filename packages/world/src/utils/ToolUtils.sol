// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";

import { ActivityType } from "../codegen/common.sol";
import { burnToolEnergy, transferEnergyToPool, updatePlayerEnergy } from "./EnergyUtils.sol";
import { InventoryUtils } from "./InventoryUtils.sol";
import { Math } from "./Math.sol";
import { OreLib } from "./OreLib.sol";
import { PlayerSkillUtils } from "./PlayerSkillUtils.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

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

  function mine(ToolData memory toolData, ObjectType minedType, uint128 useMassMax) public returns (uint128) {
    uint256 mul = PlayerSkillUtils.getMineEnergyMultiplierWad(toolData.owner, toolData.toolType, minedType);

    bool specialized = (toolData.toolType.isAxe() && minedType.hasAxeMultiplier())
      || (toolData.toolType.isPick() && minedType.hasPickMultiplier());

    return use(toolData, useMassMax, Constants.MINE_ACTION_MODIFIER, specialized, mul);
  }

  function hitPlayer(ToolData memory toolData, uint128 targetEnergyLeft) public returns (uint128) {
    uint256 mul = PlayerSkillUtils.getHitPlayerEnergyMultiplierWad(toolData.owner);
    return use(toolData, targetEnergyLeft, Constants.HIT_ACTION_MODIFIER, toolData.toolType.isWhacker(), mul);
  }

  function hitMachine(ToolData memory toolData, uint128 targetEnergyLeft) public returns (uint128) {
    uint256 mul = PlayerSkillUtils.getHitMachineEnergyMultiplierWad(toolData.owner);
    return use(toolData, targetEnergyLeft, Constants.HIT_ACTION_MODIFIER, toolData.toolType.isWhacker(), mul);
  }

  function till(ToolData memory toolData) public returns (uint128) {
    uint256 mul = PlayerSkillUtils.getTillEnergyMultiplierWad(toolData.owner);
    return use(toolData, type(uint128).max, Constants.TILL_ACTION_MODIFIER, false, mul);
  }

  function use(
    ToolData memory toolData,
    uint128 useMassMax,
    uint128 actionModifier,
    bool specialized,
    uint256 energyMultiplierWad
  ) internal returns (uint128) {
    require(useMassMax != 0, "Cannot perform action with zero mass limit");

    // Get caller's current energy and position
    uint128 callerEnergy = updatePlayerEnergy(toolData.owner).energy;

    // Base energy cost
    uint128 baseEnergyCost = getActionEnergyCost(toolData, callerEnergy, useMassMax);

    // Apply discount
    uint128 energyCost = uint128(FixedPointMathLib.mulWad(baseEnergyCost, energyMultiplierWad));

    // Drain energy
    if (energyCost > 0 && transferEnergyToPool(toolData.owner, energyCost) == 0) {
      // Return early if dead
      return 0;
    }

    // Player survived, calculate tool damage based on remaining budget
    (uint128 actionMassReduction, uint128 toolMassReduction) =
      getMassReduction(toolData, useMassMax - energyCost, actionModifier, specialized);
    reduceMass(toolData, toolMassReduction);

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
