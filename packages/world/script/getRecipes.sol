// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { RecipesData } from "../src/codegen/tables/Recipes.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

function getRecipes() pure returns (RecipesData[] memory) {
  RecipesData[] memory recipes = new RecipesData[](160);

  // Recipe 0
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.OakLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.OakPlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[0] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 1
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.BirchLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BirchPlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[1] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 2
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.JungleLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.JunglePlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[2] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 3
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.SakuraLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SakuraPlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[3] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 4
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AcaciaLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.AcaciaPlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[4] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 5
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.SpruceLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SprucePlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[5] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 6
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.DarkOakLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.DarkOakPlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[6] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 7
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.MangroveLog.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MangrovePlanks.unwrap();
    outputAmounts[0] = 4;

    recipes[7] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 8
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyLog.unwrap();
    inputAmounts[0] = 5;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Battery.unwrap();
    outputAmounts[0] = 1;

    recipes[8] = RecipesData({
      stationTypeId: ObjectTypes.Powerstone,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 9
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyLeaf.unwrap();
    inputAmounts[0] = 90;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Battery.unwrap();
    outputAmounts[0] = 1;

    recipes[9] = RecipesData({
      stationTypeId: ObjectTypes.Powerstone,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 10
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.IronOre.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.IronBar.unwrap();
    outputAmounts[0] = 1;

    recipes[10] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 11
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GoldOre.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GoldBar.unwrap();
    outputAmounts[0] = 1;

    recipes[11] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 12
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.DiamondOre.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Diamond.unwrap();
    outputAmounts[0] = 1;

    recipes[12] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 13
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.NeptuniumOre.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.NeptuniumBar.unwrap();
    outputAmounts[0] = 1;

    recipes[13] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 14
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.CopperOre.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CopperBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[14] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 15
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.IronBar.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.IronBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[15] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 16
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.GoldBar.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GoldBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[16] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 17
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Diamond.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.DiamondBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[17] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 18
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.NeptuniumBar.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.NeptuniumBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[18] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 19
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 9;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Furnace.unwrap();
    outputAmounts[0] = 1;

    recipes[19] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 20
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 4;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Workbench.unwrap();
    outputAmounts[0] = 1;

    recipes[20] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 21
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 6;
    inputTypes[1] = ObjectTypes.Sand.unwrap();
    inputAmounts[1] = 2;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Powerstone.unwrap();
    outputAmounts[0] = 1;

    recipes[21] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 22
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 30;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ForceField.unwrap();
    outputAmounts[0] = 1;

    recipes[22] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 23
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 8;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Chest.unwrap();
    outputAmounts[0] = 1;

    recipes[23] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 24
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 4;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.TextSign.unwrap();
    outputAmounts[0] = 1;

    recipes[24] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 25
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.ForceField.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 8;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SpawnTile.unwrap();
    outputAmounts[0] = 1;

    recipes[25] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 26
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Bed.unwrap();
    outputAmounts[0] = 1;

    recipes[26] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 27
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 5;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WoodenPick.unwrap();
    outputAmounts[0] = 1;

    recipes[27] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 28
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 5;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WoodenAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[28] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 29
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 8;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WoodenWhacker.unwrap();
    outputAmounts[0] = 1;

    recipes[29] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 30
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 4;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WoodenHoe.unwrap();
    outputAmounts[0] = 1;

    recipes[30] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 31
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.CopperOre.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CopperPick.unwrap();
    outputAmounts[0] = 1;

    recipes[31] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 32
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.CopperOre.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CopperAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[32] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 33
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.CopperOre.unwrap();
    inputAmounts[1] = 6;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CopperWhacker.unwrap();
    outputAmounts[0] = 1;

    recipes[33] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 34
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.IronPick.unwrap();
    outputAmounts[0] = 1;

    recipes[34] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 35
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.IronAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[35] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 36
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 6;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.IronWhacker.unwrap();
    outputAmounts[0] = 1;

    recipes[36] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 37
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.GoldBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GoldPick.unwrap();
    outputAmounts[0] = 1;

    recipes[37] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 38
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.GoldBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GoldAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[38] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 39
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.Diamond.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.DiamondPick.unwrap();
    outputAmounts[0] = 1;

    recipes[39] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 40
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.Diamond.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.DiamondAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[40] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 41
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.NeptuniumBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.NeptuniumPick.unwrap();
    outputAmounts[0] = 1;

    recipes[41] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 42
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 2;
    inputTypes[1] = ObjectTypes.NeptuniumBar.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.NeptuniumAxe.unwrap();
    outputAmounts[0] = 1;

    recipes[42] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 43
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Bucket.unwrap();
    outputAmounts[0] = 1;

    recipes[43] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 44
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Wheat.unwrap();
    inputAmounts[0] = 16;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WheatSlop.unwrap();
    outputAmounts[0] = 1;

    recipes[44] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 45
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Pumpkin.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PumpkinSoup.unwrap();
    outputAmounts[0] = 1;

    recipes[45] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 46
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Melon.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MelonSmoothie.unwrap();
    outputAmounts[0] = 1;

    recipes[46] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 47
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Torch.unwrap();
    outputAmounts[0] = 4;

    recipes[47] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 48
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Mud.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.FescueGrass.unwrap();
    inputAmounts[1] = 5;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PackedMud.unwrap();
    outputAmounts[0] = 1;

    recipes[48] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 49
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.PackedMud.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MudBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[49] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 50
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.IronBar.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.Stone.unwrap();
    inputAmounts[1] = 3;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Stonecutter.unwrap();
    outputAmounts[0] = 1;

    recipes[50] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 51
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.BambooBush.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Paper.unwrap();
    outputAmounts[0] = 1;

    recipes[51] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 52
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Glass.unwrap();
    outputAmounts[0] = 1;

    recipes[52] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 53
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Clay.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Brick.unwrap();
    outputAmounts[0] = 1;

    recipes[53] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 54
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Basalt.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SmoothBasalt.unwrap();
    outputAmounts[0] = 1;

    recipes[54] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 55
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Brick.unwrap();
    inputAmounts[0] = 4;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BrickBlock.unwrap();
    outputAmounts[0] = 1;

    recipes[55] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 56
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.AnyPlank.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Stick.unwrap();
    outputAmounts[0] = 2;

    recipes[56] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 57
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.RoseFlower.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.RedDye.unwrap();
    outputAmounts[0] = 2;

    recipes[57] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 58
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.RedMushroom.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.RedDye.unwrap();
    outputAmounts[0] = 2;

    recipes[58] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 59
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.SunFlower.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.YellowDye.unwrap();
    outputAmounts[0] = 2;

    recipes[59] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 60
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.DandelionFlower.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.YellowDye.unwrap();
    outputAmounts[0] = 2;

    recipes[60] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 61
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Ultraviolet.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlueDye.unwrap();
    outputAmounts[0] = 2;

    recipes[61] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 62
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.SwitchGrass.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GreenDye.unwrap();
    outputAmounts[0] = 1;

    recipes[62] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 63
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.FescueGrass.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GreenDye.unwrap();
    outputAmounts[0] = 1;

    recipes[63] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 64
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Bone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WhiteDye.unwrap();
    outputAmounts[0] = 3;

    recipes[64] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 65
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlackDye.unwrap();
    outputAmounts[0] = 2;

    recipes[65] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 66
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.RedDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BrownDye.unwrap();
    outputAmounts[0] = 2;

    recipes[66] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 67
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.RedDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.YellowDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.OrangeDye.unwrap();
    outputAmounts[0] = 2;

    recipes[67] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 68
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.RedDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PinkDye.unwrap();
    outputAmounts[0] = 2;

    recipes[68] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 69
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LimeDye.unwrap();
    outputAmounts[0] = 2;

    recipes[69] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 70
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CyanDye.unwrap();
    outputAmounts[0] = 2;

    recipes[70] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 71
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BlackDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GrayDye.unwrap();
    outputAmounts[0] = 2;

    recipes[71] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 72
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.RedDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PurpleDye.unwrap();
    outputAmounts[0] = 2;

    recipes[72] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 73
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.PurpleDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.PinkDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MagentaDye.unwrap();
    outputAmounts[0] = 2;

    recipes[73] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 74
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightBlueDye.unwrap();
    outputAmounts[0] = 2;

    recipes[74] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 75
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GrayDye.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightGrayDye.unwrap();
    outputAmounts[0] = 2;

    recipes[75] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 76
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WhiteConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[76] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 77
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.OrangeDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.OrangeConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[77] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 78
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.MagentaDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MagentaConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[78] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 79
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.YellowDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.YellowConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[79] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 80
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.LightBlueDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightBlueConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[80] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 81
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.LimeDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LimeConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[81] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 82
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.PinkDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PinkConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[82] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 83
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.GrayDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GrayConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[83] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 84
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.LightGrayDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightGrayConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[84] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 85
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.CyanDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CyanConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[85] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 86
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.PurpleDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PurpleConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[86] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 87
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlueConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[87] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 88
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.BrownDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BrownConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[88] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 89
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GreenConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[89] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 90
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.RedDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.RedConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[90] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 91
  {
    uint16[] memory inputTypes = new uint16[](3);
    uint16[] memory inputAmounts = new uint16[](3);
    inputTypes[0] = ObjectTypes.Sand.unwrap();
    inputAmounts[0] = 4;
    inputTypes[1] = ObjectTypes.Gravel.unwrap();
    inputAmounts[1] = 4;
    inputTypes[2] = ObjectTypes.BlackDye.unwrap();
    inputAmounts[2] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlackConcretePowder.unwrap();
    outputAmounts[0] = 8;

    recipes[91] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 92
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.WhiteConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.WhiteConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[92] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 93
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.OrangeConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.OrangeConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[93] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 94
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.MagentaConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.MagentaConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[94] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 95
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.LightBlueConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.LightBlueConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[95] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 96
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.YellowConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.YellowConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[96] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 97
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.LimeConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.LimeConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[97] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 98
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.PinkConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.PinkConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[98] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 99
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GrayConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.GrayConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[99] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 100
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.LightGrayConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.LightGrayConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[100] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 101
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.CyanConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.CyanConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[101] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 102
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.PurpleConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.PurpleConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[102] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 103
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BlueConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.BlueConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[103] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 104
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BrownConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.BrownConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[104] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 105
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.GreenConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.GreenConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[105] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 106
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.RedConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.RedConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[106] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 107
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.BlackConcretePowder.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.WaterBucket.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](2);
    uint16[] memory outputAmounts = new uint16[](2);
    outputTypes[0] = ObjectTypes.BlackConcrete.unwrap();
    outputAmounts[0] = 1;
    outputTypes[1] = ObjectTypes.Bucket.unwrap();
    outputAmounts[1] = 1;

    recipes[107] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 108
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.StoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[108] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 109
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Tuff.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.TuffBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[109] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 110
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.CobbledDeepslate.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.DeepslateBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[110] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 111
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Andesite.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedAndesite.unwrap();
    outputAmounts[0] = 1;

    recipes[111] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 112
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Granite.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedGranite.unwrap();
    outputAmounts[0] = 1;

    recipes[112] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 113
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Diorite.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedDiorite.unwrap();
    outputAmounts[0] = 1;

    recipes[113] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 114
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Tuff.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedTuff.unwrap();
    outputAmounts[0] = 1;

    recipes[114] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 115
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Basalt.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedBasalt.unwrap();
    outputAmounts[0] = 1;

    recipes[115] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 116
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Blackstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedBlackstone.unwrap();
    outputAmounts[0] = 1;

    recipes[116] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 117
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.StoneBricks.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledStoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[117] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 118
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.TuffBricks.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledTuffBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[118] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 119
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.DeepslateBricks.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledDeepslate.unwrap();
    outputAmounts[0] = 1;

    recipes[119] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 120
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.PolishedBlackstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledPolishedBlackstone.unwrap();
    outputAmounts[0] = 1;

    recipes[120] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 121
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Sandstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[121] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 122
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.RedSandstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.ChiseledRedSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[122] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 123
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Deepslate.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedDeepslate.unwrap();
    outputAmounts[0] = 1;

    recipes[123] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 124
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.PolishedBlackstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PolishedBlackstoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[124] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 125
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.Sandstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CutSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[125] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 126
  {
    uint16[] memory inputTypes = new uint16[](1);
    uint16[] memory inputAmounts = new uint16[](1);
    inputTypes[0] = ObjectTypes.RedSandstone.unwrap();
    inputAmounts[0] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CutRedSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[126] = RecipesData({
      stationTypeId: ObjectTypes.Stonecutter,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 127
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.StoneBricks.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CrackedStoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[127] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 128
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.DeepslateBricks.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CrackedDeepslateBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[128] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 129
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.PolishedBlackstoneBricks.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CrackedPolishedBlackstoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[129] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 130
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Sandstone.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SmoothSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[130] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 131
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.RedSandstone.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SmoothRedSandstone.unwrap();
    outputAmounts[0] = 1;

    recipes[131] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 132
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.CoalOre.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.SmoothStone.unwrap();
    outputAmounts[0] = 1;

    recipes[132] = RecipesData({
      stationTypeId: ObjectTypes.Furnace,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 133
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.StoneBricks.unwrap();
    inputAmounts[0] = 1;
    inputTypes[1] = ObjectTypes.Moss.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MossyStoneBricks.unwrap();
    outputAmounts[0] = 1;

    recipes[133] = RecipesData({
      stationTypeId: ObjectTypes.Null,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 134
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.BrownDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BrownTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[134] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 135
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.OrangeDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.OrangeTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[135] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 136
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WhiteTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[136] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 137
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.YellowDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.YellowTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[137] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 138
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.RedDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.RedTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[138] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 139
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.CyanDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.CyanTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[139] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 140
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.BlackDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlackTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[140] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 141
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.PurpleDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PurpleTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[141] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 142
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlueTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[142] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 143
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.MagentaDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.MagentaTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[143] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 144
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.LightGrayDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightGrayTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[144] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 145
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.LightBlueDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LightBlueTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[145] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 146
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GreenTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[146] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 147
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.PinkDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PinkTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[147] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 148
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.LimeDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.LimeTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[148] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 149
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Terracotta.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.GrayDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GrayTerracotta.unwrap();
    outputAmounts[0] = 8;

    recipes[149] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 150
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.WhiteDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.WhiteGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[150] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 151
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.OrangeDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.OrangeGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[151] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 152
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.YellowDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.YellowGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[152] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 153
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.PinkDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PinkGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[153] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 154
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.PurpleDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.PurpleGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[154] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 155
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.BlueDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlueGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[155] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 156
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.GreenDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.GreenGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[156] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 157
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.RedDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.RedGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[157] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 158
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Glass.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.BlackDye.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.BlackGlass.unwrap();
    outputAmounts[0] = 8;

    recipes[158] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  // Recipe 159
  {
    uint16[] memory inputTypes = new uint16[](2);
    uint16[] memory inputAmounts = new uint16[](2);
    inputTypes[0] = ObjectTypes.Stone.unwrap();
    inputAmounts[0] = 8;
    inputTypes[1] = ObjectTypes.IronBar.unwrap();
    inputAmounts[1] = 1;

    uint16[] memory outputTypes = new uint16[](1);
    uint16[] memory outputAmounts = new uint16[](1);
    outputTypes[0] = ObjectTypes.Lodestone.unwrap();
    outputAmounts[0] = 1;

    recipes[159] = RecipesData({
      stationTypeId: ObjectTypes.Workbench,
      craftingTime: 0,
      inputTypes: inputTypes,
      inputAmounts: inputAmounts,
      outputTypes: outputTypes,
      outputAmounts: outputAmounts
    });
  }

  return recipes;
}

function getRecipeId(RecipesData memory recipe) pure returns (bytes32) {
  return keccak256(
    abi.encode(recipe.stationTypeId, recipe.inputTypes, recipe.inputAmounts, recipe.outputTypes, recipe.outputAmounts)
  );
}
