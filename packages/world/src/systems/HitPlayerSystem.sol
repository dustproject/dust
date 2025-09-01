// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";

import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { HitPlayerNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerProgressUtils } from "../utils/PlayerProgressUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { HIT_ACTION_MODIFIER, MAX_HIT_RADIUS } from "../Constants.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectTypes } from "../types/ObjectType.sol";
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
    caller.activate();

    (, Vec3 targetCoord) = caller.requireInRange(target, MAX_HIT_RADIUS);

    target = target.baseEntityId();

    require(target != caller, "Cannot hit yourself");
    require(target._exists(), "No entity at target location");
    require(target._getObjectType() == ObjectTypes.Player, "Target is not a player");

    RateLimitUtils.hitPlayer(caller);

    // Update target player's energy
    uint128 targetEnergy = updatePlayerEnergy(target).energy;

    // If target is already dead, return early
    if (targetEnergy == 0) {
      return;
    }

    // Get tool data for damage calculation
    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);

    // Use tool and get total damage (handles energy costs internally)
    uint128 damage = toolData.use(targetEnergy, HIT_ACTION_MODIFIER, toolData.toolType.isWhacker());

    // If caller died (damage == 0), return early
    if (damage == 0) {
      return;
    }

    // Apply damage to target player
    decreasePlayerEnergy(target, damage);

    // Add target's total damage to target's local pool
    addEnergyToLocalPool(targetCoord, damage);

    // Track damage dealt
    PlayerProgressUtils.trackHitPlayer(caller, damage);

    HitPlayerLib._requireHitsAllowed(caller, target, targetCoord, toolData.tool, damage, extraData);

    notify(caller, HitPlayerNotification({ targetPlayer: target, targetCoord: targetCoord, damage: damage }));
  }
}

library HitPlayerLib {
  function _requireHitsAllowed(
    EntityId caller,
    EntityId target,
    Vec3 targetCoord,
    EntityId tool,
    uint128 totalDamage,
    bytes calldata extraData
  ) public {
    // Check if target is within a force field and call hooks
    (ProgramId program, EntityId hookTarget, EnergyData memory energyData) = ForceFieldUtils.getHookTarget(targetCoord);

    program.hook({ caller: caller, target: hookTarget, revertOnFailure: energyData.energy > 0, extraData: extraData })
      .onHit(target, tool, totalDamage);
  }
}
