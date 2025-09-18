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
import { RateLimitUnits } from "../codegen/tables/RateLimitUnits.sol";
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

    uint256 timebucket = block.timestamp - (block.timestamp % RATE_LIMIT_TIME_INTERVAL);

    uint128 currentUnits = RateLimitUnits._get(entity, timebucket, limitType);
    uint128 newUnits = currentUnits + unitCost;

    require(newUnits <= MAX_RATE_LIMIT_UNITS_PER_INTERVAL, "Rate limit exceeded");

    RateLimitUnits._set(entity, timebucket, limitType, newUnits);
  }

  // Utility function to check current units
  function getRateLimitUnits(EntityId entity, RateLimitType limitType) internal view returns (uint128) {
    uint256 timebucket = block.timestamp - (block.timestamp % RATE_LIMIT_TIME_INTERVAL);
    return RateLimitUnits._get(entity, timebucket, limitType);
  }
}
