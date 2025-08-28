// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { Energy } from "../../codegen/tables/Energy.sol";

import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import "../../Constants.sol" as Constants;
import { EntityId } from "../../types/EntityId.sol";
import { ObjectType } from "../../types/ObjectType.sol";

import { ObjectTypes } from "../../types/ObjectType.sol";

import { Vec3, vec3 } from "../../types/Vec3.sol";
import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../../utils/EnergyUtils.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";
import { PlayerProgressUtils as PlayerTrackingUtils } from "../../utils/PlayerProgressUtils.sol";
import { PlayerSkillUtils } from "../../utils/PlayerSkillUtils.sol";
import { RateLimitUtils } from "../../utils/RateLimitUtils.sol";

error NonPassableBlock(int32 x, int32 y, int32 z, ObjectType objectType);

struct MoveCounts {
  uint128 walkSteps;
  uint128 swimSteps;
  uint128 lavaSteps;
  uint128 fallEnergy;
  uint16 fallHeight;
}

struct MoveCosts {
  uint128 walkCost;
  uint128 swimCost;
  uint128 lavaCost;
  uint128 fallPerBlockCost;
}

library MoveLib {
  enum MoveStepType {
    Walk,
    Swim,
    Lava
  }

  function jump(Vec3 playerCoord) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    // NOTE: we currently don't count moves here because this is only used for jump builds

    uint128 currentEnergy = Energy._getEnergy(player);

    Vec3 above = playerCoord + vec3(0, 1, 0);
    _requireValidMove(playerCoord, above);
    MoveCosts memory costs = _initMoveCosts(player);
    uint128 totalCost = _getMoveCost(costs, above);

    if (totalCost >= currentEnergy) {
      totalCost = currentEnergy;
    }

    _setPlayerPosition(playerEntityIds, above);

    _updatePlayerDrainRate(player, above);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, totalCost);
      addEnergyToLocalPool(above, totalCost);
    }
  }

  function move(Vec3 playerCoord, Vec3[] memory newBaseCoords) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    uint128 currentEnergy = Energy._getEnergy(player);

    (Vec3 finalCoord, uint128 totalCost, MoveCounts memory counts) =
      _computePathResult(player, playerCoord, newBaseCoords, currentEnergy);

    // Update rate limits based on movement counts
    RateLimitUtils.move(player, counts.walkSteps, counts.swimSteps);
    // Track moves
    PlayerTrackingUtils.trackMoves(player, counts.walkSteps, counts.swimSteps);
    if (counts.fallEnergy > 0) {
      PlayerTrackingUtils.trackFallEnergy(player, counts.fallEnergy);
    }

    _setPlayerPosition(playerEntityIds, finalCoord);

    _updatePlayerDrainRate(player, finalCoord);

    if (totalCost > currentEnergy) {
      totalCost = currentEnergy;
    }

    if (totalCost > 0) {
      decreasePlayerEnergy(player, totalCost);
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

    (Vec3 finalCoord, uint128 totalCost) = _computeGravityResult(_initMoveCosts(player), playerCoord, 0);

    _setPlayerPosition(playerEntityIds, finalCoord);

    uint128 currentEnergy = updatePlayerEnergy(player).energy;

    _updatePlayerDrainRate(player, finalCoord);

    if (totalCost > currentEnergy) {
      totalCost = currentEnergy;
    }

    if (totalCost > 0) {
      decreasePlayerEnergy(player, totalCost);
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
    return EntityUtils.safeGetObjectTypeAt(belowCoord).isPassThrough()
      && !EntityUtils.getMovableEntityAt(belowCoord)._exists() && !_isFluid(playerCoord);
  }

  function _computeGravityResult(MoveCosts memory costs, Vec3 coord, uint16 initialFallHeight)
    private
    view
    returns (Vec3, uint128)
  {
    uint16 currentFallHeight = initialFallHeight;
    Vec3 current = coord;

    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      unchecked {
        ++currentFallHeight;
      }
    }

    // Move step on landing (discounted)
    uint128 moveCost = _getMoveCost(costs, current);

    // If currently on water or under the safe fall threshold, don't apply fall damage
    if (currentFallHeight <= Constants.PLAYER_SAFE_FALL_DISTANCE || _isFluid(current)) {
      return (current, moveCost);
    }

    return (current, moveCost + costs.fallPerBlockCost * (currentFallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE));
  }

  /**
   * Calculate total energy cost, final path coordinate, and movement counts
   * Returns: (finalCoord, cost, walkSteps, swimSteps)
   */
  function _computePathResult(EntityId player, Vec3 start, Vec3[] memory newBaseCoords, uint128 currentEnergy)
    internal
    view
    returns (Vec3 current, uint128 cost, MoveCounts memory counts)
  {
    MoveCosts memory costs = _initMoveCosts(player);
    uint16 jumps = 0;
    uint16 glides = 0;

    current = start;
    bool currentHasGravity = _gravityApplies(current);

    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      if (cost >= currentEnergy) break;

      Vec3 next = newBaseCoords[i];
      int32 dy = next.y() - current.y();
      _requireValidMove(current, next);

      bool nextHasGravity = _gravityApplies(next);

      // Only count as fall when gravity doesn't apply in current coord
      if (dy < 0 && currentHasGravity) {
        ++counts.fallHeight;
        glides = 0;
        if (!nextHasGravity) {
          MoveStepType stepType = _getMoveType(next);
          if (stepType == MoveStepType.Swim) {
            cost += costs.swimCost;
            counts.swimSteps++;
          } else if (stepType == MoveStepType.Lava) {
            cost += costs.lavaCost;
            counts.walkSteps++;
            counts.lavaSteps++;
          } else {
            cost += costs.walkCost;
            counts.walkSteps++;
          }
        }
      } else {
        if (dy > 0) {
          ++jumps;
          require(jumps <= Constants.MAX_PLAYER_JUMPS, "Cannot jump more than 3 blocks");
        } else if (nextHasGravity) {
          ++glides;
          require(glides <= Constants.MAX_PLAYER_GLIDES, "Cannot glide more than 10 blocks");
        }
        MoveStepType stepType = _getMoveType(next);
        if (stepType == MoveStepType.Swim) {
          cost += costs.swimCost;
          counts.swimSteps++;
        } else if (stepType == MoveStepType.Lava) {
          cost += costs.lavaCost;
          counts.walkSteps++;
          counts.lavaSteps++;
        } else {
          cost += costs.walkCost;
          counts.walkSteps++;
        }
      }

      if (!nextHasGravity) {
        if (counts.fallHeight > Constants.PLAYER_SAFE_FALL_DISTANCE && !_isFluid(next)) {
          uint128 fallEnergy = costs.fallPerBlockCost * (counts.fallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE);
          cost += fallEnergy;
          counts.fallEnergy += fallEnergy;
        }
        counts.fallHeight = 0;
        jumps = 0;
        glides = 0;
      }

      currentHasGravity = nextHasGravity;
      current = next;
    }

    if (currentHasGravity) {
      uint128 fallDamage;
      (current, fallDamage) = _computeGravityResult(costs, current, counts.fallHeight);
      cost += fallDamage;
      if (fallDamage > 0) counts.fallEnergy += fallDamage;
    }
  }

  function _removePlayerPosition(Vec3 playerCoord) internal returns (EntityId[] memory) {
    Vec3[] memory playerCoords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    EntityId[] memory playerEntityIds = new EntityId[](playerCoords.length);

    for (uint256 i; i < playerCoords.length; ++i) {
      playerEntityIds[i] = EntityUtils.getMovableEntityAt(playerCoords[i]);
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
      drainRate = Constants.PLAYER_LAVA_ENERGY_DRAIN_RATE;
    } else if (_isFluid(finalCoord + vec3(0, 1, 0))) {
      drainRate = Constants.PLAYER_SWIM_ENERGY_DRAIN_RATE;
    } else {
      drainRate = Constants.PLAYER_ENERGY_DRAIN_RATE;
    }

    Energy._setDrainRate(player, drainRate);
  }

  function _handleAbove(EntityId player, Vec3 playerCoord) private {
    Vec3 aboveCoord = playerCoord + vec3(0, 2, 0);
    EntityId above = EntityUtils.getMovableEntityAt(aboveCoord);

    if (!above._exists() || above._baseEntityId() == player) {
      return;
    }

    runGravity(aboveCoord);
  }

  function _isFluid(Vec3 coord) internal view returns (bool) {
    return EntityUtils.getFluidLevelAt(coord) > 0;
  }

  function _getMoveType(Vec3 coord) internal view returns (MoveStepType) {
    Vec3 belowCoord = coord - vec3(0, 1, 0);
    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    if (belowType == ObjectTypes.Lava) return MoveStepType.Lava;
    if (belowType.isPassThrough() && _isFluid(belowCoord)) return MoveStepType.Swim;
    return MoveStepType.Walk;
  }

  function _initMoveCosts(EntityId player) internal view returns (MoveCosts memory c) {
    (uint256 walkMul, uint256 swimMul, uint256 lavaMul, uint256 fallMul) =
      PlayerSkillUtils.getMoveEnergyMultipliersWad(player);
    unchecked {
      c.walkCost = uint128(FixedPointMathLib.mulWad(Constants.MOVE_ENERGY_COST, walkMul));
      c.swimCost = uint128(FixedPointMathLib.mulWad(Constants.WATER_MOVE_ENERGY_COST, swimMul));
      c.lavaCost = uint128(FixedPointMathLib.mulWad(Constants.LAVA_MOVE_ENERGY_COST, lavaMul));
      c.fallPerBlockCost = uint128(FixedPointMathLib.mulWad(Constants.PLAYER_FALL_ENERGY_COST, fallMul));
    }
  }

  function _getMoveCost(MoveCosts memory costs, Vec3 coord) internal view returns (uint128) {
    MoveStepType stepType = _getMoveType(coord);
    if (stepType == MoveStepType.Walk) {
      return costs.walkCost;
    } else if (stepType == MoveStepType.Swim) {
      return costs.swimCost;
    } else {
      return costs.lavaCost;
    }
  }
}
