// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
// import { ObjectType } from "../codegen/tables/ObjectType.sol";
// import { Mass } from "../codegen/tables/Mass.sol";

import { useEquipped } from "../utils/InventoryUtils.sol";
import { getOrCreateEntityAt, getObjectTypeIdAt } from "../utils/EntityUtils.sol";
import { requireValidPlayer, requireInPlayerInfluence } from "../utils/PlayerUtils.sol";
import { massToEnergy, transferEnergyToPool, addEnergyToLocalPool } from "../utils/EnergyUtils.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectTypeLib, TreeData } from "../ObjectTypeLib.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { Vec3, vec3 } from "../Vec3.sol";
import { PLAYER_TILL_ENERGY_COST } from "../Constants.sol";

contract FarmingSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function till(Vec3 coord) external {
    (EntityId playerEntityId, Vec3 playerCoord, ) = requireValidPlayer(_msgSender());
    requireInPlayerInfluence(playerCoord, coord);

    (EntityId farmlandEntityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(coord);
    require(objectTypeId == ObjectTypes.Dirt || objectTypeId == ObjectTypes.Grass, "Not dirt or grass");
    (uint128 massUsed, ObjectTypeId toolObjectTypeId) = useEquipped(playerEntityId);
    require(toolObjectTypeId.isHoe(), "Must equip a hoe");

    uint128 energyCost = PLAYER_TILL_ENERGY_COST + massToEnergy(massUsed);
    transferEnergyToPool(playerEntityId, playerCoord, energyCost);

    ObjectType._set(farmlandEntityId, ObjectTypes.Farmland);
  }

  function growSeed(Vec3 coord) external {
    requireValidPlayer(_msgSender());

    (EntityId seedEntityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(coord);
    require(objectTypeId.isSeed(), "Not a seed");

    require(SeedGrowth._getFullyGrownAt(seedEntityId) <= block.timestamp, "Seed cannot be grown yet");

    if (objectTypeId.isCropSeed()) {
      // Turn wet farmland to regular farmland if mining a seed or crop
      (EntityId belowEntityId, ObjectTypeId belowTypeId) = getOrCreateEntityAt(coord - vec3(0, 1, 0));
      // Sanity check
      if (belowTypeId == ObjectTypes.WetFarmland) {
        ObjectType._set(belowEntityId, ObjectTypes.Farmland);
      }

      ObjectType._set(seedEntityId, objectTypeId.getCrop());
    } else if (objectTypeId.isTreeSeed()) {
      TreeData memory treeData = objectTypeId.getTreeData();
      require(treeData.logType != ObjectTypes.Null, "Invalid tree seed");

      // Grow the tree (replace the seed with the trunk and add blocks)
      (uint32 height, uint32 leaves) = _growTree(seedEntityId, coord, treeData);
      // If something blocked the height of the tree, return the logs energy to the pool
      uint32 energyToReturn = (treeData.height - height) * ObjectTypeMetadata._getEnergy(treeData.logType);

      // If not all leaves were generated, return their energy to the local pool
      uint32 maxPossibleLeaves = (2 * treeData.canopySize + 1) ** 2 * 5 - treeData.height;
      energyToReturn += (maxPossibleLeaves - leaves) * ObjectTypeMetadata._getEnergy(treeData.leafType);
      if (energyToReturn > 0) {
        addEnergyToLocalPool(coord, energyToReturn);
      }
    }
  }

  // TODO: adjust to get desired shape
  function _growTree(
    EntityId seedEntityId,
    Vec3 baseCoord,
    TreeData memory treeData
  ) internal returns (uint32, uint32) {
    uint32 height = _growTreeTrunk(seedEntityId, baseCoord, treeData);

    if (height <= 2) {
      // Very small tree, no leaves
      return (height, 0);
    }

    // Adjust canopy parameters based on height
    int32 canopySize;
    int32 canopyStart;
    int32 canopyEnd;

    if (height <= 4) {
      // Small tree
      canopySize = int32(treeData.canopySize) - 1;
      canopyStart = int32(height) - 1;
      canopyEnd = int32(height) + 1; // Extend 1 block above trunk
    } else {
      // Normal or tall tree
      canopySize = int32(treeData.canopySize);
      canopyStart = int32(height) - 2;
      canopyEnd = int32(height) + 1; // Extend 1 block above trunk
    }

    if (height < treeData.height) {
      canopyEnd = int32(height);
    }

    uint32 leaves;

    int32 maxDistance = canopySize ** 2;
    ObjectTypeId leafType = treeData.leafType;

    // Used for randomness
    uint256 currentSeed = uint256(keccak256(abi.encodePacked(block.timestamp, baseCoord)));

    unchecked {
      // Avoid stack too deep issues
      Vec3 coord = baseCoord;
      // Create the canopy
      for (int32 x = -canopySize; x <= canopySize; ++x) {
        for (int32 z = -canopySize; z <= canopySize; ++z) {
          // Calculate distance from center axis for a more natural, rounded shape
          int32 distanceFromCenter = x ** 2 + z ** 2;
          if (distanceFromCenter > maxDistance) {
            // Always skip if beyond maximum radius
            continue;
          }

          uint256 skipChance;

          // Skip corners and edges based on distance and randomness for a more natural look
          if (distanceFromCenter == maxDistance) {
            // At the corners (maximum distance), 75% chance to skip
            skipChance = 75;
          } else if (distanceFromCenter >= maxDistance - 1) {
            skipChance = 50;
          }

          for (int32 y = canopyStart; y < canopyEnd; ++y) {
            Vec3 leafCoord = coord + vec3(x, y, z);

            // Skip the trunk position
            if (x == 0 && z == 0 && y < int32(height)) {
              continue;
            }

            // Top layer of leaves should be smaller
            if (y >= canopyEnd - 1 && distanceFromCenter > canopySize) {
              continue;
            }

            if (skipChance != 0) {
              currentSeed = uint256(keccak256(abi.encodePacked(currentSeed)));
              if (currentSeed % 100 < skipChance) {
                continue;
              }
            }

            (EntityId leafEntityId, ObjectTypeId existingType) = getOrCreateEntityAt(leafCoord);

            // Only place leaves in air blocks
            if (existingType == ObjectTypes.Air) {
              ObjectType._set(leafEntityId, leafType);
              leaves++;
            }
          }
        }
      }
    }

    return (height, leaves);
  }

  function _growTreeTrunk(EntityId seedEntityId, Vec3 baseCoord, TreeData memory treeData) internal returns (uint32) {
    // Replace the seed with the trunk
    ObjectType._set(seedEntityId, treeData.logType);

    // Create the trunk up to available space
    for (uint32 i = 1; i < treeData.height; i++) {
      Vec3 trunkCoord = baseCoord + vec3(0, int32(i), 0);
      (EntityId trunkEntityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(trunkCoord);
      if (objectTypeId != ObjectTypes.Air) {
        return i;
      }

      ObjectType._set(trunkEntityId, treeData.logType);
    }

    return treeData.height;
  }
}
