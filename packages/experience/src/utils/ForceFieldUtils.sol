// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { VoxelCoord } from "@biomesaw/world/src/Types.sol";
import { EntityId } from "@biomesaw/world/src/EntityId.sol";

import { ForceField } from "@biomesaw/world/src/codegen/tables/ForceField.sol";

import { coordToShardCoord } from "@biomesaw/world/src/utils/VoxelCoordUtils.sol";
import { FORCE_FIELD_SHARD_DIM } from "@biomesaw/world/src/Constants.sol";

import { getPosition } from "./EntityUtils.sol";

function getForceField(EntityId entityId) view returns (EntityId) {
  VoxelCoord memory coord = getPosition(entityId);
  VoxelCoord memory shardCoord = coordToShardCoord(coord, FORCE_FIELD_SHARD_DIM);
  return ForceField.get(shardCoord.x, shardCoord.y, shardCoord.z);
}
