// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Inventory } from "../codegen/tables/Inventory.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";

import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { addEnergyToLocalPool } from "../utils/EnergyUtils.sol";

import { getObjectTypeIdAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { ChunkCommitment, Position, ResourcePosition, ReversePosition } from "../utils/Vec3Storage.sol";

import { CHUNK_COMMIT_EXPIRY_BLOCKS, CHUNK_COMMIT_HALF_WIDTH, RESPAWN_ORE_BLOCK_RANGE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";

import { NatureLib } from "../NatureLib.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib, TreeData } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";

import { Vec3, vec3 } from "../Vec3.sol";

contract NatureSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function chunkCommit(EntityId caller, Vec3 chunkCoord) public {
    caller.activate();

    Vec3 callerChunkCoord = caller.getPosition().toChunkCoord();
    require(callerChunkCoord.inSurroundingCube(chunkCoord, CHUNK_COMMIT_HALF_WIDTH), "Not in commit range");

    // Check existing commitment
    uint256 commitment = ChunkCommitment._get(chunkCoord);
    require(block.number > commitment + CHUNK_COMMIT_EXPIRY_BLOCKS, "Existing chunk commitment");

    // Commit starting from next block
    ChunkCommitment._set(chunkCoord, block.number + 1);
  }

  function respawnResource(uint256 blockNumber, ObjectTypeId resourceType) public {
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
    EntityId entityId = ReversePosition._get(resourceCoord);
    ObjectTypeId objectType = ObjectType._get(entityId);
    require(objectType == ObjectTypes.Air, "Resource coordinate is not air");
    require(Inventory._length(entityId) == 0, "Cannot respawn where there are dropped objects");

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
    ObjectType._deleteRecord(entityId);
    Position._deleteRecord(entityId);
    ReversePosition._deleteRecord(resourceCoord);
  }

  function growSeed(EntityId caller, Vec3 coord) external {
    caller.activate();
    // TODO: should we do proximity checks?

    (EntityId seed, ObjectTypeId objectType) = getOrCreateEntityAt(coord);
    require(objectType.isGrowable(), "Not a seed");

    require(SeedGrowth._getFullyGrownAt(seed) <= block.timestamp, "Seed cannot be grown yet");

    // When a seed grows, it's removed from circulation
    // We only update ResourceCount since seeds don't participate in respawning (no need to track positions
    uint256 seedCount = ResourceCount._get(objectType);
    // This should never happen if there are seeds in the world obtained from drops
    require(seedCount > 0, "Not enough seeds in circulation");

    if (objectType.isSeed()) {
      // Turn wet farmland to regular farmland if mining a seed or crop
      (EntityId below, ObjectTypeId belowType) = getOrCreateEntityAt(coord - vec3(0, 1, 0));
      // Sanity check
      if (belowType == ObjectTypes.WetFarmland) {
        ObjectType._set(below, ObjectTypes.Farmland);
      }

      ObjectType._set(seed, objectType.getCrop());
    } else if (objectType.isSapling()) {
      TreeData memory treeData = objectType.getTreeData();

      // Grow the tree (replace the seed with the trunk and add blocks)
      (uint32 trunkHeight, uint32 leaves) = NatureLib.growTree(seed, coord, treeData);

      // Seed energy is the sum of the energy of all the blocks of the tree
      uint128 seedEnergy = ObjectTypeMetadata._getEnergy(objectType);

      uint128 trunkEnergy = trunkHeight * ObjectTypeMetadata._getEnergy(treeData.logType);
      uint128 leafEnergy = leaves * ObjectTypeMetadata._getEnergy(treeData.leafType);

      uint128 energyToReturn = seedEnergy - trunkEnergy - leafEnergy;
      if (energyToReturn > 0) {
        addEnergyToLocalPool(coord, energyToReturn);
      }
    }
  }
}
