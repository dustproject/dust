// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ActivityType } from "../codegen/common.sol";
import { Death } from "../codegen/tables/Death.sol";
import { PlayerActivity } from "../codegen/tables/PlayerActivity.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";

library PlayerActivityUtils {
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
    _updateActivity(player, activityType, uint256(massReduced));
  }

  // Combat tracking
  function trackHitPlayer(EntityId player, uint128 damage) internal {
    _updateActivity(player, ActivityType.HitPlayerDamage, uint256(damage));
  }

  function trackHitMachine(EntityId player, uint128 damage) internal {
    _updateActivity(player, ActivityType.HitMachineDamage, uint256(damage));
  }

  // Movement tracking
  function trackMoves(EntityId player, uint128 walkSteps, uint128 swimSteps) internal {
    if (walkSteps > 0) {
      _updateActivity(player, ActivityType.MoveWalkSteps, uint256(walkSteps));
    }
    if (swimSteps > 0) {
      _updateActivity(player, ActivityType.MoveSwimSteps, uint256(swimSteps));
    }
  }

  function trackFallEnergy(EntityId player, uint128 fallEnergy) internal {
    _updateActivity(player, ActivityType.MoveFallEnergy, uint256(fallEnergy));
  }

  // Building tracking
  function trackBuildEnergy(EntityId player, uint128 energySpent) internal {
    _updateActivity(player, ActivityType.BuildEnergy, uint256(energySpent));
  }

  function trackBuildMass(EntityId player, uint128 massBuilt) internal {
    _updateActivity(player, ActivityType.BuildMass, uint256(massBuilt));
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
    } else {
      // Hand crafting (no station required)
      activityType = ActivityType.CraftHandMass;
    }

    _updateActivity(player, activityType, uint256(massEnergy));
  }

  // Internal helper
  function _updateActivity(EntityId player, ActivityType activityType, uint256 additionalValue) private {
    if (additionalValue == 0) {
      return; // No update needed
    }

    uint256 deathCount = Death._getDeaths(player);
    uint256 currentValue = PlayerActivity._getValue(player, deathCount, activityType);
    uint256 newValue = currentValue + additionalValue;

    PlayerActivity._setValue(player, deathCount, activityType, newValue);
  }

  // Utility function to get current activity value
  function getActivityValue(EntityId player, ActivityType activityType) internal view returns (uint256) {
    uint256 deathCount = Death._getDeaths(player);
    return PlayerActivity._getValue(player, deathCount, activityType);
  }
}
