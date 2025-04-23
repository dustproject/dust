import type { ObjectTypeName } from "../objects";
import { type Recipe, recipes, validateRecipe } from "../recipes";

function renderRecipe(recipe: Recipe): string {
  const station: ObjectTypeName = recipe.station ?? "Null";

  return `{
    uint16[] memory inputTypes = new uint16[](${recipe.inputs.length});
    uint16[] memory inputAmounts = new uint16[](${recipe.inputs.length});
    ${recipe.inputs
      .map(
        (output, i) =>
          `(inputTypes[${i}], inputAmounts[${i}]) = (ObjectTypes.${output[0]}.unwrap(), ${output[1].toString()});`,
      )
      .join("\n")}

    uint16[] memory outputTypes = new uint16[](${recipe.outputs.length});
    uint16[] memory outputAmounts = new uint16[](${recipe.outputs.length});
    ${recipe.outputs
      .map(
        (output, i) =>
          `(outputTypes[${i}], outputAmounts[${i}]) = (ObjectTypes.${output[0]}.unwrap(), ${output[1].toString()});`,
      )
      .join("\n")}


    Recipes.set(
      keccak256(abi.encode(ObjectTypes.${station}, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.${station},
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }`;
}

// Template for the Solidity file
function generateInitRecipesSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Recipes, RecipesData } from "../src/codegen/tables/Recipes.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";

function initRecipes() {
  ${recipes.map(renderRecipe).join("\n")}
}
`;
}

recipes.forEach(validateRecipe);

console.info(generateInitRecipesSol());
