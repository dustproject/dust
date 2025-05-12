// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";
import { Recipes, RecipesData } from "../src/codegen/tables/Recipes.sol";

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
}
