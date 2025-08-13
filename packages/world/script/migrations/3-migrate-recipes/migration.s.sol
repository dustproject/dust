// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { IndexerResult } from "../../utils/indexer.sol";

import { Recipes, RecipesData } from "../../../src/codegen/tables/Recipes.sol";
import { getRecipeId, getRecipes } from "../../getRecipes.sol";

import { Migration } from "../Migration.sol";

contract MigrateRecipes is Migration {
  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("3-migrate-recipes");
  }

  function runMigration() internal override {
    // Get all new recipes from getRecipes
    RecipesData[] memory newRecipes = getRecipes();
    console.log("Total new recipes defined:", newRecipes.length);

    // Build array of new recipe IDs for tracking
    bytes32[] memory newRecipeIds = new bytes32[](newRecipes.length);

    for (uint256 i = 0; i < newRecipes.length; i++) {
      newRecipeIds[i] = getRecipeId(newRecipes[i]);
    }

    // Build NOT IN clause for SQL query to find recipes to delete
    string memory newRecipeIdsStr = "";
    for (uint256 i = 0; i < newRecipeIds.length; i++) {
      newRecipeIdsStr =
        string.concat(newRecipeIdsStr, "decode('", vm.replace(vm.toString(newRecipeIds[i]), "0x", ""), "', 'hex')");
      if (i < newRecipeIds.length - 1) {
        newRecipeIdsStr = string.concat(newRecipeIdsStr, ", ");
      }
    }

    // Query recipes that exist in the table but not in new recipes (to be deleted)
    console.log("\nQuerying recipes to delete...");
    string memory deleteQuery =
      string.concat("SELECT recipeId FROM Recipes WHERE recipeId NOT IN (", newRecipeIdsStr, ") ORDER BY recipeId;");

    IndexerResult memory recipesToDeleteResult = recordingQueryNoResults(deleteQuery, "(bytes32)");
    console.log("Recipes to delete:", recipesToDeleteResult.rows.length);

    // Delete obsolete recipes
    if (recipesToDeleteResult.rows.length > 0) {
      console.log("\nDeleting outdated recipes...");
      for (uint256 i = 0; i < recipesToDeleteResult.rows.length; i++) {
        bytes32 recipeId = abi.decode(recipesToDeleteResult.rows[i], (bytes32));
        console.log("Deleting recipe:", vm.toString(recipeId));

        recordChange("Delete outdated recipe", "Recipes", vm.toString(recipeId), "exists", "deleted");

        Recipes.deleteRecord(recipeId);
      }
    }

    // Process new recipes - single loop to check and set
    console.log("\nProcessing new recipes...");
    uint256 addedCount = 0;
    uint256 skippedCount = 0;

    for (uint256 i = 0; i < newRecipes.length; i++) {
      bytes32 recipeId = newRecipeIds[i];

      // Check if recipe already exists by checking if it has data
      // A recipe exists if it has at least one input defined
      if (Recipes.lengthInputAmounts(recipeId) > 0) {
        // Recipe already exists, skip it
        skippedCount++;
      } else {
        // Recipe doesn't exist, add it
        addedCount++;
        console.log("Adding new recipe:", vm.toString(recipeId));

        recordChange("Add new recipe", "Recipes", vm.toString(recipeId), "null", "added");

        Recipes.set(recipeId, newRecipes[i]);
      }
    }

    // Summary
    console.log("\nRecipe migration complete!");
    console.log("Recipes added:", addedCount);
    console.log("Recipes skipped (already exist):", skippedCount);
    console.log("Recipes deleted:", recipesToDeleteResult.rows.length);
    console.log("Total recipes after migration:", newRecipes.length);
  }
}
