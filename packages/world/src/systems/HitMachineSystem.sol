// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { console } from "forge-std/console.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { LocalEnergyPool } from "../codegen/tables/LocalEnergyPool.sol";
import { ERC165Checker } from "@latticexyz/world/src/ERC165Checker.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Position } from "../utils/Vec3Storage.sol";

import {
  addEnergyToLocalPool,
  decreaseMachineEnergy,
  decreasePlayerEnergy,
  updateMachineEnergy
} from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";

import { InventoryUtils, ToolData } from "../utils/InventoryUtils.sol";
import { Math } from "../utils/Math.sol";
import { HitMachineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import {
  DEFAULT_ORE_TOOL_MULTIPLIER,
  DEFAULT_WOODEN_TOOL_MULTIPLIER,
  HIT_ENERGY_COST,
  SAFE_PROGRAM_GAS,
  SPECIALIZED_ORE_TOOL_MULTIPLIER,
  SPECIALIZED_WOODEN_TOOL_MULTIPLIER
} from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";
import { ProgramId } from "../ProgramId.sol";
import { IHitHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

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
    require(forceField.exists(), "No force field at this location");
    Vec3 forceFieldCoord = Position._get(forceField);

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    require(machineData.energy > 0, "Cannot hit depleted forcefield");

    ToolData memory toolData = InventoryUtils.getToolData(caller, toolSlot);

    (uint128 massReduction, uint128 toolMassReduction) =
      toolData.getMassReduction(machineData.energy, _getToolMultiplier(toolData.toolType));

    uint128 playerEnergyReduction = _getCallerEnergyReduction(callerEnergy, massReduction, machineData.energy);

    // Return early if player died
    if (playerEnergyReduction > 0 && decreasePlayerEnergy(caller, callerCoord, playerEnergyReduction) == 0) {
      addEnergyToLocalPool(forceFieldCoord, playerEnergyReduction);
      return;
    }

    toolData.reduceMass(toolMassReduction);

    uint128 machineEnergyReduction = playerEnergyReduction + massReduction;
    decreaseMachineEnergy(forceField, machineEnergyReduction);

    addEnergyToLocalPool(forceFieldCoord, machineEnergyReduction + playerEnergyReduction);

    ProgramId program = forceField.getProgram();
    bytes memory onHit = abi.encodeCall(IHitHook.onHit, (caller, forceField, machineEnergyReduction, ""));
    // Don't revert and use a fixed amount of gas so the program can't prevent hitting
    program.call({ gas: SAFE_PROGRAM_GAS, hook: onHit });

    notify(caller, HitMachineNotification({ machine: forceField, machineCoord: forceFieldCoord }));
  }

  function _getCallerEnergyReduction(uint128 currentEnergy, uint128 massReduction, uint128 massLeft)
    internal
    pure
    returns (uint128)
  {
    // if tool mass reduction is not enough, consume energy from player up to hit energy cost
    if (massReduction < massLeft) {
      uint128 remaining = massLeft - massReduction;
      uint128 energyReduction = HIT_ENERGY_COST <= remaining ? HIT_ENERGY_COST : remaining;
      return Math.min(currentEnergy, energyReduction);
    }
    return 0;
  }

  function _getToolMultiplier(ObjectType toolType) internal pure returns (uint128) {
    if (toolType.isNull()) {
      return 1;
    }

    bool isWoodenTool = toolType == ObjectTypes.WoodenWhacker;

    if (toolType.isWhacker()) {
      return isWoodenTool ? SPECIALIZED_WOODEN_TOOL_MULTIPLIER : SPECIALIZED_ORE_TOOL_MULTIPLIER;
    }

    return isWoodenTool ? DEFAULT_WOODEN_TOOL_MULTIPLIER : DEFAULT_ORE_TOOL_MULTIPLIER;
  }
}
