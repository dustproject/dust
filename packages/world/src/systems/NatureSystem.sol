// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Inventory } from "../codegen/tables/Inventory.sol";

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";

import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { addEnergyToLocalPool } from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ChunkCommitment, ResourcePosition } from "../utils/Vec3Storage.sol";

import { CHUNK_COMMIT_EXPIRY_BLOCKS, CHUNK_COMMIT_HALF_WIDTH, RESPAWN_ORE_BLOCK_RANGE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";

import { NatureLib } from "../NatureLib.sol";
import { TreeData, TreeLib } from "../TreeLib.sol";

import { Vec3, vec3 } from "../Vec3.sol";

contract NatureSystem is System {
  function chunkCommit(EntityId caller, Vec3 chunkCoord) public {
    caller.activate();

    Vec3 callerChunkCoord = caller.getPosition().toChunkCoord();
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
    require(Inventory._lengthOccupiedSlots(entityId) == 0, "Cannot respawn where there are dropped objects");

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
    // TODO: should we do proximity checks?

    (EntityId seed, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isGrowable(), "Not growable");
    require(SeedGrowth._getFullyGrownAt(seed) <= block.timestamp, "Seed cannot be grown yet");

    // When a seed grows, it's removed from circulation
    // We only update ResourceCount since seeds don't participate in respawning (no need to track positions
    uint256 seedCount = ResourceCount._get(objectType);
    // This should never happen if there are seeds in the world obtained from drops
    require(seedCount > 0, "Not enough seeds in circulation");

    if (objectType.isSeed()) {
      // Turn wet farmland to regular farmland if mining a seed or crop
      (EntityId below, ObjectType belowType) = EntityUtils.getOrCreateBlockAt(coord - vec3(0, 1, 0));
      // Sanity check
      if (belowType == ObjectTypes.WetFarmland) {
        EntityObjectType._set(below, ObjectTypes.Farmland);
      }

      EntityObjectType._set(seed, objectType.getCrop());
    } else if (objectType.isSapling()) {
      // Grow the tree (replace the seed with the trunk and add blocks)
      TreeData memory treeData = TreeLib.getTreeData(objectType);

      (uint32 trunkHeight, uint32 leaves) = _growTree(seed, coord, treeData, objectType);

      uint128 seedEnergy = ObjectPhysics._getEnergy(objectType);
      uint128 trunkEnergy = trunkHeight * ObjectPhysics._getEnergy(treeData.logType);
      uint128 leafEnergy = leaves * ObjectPhysics._getEnergy(treeData.leafType);

      uint128 energyToReturn = seedEnergy - trunkEnergy - leafEnergy;

      if (energyToReturn > 0) {
        addEnergyToLocalPool(coord, energyToReturn);
      }
    }
  }

  function _growTree(EntityId seed, Vec3 baseCoord, TreeData memory treeData, ObjectType saplingType)
    private
    returns (uint32, uint32)
  {
    uint32 trunkHeight = _growTreeTrunk(seed, baseCoord, treeData);

    if (trunkHeight <= 2) {
      // Very small tree, no leaves
      return (trunkHeight, 0);
    }

    // Adjust if the tree is blocked
    bool obstructed = trunkHeight < treeData.trunkHeight;
    if (obstructed) {
      trunkHeight = trunkHeight + 1; // Still allow one layer above the trunk
    }

    (Vec3[] memory fixedLeaves, Vec3[] memory randomLeaves) = TreeLib.getLeafCoords(saplingType);

    // Initial seed for randomness
    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, baseCoord)));

    uint32 leafCount;

    for (uint256 i = 0; i < fixedLeaves.length; ++i) {
      Vec3 rel = fixedLeaves[i];
      if (obstructed && rel.y() > int32(trunkHeight)) {
        break;
      }

      if (_tryCreateLeaf(treeData.leafType, baseCoord + rel)) {
        ++leafCount;
      }
    }

    for (uint256 j = 0; j < randomLeaves.length; ++j) {
      Vec3 rel = randomLeaves[j];
      if (obstructed && rel.y() > int32(trunkHeight)) {
        break;
      }

      rand = uint256(keccak256(abi.encodePacked(rand, j))); // evolve RNG

      if (rand % 100 < 40) continue; // 40 % trimmed

      if (_tryCreateLeaf(treeData.leafType, baseCoord + rel)) {
        ++leafCount;
      }
    }

    return (trunkHeight, leafCount);
  }

  function _tryCreateLeaf(ObjectType leafType, Vec3 coord) private returns (bool) {
    (EntityId leaf, ObjectType existing) = EntityUtils.getOrCreateBlockAt(coord);
    if (existing != ObjectTypes.Air) {
      return false;
    }

    EntityObjectType._set(leaf, leafType);
    return true;
  }

  function _growTreeTrunk(EntityId seed, Vec3 baseCoord, TreeData memory treeData) private returns (uint32) {
    // Replace the seed with the trunk
    EntityObjectType._set(seed, treeData.logType);

    // Create the trunk up to available space
    for (uint32 i = 1; i < treeData.trunkHeight; i++) {
      Vec3 trunkCoord = baseCoord + vec3(0, int32(i), 0);
      (EntityId trunk, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(trunkCoord);
      if (objectType != ObjectTypes.Air) {
        return i;
      }

      EntityObjectType._set(trunk, treeData.logType);
    }

    return treeData.trunkHeight;
  }
}
