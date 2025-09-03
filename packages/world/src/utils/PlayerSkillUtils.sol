// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import {
  SKILL_CRAFT_MASS_ENERGY_TO_MAX,
  SKILL_ENERGY_MIN_MULTIPLIER_WAD,
  SKILL_FALL_ENERGY_TO_MAX,
  SKILL_HIT_MACHINE_ENERGY_TO_MAX,
  SKILL_HIT_PLAYER_ENERGY_TO_MAX,
  SKILL_MINING_MASS_TO_MAX,
  SKILL_SWIM_STEPS_TO_MAX,
  SKILL_WALK_STEPS_TO_MAX
} from "../Constants.sol";
import { ActivityType } from "../codegen/common.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { PlayerProgressUtils as Tracking } from "./PlayerProgressUtils.sol";

library PlayerSkillUtils {
  function getWalkEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveWalkSteps),
      progressCap: SKILL_WALK_STEPS_TO_MAX
    });
  }

  function getSwimEnergyMultiplierWad(EntityId player) internal view returns (uint256) {
    return getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveSwimSteps),
      progressCap: SKILL_SWIM_STEPS_TO_MAX
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

  function getEnergyMultiplierWad(uint256 progress, uint256 progressCap) internal pure returns (uint256) {
    uint256 normalized = _normalizedSmooth(progress, progressCap);
    uint256 range = 1e18 - SKILL_ENERGY_MIN_MULTIPLIER_WAD;
    return 1e18 - FixedPointMathLib.mulWad(range, normalized);
  }

  /// @dev Smooth-then-cap discount normalized by f(xCap)
  function _normalizedSmooth(uint256 x, uint256 xCap) private pure returns (uint256) {
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
