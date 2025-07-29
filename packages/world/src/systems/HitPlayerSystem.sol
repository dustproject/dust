// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";

import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { Math } from "../utils/Math.sol";
import { HitPlayerNotification, notify } from "../utils/NotifUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { DEFAULT_HIT_ENERGY_COST, HIT_ACTION_MODIFIER, MAX_HIT_RADIUS, TOOL_HIT_ENERGY_COST } from "../Constants.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3 } from "../types/Vec3.sol";
import { RateLimitUtils } from "../utils/RateLimitUtils.sol";

contract HitPlayerSystem is System {
  function hitPlayer(EntityId caller, EntityId target, uint16 toolSlot, bytes calldata extraData) public {
    _hitPlayer(caller, target, toolSlot, extraData);
  }

  function hitPlayer(EntityId caller, EntityId target, bytes calldata extraData) public {
    _hitPlayer(caller, target, type(uint16).max, extraData);
  }

  function _hitPlayer(EntityId caller, EntityId target, uint16 toolSlot, bytes calldata extraData) internal {
    // Update and check caller's energy
    uint128 callerEnergy = caller.activate().energy;

    (Vec3 callerCoord, Vec3 targetCoord) = caller.requireInRange(target, MAX_HIT_RADIUS);

    require(target != caller, "Cannot hit yourself");
    require(target._exists(), "No entity at target location");
    require(target._getObjectType() == ObjectTypes.Player, "Target is not a player");

    // Check rate limit for combat actions
    RateLimitUtils.hit(caller);

    // Update target player's energy
    uint128 targetEnergyLeft = updatePlayerEnergy(target).energy;

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
    targetEnergyLeft -= callerEnergyReduction;

    // Apply damage to target player
    uint128 toolEnergyReduction = toolData.use(targetEnergyLeft, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());
    uint128 totalDamage = callerEnergyReduction + toolEnergyReduction;
    decreasePlayerEnergy(target, targetCoord, totalDamage);

    // Add caller's energy reduction to caller's local pool
    addEnergyToLocalPool(callerCoord, callerEnergyReduction);
    // Add target's total damage to target's local pool
    addEnergyToLocalPool(targetCoord, totalDamage);

    _requireHitsAllowed(caller, targetCoord, toolData.tool, totalDamage, extraData);

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

  function _requireHitsAllowed(
    EntityId caller,
    Vec3 targetCoord,
    EntityId tool,
    uint128 totalDamage,
    bytes calldata extraData
  ) internal {
    // Check if target is within a force field and call hooks
    (ProgramId program, EntityId hookTarget, EnergyData memory energyData) = ForceFieldUtils.getHookTarget(targetCoord);

    if (!program.exists()) {
      return;
    }

    program.hook({ caller: caller, target: hookTarget, revertOnFailure: energyData.energy > 0, extraData: extraData })
      .onHit(tool, totalDamage);
  }
}
