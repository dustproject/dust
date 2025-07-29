// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import {
  addEnergyToLocalPool,
  decreaseMachineEnergy,
  decreasePlayerEnergy,
  updateMachineEnergy
} from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";

import { Math } from "../utils/Math.sol";
import { HitMachineNotification, notify } from "../utils/NotifUtils.sol";

import { RateLimitUtils } from "../utils/RateLimitUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { DEFAULT_HIT_ENERGY_COST, HIT_ACTION_MODIFIER, MAX_HIT_RADIUS, TOOL_HIT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { Vec3 } from "../types/Vec3.sol";

contract HitMachineSystem is System {
  function hitForceField(EntityId caller, Vec3 coord, uint16 toolSlot) public {
    _hitForceField(caller, coord, toolSlot);
  }

  function hitForceField(EntityId caller, Vec3 coord) public {
    _hitForceField(caller, coord, type(uint16).max);
  }

  function _hitForceField(EntityId caller, Vec3 coord, uint16 toolSlot) internal {
    uint128 callerEnergy = caller.activate().energy;

    (Vec3 callerCoord,) = caller.requireInRange(coord, MAX_HIT_RADIUS);
    (EntityId forceField,) = ForceFieldUtils.getForceField(coord);
    require(forceField._exists(), "No force field at this location");

    uint128 energyLeft = updateMachineEnergy(forceField).energy;
    require(energyLeft > 0, "Cannot hit depleted forcefield");

    // Check rate limit for combat actions
    RateLimitUtils.hit(caller);

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    uint128 playerEnergyReduction = _getCallerEnergyReduction(toolData.toolType, callerEnergy, energyLeft);

    // Return early if player died
    if (playerEnergyReduction > 0 && decreasePlayerEnergy(caller, callerCoord, playerEnergyReduction) == 0) {
      addEnergyToLocalPool(callerCoord, playerEnergyReduction);
      return;
    }

    energyLeft -= playerEnergyReduction;

    uint128 massReduction = toolData.use(energyLeft, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());
    uint128 machineEnergyReduction = playerEnergyReduction + massReduction;

    decreaseMachineEnergy(forceField, machineEnergyReduction);

    Vec3 forceFieldCoord = forceField._getPosition();

    // Add player's energy reduction to player's local pool
    addEnergyToLocalPool(callerCoord, playerEnergyReduction);
    // Add total machine damage to force field's local pool
    addEnergyToLocalPool(forceFieldCoord, machineEnergyReduction);

    // Don't revert so the program can't prevent hitting
    forceField._getProgram().hook({ caller: caller, target: forceField, revertOnFailure: false, extraData: "" }).onHit(
      toolData.tool, machineEnergyReduction
    );

    notify(caller, HitMachineNotification({ machine: forceField, machineCoord: forceFieldCoord }));
  }

  function _getCallerEnergyReduction(ObjectType toolType, uint128 currentEnergy, uint128 energyLeft)
    internal
    pure
    returns (uint128)
  {
    uint128 maxEnergyCost = toolType.isNull() ? DEFAULT_HIT_ENERGY_COST : TOOL_HIT_ENERGY_COST;
    maxEnergyCost = Math.min(currentEnergy, maxEnergyCost);
    return Math.min(energyLeft, maxEnergyCost);
  }
}
