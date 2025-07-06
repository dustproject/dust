// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { LocalEnergyPool } from "../codegen/tables/LocalEnergyPool.sol";
import { System } from "@latticexyz/world/src/System.sol";

import {
  addEnergyToLocalPool, decreasePlayerEnergy, updateMachineEnergy, updatePlayerEnergy
} from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { Math } from "../utils/Math.sol";
import { HitPlayerNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import {
  DEFAULT_HIT_ENERGY_COST,
  HIT_ACTION_MODIFIER,
  ORE_TOOL_BASE_MULTIPLIER,
  SAFE_PROGRAM_GAS,
  SPECIALIZATION_MULTIPLIER,
  TOOL_HIT_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3 } from "../types/Vec3.sol";

contract HitPlayerSystem is System {
  function hitPlayer(EntityId caller, Vec3 targetCoord, uint16 toolSlot) public {
    _hitPlayer(caller, targetCoord, toolSlot);
  }

  function hitPlayer(EntityId caller, Vec3 targetCoord) public {
    _hitPlayer(caller, targetCoord, type(uint16).max);
  }

  function _hitPlayer(EntityId caller, Vec3 targetCoord, uint16 toolSlot) internal {
    // Update and check caller's energy
    uint128 callerEnergy = caller.activate().energy;

    (Vec3 callerCoord,) = caller.requireConnected(targetCoord);

    // Get target player at the coordinate
    EntityId target = EntityUtils.getMovableEntityAt(targetCoord);
    require(target != caller, "Cannot hit yourself");
    require(target._exists(), "No player at target location");
    require(target._getObjectType() == ObjectTypes.Player, "Target is not a player");

    // Update target player's energy
    EnergyData memory targetData = updatePlayerEnergy(target);
    uint128 targetEnergyLeft = targetData.energy;

    // If target is already dead, return early
    if (targetEnergyLeft == 0) {
      return;
    }

    // Get tool data for damage calculation
    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    uint128 callerEnergyReduction = _getCallerEnergyReduction(toolData.toolType, callerEnergy, targetEnergyLeft);

    // Reduce caller's energy first
    if (callerEnergyReduction > 0 && decreasePlayerEnergy(caller, callerCoord, callerEnergyReduction) == 0) {
      // Caller died from the energy cost
      addEnergyToLocalPool(callerCoord, callerEnergyReduction);
      return;
    }

    // Calculate damage based on tool
    uint128 remainingTargetEnergy = targetEnergyLeft - callerEnergyReduction;
    uint128 massReduction = toolData.use(remainingTargetEnergy, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());

    uint128 totalDamage = callerEnergyReduction + massReduction;

    // Apply damage to target player
    uint128 newTargetEnergy = decreasePlayerEnergy(target, targetCoord, totalDamage);

    // Add energy to local pool at target location
    addEnergyToLocalPool(targetCoord, totalDamage);

    {
      // Check if target is within a force field and call hooks
      (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(targetCoord);
      if (forceField._exists()) {
        EnergyData memory machineData = updateMachineEnergy(forceField);
        if (machineData.energy > 0) {
          // Get program from fragment first, then forcefield
          ProgramId program = fragment._getProgram();
          if (!program.exists()) {
            program = forceField._getProgram();
          }

          if (program.exists()) {
            Hooks.HitContext memory ctx =
              Hooks.HitContext({ caller: caller, target: target, damage: totalDamage, extraData: "" });
            bytes memory onHit = abi.encodeCall(Hooks.IHit.onHit, ctx);

            // Don't revert and use a fixed amount of gas so the program can't prevent hitting
            program.call({ gas: SAFE_PROGRAM_GAS, hook: onHit });
          }
        }
      }
    }

    // Notify both players about the hit
    notify(caller, HitPlayerNotification({ targetPlayer: target, targetCoord: targetCoord, damage: totalDamage }));

    // TODO: Notify target about being hit?
    // notify(target, HitPlayerNotification({ targetPlayer: caller, targetCoord: callerCoord, damage: totalDamage }));
  }

  function _getCallerEnergyReduction(ObjectType toolType, uint128 currentEnergy, uint128 targetEnergyLeft)
    internal
    pure
    returns (uint128)
  {
    uint128 maxEnergyCost = toolType.isNull() ? DEFAULT_HIT_ENERGY_COST : TOOL_HIT_ENERGY_COST;
    maxEnergyCost = Math.min(currentEnergy, maxEnergyCost);
    return Math.min(targetEnergyLeft, maxEnergyCost);
  }
}
