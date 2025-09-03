// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ActivityType } from "../codegen/common.sol";

import { PROGRESS_DECAY_LAMBDA_WAD } from "../Constants.sol";
import { Death } from "../codegen/tables/Death.sol";

import { PlayerProgress, PlayerProgressData } from "../codegen/tables/PlayerProgress.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { Math } from "../utils/Math.sol";

library PlayerProgressUtils {
  function getProgress(EntityId player, ActivityType activityType) internal view returns (uint256) {
    PlayerProgressData memory data = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    uint256 e = uint256(data.exponent);
    uint256 diff = deaths > e ? (deaths - e) : 0;

    uint128 decayed = _decay(data.current, data.lastUpdatedAt);
    uint128 decayedEffective = diff > 0 ? decayed >> diff : decayed;
    uint128 alignedAccumulated = diff > 0 ? data.accumulated >> diff : data.accumulated;

    // Floor is just accumulated / 3
    uint128 floor = alignedAccumulated / 3;
    uint128 result = decayedEffective > floor ? decayedEffective : floor;
    return uint256(result);
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
    _trackProgress(player, activityType, massReduced);
  }

  // Combat tracking
  function trackHitPlayer(EntityId player, uint128 damage) internal {
    _trackProgress(player, ActivityType.HitPlayerDamage, damage);
  }

  function trackHitMachine(EntityId player, uint128 damage) internal {
    _trackProgress(player, ActivityType.HitMachineDamage, damage);
  }

  // Movement tracking
  function trackMoves(EntityId player, uint128 walkSteps, uint128 swimSteps) internal {
    if (walkSteps > 0) {
      _trackProgress(player, ActivityType.MoveWalkSteps, walkSteps);
    }
    if (swimSteps > 0) {
      _trackProgress(player, ActivityType.MoveSwimSteps, swimSteps);
    }
  }

  function trackFallEnergy(EntityId player, uint128 fallEnergy) internal {
    _trackProgress(player, ActivityType.MoveFallEnergy, fallEnergy);
  }

  // Building tracking
  function trackBuildEnergy(EntityId player, uint128 energySpent) internal {
    _trackProgress(player, ActivityType.BuildEnergy, energySpent);
  }

  function trackBuildMass(EntityId player, uint128 massBuilt) internal {
    _trackProgress(player, ActivityType.BuildMass, massBuilt);
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

    _trackProgress(player, activityType, massEnergy);
  }

  // Internal helper
  function _trackProgress(EntityId player, ActivityType activityType, uint128 value) private {
    uint256 deaths = Death._getDeaths(player);
    PlayerProgressData memory previous = PlayerProgress._get(player, activityType);

    // Decay current mantissa to now in its stored scale
    uint128 current = _decay(previous.current, previous.lastUpdatedAt);
    uint128 accumulated = previous.accumulated;

    // Align stored mantissas to the current global exponent
    uint256 e = uint256(previous.exponent);
    if (deaths > e) {
      uint256 diff = deaths - e;
      // Right shift by diff == divide by 2^diff
      current = current >> diff;
      accumulated = accumulated >> diff;
    }

    // Add new value and compute the new floor
    accumulated += value;

    // Ensure current reflects the floor (acc / 3)
    uint128 nextCurrent = uint128(Math.max(current + value, accumulated / 3));

    PlayerProgress._set(
      player,
      activityType,
      PlayerProgressData({
        accumulated: accumulated,
        current: nextCurrent,
        lastUpdatedAt: uint128(block.timestamp),
        exponent: uint128(deaths)
      })
    );
  }

  /// @dev Exponential decay toward zero using half-life, in mantissa units
  function _decay(uint128 current, uint128 lastUpdatedAt) private view returns (uint128) {
    if (current == 0 || block.timestamp <= lastUpdatedAt) return current;

    unchecked {
      int256 x = -int256(PROGRESS_DECAY_LAMBDA_WAD) * int256(uint256(block.timestamp - lastUpdatedAt)); // wad * seconds
      uint256 factorWad = uint256(FixedPointMathLib.expWad(x)); // in [0..1e18]
      return uint128(FixedPointMathLib.mulWad(current, factorWad));
    }
  }
}
