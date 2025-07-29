// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  COMBAT_HIT_UNIT_COST,
  MAX_RATE_LIMIT_UNITS_PER_BLOCK,
  MOVEMENT_SWIM_UNIT_COST,
  MOVEMENT_WALK_UNIT_COST,
  WORK_BUILD_UNIT_COST,
  WORK_MINE_UNIT_COST
} from "../Constants.sol";
import { RateLimitType } from "../codegen/common.sol";
import { RateLimitUnits } from "../codegen/tables/RateLimitUnits.sol";
import { EntityId } from "../types/EntityId.sol";

library RateLimitUtils {
  // Movement actions - batch
  function move(EntityId entity, uint128 walkSteps, uint128 swimSteps) internal {
    _updateRateLimit(
      entity, RateLimitType.Movement, MOVEMENT_WALK_UNIT_COST * walkSteps + MOVEMENT_SWIM_UNIT_COST * swimSteps
    );
  }

  // Combat actions
  function hit(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.Combat, COMBAT_HIT_UNIT_COST);
  }

  // Work actions
  function mine(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.Work, WORK_MINE_UNIT_COST);
  }

  function build(EntityId entity) internal {
    _updateRateLimit(entity, RateLimitType.Work, WORK_BUILD_UNIT_COST);
  }

  // Internal helper
  function _updateRateLimit(EntityId entity, RateLimitType limitType, uint128 unitCost) private {
    if (unitCost == 0) {
      return; // No cost, no rate limit update needed
    }

    uint128 currentUnits = RateLimitUnits._get(entity, block.number, limitType);
    uint128 newUnits = currentUnits + unitCost;

    require(newUnits <= MAX_RATE_LIMIT_UNITS_PER_BLOCK, "Rate limit exceeded");

    RateLimitUnits._set(entity, block.number, limitType, newUnits);
  }

  // Utility function to check current units
  function getRateLimitUnits(EntityId entity, RateLimitType limitType) internal view returns (uint128) {
    return RateLimitUnits._get(entity, block.number, limitType);
  }
}
