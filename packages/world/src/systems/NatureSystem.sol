// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { ChunkCommitment, ResourcePosition } from "../utils/Vec3Storage.sol";

import { CHUNK_COMMIT_EXPIRY_BLOCKS, CHUNK_COMMIT_HALF_WIDTH, RESPAWN_ORE_BLOCK_RANGE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";

import { NatureLib } from "../NatureLib.sol";

import { Vec3, vec3 } from "../Vec3.sol";

contract NatureSystem is System {
  function chunkCommit(EntityId caller, Vec3 chunkCoord) public {
    caller.activate();

    Vec3 callerChunkCoord = caller._getPosition().toChunkCoord();
    require(callerChunkCoord.inSurroundingCube(chunkCoord, CHUNK_COMMIT_HALF_WIDTH), "Entity is too far to commit");

    // Check existing commitment
    uint256 commitment = ChunkCommitment._get(chunkCoord);
    require(block.number > commitment + CHUNK_COMMIT_EXPIRY_BLOCKS, "Existing chunk commitment");

    // Commit starting from next block
    ChunkCommitment._set(chunkCoord, block.number + 1);
  }

  function respawnResource(uint256 blockNumber, ObjectType resourceType) public {
    require(
      blockNumber < block.number && blockNumber >= block.number - RESPAWN_ORE_BLOCK_RANGE,
      "Can only choose past 10 blocks"
    );

    uint256 burned = BurnedResourceCount._get(resourceType);
    require(burned > 0, "No resources available for respawn");

    uint256 collected = ResourceCount._get(resourceType);
    uint256 resourceIdx = uint256(blockhash(blockNumber)) % collected;

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

  function growSeed(EntityId caller, Vec3 coord) external {
    caller.activate();
    (EntityId seed, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isGrowable(), "Not growable");
    require(SeedGrowth._getFullyGrownAt(seed) <= block.timestamp, "Seed cannot be grown yet");
    NatureLib.growSeed(coord, seed, objectType);
  }
}
