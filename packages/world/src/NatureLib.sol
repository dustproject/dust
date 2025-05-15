// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "./codegen/tables/BurnedResourceCount.sol";
import { DisabledExtraDrops } from "./codegen/tables/DisabledExtraDrops.sol";
import { ResourceCount } from "./codegen/tables/ResourceCount.sol";

import { ChunkCommitment } from "./utils/Vec3Storage.sol";

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
} from "./Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "./ObjectType.sol";

import { EntityId } from "./EntityId.sol";
import { TreeLib } from "./TreeLib.sol";
import { Vec3, vec3 } from "./Vec3.sol";

library NatureLib {
  struct RandomDrop {
    ObjectType objectType;
    uint256[] distribution;
  }

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

  function getMineDrops(EntityId mined, ObjectType objectType, Vec3 coord)
    internal
    view
    returns (ObjectAmount[] memory result)
  {
    RandomDrop[] memory randomDrops = getRandomDrops(mined, objectType);

    result = new ObjectAmount[](randomDrops.length + 1);

    if (randomDrops.length > 0) {
      uint256 randomSeed = getRandomSeed(coord);
      for (uint256 i = 0; i < randomDrops.length; i++) {
        RandomDrop memory drop = randomDrops[i];
        (uint256 cap, uint256 remaining) = getCapAndRemaining(drop.objectType);
        uint256[] memory weights = adjustWeights(drop.distribution, cap, remaining);
        uint256 amount = selectByWeight(weights, randomSeed);
        result[i] = ObjectAmount(drop.objectType, uint16(amount));
      }
    }

    // If farmland, convert to dirt
    if (objectType == ObjectTypes.Farmland || objectType == ObjectTypes.WetFarmland) {
      objectType = ObjectTypes.Dirt;
    }

    // Add base type as a drop for all objects
    result[result.length - 1] = ObjectAmount(objectType, 1);

    return result;
  }

  function getRandomDrops(EntityId mined, ObjectType objectType) internal view returns (RandomDrop[] memory drops) {
    if (!objectType.hasExtraDrops() || DisabledExtraDrops._get(mined)) {
      return drops;
    }

    if (objectType == ObjectTypes.FescueGrass || objectType == ObjectTypes.SwitchGrass) {
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = 43; // 0 seeds: 43%
      distribution[1] = 57; // 1 seed:  57%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Wheat) {
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 40; // 0 seeds: 40%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 20; // 2 seeds: 20%
      distribution[3] = 10; // 3 seeds: 10%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Melon) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20; // 0 seeds: 20%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 27; // 2 seeds: 27%
      distribution[3] = 23; // 3 seeds: 23%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.MelonSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Pumpkin) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20; // 0 seeds: 20%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 27; // 2 seeds: 27%
      distribution[3] = 23; // 3 seeds: 23%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.PumpkinSeed, distribution);
      return drops;
    }

    if (objectType.isLeaf()) {
      uint256 chance = TreeLib.getLeafDropChance(objectType);
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = 100 - chance; // No sapling
      distribution[1] = chance; // 1 sapling

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(objectType.getSapling(), distribution);
      return drops;
    }
  }

  function getRandomOre(Vec3 coord) internal view returns (ObjectType) {
    uint256 randomSeed = getRandomSeed(coord);

    // Get ore options and their weights (based on remaining amounts)

    ObjectType[7] memory oreTypes = ObjectTypeLib.getOreTypes();
    uint256[] memory weights = new uint256[](oreTypes.length - 1);

    // Use remaining amounts directly as weights
    // Skip UnrevealedOre (index 0) since it's not a specific ore type
    for (uint256 i = 1; i < oreTypes.length; i++) {
      (, weights[i - 1]) = getCapAndRemaining(oreTypes[i]);
    }

    // Select ore based on availability
    return oreTypes[selectByWeight(weights, randomSeed) + 1];
  }

  function burnOre(ObjectType self, uint256 amount) internal {
    // This increases the availability of the ores being burned
    ResourceCount._set(self, ResourceCount._get(self) - amount);
    // This allows the same amount of ores to respawn
    BurnedResourceCount._set(ObjectTypes.UnrevealedOre, BurnedResourceCount._get(ObjectTypes.UnrevealedOre) + amount);
  }

  function burnOres(ObjectType self) internal {
    ObjectAmount memory oreAmount = self.getOreAmount();
    if (!oreAmount.objectType.isNull()) {
      burnOre(oreAmount.objectType, oreAmount.amount);
    }
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
  function adjustWeights(uint256[] memory distribution, uint256 cap, uint256 remaining)
    private
    pure
    returns (uint256[] memory weights)
  {
    uint8 maxAmount = uint8(distribution.length - 1);

    weights = new uint256[](distribution.length);

    weights[0] = distribution[0]; // Weight for 0 drops stays the same

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
