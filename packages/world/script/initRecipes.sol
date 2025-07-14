// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Recipes, RecipesData } from "../src/codegen/tables/Recipes.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";

function initRecipes() {
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.OakLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OakPlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BirchLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BirchPlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.JungleLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.JunglePlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.SakuraLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SakuraPlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AcaciaLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.AcaciaPlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.SpruceLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SprucePlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.DarkOakLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.DarkOakPlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.MangroveLog.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MangrovePlanks.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyLog.unwrap(), 5);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Battery.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Powerstone, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Powerstone,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyLeaf.unwrap(), 90);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Battery.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Powerstone, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Powerstone,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.IronOre.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.IronBar.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GoldOre.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GoldBar.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.DiamondOre.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Diamond.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.NeptuniumOre.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.NeptuniumBar.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.CopperOre.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CopperBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.IronBar.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.IronBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GoldBar.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GoldBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Diamond.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.DiamondBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.NeptuniumBar.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.NeptuniumBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 9);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Furnace.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 4);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Workbench.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 6);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Sand.unwrap(), 2);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Powerstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 30);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ForceField.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 8);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Chest.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 4);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.TextSign.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.ForceField.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 8);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SpawnTile.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Bed.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 5);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WoodenPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 5);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WoodenAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 8);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WoodenWhacker.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 4);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WoodenHoe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CopperOre.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CopperPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CopperOre.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CopperAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CopperOre.unwrap(), 6);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CopperWhacker.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.IronPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.IronAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 6);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.IronWhacker.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.GoldBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GoldPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.GoldBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GoldAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Diamond.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.DiamondPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Diamond.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.DiamondAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.NeptuniumBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.NeptuniumPick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 2);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.NeptuniumBar.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.NeptuniumAxe.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Wheat.unwrap(), 16);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WheatSlop.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Pumpkin.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PumpkinSoup.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Melon.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MelonSmoothie.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Torch.unwrap(), 4);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Mud.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.FescueGrass.unwrap(), 5);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PackedMud.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PackedMud.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MudBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.IronBar.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Stone.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Stonecutter.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BambooBush.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Paper.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Clay.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Brick.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Brick.unwrap(), 4);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrickBlock.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.AnyPlank.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Stick.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RoseFlower.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedMushroom.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.SunFlower.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.DandelionFlower.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Ultraviolet.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlueDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.SwitchGrass.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GreenDye.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.FescueGrass.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GreenDye.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Bone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WhiteDye.unwrap(), 3);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlackDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BrownMushroomBlock.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GreenDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.RedDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.YellowDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OrangeDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PinkDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GreenDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LimeDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BlueDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.GreenDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CyanDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BlackDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GrayDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PurpleDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PurpleDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.PinkDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MagentaDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BlueDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightBlueDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GrayDye.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightGrayDye.unwrap(), 2);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WhiteConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.OrangeDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OrangeConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.MagentaDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MagentaConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.YellowDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.LightBlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightBlueConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.LimeDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LimeConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.PinkDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PinkConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.GrayDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GrayConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.LightGrayDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightGrayConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.CyanDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CyanConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.PurpleDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PurpleConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.BlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlueConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.BrownDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.GreenDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GreenConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.RedDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sand.unwrap(), 4);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Gravel.unwrap(), 4);
    (inputTypes[2], inputAmounts[2]) = (ObjectTypes.BlackDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlackConcretePowder.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.WhiteConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WhiteConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.OrangeConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OrangeConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.MagentaConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MagentaConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.LightBlueConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightBlueConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.YellowConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.LimeConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LimeConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PinkConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PinkConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GrayConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GrayConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.LightGrayConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightGrayConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.CyanConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CyanConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PurpleConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PurpleConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BlueConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlueConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BrownConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.GreenConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GreenConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.BlackConcretePowder.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WaterBucket.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlackConcrete.unwrap(), 1);
    (outputTypes[1], outputAmounts[1]) = (ObjectTypes.Bucket.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.StoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Tuff.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.TuffBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.CobbledDeepslate.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.DeepslateBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Andesite.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedAndesite.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Granite.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedGranite.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Diorite.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedDiorite.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Tuff.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedTuff.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Basalt.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedBasalt.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Blackstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedBlackstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.StoneBricks.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledStoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.TuffBricks.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledTuffBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.DeepslateBricks.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledDeepslate.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PolishedBlackstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledPolishedBlackstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedSandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.ChiseledRedSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Deepslate.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedDeepslate.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PolishedBlackstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PolishedBlackstoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CutSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedSandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CutRedSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.StoneBricks.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CrackedStoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.TuffBricks.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CrackedTuffBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.DeepslateBricks.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CrackedDeepslateBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.PolishedBlackstoneBricks.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CoalOre.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CrackedPolishedBlackstoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Furnace, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Furnace,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Sandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SmoothSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.RedSandstone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SmoothRedSandstone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.SmoothStone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Stonecutter, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Stonecutter,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.StoneBricks.unwrap(), 1);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.Moss.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MossyStoneBricks.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BrownDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.OrangeDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OrangeTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WhiteTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.YellowDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.RedDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CyanDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CyanTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BlackDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlackTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.PurpleDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PurpleTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlueTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.MagentaDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MagentaTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.LightGrayDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightGrayTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Terracotta.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.LightBlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightBlueTerracotta.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.WhiteDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.WhiteGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.OrangeDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.OrangeGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.MagentaDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.MagentaGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.LightBlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightBlueGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.YellowDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.YellowGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.LimeDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LimeGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.PinkDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PinkGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.GrayDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GrayGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.LightGrayDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.LightGrayGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.CyanDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.CyanGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.PurpleDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.PurpleGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BlueDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlueGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BrownDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BrownGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.GreenDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GreenGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.RedDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.RedGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.BlackDye.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.BlackGlass.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Glass.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.GlassPane.unwrap(), 8);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Workbench,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Brick.unwrap(), 3);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.FlowerPot.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    (inputTypes[0], inputAmounts[0]) = (ObjectTypes.Stone.unwrap(), 8);
    (inputTypes[1], inputAmounts[1]) = (ObjectTypes.IronBar.unwrap(), 1);

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    (outputTypes[0], outputAmounts[0]) = (ObjectTypes.Lodestone.unwrap(), 1);

    Recipes.set(
      keccak256(abi.encode(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts)),
      ObjectTypes.Null,
      0,
      inputTypes,
      inputAmounts,
      outputTypes,
      outputAmounts
    );
  }
}
