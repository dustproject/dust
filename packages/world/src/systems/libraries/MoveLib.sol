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
import { addEnergyToLocalPool, decreasePlayerEnergy, getEnergyData } from "../../utils/EnergyUtils.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";
import { PlayerProgressUtils as PlayerTrackingUtils } from "../../utils/PlayerProgressUtils.sol";
import { PlayerSkillUtils } from "../../utils/PlayerSkillUtils.sol";
import { RateLimitUtils } from "../../utils/RateLimitUtils.sol";

struct PathResult {
  Vec3 finalCoord;
  uint128 totalCost;
  uint128 walkSteps;
  uint128 swimSteps;
  uint128 lavaSteps;
  uint128 fallEnergy;
  uint16 fallHeight;
}

struct MoveContext {
  EntityId player;
  uint128 initialEnergy;
  // Lazy cached costs
  uint128 _walkCost;
  uint128 _swimCost;
  // uint128 _lavaCost; // currently same as walk (not cached)
  uint128 _fallCost;
}

enum MoveStepType {
  Walk,
  Swim,
  Lava
}

struct StepContext {
  MoveStepType stepType;
  bool gravityApplies;
  bool isFluid;
}

library MoveLib {
  function jump(Vec3 playerCoord) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    // NOTE: we currently don't count moves here because this is only used for jump builds

    Vec3 above = playerCoord + vec3(0, 1, 0);
    _requireValidMove(playerCoord, above);
    MoveContext memory ctx = _moveContext(player);
    uint128 totalCost = _getMoveCost(ctx, above);

    if (totalCost >= ctx.initialEnergy) {
      totalCost = ctx.initialEnergy;
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

    MoveContext memory ctx = _moveContext(player);

    PathResult memory result = _computePathResult(ctx, playerCoord, newBaseCoords);

    // Update rate limits based on movement counts
    RateLimitUtils.move(player, result.walkSteps, result.swimSteps);

    // Track moves
    PlayerTrackingUtils.trackMoves(player, result.walkSteps, result.swimSteps);
    if (result.fallEnergy > 0) {
      PlayerTrackingUtils.trackFallEnergy(player, result.fallEnergy);
    }

    _setPlayerPosition(playerEntityIds, result.finalCoord);

    _updatePlayerDrainRate(player, result.finalCoord);

    if (result.totalCost > ctx.initialEnergy) {
      result.totalCost = ctx.initialEnergy;
    }

    if (result.totalCost > 0) {
      decreasePlayerEnergy(player, result.totalCost);
      addEnergyToLocalPool(result.finalCoord, result.totalCost);
    }

    _handleAbove(player, playerCoord);
  }

  function runGravity(Vec3 playerCoord) public {
    if (!_gravityApplies(playerCoord)) {
      return;
    }

    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    MoveContext memory ctx = _moveContext(player);

    PathResult memory result = _computeGravityPath(ctx, playerCoord);

    _setPlayerPosition(playerEntityIds, result.finalCoord);

    _updatePlayerDrainRate(player, result.finalCoord);

    if (result.totalCost > ctx.initialEnergy) {
      result.totalCost = ctx.initialEnergy;
    }

    if (result.totalCost > 0) {
      decreasePlayerEnergy(player, result.totalCost);
      addEnergyToLocalPool(result.finalCoord, result.totalCost);
    }

    _handleAbove(player, playerCoord);
  }

  function _requireValidMove(Vec3 baseOldCoord, Vec3 baseNewCoord) internal view {
    require(baseOldCoord.inSurroundingCube(baseNewCoord, 1), "New coord is too far from old coord");

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(baseNewCoord);

    for (uint256 i = 0; i < newPlayerCoords.length; i++) {
      Vec3 newCoord = newPlayerCoords[i];

      ObjectType newObjectType = EntityUtils.safeGetObjectTypeAt(newCoord);
      require(newObjectType.isPassThrough(), "Cannot move through solid block");
      require(!EntityUtils.getMovableEntityAt(newCoord)._exists(), "Cannot move through a player");
    }
  }

  function _gravityApplies(Vec3 playerCoord) internal view returns (bool) {
    Vec3 belowCoord = playerCoord - vec3(0, 1, 0);
    return EntityUtils.safeGetObjectTypeAt(belowCoord).isPassThrough()
      && !EntityUtils.getMovableEntityAt(belowCoord)._exists() && !_isFluid(playerCoord);
  }

  function _computeGravityResult(MoveContext memory ctx, Vec3 start, uint16 initialFallHeight)
    private
    view
    returns (Vec3, uint128)
  {
    uint16 currentFallHeight = initialFallHeight;
    Vec3 current = start;

    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      unchecked {
        ++currentFallHeight;
      }
    }

    // Move step on landing (discounted)
    uint128 moveCost = _getMoveCost(ctx, current);

    // If currently on water or under the safe fall threshold, don't apply fall damage
    if (currentFallHeight <= Constants.PLAYER_SAFE_FALL_DISTANCE || _isFluid(current)) {
      return (current, moveCost);
    }

    return (current, moveCost + ctx.getFallCost() * (currentFallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE));
  }

  /**
   * Calculate total energy cost, final path coordinate, and movement counts
   * Returns: (finalCoord, cost, walkSteps, swimSteps)
   */
  function _computePathResult(MoveContext memory ctx, Vec3 start, Vec3[] memory newBaseCoords)
    internal
    view
    returns (PathResult memory res)
  {
    uint16 jumps = 0;
    uint16 glides = 0;

    Vec3 current = start;
    bool currentHasGravity = _gravityApplies(current);

    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      if (res.totalCost >= ctx.initialEnergy) break;

      Vec3 next = newBaseCoords[i];
      int32 dy = next.y() - current.y();
      _requireValidMove(current, next);

      StepContext memory stepCtx = _stepContext(next);
      bool nextHasGravity = stepCtx.gravityApplies;

      // Only count as fall when gravity doesn't apply in current coord
      if (dy < 0 && currentHasGravity) {
        ++res.fallHeight;
        glides = 0;
        if (!nextHasGravity) {
          MoveStepType stepType = stepCtx.stepType;
          if (stepType == MoveStepType.Swim) {
            res.totalCost += ctx.getSwimCost();
            res.swimSteps++;
          } else if (stepType == MoveStepType.Lava) {
            res.totalCost += ctx.getLavaCost();
            res.walkSteps++;
            res.lavaSteps++;
          } else {
            res.totalCost += ctx.getWalkCost();
            res.walkSteps++;
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
        MoveStepType stepType = stepCtx.stepType;
        if (stepType == MoveStepType.Swim) {
          res.totalCost += ctx.getSwimCost();
          res.swimSteps++;
        } else if (stepType == MoveStepType.Lava) {
          res.totalCost += ctx.getLavaCost();
          res.walkSteps++;
          res.lavaSteps++;
        } else {
          res.totalCost += ctx.getWalkCost();
          res.walkSteps++;
        }
      }

      if (!nextHasGravity) {
        if (res.fallHeight > Constants.PLAYER_SAFE_FALL_DISTANCE && !stepCtx.isFluid) {
          uint128 fallEnergy = ctx.getFallCost() * (res.fallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE);
          res.totalCost += fallEnergy;
          res.fallEnergy += fallEnergy;
        }
        res.fallHeight = 0;
        jumps = 0;
        glides = 0;
      }

      currentHasGravity = nextHasGravity;
      current = next;
    }

    if (currentHasGravity) {
      uint128 fallDamage;
      (current, fallDamage) = _computeGravityResult(ctx, current, res.fallHeight);
      res.totalCost += fallDamage;
      res.fallEnergy += fallDamage;
    }

    res.finalCoord = current;
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

  function _moveContext(EntityId player) internal view returns (MoveContext memory c) {
    c.player = player;
    c.initialEnergy = getEnergyData(player).energy;
  }

  function _getMoveCost(MoveContext memory ctx, Vec3 coord) internal view returns (uint128) {
    MoveStepType stepType = _getMoveType(coord);
    if (stepType == MoveStepType.Walk) {
      return ctx.getWalkCost();
    } else if (stepType == MoveStepType.Swim) {
      return ctx.getSwimCost();
    } else {
      return ctx.getLavaCost();
    }
  }

  function _stepContext(Vec3 next) internal view returns (StepContext memory ctx) {
    Vec3 belowCoord = next - vec3(0, 1, 0);
    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    bool belowPass = belowType.isPassThrough();
    ctx.isFluid = _isFluid(next);

    if (belowType == ObjectTypes.Lava) ctx.stepType = MoveStepType.Lava;
    else if (belowPass && _isFluid(belowCoord)) ctx.stepType = MoveStepType.Swim;
    else ctx.stepType = MoveStepType.Walk;

    ctx.gravityApplies = belowPass && !ctx.isFluid && !EntityUtils.getMovableEntityAt(belowCoord)._exists();
  }

  function _computeGravityPath(MoveContext memory ctx, Vec3 start) internal view returns (PathResult memory res) {
    if (!_gravityApplies(start)) {
      res.finalCoord = start;
      res.totalCost = 0;
      return res;
    }
    uint128 fallDamage;
    (res.finalCoord, fallDamage) = _computeGravityResult(ctx, start, 0);
    res.totalCost = fallDamage;
  }
}

library MoveContextLib {
  function getWalkCost(MoveContext memory ctx) internal view returns (uint128) {
    if (ctx._walkCost == 0) {
      uint256 walkMul = PlayerSkillUtils.getWalkEnergyMultiplierWad(ctx.player);
      ctx._walkCost = uint128(FixedPointMathLib.mulWad(Constants.MOVE_ENERGY_COST, walkMul));
    }
    return ctx._walkCost;
  }

  function getSwimCost(MoveContext memory ctx) internal view returns (uint128) {
    if (ctx._swimCost == 0) {
      uint256 swimMul = PlayerSkillUtils.getSwimEnergyMultiplierWad(ctx.player);
      ctx._swimCost = uint128(FixedPointMathLib.mulWad(Constants.WATER_MOVE_ENERGY_COST, swimMul));
    }
    return ctx._swimCost;
  }

  function getLavaCost(MoveContext memory) internal pure returns (uint128) {
    return Constants.LAVA_MOVE_ENERGY_COST;
  }

  function getFallCost(MoveContext memory ctx) internal view returns (uint128) {
    if (ctx._fallCost == 0) {
      uint256 fallMul = PlayerSkillUtils.getFallEnergyMultiplierWad(ctx.player);
      ctx._fallCost = uint128(FixedPointMathLib.mulWad(Constants.PLAYER_FALL_ENERGY_COST, fallMul));
    }
    return ctx._fallCost;
  }
}

using MoveContextLib for MoveContext;
