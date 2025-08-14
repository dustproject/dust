import { biomes } from "../biomes";
import { categories } from "../objects";

// Generate the BiomesLib.sol file from biomes data
function generateBiomesLibSol(): string {
  const oreTypes = categories.Ore.objects;

  // Generate the biome multiplier cases
  const biomeMultiplierCases = biomes
    .filter((biome) =>
      biome.oreMultipliers.some(([, multiplier]) => multiplier > 0),
    )
    .map((biome) => {
      const multipliers = biome.oreMultipliers
        .map(([oreType, multiplier]) =>
          oreType === "CoalOre"
            ? `uint256(${multiplier.toString()})`
            : multiplier.toString(),
        )
        .join(", ");
      return `    // biomeIndex == ${biome.id}: ${biome.name}
    ${biome.id === 0 ? "if" : "else if"} (biomeIndex == ${biome.id}) return [${multipliers}];`;
    })
    .join("\n");

  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

library BiomesLib {
  function getOreMultipliers(uint8 biomeIndex) public pure returns (uint256[${oreTypes.length}] memory) {
${biomeMultiplierCases}

    revert("Invalid biome index");
  }
}
`;
}

console.info(generateBiomesLibSol());
