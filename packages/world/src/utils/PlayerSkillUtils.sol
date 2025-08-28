// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import {
  LAVA_MOVE_ENERGY_COST,
  MAX_RATE_LIMIT_UNITS_PER_SECOND,
  MOVE_ENERGY_COST,
  PLAYER_FALL_ENERGY_COST,
  SKILL_CRAFT_MASS_ENERGY_TO_MAX,
  SKILL_ENERGY_MIN_MULTIPLIER_WAD,
  SKILL_FALL_BLOCKS_TO_MAX,
  SKILL_HIT_MACHINE_ENERGY_TO_MAX,
  SKILL_HIT_PLAYER_ENERGY_TO_MAX,
  SKILL_MINING_BLOCKS_TO_MAX,
  SKILL_SWIM_SECONDS_TO_MAX,
  SKILL_WALK_SECONDS_TO_MAX,
  SWIM_UNIT_COST,
  WALK_UNIT_COST,
  WATER_MOVE_ENERGY_COST
} from "../Constants.sol";
import { ActivityType } from "../codegen/common.sol";

import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { PlayerProgressUtils as Tracking } from "./PlayerProgressUtils.sol";

struct MoveCosts {
  uint128 walkCost;
  uint128 swimCost;
  uint128 lavaCost;
  uint128 fallPerBlockCost;
}

library PlayerSkillUtils {
  function getMoveEnergyMultipliersWad(EntityId player)
    internal
    view
    returns (uint256 walkMul, uint256 swimMul, uint256 lavaMul, uint256 fallMul)
  {
    walkMul = getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveWalkSteps),
      progressCap: _walkStepsToMax()
    });

    swimMul = getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveSwimSteps),
      progressCap: _swimStepsToMax()
    });

    lavaMul = walkMul; // reuse walk for now

    fallMul = getEnergyMultiplierWad({
      progress: Tracking.getProgress(player, ActivityType.MoveFallEnergy),
      progressCap: _fallEnergyToMax()
    });
  }

  function movementPricing(EntityId player) internal view returns (MoveCosts memory p) {
    (uint256 walkMul, uint256 swimMul, uint256 lavaMul, uint256 fallMul) = getMoveEnergyMultipliersWad(player);
    unchecked {
      p.walkCost = uint128(FixedPointMathLib.mulWad(MOVE_ENERGY_COST, walkMul));
      p.swimCost = uint128(FixedPointMathLib.mulWad(WATER_MOVE_ENERGY_COST, swimMul));
      p.lavaCost = uint128(FixedPointMathLib.mulWad(LAVA_MOVE_ENERGY_COST, lavaMul));
      p.fallPerBlockCost = uint128(FixedPointMathLib.mulWad(PLAYER_FALL_ENERGY_COST, fallMul));
    }
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

    uint256 blockMass = ObjectPhysics._getMass(minedType);
    uint256 progressCap = blockMass * SKILL_MINING_BLOCKS_TO_MAX;
    uint256 progress = Tracking.getProgress(player, activityType);

    return getEnergyMultiplierWad(progress, progressCap);
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

    uint256 progress = Tracking.getProgress(player, activityType);
    return getEnergyMultiplierWad(progress, SKILL_CRAFT_MASS_ENERGY_TO_MAX);
  }

  function getEnergyMultiplierWad(uint256 progress, uint256 progressCap) internal pure returns (uint256) {
    uint256 normalized = _normalizedSmooth(progress, progressCap);
    uint256 range = 1e18 - SKILL_ENERGY_MIN_MULTIPLIER_WAD;
    return 1e18 - FixedPointMathLib.mulWad(range, normalized);
  }

  /// @dev Smooth-then-cap discount using dynamic s and xCap anchors
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

  function _stepsPerSecond(uint256 unitCost) private pure returns (uint256) {
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
}
