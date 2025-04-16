// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ObjectType } from "./codegen/tables/ObjectType.sol";
import { ResourceCount } from "./codegen/tables/ResourceCount.sol";

import { getObjectTypeIdAt, getOrCreateEntityAt } from "./utils/EntityUtils.sol";
import { ChunkCommitment } from "./utils/Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_ACACIA_SEED,
  MAX_BIRCH_SEED,
  MAX_COAL,
  MAX_COPPER,
  MAX_DARK_OAK_SEED,
  MAX_DIAMOND,
  MAX_GOLD,
  MAX_IRON,
  MAX_JUNGLE_SEED,
  MAX_MANGROVE_SEED,
  MAX_MELON_SEED,
  MAX_NEPTUNIUM,
  MAX_OAK_SEED,
  MAX_PUMPKIN_SEED,
  MAX_SAKURA_SEED,
  MAX_SPRUCE_SEED,
  MAX_WHEAT_SEED
} from "./Constants.sol";

import { EntityId } from "./EntityId.sol";
import { ObjectTypeId } from "./ObjectTypeId.sol";
import { ObjectAmount, ObjectTypeLib, TreeData, getOreObjectTypes } from "./ObjectTypeLib.sol";
import { ObjectTypes } from "./ObjectTypes.sol";
import { Vec3, vec3 } from "./Vec3.sol";

library NatureLib {
  using ObjectTypeLib for ObjectTypeId;

  function getRandomSeed(Vec3 coord) internal view returns (uint256) {
    // Get chunk commitment for the coord, but only validate it for random resources (done in NatureLib)
    Vec3 chunkCoord = coord.toChunkCoord();
    uint256 commitment = ChunkCommitment._get(chunkCoord);
    // We can't get blockhash of current block
    require(block.number > commitment, "Not within commitment blocks");
    require(block.number <= commitment + CHUNK_COMMIT_EXPIRY_BLOCKS, "Chunk commitment expired");
    return uint256(keccak256(abi.encodePacked(blockhash(commitment), coord)));
  }

  // Get resource cap for a specific resource type
  function getResourceCap(ObjectTypeId objectTypeId) internal pure returns (uint256) {
    if (objectTypeId == ObjectTypes.CoalOre) return MAX_COAL;
    if (objectTypeId == ObjectTypes.CopperOre) return MAX_COPPER;
    if (objectTypeId == ObjectTypes.IronOre) return MAX_IRON;
    if (objectTypeId == ObjectTypes.GoldOre) return MAX_GOLD;
    if (objectTypeId == ObjectTypes.DiamondOre) return MAX_DIAMOND;
    if (objectTypeId == ObjectTypes.NeptuniumOre) return MAX_NEPTUNIUM;
    if (objectTypeId == ObjectTypes.WheatSeed) return MAX_WHEAT_SEED;
    if (objectTypeId == ObjectTypes.MelonSeed) return MAX_MELON_SEED;
    if (objectTypeId == ObjectTypes.PumpkinSeed) return MAX_PUMPKIN_SEED;
    if (objectTypeId == ObjectTypes.OakSapling) return MAX_OAK_SEED;
    if (objectTypeId == ObjectTypes.SpruceSapling) return MAX_SPRUCE_SEED;
    if (objectTypeId == ObjectTypes.MangroveSapling) return MAX_MANGROVE_SEED;
    if (objectTypeId == ObjectTypes.SakuraSapling) return MAX_SAKURA_SEED;
    if (objectTypeId == ObjectTypes.DarkOakSapling) return MAX_DARK_OAK_SEED;
    if (objectTypeId == ObjectTypes.BirchSapling) return MAX_BIRCH_SEED;
    if (objectTypeId == ObjectTypes.AcaciaSapling) return MAX_ACACIA_SEED;
    if (objectTypeId == ObjectTypes.JungleSapling) return MAX_JUNGLE_SEED;

    // If no specific cap, use a high value
    return type(uint256).max;
  }

  // Get remaining amount of a resource
  function getCapAndRemaining(ObjectTypeId objectTypeId) internal view returns (uint256, uint256) {
    if (objectTypeId == ObjectTypes.Null) return (type(uint256).max, type(uint256).max);

    uint256 cap = getResourceCap(objectTypeId);
    uint256 mined = ResourceCount._get(objectTypeId);
    return (cap, mined >= cap ? 0 : cap - mined);
  }

  function getMineDrops(ObjectTypeId objectType, Vec3 coord) internal view returns (ObjectAmount[] memory result) {
    // Wheat drops wheat + 0-3 wheat seeds
    if (objectType == ObjectTypes.Wheat) {
      return getWheatDrops(getRandomSeed(coord));
    }

    // FescueGrass has a chance to drop wheat seeds
    if (objectType == ObjectTypes.FescueGrass) {
      return getGrassDrops(getRandomSeed(coord));
    }

    if (objectType.isLeaf()) {
      return getLeafDrops(objectType, getRandomSeed(coord));
    }

    if (objectType == ObjectTypes.Farmland || objectType == ObjectTypes.WetFarmland) {
      result = new ObjectAmount[](1);
      result[0] = ObjectAmount(ObjectTypes.Dirt, 1);
      return result;
    }

    // Default behavior for all other objects
    result = new ObjectAmount[](1);
    result[0] = ObjectAmount(objectType, 1);

    return result;
  }

  function getWheatDrops(uint256 randomSeed) internal view returns (ObjectAmount[] memory result) {
    // Distribution with expected value of exactly 1
    uint256[] memory distribution = new uint256[](4);
    distribution[0] = 40; // 0 seeds: 40%
    distribution[1] = 30; // 1 seed: 30%
    distribution[2] = 20; // 2 seeds: 20%
    distribution[3] = 10; // 3 seeds: 10%

    // Get wheat seed options and their weights using distribution
    (ObjectAmount[] memory seedOptions, uint256[] memory weights) = getDropWeights(ObjectTypes.WheatSeed, distribution);

    // Select seed drop based on calculated weights
    ObjectAmount memory seedDrop = selectObjectByWeight(seedOptions, weights, randomSeed);

    // Always drop wheat, plus seeds if any were selected
    if (seedDrop.objectTypeId != ObjectTypes.Null) {
      result = new ObjectAmount[](2);
      result[0] = ObjectAmount(ObjectTypes.Wheat, 1);
      result[1] = seedDrop;
    } else {
      result = new ObjectAmount[](1);
      result[0] = ObjectAmount(ObjectTypes.Wheat, 1);
    }

    return result;
  }

  function getGrassDrops(uint256 randomSeed) internal view returns (ObjectAmount[] memory result) {
    uint256[] memory distribution = new uint256[](2);
    distribution[0] = 43; // No seed: 43%
    distribution[1] = 57; // 1 seed: 57%

    (ObjectAmount[] memory grassOptions, uint256[] memory weights) = getDropWeights(ObjectTypes.WheatSeed, distribution);

    // Select drop based on calculated weights
    ObjectAmount memory seedDrop = selectObjectByWeight(grassOptions, weights, randomSeed);

    if (seedDrop.objectTypeId != ObjectTypes.Null) {
      result = new ObjectAmount[](1);
      result[0] = seedDrop;
    }

    return result;
  }

  function getLeafDrops(ObjectTypeId objectType, uint256 randomSeed)
    internal
    view
    returns (ObjectAmount[] memory result)
  {
    uint256[] memory distribution = new uint256[](2);
    distribution[0] = 43; // No sapling: 43%
    distribution[1] = 57; // 1 sapling: 57%

    // Get sapling options and their weights using distribution
    (ObjectAmount[] memory saplingOptions, uint256[] memory weights) =
      getDropWeights(objectType.getSapling(), distribution);

    // Select sapling drop based on calculated weights
    ObjectAmount memory saplingDrop = selectObjectByWeight(saplingOptions, weights, randomSeed);

    if (saplingDrop.objectTypeId != ObjectTypes.Null) {
      result = new ObjectAmount[](1);
      result[0] = saplingDrop;
    }

    return result;
  }

  function getRandomOre(Vec3 coord) internal view returns (ObjectTypeId) {
    uint256 randomSeed = getRandomSeed(coord);

    // Get ore options and their weights (based on remaining amounts)
    ObjectAmount[] memory oreOptions = new ObjectAmount[](5);
    uint256[] memory weights = new uint256[](5);

    ObjectTypeId[] memory oreTypes = getOreObjectTypes();
    // Use remaining amounts directly as weights
    for (uint256 i = 0; i < weights.length; i++) {
      oreOptions[i] = ObjectAmount(oreTypes[i], 1);
      (, weights[i]) = getCapAndRemaining(oreTypes[i]);
    }

    // Select ore based on availability
    ObjectAmount memory selectedOre = selectObjectByWeight(oreOptions, weights, randomSeed);

    // Return selected ore type and current mined count
    return selectedOre.objectTypeId;
  }

  function growTree(EntityId seed, Vec3 baseCoord, TreeData memory treeData) public returns (uint32, uint32) {
    uint32 trunkHeight = growTreeTrunk(seed, baseCoord, treeData);

    if (trunkHeight <= 2) {
      // Very small tree, no leaves
      return (trunkHeight, 0);
    }

    // Define canopy parameters
    uint32 size = treeData.canopyWidth;
    uint32 start = treeData.canopyStart; // Bottom of the canopy
    uint32 end = treeData.canopyEnd; // Top of the canopy
    uint32 stretch = treeData.stretchFactor; // How many times to repeat each sphere layer
    int32 center = int32(trunkHeight) + treeData.centerOffset; // Center of the sphere

    // Adjust if the tree is blocked
    if (trunkHeight < treeData.trunkHeight) {
      end = trunkHeight + 1; // Still allow one layer above the trunk
    }

    uint32 leaves;

    // Initial seed for randomness
    uint256 randomSeed = uint256(keccak256(abi.encodePacked(block.timestamp, baseCoord)));

    ObjectTypeId leafType = treeData.leafType;

    // Avoid stack too deep issues
    Vec3 coord = baseCoord;

    for (int32 y = int32(start); y < int32(end); ++y) {
      // Calculate distance from sphere center
      uint32 dy = uint32(FixedPointMathLib.dist(y, center));
      if (size < dy / stretch) {
        continue;
      }

      // We know this is not negative, but we use int32 to simplify operations
      int32 radius = int32(size - dy / stretch);

      // Create the canopy
      for (int32 x = -radius; x <= radius; ++x) {
        for (int32 z = -radius; z <= radius; ++z) {
          // Skip the trunk position
          if (x == 0 && z == 0 && y < int32(trunkHeight)) {
            continue;
          }

          // If it is a corner
          if (radius != 0 && int256(FixedPointMathLib.abs(x)) == radius && int256(FixedPointMathLib.abs(z)) == radius) {
            if ((dy + 1) % stretch == 0) {
              continue;
            }

            randomSeed = uint256(keccak256(abi.encodePacked(randomSeed)));
            if (randomSeed % 100 < 40) {
              continue;
            }
          }

          (EntityId leaf, ObjectTypeId existingType) = getOrCreateEntityAt(coord + vec3(x, y, z));

          // Only place leaves in air blocks
          if (existingType == ObjectTypes.Air) {
            ObjectType._set(leaf, leafType);
            leaves++;
          }
        }
      }
    }

    return (trunkHeight, leaves);
  }

  function growTreeTrunk(EntityId seed, Vec3 baseCoord, TreeData memory treeData) internal returns (uint32) {
    // Replace the seed with the trunk
    ObjectType._set(seed, treeData.logType);

    // Create the trunk up to available space
    for (uint32 i = 1; i < treeData.trunkHeight; i++) {
      Vec3 trunkCoord = baseCoord + vec3(0, int32(i), 0);
      (EntityId trunk, ObjectTypeId objectTypeId) = getOrCreateEntityAt(trunkCoord);
      if (objectTypeId != ObjectTypes.Air) {
        return i;
      }

      ObjectType._set(trunk, treeData.logType);
    }

    return treeData.trunkHeight;
  }

  // Simple random selection based on weights
  function selectObjectByWeight(ObjectAmount[] memory options, uint256[] memory weights, uint256 randomSeed)
    private
    pure
    returns (ObjectAmount memory)
  {
    return options[selectByWeight(weights, randomSeed)];
  }

  // Simple weighted selection from an array of weights
  function selectByWeight(uint256[] memory weights, uint256 randomSeed) private pure returns (uint256) {
    uint256 totalWeight = 0;
    for (uint256 i = 0; i < weights.length; i++) {
      totalWeight += weights[i];
    }

    require(totalWeight > 0, "No options available");

    // Select option based on weights
    uint256 randomValue = randomSeed % totalWeight;
    uint256 cumulativeWeight = 0;

    uint256 j = 0;
    for (; j < weights.length - 1; j++) {
      cumulativeWeight += weights[j];
      if (randomValue < cumulativeWeight) break;
    }

    return j;
  }

  // Adjusts pre-calculated weights based on resource availability
  function getDropWeights(ObjectTypeId objectType, uint256[] memory distribution)
    internal
    view
    returns (ObjectAmount[] memory options, uint256[] memory weights)
  {
    uint8 maxAmount = uint8(distribution.length - 1);

    options = new ObjectAmount[](distribution.length);
    options[0] = ObjectAmount(ObjectTypes.Null, 0); // Option for 0 drops

    for (uint8 i = 1; i <= maxAmount; i++) {
      options[i] = ObjectAmount(objectType, i);
    }

    // Start with the base weights and adjust for availability
    weights = new uint256[](distribution.length);
    weights[0] = distribution[0]; // Weight for 0 drops stays the same

    // Get resource availability info
    (uint256 cap, uint256 remaining) = getCapAndRemaining(objectType);

    // For each non-zero option, apply compound probability adjustment
    for (uint8 i = 1; i <= maxAmount; i++) {
      if (remaining < i) {
        weights[i] = 0;
        continue;
      }

      // Calculate compound probability for getting i resources
      uint256 p = distribution[i];

      // Apply availability adjustment for each resource needed
      for (uint8 j = 0; j < i; j++) {
        p = p * (remaining - j) / (cap - j);
      }

      weights[i] = p;
    }
  }
}
