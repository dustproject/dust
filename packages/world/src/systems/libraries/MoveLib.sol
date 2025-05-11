// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy } from "../../codegen/tables/Energy.sol";
import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import {
  MAX_PLAYER_GLIDES,
  MAX_PLAYER_JUMPS,
  MOVE_ENERGY_COST,
  PLAYER_FALL_DAMAGE_THRESHOLD,
  PLAYER_FALL_ENERGY_COST
} from "../../Constants.sol";
import { EntityId } from "../../EntityId.sol";
import { ObjectType } from "../../ObjectType.sol";

import { ObjectTypes } from "../../ObjectType.sol";

import { Vec3, vec3 } from "../../Vec3.sol";
import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../../utils/EnergyUtils.sol";
import {
  getMovableEntityAt, getObjectTypeAt, safeGetObjectTypeAt, setMovableEntityAt
} from "../../utils/EntityUtils.sol";

library MoveLib {
  function moveWithoutGravity(Vec3 playerCoord, Vec3[] memory newBaseCoords) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    uint128 currentEnergy = Energy._getEnergy(player);

    uint128 totalCost;
    Vec3 currentCoord = playerCoord;
    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      Vec3 nextBaseCoord = newBaseCoords[i];
      _requireValidMove(currentCoord, nextBaseCoord);
      currentCoord = nextBaseCoord;
      totalCost += MOVE_ENERGY_COST;

      if (totalCost >= currentEnergy) {
        totalCost = currentEnergy;
        break;
      }
    }

    _setPlayerPosition(playerEntityIds, currentCoord);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, currentCoord, totalCost);
      addEnergyToLocalPool(currentCoord, totalCost);
    }
  }

  function move(Vec3 playerCoord, Vec3[] memory newBaseCoords) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    uint128 currentEnergy = Energy._getEnergy(player);

    (Vec3 finalCoord, uint128 totalCost) = _computePathResult(playerCoord, newBaseCoords, currentEnergy);

    if (totalCost > currentEnergy) {
      totalCost = currentEnergy;
    }

    _setPlayerPosition(playerEntityIds, finalCoord);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, finalCoord, totalCost);
      addEnergyToLocalPool(finalCoord, totalCost);
    }

    _handleAbove(finalCoord);
  }

  function runGravity(Vec3 playerCoord) public {
    if (!_gravityApplies(playerCoord)) {
      return;
    }

    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    (Vec3 finalCoord, uint128 totalCost) = _computeGravityResult(playerCoord, 0);

    _setPlayerPosition(playerEntityIds, finalCoord);

    uint128 currentEnergy = updatePlayerEnergy(player).energy;

    if (totalCost > currentEnergy) {
      totalCost = currentEnergy;
    }

    if (totalCost > 0) {
      decreasePlayerEnergy(player, finalCoord, totalCost);
      addEnergyToLocalPool(finalCoord, totalCost);
    }

    _handleAbove(finalCoord);
  }

  function _requireValidMove(Vec3 baseOldCoord, Vec3 baseNewCoord) internal view {
    require(baseOldCoord.inSurroundingCube(baseNewCoord, 1), "New coord is too far from old coord");

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(baseNewCoord);

    for (uint256 i = 0; i < newPlayerCoords.length; i++) {
      Vec3 newCoord = newPlayerCoords[i];

      ObjectType newObjectType = safeGetObjectTypeAt(newCoord);
      require(newObjectType.isPassThrough(), "Cannot move through a non-passable block");

      require(!getMovableEntityAt(newCoord).exists(), "Cannot move through a player");
    }
  }

  function _gravityApplies(Vec3 playerCoord) internal view returns (bool) {
    Vec3 belowCoord = playerCoord - vec3(0, 1, 0);
    bool onSolidBlock = !safeGetObjectTypeAt(belowCoord).isPassThrough() || getMovableEntityAt(belowCoord).exists();
    return !onSolidBlock && getObjectTypeAt(playerCoord) != ObjectTypes.Water;
  }

  function _computeGravityResult(Vec3 coord, uint16 initialFallHeight) private view returns (Vec3, uint128) {
    uint16 currentFallHeight = initialFallHeight;
    Vec3 current = coord;
    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      currentFallHeight++;
    }

    // If currently on water, don't apply fall damage
    if (getObjectTypeAt(current) == ObjectTypes.Water) {
      return (current, 0);
    }

    uint128 cost = 0;
    if (currentFallHeight >= PLAYER_FALL_DAMAGE_THRESHOLD) {
      cost = PLAYER_FALL_ENERGY_COST * (currentFallHeight - PLAYER_FALL_DAMAGE_THRESHOLD + 1);
    }

    return (current, cost);
  }

  /**
   * Calculate total energy cost and final path coordinate
   */
  function _computePathResult(Vec3 currentBaseCoord, Vec3[] memory newBaseCoords, uint128 currentEnergy)
    internal
    view
    returns (Vec3, uint128)
  {
    uint128 totalCost = 0;
    uint16 numJumps = 0;
    uint16 numGlides = 0;
    uint16 currentFallHeight = 0;

    bool gravityApplies = false;
    uint128 fallDamage = 0;

    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      Vec3 nextBaseCoord = newBaseCoords[i];
      _requireValidMove(currentBaseCoord, nextBaseCoord);

      gravityApplies = _gravityApplies(nextBaseCoord);
      if (gravityApplies) {
        if (nextBaseCoord.y() > currentBaseCoord.y()) {
          numJumps++;
          require(numJumps <= MAX_PLAYER_JUMPS, "Cannot jump more than 3 blocks");
          totalCost += MOVE_ENERGY_COST;
        } else if (nextBaseCoord.y() < currentBaseCoord.y()) {
          numGlides = 0;
          currentFallHeight++;

          if (currentFallHeight >= PLAYER_FALL_DAMAGE_THRESHOLD) {
            fallDamage += PLAYER_FALL_ENERGY_COST;
          }
        } else {
          numGlides++;
          require(numGlides <= MAX_PLAYER_GLIDES, "Cannot glide more than 10 blocks");
          totalCost += MOVE_ENERGY_COST;
        }
      } else {
        // Only apply fall damage if the player didn't land on water
        if (getObjectTypeAt(currentBaseCoord) != ObjectTypes.Water) {
          totalCost += fallDamage;
        }
        totalCost += MOVE_ENERGY_COST;
        fallDamage = 0;
        numJumps = 0;
        numGlides = 0;
        currentFallHeight = 0;
      }

      currentBaseCoord = nextBaseCoord;

      if (totalCost >= currentEnergy) {
        break;
      }
    }

    if (gravityApplies) {
      (currentBaseCoord, fallDamage) = _computeGravityResult(currentBaseCoord, currentFallHeight);
      totalCost += fallDamage;
    }

    return (currentBaseCoord, totalCost);
  }

  function _removePlayerPosition(Vec3 playerCoord) private returns (EntityId[] memory) {
    Vec3[] memory playerCoords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    EntityId[] memory playerEntityIds = _getEntityIds(playerCoords);
    for (uint256 i = 0; i < playerCoords.length; i++) {
      ReverseMovablePosition._deleteRecord(playerCoords[i]);
    }
    return playerEntityIds;
  }

  function _setPlayerPosition(EntityId[] memory playerEntityIds, Vec3 playerCoord) private {
    Vec3[] memory playerCoords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    for (uint256 i = 0; i < playerCoords.length; i++) {
      setMovableEntityAt(playerCoords[i], playerEntityIds[i]);
    }
  }

  function _getEntityIds(Vec3[] memory playerCoords) private view returns (EntityId[] memory) {
    EntityId[] memory entityIds = new EntityId[](playerCoords.length);
    for (uint256 i = 0; i < playerCoords.length; i++) {
      entityIds[i] = getMovableEntityAt(playerCoords[i]);
    }
    return entityIds;
  }

  function _handleAbove(Vec3 playerCoord) private {
    Vec3 aboveCoord = playerCoord + vec3(0, 2, 0);
    EntityId above = getMovableEntityAt(aboveCoord);
    // Note: currently it is not possible for the above player to not be the base entity,
    // but if we add other types of movable entities we should check that it is a base entity
    if (above.exists()) {
      runGravity(aboveCoord);
    }
  }
}
