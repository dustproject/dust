// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EnergyData } from "../codegen/tables/Energy.sol";
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
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { DEFAULT_HIT_ENERGY_COST, HIT_ACTION_MODIFIER, SAFE_PROGRAM_GAS, TOOL_HIT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
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
    (Vec3 callerCoord,) = caller.requireConnected(coord);
    (EntityId forceField,) = ForceFieldUtils.getForceField(coord);
    require(forceField._exists(), "No force field at this location");

    EnergyData memory machineData = updateMachineEnergy(forceField);
    uint128 energyLeft = machineData.energy;
    require(energyLeft > 0, "Cannot hit depleted forcefield");

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    uint128 playerEnergyReduction = _getCallerEnergyReduction(toolData.toolType, callerEnergy, energyLeft);

    Vec3 forceFieldCoord = forceField._getPosition();

    // Return early if player died
    if (playerEnergyReduction > 0 && decreasePlayerEnergy(caller, callerCoord, playerEnergyReduction) == 0) {
      addEnergyToLocalPool(forceFieldCoord, playerEnergyReduction);
      return;
    }

    energyLeft -= playerEnergyReduction;

    uint128 massReduction = toolData.use(energyLeft, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());

    uint128 machineEnergyReduction = playerEnergyReduction + massReduction;

    decreaseMachineEnergy(forceField, machineEnergyReduction);
    addEnergyToLocalPool(forceFieldCoord, machineEnergyReduction + playerEnergyReduction);

    {
      ProgramId program = forceField._getProgram();
      // Don't revert so the program can't prevent hitting
      program.hook({ caller: caller, target: forceField, revertOnFailure: false, extraData: "" }).onHit(
        machineEnergyReduction
      );
    }

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
