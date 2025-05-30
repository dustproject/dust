// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy } from "../../codegen/tables/Energy.sol";
import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import {
  LAVA_MOVE_ENERGY_COST,
  MAX_PLAYER_GLIDES,
  MAX_PLAYER_JUMPS,
  MOVE_ENERGY_COST,
  PLAYER_ENERGY_DRAIN_RATE,
  PLAYER_FALL_ENERGY_COST,
  PLAYER_LAVA_ENERGY_DRAIN_RATE,
  PLAYER_SAFE_FALL_DISTANCE,
  PLAYER_SWIM_ENERGY_DRAIN_RATE
} from "../../Constants.sol";
import { EntityId } from "../../EntityId.sol";
import { ObjectType } from "../../ObjectType.sol";

import { ObjectTypes } from "../../ObjectType.sol";

import { Vec3, vec3 } from "../../Vec3.sol";
import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../../utils/EnergyUtils.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";

error NonPassableBlock(int32 x, int32 y, int32 z, ObjectType objectType);

library MoveLib {
  function moveWithoutGravity(Vec3 playerCoord, Vec3[] memory newBaseCoords) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    uint128 currentEnergy = Energy._getEnergy(player);

    uint128 totalCost;
    Vec3 current = playerCoord;
    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      Vec3 next = newBaseCoords[i];
      _requireValidMove(current, next);
      totalCost += _getMoveCost(next);
      current = next;

      if (totalCost >= currentEnergy) {
        totalCost = currentEnergy;
        break;
      }
    }

    _setPlayerPosition(playerEntityIds, current);

    _updatePlayerDrainRate(player, current);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, current, totalCost);
      addEnergyToLocalPool(current, totalCost);
    }

    _handleAbove(player, playerCoord);
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

    _updatePlayerDrainRate(player, finalCoord);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, finalCoord, totalCost);
      addEnergyToLocalPool(finalCoord, totalCost);
    }

    _handleAbove(player, playerCoord);
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

    _updatePlayerDrainRate(player, finalCoord);

    if (totalCost > currentEnergy) {
      totalCost = currentEnergy;
    }

    if (totalCost > 0) {
      decreasePlayerEnergy(player, finalCoord, totalCost);
      addEnergyToLocalPool(finalCoord, totalCost);
    }

    _handleAbove(player, playerCoord);
  }

  function _requireValidMove(Vec3 baseOldCoord, Vec3 baseNewCoord) internal view {
    require(baseOldCoord.inSurroundingCube(baseNewCoord, 1), "New coord is too far from old coord");

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(baseNewCoord);

    for (uint256 i = 0; i < newPlayerCoords.length; i++) {
      Vec3 newCoord = newPlayerCoords[i];

      ObjectType newObjectType = EntityUtils.safeGetObjectTypeAt(newCoord);
      if (!newObjectType.isPassThrough()) {
        revert NonPassableBlock(newCoord.x(), newCoord.y(), newCoord.z(), newObjectType);
      }
      require(!EntityUtils.getMovableEntityAt(newCoord)._exists(), "Cannot move through a player");
    }
  }

  function _gravityApplies(Vec3 playerCoord) internal view returns (bool) {
    Vec3 belowCoord = playerCoord - vec3(0, 1, 0);
    bool onSolidBlock = !EntityUtils.safeGetObjectTypeAt(belowCoord).isPassThrough()
      || EntityUtils.getMovableEntityAt(belowCoord)._exists();
    return !onSolidBlock && !_isFluid(playerCoord);
  }

  function _computeGravityResult(Vec3 coord, uint16 initialFallHeight) private view returns (Vec3, uint128) {
    uint16 currentFallHeight = initialFallHeight;
    Vec3 current = coord;
    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      currentFallHeight++;
    }

    // If currently on water, don't apply fall damage
    if (_isFluid(current)) {
      return (current, 0);
    }

    uint128 cost = 0;
    if (currentFallHeight > PLAYER_SAFE_FALL_DISTANCE) {
      cost = PLAYER_FALL_ENERGY_COST * (currentFallHeight - PLAYER_SAFE_FALL_DISTANCE);
    }

    return (current, cost);
  }

  /**
   * Calculate total energy cost and final path coordinate
   */
  function _computePathResult(Vec3 current, Vec3[] memory newBaseCoords, uint128 currentEnergy)
    internal
    view
    returns (Vec3, uint128)
  {
    uint128 cost = 0;
    uint16 jumps = 0;
    uint16 glides = 0;
    uint16 fallHeight = 0;

    bool gravityApplies = false;
    uint128 fallDamage = 0;

    for (uint256 i = 0; i < newBaseCoords.length && cost < currentEnergy; i++) {
      Vec3 next = newBaseCoords[i];
      _requireValidMove(current, next);

      gravityApplies = _gravityApplies(next);

      int32 dy = next.y() - current.y();

      // Only count as fall when gravity doesn't apply in current coord
      if (dy < 0 && _gravityApplies(current)) {
        // For falls, cost will be computed upon landing
        ++fallHeight;
        glides = 0;
      } else {
        if (dy > 0) {
          ++jumps;
          require(jumps <= MAX_PLAYER_JUMPS, "Cannot jump more than 3 blocks");
        } else if (gravityApplies) {
          ++glides;
          require(glides <= MAX_PLAYER_GLIDES, "Cannot glide more than 10 blocks");
        }
        cost += _getMoveCost(next);
      }

      if (!gravityApplies) {
        if (fallHeight > PLAYER_SAFE_FALL_DISTANCE && !_isFluid(next)) {
          cost += PLAYER_FALL_ENERGY_COST * (fallHeight - PLAYER_SAFE_FALL_DISTANCE);
        }
        fallDamage = 0;
        fallHeight = 0;
        jumps = 0;
        glides = 0;
      }

      current = next;
    }

    // If gravity still applies after last path move, run gravity all the way down,
    // taking into account the current fallHeight
    if (gravityApplies) {
      (current, fallDamage) = _computeGravityResult(current, fallHeight);
      cost += fallDamage;
    }

    return (current, cost);
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
      EntityUtils.setMovableEntityAt(playerCoords[i], playerEntityIds[i]);
    }
  }

  function _updatePlayerDrainRate(EntityId player, Vec3 finalCoord) private {
    uint128 drainRate;
    if (EntityUtils.getObjectTypeAt(finalCoord - vec3(0, 1, 0)) == ObjectTypes.Lava) {
      drainRate = PLAYER_LAVA_ENERGY_DRAIN_RATE;
    } else if (EntityUtils.getObjectTypeAt(finalCoord + vec3(0, 1, 0)) == ObjectTypes.Water) {
      drainRate = PLAYER_SWIM_ENERGY_DRAIN_RATE;
    } else {
      drainRate = PLAYER_ENERGY_DRAIN_RATE;
    }

    Energy._setDrainRate(player, drainRate);
  }

  function _getEntityIds(Vec3[] memory playerCoords) private view returns (EntityId[] memory) {
    EntityId[] memory entityIds = new EntityId[](playerCoords.length);
    for (uint256 i = 0; i < playerCoords.length; i++) {
      entityIds[i] = EntityUtils.getMovableEntityAt(playerCoords[i]);
    }
    return entityIds;
  }

  function _handleAbove(EntityId player, Vec3 playerCoord) private {
    Vec3 aboveCoord = playerCoord + vec3(0, 2, 0);
    EntityId above = EntityUtils.getMovableEntityAt(aboveCoord);
    if (!above._exists()) {
      return;
    }

    above = above.baseEntityId();

    if (above != player) {
      runGravity(aboveCoord);
    }
  }

  function _isFluid(Vec3 coord) internal view returns (bool) {
    return EntityUtils.getFluidLevelAt(coord) > 0;
  }

  function _getMoveCost(Vec3 coord) internal view returns (uint128) {
    Vec3 belowCoord = coord - vec3(0, 1, 0);
    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    return belowType == ObjectTypes.Lava ? LAVA_MOVE_ENERGY_COST : MOVE_ENERGY_COST;
  }
}
