// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { TerrainLib } from "../systems/libraries/TerrainLib.sol";

import { PRECISION_MULTIPLIER } from "../Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "../types/ObjectType.sol";

import { BiomesLib } from "./BiomesLib.sol";
import { NatureLib } from "./NatureLib.sol";
import { RandomLib } from "./RandomLib.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";

library OreLib {
  function getRandomOre(Vec3 coord) internal view returns (ObjectType) {
    uint256 randomSeed = NatureLib.getRandomSeed(coord);

    // Get ore options and their weights (based on remaining amounts and multipliers)
    ObjectType[6] memory oreTypes = ObjectTypeLib.getOreTypes();

    uint8 biome = TerrainLib._getBiome(coord);
    uint256[6] memory biomeMultipliers = BiomesLib.getOreMultipliers(biome);

    uint256[] memory weights = new uint256[](oreTypes.length);

    for (uint256 i = 0; i < oreTypes.length; i++) {
      (uint256 cap, uint256 remaining) = NatureLib.getCapAndRemaining(oreTypes[i]);
      weights[i] = biomeMultipliers[i] * remaining * PRECISION_MULTIPLIER / cap;
    }

    // Select ore based on availability
    return oreTypes[RandomLib.selectByWeight(weights, randomSeed)];
  }

  function burnOre(ObjectType self, uint256 amount) internal {
    uint256 resourceCount = ResourceCount._get(self);

    require(resourceCount >= amount, "Not enough resources to burn");
    // This increases the availability of the ores being burned
    ResourceCount._set(self, resourceCount - amount);

    // This allows the same amount of ores to respawn
    BurnedResourceCount._set(ObjectTypes.UnrevealedOre, BurnedResourceCount._get(ObjectTypes.UnrevealedOre) + amount);
  }

  function burnOres(ObjectType self) internal {
    ObjectAmount memory oreAmount = self.getOreAmount();
    if (!oreAmount.objectType.isNull()) {
      burnOre(oreAmount.objectType, oreAmount.amount);
    }
  }
}
