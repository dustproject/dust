// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "./codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "./codegen/tables/ResourceCount.sol";

import { TerrainLib } from "./systems/libraries/TerrainLib.sol";
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
import { Vec3, vec3 } from "./Vec3.sol";

int256 constant SEA_LEVEL = 62;

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
}
