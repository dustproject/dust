// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy } from "../../codegen/tables/Energy.sol";

import { MoveUnits } from "../../codegen/tables/MoveUnits.sol";
import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import "../../Constants.sol" as Constants;
import { EntityId } from "../../types/EntityId.sol";
import { ObjectType } from "../../types/ObjectType.sol";

import { ObjectTypes } from "../../types/ObjectType.sol";

import { Vec3, vec3 } from "../../types/Vec3.sol";
import { addEnergyToLocalPool, decreasePlayerEnergy, updatePlayerEnergy } from "../../utils/EnergyUtils.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";

error NonPassableBlock(int32 x, int32 y, int32 z, ObjectType objectType);

library MoveLib {
  function jump(Vec3 playerCoord) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    // NOTE: we currently don't count moves here because this is only used for jump builds

    uint128 currentEnergy = Energy._getEnergy(player);

    Vec3 above = playerCoord + vec3(0, 1, 0);
    _requireValidMove(playerCoord, above);
    (uint128 totalCost,) = _getMoveCost(above);

    if (totalCost >= currentEnergy) {
      totalCost = currentEnergy;
    }

    _setPlayerPosition(playerEntityIds, above);

    _updatePlayerDrainRate(player, above);

    if (totalCost > 0) {
      decreasePlayerEnergy(player, above, totalCost);
      addEnergyToLocalPool(above, totalCost);
    }
  }

  function move(Vec3 playerCoord, Vec3[] memory newBaseCoords) public {
    EntityId[] memory playerEntityIds = _removePlayerPosition(playerCoord);
    EntityId player = playerEntityIds[0];

    uint128 currentEnergy = Energy._getEnergy(player);
    uint128 currentMoveUnits = _getMoveUnits(player);

    (Vec3 finalCoord, uint128 totalCost, uint128 newMoveUnits) =
      _computePathResult(playerCoord, newBaseCoords, currentEnergy, currentMoveUnits);

    _setMoveUnits(player, newMoveUnits);

    _setPlayerPosition(playerEntityIds, finalCoord);

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
    return EntityUtils.safeGetObjectTypeAt(belowCoord).isPassThrough()
      && !EntityUtils.getMovableEntityAt(belowCoord)._exists() && !_isFluid(playerCoord);
  }

  function _computeGravityResult(Vec3 coord, uint16 initialFallHeight) private view returns (Vec3, uint128) {
    uint16 currentFallHeight = initialFallHeight;
    Vec3 current = coord;

    while (_gravityApplies(current)) {
      current = current - vec3(0, 1, 0);
      unchecked {
        ++currentFallHeight;
      }
    }

    // We don't count move units as we are not moving, just falling
    (uint128 moveCost,) = _getMoveCost(current);
    // If currently on water or under the safe fall threshold, don't apply fall damage
    if (currentFallHeight <= Constants.PLAYER_SAFE_FALL_DISTANCE || _isFluid(current)) {
      return (current, moveCost);
    }

    return (
      current, moveCost + Constants.PLAYER_FALL_ENERGY_COST * (currentFallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE)
    );
  }

  /**
   * Calculate total energy cost and final path coordinate
   */
  function _computePathResult(
    Vec3 current,
    Vec3[] memory newBaseCoords,
    uint128 currentEnergy,
    uint128 currentMoveUnits
  ) internal view returns (Vec3, uint128, uint128) {
    uint128 cost = 0;
    uint16 jumps = 0;
    uint16 glides = 0;
    uint16 fallHeight = 0;

    bool currentHasGravity = _gravityApplies(current);

    for (uint256 i = 0; i < newBaseCoords.length; i++) {
      if (cost >= currentEnergy) break;

      Vec3 next = newBaseCoords[i];

      int32 dy = next.y() - current.y();

      _requireValidMove(current, next);

      bool nextHasGravity = _gravityApplies(next);

      // Only count as fall when gravity doesn't apply in current coord
      if (dy < 0 && currentHasGravity) {
        // For falls, cost will be computed upon landing
        ++fallHeight;
        glides = 0;

        // If landing, apply normal move cost
        if (!nextHasGravity) {
          (uint128 moveCost, uint128 moveUnits) = _getMoveCost(next);
          cost += moveCost;
          currentMoveUnits += moveUnits;
        }
      } else {
        if (dy > 0) {
          ++jumps;
          require(jumps <= Constants.MAX_PLAYER_JUMPS, "Cannot jump more than 3 blocks");
        } else if (nextHasGravity) {
          ++glides;
          require(glides <= Constants.MAX_PLAYER_GLIDES, "Cannot glide more than 10 blocks");
        }
        (uint128 moveCost, uint128 moveUnits) = _getMoveCost(next);
        cost += moveCost;
        currentMoveUnits += moveUnits;
      }

      require(currentMoveUnits <= Constants.MAX_MOVE_UNITS_PER_BLOCK, "Move limit exceeded");

      if (!nextHasGravity) {
        // If landing after a long fall, apply fall damage
        if (fallHeight > Constants.PLAYER_SAFE_FALL_DISTANCE && !_isFluid(next)) {
          cost += Constants.PLAYER_FALL_ENERGY_COST * (fallHeight - Constants.PLAYER_SAFE_FALL_DISTANCE);
        }
        fallHeight = 0;
        jumps = 0;
        glides = 0;
      }

      currentHasGravity = nextHasGravity;
      current = next;
    }

    // If gravity still applies after last path move, run gravity all the way down,
    // taking into account the current fallHeight
    if (currentHasGravity) {
      uint128 fallDamage;
      (current, fallDamage) = _computeGravityResult(current, fallHeight);
      cost += fallDamage;
    }

    return (current, cost, currentMoveUnits);
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

    if (!above._exists() || above.baseEntityId() == player) {
      return;
    }

    runGravity(aboveCoord);
  }

  function _isFluid(Vec3 coord) internal view returns (bool) {
    return EntityUtils.getFluidLevelAt(coord) > 0;
  }

  function _getMoveCost(Vec3 coord) internal view returns (uint128 energyCost, uint128 moveUnitCost) {
    Vec3 belowCoord = coord - vec3(0, 1, 0);
    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    if (belowType == ObjectTypes.Lava) {
      return (Constants.LAVA_MOVE_ENERGY_COST, Constants.MOVING_UNIT_COST);
    }

    if (belowType.isPassThrough() && _isFluid(belowCoord)) {
      return (Constants.WATER_MOVE_ENERGY_COST, Constants.SWIMMING_UNIT_COST);
    }

    return (Constants.MOVE_ENERGY_COST, Constants.MOVING_UNIT_COST);
  }

  function _getMoveUnits(EntityId entity) internal view returns (uint128) {
    return MoveUnits._get(entity, block.number);
  }

  function _setMoveUnits(EntityId entity, uint128 moveUnits) internal {
    MoveUnits._set(entity, block.number, moveUnits);
  }
}
