// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import {
  SKILL_BUILD_ENERGY_TO_MAX,
  SKILL_CRAFT_MASS_ENERGY_TO_MAX,
  SKILL_ENERGY_MAX_DISCOUNT_WAD,
  SKILL_FALL_ENERGY_TO_MAX,
  SKILL_HIT_MACHINE_ENERGY_TO_MAX,
  SKILL_HIT_PLAYER_ENERGY_TO_MAX,
  SKILL_MINING_MASS_TO_MAX,
  SKILL_MOVE_ENERGY_TO_MAX
} from "../Constants.sol";
import { ActivityType } from "../codegen/common.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { PlayerProgressUtils as Tracking } from "./PlayerProgressUtils.sol";

library PlayerSkillUtils {
  function getMoveEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveEnergy),
      progressCap: SKILL_MOVE_ENERGY_TO_MAX
    });
  }

  function getFallEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveFallEnergy),
      progressCap: SKILL_FALL_ENERGY_TO_MAX
    });
  }

  function getMineEnergyMultiplierWad(EntityId player, ObjectType toolType, ObjectType minedType)
    internal
    view
    returns (uint256)
  {
    ActivityType activityType;
    if (minedType.isCrop()) {
      activityType = ActivityType.MineCropMass;
    } else if (toolType.isAxe()) {
      activityType = ActivityType.MineAxeMass;
    } else if (toolType.isPick()) {
      activityType = ActivityType.MinePickMass;
    } else {
      // TODO: use wad
      return 1e18; // no applicable mining progress
    }

    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, activityType),
      progressCap: SKILL_MINING_MASS_TO_MAX
    });
  }

  function getHitPlayerEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.HitPlayerDamage),
      progressCap: SKILL_HIT_PLAYER_ENERGY_TO_MAX
    });
  }

  function getHitMachineEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.HitMachineDamage),
      progressCap: SKILL_HIT_MACHINE_ENERGY_TO_MAX
    });
  }

  function getTillEnergyMultiplierWad(EntityId /*player*/ ) internal pure returns (uint256) {
    // No skill benefit for tilling (for now); keep encapsulated for easy future tuning
    return FixedPointMathLib.WAD;
  }

  function getCraftEnergyMultiplierWad(EntityId player, ObjectType stationType) internal view returns (uint256) {
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
      activityType = ActivityType.CraftHandMass;
    }

    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, activityType),
      progressCap: SKILL_CRAFT_MASS_ENERGY_TO_MAX
    });
  }

  function getBuildEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.BuildMass),
      progressCap: SKILL_BUILD_ENERGY_TO_MAX
    });
  }

  /**
   * @dev Map activity progress to an energy-cost multiplier in WAD (1e18 = 1.0x).
   *
   * Produces a smooth, bounded discount in [1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, 1e18].
   *
   * Intuition
   * - Players accumulate per-activity "progress" (e.g. energy spent or mass reduced).
   * - We normalize that progress to [0, 1] with a smooth, saturating curve (see `_normalizedSmooth`).
   * - We linearly mix between no discount (1e18) and the configured maximum discount
   *   (SKILL_ENERGY_MAX_DISCOUNT_WAD) according to that normalized score.
   *
   * Properties
   * - Monotonic: More progress → equal or smaller multiplier (never increases cost).
   * - Bounded: multiplier ≥ SKILL_ENERGY_MAX_DISCOUNT_WAD and ≤ 1e18.
   * - Smooth: No cliffs; small progress changes yield small multiplier changes.
   *
   * Example
   * - With SKILL_ENERGY_MAX_DISCOUNT_WAD = 0.30e18 (30% max discount):
   *   - progress = 0      → multiplier = 1.00e18 (no discount)
   *   - progress ≈ cap    → multiplier ≈ 0.70e18 (max discount)
   *
   * @param progress    Activity progress in domain units (energy, mass, etc.).
   * @param progressCap Soft cap (domain units) representing "effort to reach max" for the activity.
   * @return multiplier Energy multiplier in WAD to apply to base costs.
   */
  function getEnergyMultiplierWad(uint128 progress, uint128 progressCap) internal pure returns (uint256) {
    uint256 normalized = _normalizedSmooth(progress, progressCap);
    uint256 discount = FixedPointMathLib.mulWad(SKILL_ENERGY_MAX_DISCOUNT_WAD, normalized);
    return FixedPointMathLib.WAD - discount;
  }

  /**
   * @dev Smooth, capped normalization of progress into [0, 1] (WAD).
   *
   * Uses an intuitive saturating curve with diminishing returns:
   *
   * Curve
   * - Let s = xCap and define f(x) = x / (x + s).
   *   - f(0) = 0 (no progress → no benefit)
   *   - f(s) = 1/2 (reaching the cap marks a midpoint on the curve)
   *   - f(∞) → 1 (diminishing returns as progress grows large)
   * - We normalize by f(xCap) so that reaching the cap maps to 1.0 (WAD = 1e18).
   * - Finally, clamp to [0, 1e18] for stability.
   *
   * Why this form
   * - Easy tuning: choose xCap as the intuitive "effort to reach max"; the shape follows naturally.
   * - Smooth and monotonic: avoids abrupt changes in player experience.
   *
   * @param x     Current progress in domain units.
   * @param xCap  Soft cap for the activity (domain units). If 0, treated as already maxed.
   * @return normalized Value in [0, 1e18] representing relative progress.
   */
  function _normalizedSmooth(uint128 x, uint128 xCap) private pure returns (uint256) {
    if (x == 0) return 0;
    if (xCap == 0) return 1e18; // degenerate case, treat as max
    uint256 s = xCap;
    // f(x) = x / (x + s)
    uint256 fx = FixedPointMathLib.divWad(x, x + s);
    uint256 fcap = FixedPointMathLib.divWad(xCap, xCap + s); // = 0.5 when S = xCap
    // normalized = min(1, fx / fcap)
    uint256 ratio = FixedPointMathLib.divWad(fx, fcap);
    return ratio > 1e18 ? 1e18 : ratio;
  }
}
