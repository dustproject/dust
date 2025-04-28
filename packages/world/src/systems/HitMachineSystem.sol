// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { LocalEnergyPool } from "../codegen/tables/LocalEnergyPool.sol";
import { ERC165Checker } from "@latticexyz/world/src/ERC165Checker.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Position } from "../utils/Vec3Storage.sol";

import { HIT_ENERGY_COST, SAFE_PROGRAM_GAS } from "../Constants.sol";
import {
  addEnergyToLocalPool,
  decreaseMachineEnergy,
  decreasePlayerEnergy,
  updateMachineEnergy
} from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils, ToolData } from "../utils/InventoryUtils.sol";
import { HitMachineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

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
    caller.activate();
    (Vec3 callerCoord,) = caller.requireConnected(coord);
    (EntityId forceField,) = ForceFieldUtils.getForceField(coord);
    require(forceField.exists(), "No force field at this location");
    Vec3 forceFieldCoord = Position._get(forceField);

    uint128 energyReduction =
      HitMachineLib._processEnergyReduction(caller, callerCoord, toolSlot, forceField, forceFieldCoord);

    ProgramId program = forceField.getProgram();
    bytes memory onHit = abi.encodeCall(IHitHook.onHit, (caller, forceField, energyReduction, ""));
    // Don't revert and use a fixed amount of gas so the program can't prevent hitting
    program.call({ gas: SAFE_PROGRAM_GAS, hook: onHit });

    notify(caller, HitMachineNotification({ machine: forceField, machineCoord: forceFieldCoord }));
  }
}

library HitMachineLib {
  function _processEnergyReduction(
    EntityId caller,
    Vec3 callerCoord,
    uint16 toolSlot,
    EntityId forceField,
    Vec3 forceFieldCoord
  ) public returns (uint128) {
    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    require(machineData.energy > 0, "Cannot hit depleted forcefield");

    ToolData memory toolData = InventoryUtils.getToolData(caller, toolSlot);
    uint128 toolMassReduction = toolData.getMassReduction(machineData.energy);

    uint128 playerEnergyReduction = 0;

    // if tool mass reduction is not enough, consume energy from player up to hit energy cost
    uint128 energyLeft;
    if (toolMassReduction < machineData.energy) {
      uint128 remaining = machineData.energy - toolMassReduction;
      playerEnergyReduction = HIT_ENERGY_COST <= remaining ? HIT_ENERGY_COST : remaining;
      energyLeft = decreasePlayerEnergy(caller, callerCoord, playerEnergyReduction);
    }

    uint128 machineEnergyReduction = 0;

    // If player is alive, apply tool usage and decrease machine's energy
    if (energyLeft != 0) {
      toolData.applyMassReduction(callerCoord, toolMassReduction);
      machineEnergyReduction = playerEnergyReduction + toolMassReduction;
      decreaseMachineEnergy(forceField, machineEnergyReduction);
    }

    addEnergyToLocalPool(forceFieldCoord, machineEnergyReduction + playerEnergyReduction);
    return machineEnergyReduction;
  }
}
