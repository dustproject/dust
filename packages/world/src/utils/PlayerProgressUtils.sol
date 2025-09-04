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
  /// @dev Decay `current` to now and align `current` and `accumulated` by halving for each extra death.
  function _decayAndAlign(PlayerProgressData memory data, uint256 deaths)
    private
    view
    returns (uint128 current, uint128 accumulated)
  {
    current = _decay(data.current, data.lastUpdatedAt);
    accumulated = data.accumulated;

    uint256 e = uint256(data.exponent);
    if (deaths > e) {
      uint256 diff = deaths - e;
      current = current >> diff;
      accumulated = accumulated >> diff;
    }
  }

  function getProgress(EntityId player, ActivityType activityType) internal view returns (uint128) {
    PlayerProgressData memory data = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    (uint128 current, uint128 accumulated) = _decayAndAlign(data, deaths);

    return uint128(Math.max(current, _floor(accumulated)));
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
  function trackMoveEnergy(EntityId player, uint128 moveEnergy) internal {
    _trackProgress(player, ActivityType.MoveEnergy, moveEnergy);
  }

  function trackFallEnergy(EntityId player, uint128 fallEnergy) internal {
    _trackProgress(player, ActivityType.MoveFallEnergy, fallEnergy);
  }

  // Building tracking
  function trackBuild(EntityId player, uint128 massBuilt) internal {
    // TODO: should we include build energy? if so, it will be dependent on the energy discount
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
    if (value == 0) {
      return;
    }

    PlayerProgressData memory previous = PlayerProgress._get(player, activityType);
    uint256 deaths = Death._getDeaths(player);
    (uint128 current, uint128 accumulated) = _decayAndAlign(previous, deaths);

    // Add new value and compute the new floor
    accumulated += value;

    // Ensure current reflects the floor
    current = uint128(Math.max(current + value, _floor(accumulated)));

    PlayerProgress._set(
      player,
      activityType,
      PlayerProgressData({
        accumulated: accumulated,
        current: current,
        lastUpdatedAt: uint128(block.timestamp),
        exponent: uint128(deaths)
      })
    );
  }

  function _floor(uint128 accumulated) private pure returns (uint128) {
    return accumulated / 3;
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
