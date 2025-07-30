// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Death } from "../codegen/tables/Death.sol";
import { PlayerActivity } from "../codegen/tables/PlayerActivity.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

library PlayerActivityUtils {
  // Mining tracking - with tool specialization
  function updateMinedMass(EntityId player, uint128 massReduced, ObjectType toolType, ObjectType minedType) internal {
    bytes32 key;
    if (toolType.isAxe() && minedType.hasAxeMultiplier()) {
      key = keccak256(abi.encodePacked("mine.axe"));
    } else if (toolType.isPick() && minedType.hasPickMultiplier()) {
      key = keccak256(abi.encodePacked("mine.pick"));
    } else {
      return;
    }
    _updateActivity(player, key, uint256(massReduced));
  }

  // Combat tracking - player
  function updateDealtDamageToPlayer(EntityId player, uint128 damage) internal {
    _updateActivity(player, keccak256(abi.encodePacked("combat.player")), uint256(damage));
  }

  // Combat tracking - machine
  function updateDealtDamageToMachine(EntityId player, uint128 damage) internal {
    _updateActivity(player, keccak256(abi.encodePacked("combat.machine")), uint256(damage));
  }

  // Movement tracking - walk
  function updateWalkEnergy(EntityId player, uint128 energySpent) internal {
    _updateActivity(player, keccak256(abi.encodePacked("move.walk")), uint256(energySpent));
  }

  // Movement tracking - swim
  function updateSwimEnergy(EntityId player, uint128 energySpent) internal {
    _updateActivity(player, keccak256(abi.encodePacked("move.swim")), uint256(energySpent));
  }

  // Building tracking - energy
  function updateBuildEnergy(EntityId player, uint128 energySpent) internal {
    _updateActivity(player, keccak256(abi.encodePacked("build.energy")), uint256(energySpent));
  }

  // Building tracking - mass with object type
  function updateBuildMass(EntityId player, uint128 massBuilt, uint16 objectType) internal {
    bytes32 key = keccak256(abi.encodePacked("build.mass.", objectType));
    _updateActivity(player, key, uint256(massBuilt));
  }

  // Internal helper
  function _updateActivity(EntityId player, bytes32 activityKey, uint256 additionalValue) private {
    if (additionalValue == 0) {
      return; // No update needed
    }

    uint256 deathCount = Death._getDeaths(player);
    uint256 currentValue = PlayerActivity._getValue(player, deathCount, activityKey);
    uint256 newValue = currentValue + additionalValue;

    PlayerActivity._setValue(player, deathCount, activityKey, newValue);
  }

  // Utility function to get current activity value
  function getActivityValue(EntityId player, bytes32 activityKey) internal view returns (uint256) {
    uint256 deathCount = Death._getDeaths(player);
    return PlayerActivity._getValue(player, deathCount, activityKey);
  }
}
