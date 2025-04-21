// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { addEnergyToLocalPool, transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { getObjectTypeAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { TILL_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";
import { ObjectTypeLib, TreeData } from "../ObjectTypeLib.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract FarmingSystem is System {
  using ObjectTypeLib for ObjectType;

  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    caller.activate();
    (Vec3 callerCoord,) = caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = getOrCreateEntityAt(coord);
    require(objectType == ObjectTypes.Dirt || objectType == ObjectTypes.Grass, "Not dirt or grass");

    // If player died, return early
    uint128 callerEnergy = FarmingLib._processEnergyReduction(caller);
    if (callerEnergy == 0) {
      return;
    }

    ObjectType toolType = InventoryUtils.useTool(caller, callerCoord, toolSlot, type(uint128).max);
    require(toolType.isHoe(), "Must equip a hoe");

    EntityObjectType._set(farmland, ObjectTypes.Farmland);
  }

  function growSeed(EntityId caller, Vec3 coord) external {
    caller.activate();
    // TODO: should we do proximity checks?

    (EntityId seed, ObjectType objectType) = getOrCreateEntityAt(coord);
    require(objectType.isSeed(), "Not a seed");

    require(SeedGrowth._getFullyGrownAt(seed) <= block.timestamp, "Seed cannot be grown yet");

    // When a seed grows, it's removed from circulation
    // We only update ResourceCount since seeds don't participate in respawning (no need to track positions
    uint256 seedCount = ResourceCount._get(objectType);
    // This should never happen if there are seeds in the world obtained from drops
    require(seedCount > 0, "Not enough seeds in circulation");
    ResourceCount._set(objectType, seedCount - 1);

    if (objectType.isCropSeed()) {
      // Turn wet farmland to regular farmland if mining a seed or crop
      (EntityId below, ObjectType belowTypeId) = getOrCreateEntityAt(coord - vec3(0, 1, 0));
      // Sanity check
      if (belowTypeId == ObjectTypes.WetFarmland) {
        EntityObjectType._set(below, ObjectTypes.Farmland);
      }

      EntityObjectType._set(seed, objectType.getCrop());
    } else if (objectType.isTreeSeed()) {
      TreeData memory treeData = objectType.getTreeData();

      // Grow the tree (replace the seed with the trunk and add blocks)
      (uint32 trunkHeight, uint32 leaves) = FarmingLib._growTree(seed, coord, treeData);

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

library FarmingLib {
  function _processEnergyReduction(EntityId caller) public returns (uint128) {
    (uint128 callerEnergy,) = transferEnergyToPool(caller, TILL_ENERGY_COST);
    return callerEnergy;
  }

  function _growTree(EntityId seed, Vec3 baseCoord, TreeData memory treeData) public returns (uint32, uint32) {
    uint32 trunkHeight = _growTreeTrunk(seed, baseCoord, treeData);

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
    uint256 currentSeed = uint256(keccak256(abi.encodePacked(block.timestamp, baseCoord)));

    ObjectType leafType = treeData.leafType;

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

            currentSeed = uint256(keccak256(abi.encodePacked(currentSeed)));
            if (currentSeed % 100 < 40) {
              continue;
            }
          }

          (EntityId leaf, ObjectType existingType) = getOrCreateEntityAt(coord + vec3(x, y, z));

          // Only place leaves in air blocks
          if (existingType == ObjectTypes.Air) {
            EntityObjectType._set(leaf, leafType);
            leaves++;
          }
        }
      }
    }

    return (trunkHeight, leaves);
  }

  function _growTreeTrunk(EntityId seed, Vec3 baseCoord, TreeData memory treeData) internal returns (uint32) {
    // Replace the seed with the trunk
    EntityObjectType._set(seed, treeData.logType);

    // Create the trunk up to available space
    for (uint32 i = 1; i < treeData.trunkHeight; i++) {
      Vec3 trunkCoord = baseCoord + vec3(0, int32(i), 0);
      (EntityId trunk, ObjectType objectType) = getOrCreateEntityAt(trunkCoord);
      if (objectType != ObjectTypes.Air) {
        return i;
      }

      EntityObjectType._set(trunk, treeData.logType);
    }

    return treeData.trunkHeight;
  }
}
