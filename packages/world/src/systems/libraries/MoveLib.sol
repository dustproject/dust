// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy } from "../../codegen/tables/Energy.sol";

import "../../Constants.sol" as Constants;

import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../../utils/EnergyUtils.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";
import { Math } from "../../utils/Math.sol";
import { PlayerProgressUtils } from "../../utils/PlayerProgressUtils.sol";
import { PlayerSkillUtils } from "../../utils/PlayerSkillUtils.sol";
import { RateLimitUtils } from "../../utils/RateLimitUtils.sol";
import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import { EntityId } from "../../types/EntityId.sol";
import { ObjectType } from "../../types/ObjectType.sol";
import { ObjectTypes } from "../../types/ObjectType.sol";
import { Vec3, vec3 } from "../../types/Vec3.sol";

struct PathResult {
  Vec3 coord;
  uint128 totalCost;
  uint128 moveEnergy;
  uint128 fallEnergy;
  uint128 walkSteps;
  uint128 swimSteps;
}

struct MoveContext {
  EntityId player;
  uint128 initialEnergy;
  // Lazy cached costs
  uint256 _moveEnergyMul;
  uint128 _walkCost;
  uint128 _swimCost;
  uint128 _lavaCost;
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
  uint128 cost;
}

library MoveLib {
  function jump(Vec3 playerCoord) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    // NOTE: we currently don't count moves here because this is only used for jump builds

    Vec3 above = playerCoord + vec3(0, 1, 0);
    _requireValidMove(playerCoord, above);
    MoveContext memory ctx = _moveContext(player);

    uint128 cost = _stepContext(ctx, above).cost;

    _setPlayerPosition(playerEntityIds, above);

    _updatePlayerDrainRate(player, above);

    if (cost > 0) {
      decreasePlayerEnergy(player, cost);
      addEnergyToLocalPool(above, cost);
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
    PlayerProgressUtils.trackMoveEnergy(player, result.moveEnergy);
    PlayerProgressUtils.trackFallEnergy(player, result.fallEnergy);

    _setPlayerPosition(playerEntityIds, result.coord);

    _updatePlayerDrainRate(player, result.coord);

    if (result.totalCost > 0) {
      decreasePlayerEnergy(player, result.totalCost);
      addEnergyToLocalPool(result.coord, result.totalCost);
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

    (Vec3 finalCoord, StepContext memory stepCtx, uint128 fallDamage) = _computeGravityResult(ctx, playerCoord, 0);

    _setPlayerPosition(playerEntityIds, finalCoord);
    _updatePlayerDrainRate(player, finalCoord);

    uint128 totalCost;
    (totalCost, fallDamage) = _clampEnergyCosts(ctx, 0, stepCtx.cost, fallDamage);
    totalCost += fallDamage;

    if (totalCost > 0) {
      decreasePlayerEnergy(player, totalCost);
      addEnergyToLocalPool(finalCoord, totalCost);
    }

    _handleAbove(player, playerCoord);
  }

  function _requireValidMove(Vec3 baseOldCoord, Vec3 baseNewCoord) internal view {
    require(baseOldCoord.inSurroundingCube(baseNewCoord, 1), "New coord is too far from old coord");

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(baseNewCoord);

    for (uint256 i = 0; i < newPlayerCoords.length; ++i) {
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

  function _computeGravityResult(MoveContext memory ctx, Vec3 current, uint16 currentFallHeight)
    private
    view
    returns (Vec3, StepContext memory, uint128)
  {
    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      unchecked {
        ++currentFallHeight;
      }
    }

    // Move step on landing (discounted)
    StepContext memory stepCtx = _stepContext(ctx, current);

    return (current, stepCtx, _computeFallDamage(ctx, stepCtx, currentFallHeight));
  }

  function _clampEnergyCosts(MoveContext memory ctx, uint128 currentCost, uint128 moveCost, uint128 fallCost)
    internal
    pure
    returns (uint128, uint128)
  {
    if (ctx.initialEnergy <= currentCost) {
      return (0, 0);
    }

    uint128 remaining = ctx.initialEnergy - currentCost;

    moveCost = Math.min(remaining, moveCost);

    remaining -= moveCost;

    fallCost = Math.min(remaining, fallCost);

    return (moveCost, fallCost);
  }

  function _computeFallDamage(MoveContext memory ctx, StepContext memory stepCtx, uint16 fallHeight)
    internal
    view
    returns (uint128)
  {
    // If currently on water or under the safe fall threshold, don't apply fall damage
    if (fallHeight <= Constants.PLAYER_SAFE_FALL_DISTANCE || stepCtx.isFluid) {
      return 0;
    }
    return ctx.getFallCost() * (fallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE);
  }

  /**
   * Calculate path result from start
   */
  function _computePathResult(MoveContext memory ctx, Vec3 start, Vec3[] memory newBaseCoords)
    internal
    view
    returns (PathResult memory res)
  {
    uint16 falls = 0;
    uint16 jumps = 0;
    uint16 glides = 0;

    bool currentHasGravity = _gravityApplies(start);

    res.coord = start;

    StepContext memory stepCtx;

    for (uint256 i = 0; i < newBaseCoords.length; ++i) {
      if (res.totalCost >= ctx.initialEnergy) break;

      Vec3 next = newBaseCoords[i];
      int32 dy = next.y() - res.coord.y();
      _requireValidMove(res.coord, next);

      stepCtx = _stepContext(ctx, next);
      bool nextHasGravity = stepCtx.gravityApplies;

      // Only count as fall when gravity doesn't apply in current coord
      if (dy < 0 && currentHasGravity) {
        ++falls;
        glides = 0;

        // Landing
        if (!nextHasGravity) {
          uint128 fallDamage = _computeFallDamage(ctx, stepCtx, falls);
          _updatePathResult(ctx, stepCtx, fallDamage, res);
        }
      } else {
        if (dy > 0) {
          ++jumps;
          require(jumps <= Constants.MAX_PLAYER_JUMPS, "Cannot jump more than 3 blocks");
          require(falls == 0, "Cannot jump while falling");
        } else if (nextHasGravity) {
          ++glides;
          require(glides <= Constants.MAX_PLAYER_GLIDES, "Cannot glide more than 10 blocks");
        }

        // Apply fall damage if landing
        uint128 fallDamage = currentHasGravity && !nextHasGravity ? _computeFallDamage(ctx, stepCtx, falls) : 0;

        // Apply regular move cost too
        _updatePathResult(ctx, stepCtx, fallDamage, res);
      }

      // Reset counters
      if (!nextHasGravity) {
        falls = 0;
        jumps = 0;
        glides = 0;
      }

      currentHasGravity = nextHasGravity;
      res.coord = next;
    }

    if (currentHasGravity) {
      uint128 fallDamage;
      (res.coord, stepCtx, fallDamage) = _computeGravityResult(ctx, res.coord, falls);
      _updatePathResult(ctx, stepCtx, fallDamage, res);
    }
  }

  function _updatePathResult(
    MoveContext memory ctx,
    StepContext memory stepCtx,
    uint128 fallDamage,
    PathResult memory res
  ) internal pure {
    unchecked {
      MoveStepType stepType = stepCtx.stepType;
      if (stepType == MoveStepType.Swim) {
        ++res.swimSteps;
      } else {
        ++res.walkSteps;
      }

      (uint128 moveCost, uint128 fallCost) = _clampEnergyCosts(ctx, res.totalCost, stepCtx.cost, fallDamage);

      res.moveEnergy += moveCost;
      res.fallEnergy += fallCost;
      res.totalCost += moveCost + fallCost;
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
    for (uint256 i = 0; i < playerCoords.length; ++i) {
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

  function _moveContext(EntityId player) internal returns (MoveContext memory c) {
    c.player = player;
    c.initialEnergy = updatePlayerEnergy(player).energy;
    c._moveEnergyMul = PlayerSkillUtils.getMoveEnergyMultiplierWad(c.player);
  }

  function _stepContext(MoveContext memory ctx, Vec3 next) internal view returns (StepContext memory stepCtx) {
    Vec3 belowCoord = next - vec3(0, 1, 0);
    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    bool belowPass = belowType.isPassThrough();

    if (belowType == ObjectTypes.Lava) {
      stepCtx.stepType = MoveStepType.Lava;
      stepCtx.cost = ctx.getLavaCost();
    } else if (belowPass && _isFluid(belowCoord)) {
      stepCtx.stepType = MoveStepType.Swim;
      stepCtx.cost = ctx.getSwimCost();
    } else {
      stepCtx.stepType = MoveStepType.Walk;
      stepCtx.cost = ctx.getWalkCost();
    }

    stepCtx.isFluid = _isFluid(next);
    stepCtx.gravityApplies = belowPass && !stepCtx.isFluid && !EntityUtils.getMovableEntityAt(belowCoord)._exists();
  }
}

library MoveContextLib {
  function getWalkCost(MoveContext memory ctx) internal pure returns (uint128) {
    if (ctx._walkCost == 0) {
      ctx._walkCost = _getMoveCost(ctx, Constants.MOVE_ENERGY_COST);
    }
    return ctx._walkCost;
  }

  function getSwimCost(MoveContext memory ctx) internal pure returns (uint128) {
    if (ctx._swimCost == 0) {
      ctx._swimCost = _getMoveCost(ctx, Constants.WATER_MOVE_ENERGY_COST);
    }
    return ctx._swimCost;
  }

  function getLavaCost(MoveContext memory ctx) internal pure returns (uint128) {
    if (ctx._lavaCost == 0) {
      ctx._lavaCost = _getMoveCost(ctx, Constants.LAVA_MOVE_ENERGY_COST);
    }
    return ctx._lavaCost;
  }

  function getFallCost(MoveContext memory ctx) internal view returns (uint128) {
    if (ctx._fallCost == 0) {
      uint256 fallMul = PlayerSkillUtils.getFallEnergyMultiplierWad(ctx.player);
      ctx._fallCost = uint128(Math.mulWad(Constants.PLAYER_FALL_ENERGY_COST, fallMul));
    }
    return ctx._fallCost;
  }

  function _getMoveCost(MoveContext memory ctx, uint128 baseCost) private pure returns (uint128) {
    return uint128(Math.mulWad(baseCost, ctx._moveEnergyMul));
  }
}

using MoveContextLib for MoveContext;
