// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { useEquipped } from "../utils/InventoryUtils.sol";
import { getOrCreateEntityAt, getObjectTypeIdAt } from "../utils/EntityUtils.sol";
import { addEnergyToLocalPool, transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectTypeLib, TreeData } from "../ObjectTypeLib.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { Vec3, vec3 } from "../Vec3.sol";
import { TILL_ENERGY_COST } from "../Constants.sol";

contract FarmingSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function till(EntityId callerEntityId, Vec3 coord) external {
    callerEntityId.activate();
    callerEntityId.requireConnected(coord);

    (EntityId farmlandEntityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(coord);
    require(objectTypeId == ObjectTypes.Dirt || objectTypeId == ObjectTypes.Grass, "Not dirt or grass");
    (, ObjectTypeId toolObjectTypeId) = useEquipped(callerEntityId, type(uint128).max);
    require(toolObjectTypeId.isHoe(), "Must equip a hoe");

    FarmingLib._processEnergyReduction(callerEntityId);

    ObjectType._set(farmlandEntityId, ObjectTypes.Farmland);
  }

  function growSeed(EntityId callerEntityId, Vec3 coord) external {
    callerEntityId.activate();
    // TODO: should we do proximity checks?

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

      // Grow the tree (replace the seed with the trunk and add blocks)
      (uint32 trunkHeight, uint32 leaves) = FarmingLib._growTree(seedEntityId, coord, treeData);

      // Seed energy is the sum of the energy of all the blocks of the tree
      uint32 seedEnergy = ObjectTypeMetadata._getEnergy(objectTypeId);

      uint32 trunkEnergy = trunkHeight * ObjectTypeMetadata._getEnergy(treeData.logType);
      uint32 leafEnergy = leaves * ObjectTypeMetadata._getEnergy(treeData.leafType);

      uint32 energyToReturn = seedEnergy - trunkEnergy - leafEnergy;
      if (energyToReturn > 0) {
        addEnergyToLocalPool(coord, energyToReturn);
      }
    }
  }
}

library FarmingLib {
  function _processEnergyReduction(EntityId callerEntityId) public {
    transferEnergyToPool(callerEntityId, TILL_ENERGY_COST);
  }

  function _growTree(EntityId seedEntityId, Vec3 baseCoord, TreeData memory treeData) public returns (uint32, uint32) {
    uint32 trunkHeight = _growTreeTrunk(seedEntityId, baseCoord, treeData);

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

            currentSeed = uint256(keccak256(abi.encodePacked(currentSeed)));
            if (currentSeed % 100 < 40) {
              continue;
            }
          }

          (EntityId leafEntityId, ObjectTypeId existingType) = getOrCreateEntityAt(coord + vec3(x, y, z));

          // Only place leaves in air blocks
          if (existingType == ObjectTypes.Air) {
            ObjectType._set(leafEntityId, leafType);
            leaves++;
          }
        }
      }
    }

    return (trunkHeight, leaves);
  }

  function _growTreeTrunk(EntityId seedEntityId, Vec3 baseCoord, TreeData memory treeData) internal returns (uint32) {
    // Replace the seed with the trunk
    ObjectType._set(seedEntityId, treeData.logType);

    // Create the trunk up to available space
    for (uint32 i = 1; i < treeData.trunkHeight; i++) {
      Vec3 trunkCoord = baseCoord + vec3(0, int32(i), 0);
      (EntityId trunkEntityId, ObjectTypeId objectTypeId) = getOrCreateEntityAt(trunkCoord);
      if (objectTypeId != ObjectTypes.Air) {
        return i;
      }

      ObjectType._set(trunkEntityId, treeData.logType);
    }

    return treeData.trunkHeight;
  }
}
