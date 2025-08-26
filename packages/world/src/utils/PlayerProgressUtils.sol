// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ActivityType } from "../codegen/common.sol";

import {
  MAX_RATE_LIMIT_UNITS_PER_SECOND,
  PLAYER_FALL_ENERGY_COST,
  PROGRESS_DECAY_LAMBDA_WAD,
  SKILL_FALL_BLOCKS_TO_MAX,
  SKILL_MAX_ENERGY_DISCOUNT_WAD,
  SKILL_MINING_BLOCKS_TO_MAX,
  SKILL_SWIM_SECONDS_TO_MAX,
  SKILL_WALK_SECONDS_TO_MAX,
  SWIM_UNIT_COST,
  WALK_UNIT_COST
} from "../Constants.sol";
import { Death } from "../codegen/tables/Death.sol";

import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { PlayerProgress, PlayerProgressData } from "../codegen/tables/PlayerProgress.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { Math } from "../utils/Math.sol";

library PlayerProgressUtils {
  // Reads -----------------------------------------------------------
  function getAccumulated(EntityId player, ActivityType activityType) public view returns (uint256) {
    PlayerProgressData memory data = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    uint256 e = data.exponent;
    uint256 diff = deaths > e ? (deaths - e) : 0;
    return data.accumulated >> diff;
  }

  function getProgress(EntityId player, ActivityType activityType) public view returns (uint256) {
    PlayerProgressData memory data = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    uint256 e = data.exponent;
    uint256 diff = deaths > e ? (deaths - e) : 0;
    uint256 decayed = _decay(data.current, data.lastUpdatedAt);
    uint256 decayedEffective = decayed >> diff;
    uint256 alignedAccumulated = data.accumulated >> diff;
    uint256 floorEffective = alignedAccumulated / 3;
    return Math.max(decayedEffective, floorEffective);
  }

  function getFloor(EntityId player, ActivityType activityType) public view returns (uint256) {
    PlayerProgressData memory data = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    uint256 e = data.exponent;
    uint256 diff = deaths > e ? (deaths - e) : 0;
    uint256 alignedAccumulated = data.accumulated >> diff;
    return alignedAccumulated / 3;
  }

  // Mining tracking - with tool specialization and crop detection
  function trackMine(EntityId player, uint128 massReduced, ObjectType toolType, ObjectType minedType) internal {
    ActivityType activityType;

    // Check if we're mining a crop
    if (minedType.isCrop()) {
      // TODO: should we still track axe/pick mining independently?
      activityType = ActivityType.MineCropMass;
    } else if (toolType.isAxe()) {
      activityType = ActivityType.MineAxeMass;
    } else if (toolType.isPick()) {
      activityType = ActivityType.MinePickMass;
    } else {
      // Bare hands / whacker mining of non-crops - not tracked for now
      return;
    }
    _trackProgress(player, activityType, uint256(massReduced));
  }

  // Combat tracking
  function trackHitPlayer(EntityId player, uint128 damage) internal {
    _trackProgress(player, ActivityType.HitPlayerDamage, uint256(damage));
  }

  function trackHitMachine(EntityId player, uint128 damage) internal {
    _trackProgress(player, ActivityType.HitMachineDamage, uint256(damage));
  }

  // Movement tracking
  function trackMoves(EntityId player, uint128 walkSteps, uint128 swimSteps) internal {
    if (walkSteps > 0) {
      _trackProgress(player, ActivityType.MoveWalkSteps, uint256(walkSteps));
    }
    if (swimSteps > 0) {
      _trackProgress(player, ActivityType.MoveSwimSteps, uint256(swimSteps));
    }
  }

  function trackFallEnergy(EntityId player, uint128 fallEnergy) internal {
    _trackProgress(player, ActivityType.MoveFallEnergy, uint256(fallEnergy));
  }

  // Building tracking
  function trackBuildEnergy(EntityId player, uint128 energySpent) internal {
    _trackProgress(player, ActivityType.BuildEnergy, uint256(energySpent));
  }

  function trackBuildMass(EntityId player, uint128 massBuilt) internal {
    _trackProgress(player, ActivityType.BuildMass, uint256(massBuilt));
  }

  // Crafting tracking - per station type
  function trackCraft(EntityId player, ObjectType stationType, uint128 massEnergy) internal {
    ActivityType activityType;

    if (stationType == ObjectTypes.Workbench) {
      activityType = ActivityType.CraftWorkbenchMass;
    } else if (stationType == ObjectTypes.Powerstone) {
      activityType = ActivityType.CraftPowerstoneMass;
    } else if (stationType == ObjectTypes.Furnace) {
      activityType = ActivityType.CraftFurnaceMass;
    } else if (stationType == ObjectTypes.Stonecutter) {
      activityType = ActivityType.CraftStonecutterMass;
    } else if (stationType == ObjectTypes.Anvil) {
      activityType = ActivityType.CraftAnvilMass;
    } else {
      // Hand crafting (no station required)
      activityType = ActivityType.CraftHandMass;
    }

    _trackProgress(player, activityType, uint256(massEnergy));
  }

  // Internal helper
  function _trackProgress(EntityId player, ActivityType activityType, uint256 value) private {
    uint256 deaths = Death._getDeaths(player);
    PlayerProgressData memory previous = PlayerProgress._get(player, activityType);

    // Decay current mantissa to now in its stored scale
    uint256 current = _decay(previous.current, previous.lastUpdatedAt);
    uint256 accumulated = previous.accumulated;

    // Align stored mantissas to the current global exponent
    uint256 e = previous.exponent;
    if (deaths > e) {
      uint256 diff = deaths - e;
      // Right shift by diff == divide by 2^diff
      current >>= diff;
      accumulated >>= diff;
    }

    // Add new value and compute the new floor (minimal clamp semantics)
    accumulated = accumulated + value;
    uint256 floorNew = accumulated / 3;

    // Minimal update: ensure current reflects the new floor but don't overshoot
    current = Math.max(current + value, floorNew);

    PlayerProgress._set(
      player,
      activityType,
      PlayerProgressData({
        accumulated: accumulated,
        current: current,
        lastUpdatedAt: uint128(block.timestamp),
        exponent: deaths
      })
    );
  }

  /// @dev Exponential decay toward zero using half-life, in mantissa units
  function _decay(uint256 current, uint128 lastUpdatedAt) private view returns (uint256) {
    if (current == 0 || block.timestamp <= lastUpdatedAt) return current;

    unchecked {
      int256 x = -int256(PROGRESS_DECAY_LAMBDA_WAD) * int256(uint256(block.timestamp - lastUpdatedAt)); // wad * seconds
      uint256 factorWad = uint256(FixedPointMathLib.expWad(x)); // in [0..1e18]
      return FixedPointMathLib.mulWad(current, factorWad);
    }
  }

  // ----------------------------------------------------------------
  // Skill benefits (energy discounts)
  // ----------------------------------------------------------------

  // Smooth-then-cap discount using dynamic S and xCap anchors
  function _normalizedSmooth(uint256 x, uint256 xCap) private pure returns (uint256) {
    if (x == 0) return 0;
    if (xCap == 0) return 1e18; // degenerate case, treat as max
    // Use S = xCap
    uint256 S = xCap;
    // f(x) = x / (x + S)
    uint256 fx = FixedPointMathLib.divWad(x, x + S);
    uint256 fcap = FixedPointMathLib.divWad(xCap, xCap + S); // = 0.5 when S = xCap
    // normalized = min(1, fx / fcap)
    uint256 ratio = FixedPointMathLib.divWad(fx, fcap);
    return ratio > 1e18 ? 1e18 : ratio;
  }

  function _stepsPerSecond(uint256 unitCost) private pure returns (uint256) {
    // steps_per_second = MAX_RATE_LIMIT_UNITS_PER_SECOND / UNIT_COST
    return MAX_RATE_LIMIT_UNITS_PER_SECOND / unitCost;
  }

  function _walkStepsToMax() private pure returns (uint256) {
    return _stepsPerSecond(WALK_UNIT_COST) * SKILL_WALK_SECONDS_TO_MAX;
  }

  function _swimStepsToMax() private pure returns (uint256) {
    return _stepsPerSecond(SWIM_UNIT_COST) * SKILL_SWIM_SECONDS_TO_MAX;
  }

  function _fallEnergyToMax() private pure returns (uint256) {
    return uint256(PLAYER_FALL_ENERGY_COST) * SKILL_FALL_BLOCKS_TO_MAX;
  }

  function getEnergyDiscountWad(EntityId player, ActivityType activityType) internal view returns (uint256) {
    uint256 progress = getFloor(player, activityType);

    uint256 xCap;
    if (activityType == ActivityType.MoveWalkSteps) {
      xCap = _walkStepsToMax();
    } else if (activityType == ActivityType.MoveSwimSteps) {
      xCap = _swimStepsToMax();
    } else if (activityType == ActivityType.MoveFallEnergy) {
      xCap = _fallEnergyToMax();
    } else if (
      activityType == ActivityType.MinePickMass || activityType == ActivityType.MineAxeMass
        || activityType == ActivityType.MineCropMass
    ) {
      // For mining families, caller should use getMiningEnergyDiscountWad as it needs minedType for scaling
      revert("Use mining-specific discount");
    } else {
      // No discount for other activities (yet)
      return 0;
    }

    uint256 normalized = _normalizedSmooth(progress, xCap);
    return FixedPointMathLib.mulWad(SKILL_MAX_ENERGY_DISCOUNT_WAD, normalized);
  }

  function getMiningEnergyDiscountWad(EntityId player, ObjectType toolType, ObjectType minedType)
    internal
    view
    returns (uint256 discountWad)
  {
    ActivityType activityType;
    if (minedType.isCrop()) {
      activityType = ActivityType.MineCropMass;
    } else if (toolType.isAxe()) {
      activityType = ActivityType.MineAxeMass;
    } else if (toolType.isPick()) {
      activityType = ActivityType.MinePickMass;
    } else {
      return 0;
    }

    uint256 progress = getFloor(player, activityType);
    // xCap is derived from mass-per-block * blocks_to_max
    uint256 blockMass = ObjectPhysics._getMass(minedType);
    uint256 xCap = blockMass * SKILL_MINING_BLOCKS_TO_MAX;
    uint256 normalized = _normalizedSmooth(progress, xCap);
    return FixedPointMathLib.mulWad(SKILL_MAX_ENERGY_DISCOUNT_WAD, normalized);
  }
}
