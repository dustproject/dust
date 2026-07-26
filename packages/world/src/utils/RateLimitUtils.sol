// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  BUILD_UNIT_COST,
  HIT_MACHINE_UNIT_COST,
  HIT_PLAYER_UNIT_COST,
  MAX_RATE_LIMIT_UNITS_PER_INTERVAL,
  MINE_UNIT_COST,
  RATE_LIMIT_TIME_INTERVAL,
  SWIM_UNIT_COST,
  WALK_UNIT_COST
} from "../Constants.sol";
import { RateLimitType } from "../codegen/common.sol";
import { RateLimitUnits, RateLimitUnitsData } from "../codegen/tables/RateLimitUnits.sol";
import { EntityId } from "../types/EntityId.sol";

library RateLimitUtils {
  // Movement actions - batch
  function move(EntityId entity, uint128 walkSteps, uint128 swimSteps) internal {
    _updateRateLimit(entity, RateLimitType.Movement, WALK_UNIT_COST * walkSteps + SWIM_UNIT_COST * swimSteps);
  }

  function hitPlayer(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.HitPlayer, HIT_PLAYER_UNIT_COST);
  }

  function hitMachine(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.HitMachine, HIT_MACHINE_UNIT_COST);
  }

  // Work actions
  function mine(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.Work, MINE_UNIT_COST);
  }

  function build(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.Work, BUILD_UNIT_COST);
  }

  // Internal helper
  function _updateRateLimit(EntityId entity, RateLimitType limitType, uint128 unitCost) private {
    if (unitCost == 0) {
      return; // No cost, no rate limit update needed
    }

    uint64 timebucket = _timebucket();

    uint128 newUnits = _getUnits(entity, limitType, timebucket) + unitCost;

    require(newUnits <= MAX_RATE_LIMIT_UNITS_PER_INTERVAL, "Rate limit exceeded");

    RateLimitUnits._set(entity, limitType, timebucket, newUnits);
  }

  // Utility function to check current units
  function getRateLimitUnits(EntityId entity, RateLimitType limitType) internal view returns (uint128) {
    return _getUnits(entity, limitType, _timebucket());
  }

  function _timebucket() private view returns (uint64) {
    return uint64(block.timestamp - (block.timestamp % RATE_LIMIT_TIME_INTERVAL));
  }

  /// @dev A bucket stamped with an earlier interval is spent, so it reads as
  /// empty rather than being cleared — the next write overwrites it in place.
  function _getUnits(EntityId entity, RateLimitType limitType, uint64 timebucket) private view returns (uint128) {
    RateLimitUnitsData memory bucket = RateLimitUnits._get(entity, limitType);
    return bucket.timestamp == timebucket ? bucket.units : 0;
  }
}
