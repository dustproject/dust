// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { ObjectTypes } from "../types/ObjectType.sol";

import { TerrainLib } from "./TerrainLib.sol";

import { addEnergyToLocalPool } from "./EnergyUtils.sol";
import { EntityUtils } from "./EntityUtils.sol";
import { ChunkCommitment } from "./Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_ACACIA_SAPLING,
  MAX_BIRCH_SAPLING,
  MAX_COAL,
  MAX_COPPER,
  MAX_DARK_OAK_SAPLING,
  MAX_DIAMOND,
  MAX_GOLD,
  MAX_IRON,
  MAX_JUNGLE_SAPLING,
  MAX_MANGROVE_SAPLING,
  MAX_MELON_SEED,
  MAX_NEPTUNIUM,
  MAX_OAK_SAPLING,
  MAX_PUMPKIN_SEED,
  MAX_SAKURA_SAPLING,
  MAX_SPRUCE_SAPLING,
  MAX_WHEAT_SEED
} from "../Constants.sol";
import { ObjectAmount, ObjectType } from "../types/ObjectType.sol";

import { EntityId } from "../types/EntityId.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";
import { TreeData, TreeLib } from "./TreeLib.sol";

library NatureLib {
  function getRandomSeed(Vec3 coord) internal view returns (uint256) {
    Vec3 chunkCoord = coord.toChunkCoord();
    uint256 commitment = ChunkCommitment._get(chunkCoord);
    // We can't get blockhash of current block
    require(block.number > commitment, "Not within commitment blocks");
    require(block.number <= commitment + CHUNK_COMMIT_EXPIRY_BLOCKS, "Chunk commitment expired");
    return uint256(keccak256(abi.encodePacked(blockhash(commitment), coord)));
  }

  // Get resource cap for a specific resource type
  function getResourceCap(ObjectType objectType) internal pure returns (uint256) {
    if (objectType == ObjectTypes.CoalOre) return MAX_COAL;
    if (objectType == ObjectTypes.CopperOre) return MAX_COPPER;
    if (objectType == ObjectTypes.IronOre) return MAX_IRON;
    if (objectType == ObjectTypes.GoldOre) return MAX_GOLD;
    if (objectType == ObjectTypes.DiamondOre) return MAX_DIAMOND;
    if (objectType == ObjectTypes.NeptuniumOre) return MAX_NEPTUNIUM;
    if (objectType == ObjectTypes.WheatSeed) return MAX_WHEAT_SEED;
    if (objectType == ObjectTypes.MelonSeed) return MAX_MELON_SEED;
    if (objectType == ObjectTypes.PumpkinSeed) return MAX_PUMPKIN_SEED;
    if (objectType == ObjectTypes.OakSapling) return MAX_OAK_SAPLING;
    if (objectType == ObjectTypes.SpruceSapling) return MAX_SPRUCE_SAPLING;
    if (objectType == ObjectTypes.MangroveSapling) return MAX_MANGROVE_SAPLING;
    if (objectType == ObjectTypes.SakuraSapling) return MAX_SAKURA_SAPLING;
    if (objectType == ObjectTypes.DarkOakSapling) return MAX_DARK_OAK_SAPLING;
    if (objectType == ObjectTypes.BirchSapling) return MAX_BIRCH_SAPLING;
    if (objectType == ObjectTypes.AcaciaSapling) return MAX_ACACIA_SAPLING;
    if (objectType == ObjectTypes.JungleSapling) return MAX_JUNGLE_SAPLING;

    // If no specific cap, use a high value
    return type(uint256).max;
  }

  // Get remaining amount of a resource
  function getCapAndRemaining(ObjectType objectType) internal view returns (uint256, uint256) {
    if (objectType == ObjectTypes.Null) return (type(uint256).max, type(uint256).max);

    uint256 cap = getResourceCap(objectType);
    uint256 mined = ResourceCount._get(objectType);
    return (cap, mined >= cap ? 0 : cap - mined);
  }

  function growSeed(Vec3 coord, EntityId seed, ObjectType objectType) public returns (ObjectType) {
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

      ObjectType cropType = objectType.getCrop();
      EntityObjectType._set(seed, cropType);
      return cropType;
    } else if (objectType.isSapling()) {
      // Grow the tree (replace the seed with the trunk and add blocks)
      TreeData memory treeData = TreeLib.getTreeData(objectType);

      (uint32 trunkHeight, uint32 leaves) = _growTree(seed, coord, treeData, objectType);

      uint128 growableEnergy = objectType.getGrowableEnergy();
      uint128 trunkEnergy = trunkHeight * ObjectPhysics._getEnergy(treeData.logType);
      uint128 leafEnergy = leaves * ObjectPhysics._getEnergy(treeData.leafType);

      uint128 energyToReturn = growableEnergy - trunkEnergy - leafEnergy;

      if (energyToReturn > 0) {
        addEnergyToLocalPool(coord, energyToReturn);
      }

      return treeData.logType;
    }

    revert("Not a seed or sapling");
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
