import type { ObjectName } from "../objects";
import { type Recipe, recipes, validateRecipe } from "../recipes";

function renderRecipe(recipe: Recipe, index: number): string {
  const station: ObjectName = recipe.station ?? "Null";

  return `  // Recipe ${index}
  {
    uint16[] memory inputTypes = new uint16[](${recipe.inputs.length});
    uint16[] memory inputAmounts = new uint16[](${recipe.inputs.length});
    ${recipe.inputs
      .map(
        (input, i) =>
          `inputTypes[${i}] = ObjectTypes.${input[0]}.unwrap();
    inputAmounts[${i}] = ${input[1].toString()};`,
      )
      .join("\n    ")}

    uint16[] memory outputTypes = new uint16[](${recipe.outputs.length});
    uint16[] memory outputAmounts = new uint16[](${recipe.outputs.length});
    ${recipe.outputs
      .map(
        (output, i) =>
          `outputTypes[${i}] = ObjectTypes.${output[0]}.unwrap();
    outputAmounts[${i}] = ${output[1].toString()};`,
      )
      .join("\n    ")}
    
    recipes[${index}] = RecipesData({
      stationTypeId: ObjectTypes.${station},
      craftingTime: ${recipe.craftingTime ?? 0},
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }`;
}

// Template for the Solidity file
function generateGetRecipesSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { RecipesData } from "../src/codegen/tables/Recipes.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

function getRecipes() pure returns (RecipesData[] memory) {
  RecipesData[] memory recipes = new RecipesData[](${recipes.length});

${recipes.map((recipe, index) => renderRecipe(recipe, index)).join("\n\n")}

  return recipes;
}

function getRecipeId(RecipesData memory recipe) pure returns (bytes32) {
  return keccak256(
    abi.encode(
      recipe.stationTypeId,
      recipe.inputTypes,
      recipe.inputAmounts,
      recipe.outputTypes,
      recipe.outputAmounts
    )
  );
}
`;
}

recipes.forEach(validateRecipe);

console.info(generateGetRecipesSol());
