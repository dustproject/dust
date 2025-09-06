// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Recipes, RecipesData } from "../src/codegen/tables/Recipes.sol";
import { getRecipeId, getRecipes } from "./getRecipes.sol";

function initRecipes() {
  RecipesData[] memory recipes = getRecipes();

  for (uint256 i = 0; i < recipes.length; ++i) {
    RecipesData memory recipe = recipes[i];
    Recipes.set(getRecipeId(recipe), recipe);
  }
}
