// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Math } from "./Math.sol";

import {
  SKILL_BUILD_ENERGY_TO_MAX,
  SKILL_CRAFT_MASS_ENERGY_TO_MAX,
  SKILL_ENERGY_MAX_DISCOUNT_WAD,
  SKILL_FALL_ENERGY_TO_MAX,
  SKILL_HIT_MACHINE_ENERGY_TO_MAX,
  SKILL_HIT_PLAYER_ENERGY_TO_MAX,
  SKILL_MINING_MASS_TO_MAX,
  SKILL_MOVE_ENERGY_TO_MAX,
  WAD
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

  function getMineEnergyMultiplierWad(EntityId player, ObjectType toolType) internal view returns (uint256) {
    ActivityType activityType;
    if (toolType.isAxe()) {
      activityType = ActivityType.MineAxeMass;
    } else if (toolType.isPick()) {
      activityType = ActivityType.MinePickMass;
    } else {
      return WAD; // no applicable mining progress
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
    return WAD;
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
   * - Bounded: 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD <= multiplier ≤ 1e18.
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
    // No progress => no discount
    if (progress == 0) return WAD;

    /**
     * Smoothing curve:
     *
     *   Let x = progress, c = progressCap.
     *
     *   Smoothing function: f(x) = x/(x+c)
     *
     *   Normalized: f'(x) = min(1, 2x / (x + c))
     *     - This is f(x) re-scaled so that f(c) = 1/2  =>  f'(c) = 1.
     *     - Monotone increasing, concave (diminishing returns), saturates at 1.
     *
     *   multiplier = 1 - maxDiscount * f'(x)
     */

    // Degenerate / at-or-over cap => max discount
    if (progressCap == 0 || progress >= progressCap) {
      return WAD - SKILL_ENERGY_MAX_DISCOUNT_WAD;
    }

    uint256 sum = uint256(progress) + uint256(progressCap); // x + xCap
    uint256 numerator = uint256(SKILL_ENERGY_MAX_DISCOUNT_WAD) * (uint256(progress) << 1); // maxDiscount * 2x
    uint256 discount = numerator / sum; // WAD-scaled (domain units cancel)

    unchecked {
      return WAD - discount;
    }
  }
}
