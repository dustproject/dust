import { biomes } from "../biomes";
import { categories } from "../objects";

// Generate the OreLib.sol file from biomes data
function generateOreLibSol(): string {
  const oreTypes = categories.Ore.objects;

  // Generate the biome multiplier cases
  const biomeMultiplierCases = biomes
    .filter((biome) =>
      biome.oreMultipliers.some(([, multiplier]) => multiplier > 0),
    )
    .map((biome) => {
      const multipliers = biome.oreMultipliers
        .map(([oreType, multiplier]) => `uint256(${multiplier.toString()})`)
        .join(", ");
      return `    // biomeIndex == ${biome.id}: ${biome.name}
    ${biome.id === 0 ? "if" : "else if"} (biomeIndex == ${biome.id}) return [${multipliers}];`;
    })
    .join("\n");

  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { TerrainLib } from "../systems/libraries/TerrainLib.sol";
import { ChunkCommitment } from "./Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_COAL,
  MAX_COPPER,
  MAX_DIAMOND,
  MAX_GOLD,
  MAX_IRON,
  MAX_NEPTUNIUM,
  PRECISION_MULTIPLIER
} from "../Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "../types/ObjectType.sol";

import { NatureLib } from "./NatureLib.sol";
import { RandomLib } from "./RandomLib.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";

library OreLib {
  function getRandomOre(Vec3 coord) internal view returns (ObjectType) {
    uint256 randomSeed = NatureLib.getRandomSeed(coord);

    // Get ore options and their weights (based on remaining amounts and multipliers)
    ObjectType[${oreTypes.length}] memory oreTypes = ObjectTypeLib.getOreTypes();

    uint8 biome = TerrainLib._getBiome(coord);
    uint256[${oreTypes.length}] memory biomeMultipliers = _getBiomeMultipliers(biome);

    uint256[] memory weights = new uint256[](oreTypes.length);

    for (uint256 i = 0; i < oreTypes.length; i++) {
      (uint256 cap, uint256 remaining) = NatureLib.getCapAndRemaining(oreTypes[i]);
      weights[i] = biomeMultipliers[i] * remaining * PRECISION_MULTIPLIER / cap;
    }

    // Select ore based on availability
    return oreTypes[RandomLib.selectByWeight(weights, randomSeed)];
  }

  function _getBiomeMultipliers(uint8 biomeIndex) public pure returns (uint256[${oreTypes.length}] memory) {
${biomeMultiplierCases}

    revert("Invalid biome index");
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
}
`;
}

console.info(generateOreLibSol());
