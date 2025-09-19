// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";
import { ChunkCommitment, ChunkCommitmentData } from "../codegen/tables/ChunkCommitment.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { ResourcePosition } from "../utils/Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_TIME,
  CHUNK_COMMIT_HALF_WIDTH,
  CHUNK_COMMIT_SUBMIT_TIME,
  RESPAWN_RESOURCE_TIME_RANGE
} from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { ObjectTypes } from "../types/ObjectType.sol";

import { NatureLib } from "../utils/NatureLib.sol";

import { Vec3 } from "../types/Vec3.sol";
import { DrandData } from "../utils/DrandUtils.sol";

contract NatureSystem is System {
  function initChunkCommit(EntityId caller, Vec3 chunkCoord) public {
    caller.activate();

    Vec3 callerChunkCoord = caller._getPosition().toChunkCoord();
    require(callerChunkCoord.inSurroundingCube(chunkCoord, CHUNK_COMMIT_HALF_WIDTH), "Entity is too far to commit");

    // Check existing commitment
    ChunkCommitmentData memory commitment = ChunkCommitment._get(chunkCoord.x(), chunkCoord.y(), chunkCoord.z());
    require(block.timestamp > commitment.timestamp + CHUNK_COMMIT_EXPIRY_TIME, "Existing chunk commitment");

    // Commit starting from next timestamp
    ChunkCommitment._setTimestamp(chunkCoord.x(), chunkCoord.y(), chunkCoord.z(), block.timestamp + 3 seconds);
  }

  function fulfillChunkCommit(Vec3 chunkCoord, DrandData calldata drand) public {
    ChunkCommitmentData memory commitment = ChunkCommitment._get(chunkCoord.x(), chunkCoord.y(), chunkCoord.z());
    require(block.timestamp > commitment.timestamp, "Not yet fulfillable");
    require(block.timestamp <= commitment.timestamp + CHUNK_COMMIT_SUBMIT_TIME, "Chunk commitment expired");
    require(commitment.randomness == 0, "Chunk already fulfilled");
    drand.verifyWithinTimeRange(CHUNK_COMMIT_SUBMIT_TIME);
    ChunkCommitment._setRandomness(chunkCoord.x(), chunkCoord.y(), chunkCoord.z(), drand.getRandomness());
  }

  // @notice deprecated
  function chunkCommit(EntityId caller, Vec3 chunkCoord) public {
    revert("Deprecated, use initChunkCommit");
  }

  function respawnResource(DrandData calldata drand, ObjectType resourceType) public {
    drand.verifyWithinTimeRange(RESPAWN_RESOURCE_TIME_RANGE);

    uint256 burned = BurnedResourceCount._get(resourceType);
    require(burned > 0, "No resources available for respawn");

    uint256 collected = ResourceCount._get(resourceType);
    uint256 resourceIdx = drand.getRandomness() % collected;

    Vec3 resourceCoord = ResourcePosition._get(resourceType, resourceIdx);

    // Check existing entity
    (EntityId entityId, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(resourceCoord);
    require(objectType == ObjectTypes.Air, "Resource coordinate is not air");
    require(InventoryUtils.isEmpty(entityId), "Cannot respawn where there are dropped objects");

    // Remove from collected resource array
    if (resourceIdx < collected) {
      Vec3 last = ResourcePosition._get(resourceType, collected - 1);
      ResourcePosition._set(resourceType, resourceIdx, last);
    }
    ResourcePosition._deleteRecord(resourceType, collected - 1);

    // Update total amounts
    BurnedResourceCount._set(resourceType, burned - 1);
    ResourceCount._set(resourceType, collected - 1);

    // This is enough to respawn the resource block, as it will be read from the original terrain next time
    EntityObjectType._deleteRecord(entityId);
  }

  /// @notice deprecated
  function respawnResource(uint256 blockNumber, ObjectType resourceType) public {
    revert("Deprecated, use respawnResource with drand signature");
  }

  function growSeed(EntityId caller, Vec3 coord) external {
    caller.activate();
    (EntityId seed, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isGrowable(), "Not growable");
    require(SeedGrowth._getFullyGrownAt(seed) <= block.timestamp, "Seed cannot be grown yet");
    NatureLib.growSeed(coord, seed, objectType);
  }
}
