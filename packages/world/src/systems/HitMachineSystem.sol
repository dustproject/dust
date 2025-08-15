// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { addEnergyToLocalPool, decreaseMachineEnergy, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";

import { HitMachineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerProgressUtils } from "../utils/PlayerProgressUtils.sol";

import { RateLimitUtils } from "../utils/RateLimitUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { HIT_ACTION_MODIFIER, MAX_HIT_RADIUS } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";

import { Vec3 } from "../types/Vec3.sol";

contract HitMachineSystem is System {
  function hitForceField(EntityId caller, Vec3 coord, uint16 toolSlot) public {
    _hitForceField(caller, coord, toolSlot);
  }

  function hitForceField(EntityId caller, Vec3 coord) public {
    _hitForceField(caller, coord, type(uint16).max);
  }

  function _hitForceField(EntityId caller, Vec3 coord, uint16 toolSlot) internal {
    caller.activate();
    caller.requireInRange(coord, MAX_HIT_RADIUS);

    (EntityId target,) = ForceFieldUtils.getForceField(coord);
    require(target._exists(), "No force field at this location");

    uint128 energyLeft = updateMachineEnergy(target).energy;
    require(energyLeft > 0, "Cannot hit depleted forcefield");

    // Check rate limit for hit
    RateLimitUtils.hit(caller);

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);

    // Use tool and get total damage (handles energy costs internally)
    uint128 damage = toolData.use(energyLeft, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());

    // If caller died (damage == 0), return early
    if (damage == 0) {
      return;
    }

    decreaseMachineEnergy(target, damage);

    Vec3 forceFieldCoord = target._getPosition();

    // Add total machine damage to force field's local pool
    addEnergyToLocalPool(forceFieldCoord, damage);

    // Track damage dealt for player activity
    PlayerProgressUtils.trackHitMachine(caller, damage);

    // Don't revert so the program can't prevent hitting
    target._getProgram().hook({ caller: caller, target: target, revertOnFailure: false, extraData: "" }).onHit(
      target, toolData.tool, damage
    );

    notify(caller, HitMachineNotification({ machine: target, machineCoord: forceFieldCoord }));
  }
}
