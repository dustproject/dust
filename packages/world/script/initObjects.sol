// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectTypes } from "../src/ObjectType.sol";
import { ObjectTypeMetadata, ObjectTypeMetadataData } from "../src/codegen/tables/ObjectTypeMetadata.sol";

function initObjects() {
  ObjectTypeMetadata.set(ObjectTypes.Air, ObjectTypeMetadataData({ mass: 0, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Water, ObjectTypeMetadataData({ mass: 0, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Lava, ObjectTypeMetadataData({ mass: 500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Stone, ObjectTypeMetadataData({ mass: 12000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Bedrock, ObjectTypeMetadataData({ mass: 1000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Deepslate, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Granite, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Tuff, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Calcite, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Basalt, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SmoothBasalt, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Andesite, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Diorite, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Cobblestone, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MossyCobblestone, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Obsidian, ObjectTypeMetadataData({ mass: 90000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Dripstone, ObjectTypeMetadataData({ mass: 75000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Blackstone, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CobbledDeepslate, ObjectTypeMetadataData({ mass: 100000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Amethyst, ObjectTypeMetadataData({ mass: 100000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Glowstone, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Grass, ObjectTypeMetadataData({ mass: 3000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Dirt, ObjectTypeMetadataData({ mass: 2400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Moss, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Podzol, ObjectTypeMetadataData({ mass: 5000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DirtPath, ObjectTypeMetadataData({ mass: 5000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Mud, ObjectTypeMetadataData({ mass: 4000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.PackedMud, ObjectTypeMetadataData({ mass: 5000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Farmland, ObjectTypeMetadataData({ mass: 3000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WetFarmland, ObjectTypeMetadataData({ mass: 3000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.AnyOre, ObjectTypeMetadataData({ mass: 10000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CoalOre, ObjectTypeMetadataData({ mass: 540000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CopperOre, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronOre, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldOre, ObjectTypeMetadataData({ mass: 1600000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DiamondOre, ObjectTypeMetadataData({ mass: 5000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.NeptuniumOre, ObjectTypeMetadataData({ mass: 5000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Gravel, ObjectTypeMetadataData({ mass: 2400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Sand, ObjectTypeMetadataData({ mass: 4000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RedSand, ObjectTypeMetadataData({ mass: 5000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Sandstone, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RedSandstone, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Clay, ObjectTypeMetadataData({ mass: 2400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Terracotta, ObjectTypeMetadataData({ mass: 18000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BrownTerracotta, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.OrangeTerracotta, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WhiteTerracotta, ObjectTypeMetadataData({ mass: 22500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(
    ObjectTypes.LightGrayTerracotta, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 })
  );
  ObjectTypeMetadata.set(ObjectTypes.YellowTerracotta, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RedTerracotta, ObjectTypeMetadataData({ mass: 30000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(
    ObjectTypes.LightBlueTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 })
  );
  ObjectTypeMetadata.set(ObjectTypes.CyanTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BlackTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.PurpleTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BlueTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MagentaTerracotta, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(
    ObjectTypes.AnyLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BirchLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.JungleLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SakuraLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AcaciaLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpruceLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DarkOakLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangroveLog, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 5500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AnyLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BirchLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.JungleLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SakuraLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpruceLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AcaciaLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DarkOakLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AzaleaLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FloweringAzaleaLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangroveLeaf, ObjectTypeMetadataData({ mass: 500000000000000, energy: 500000000000000 })
  );
  ObjectTypeMetadata.set(ObjectTypes.MangroveRoots, ObjectTypeMetadataData({ mass: 400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MuddyMangroveRoots, ObjectTypeMetadataData({ mass: 400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.AzaleaFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BellFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DandelionFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DaylilyFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.LilacFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RoseFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.FireFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MorninggloryFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.PeonyFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Ultraviolet, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SunFlower, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.FlyTrap, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.FescueGrass, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SwitchGrass, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CottonBush, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BambooBush, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.VinesBush, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IvyVine, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.HempBush, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldenMushroom, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RedMushroom, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CoffeeBush, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.StrawberryBush, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.RaspberryBush, ObjectTypeMetadataData({ mass: 300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Cactus, ObjectTypeMetadataData({ mass: 1300000000000000, energy: 0 }));
  ObjectTypeMetadata.set(
    ObjectTypes.Pumpkin, ObjectTypeMetadataData({ mass: 1300000000000000, energy: 16500000000000000 })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Melon, ObjectTypeMetadataData({ mass: 1300000000000000, energy: 16500000000000000 })
  );
  ObjectTypeMetadata.set(ObjectTypes.RedMushroomBlock, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BrownMushroomBlock, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MushroomStem, ObjectTypeMetadataData({ mass: 12500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Wheat, ObjectTypeMetadataData({ mass: 300000000000000, energy: 500000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.Coral, ObjectTypeMetadataData({ mass: 400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SeaAnemone, ObjectTypeMetadataData({ mass: 400000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Algae, ObjectTypeMetadataData({ mass: 200000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.HornCoralBlock, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.FireCoralBlock, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.TubeCoralBlock, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BubbleCoralBlock, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BrainCoralBlock, ObjectTypeMetadataData({ mass: 37500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.AnyPlank, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.OakPlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.BirchPlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.JunglePlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SakuraPlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SprucePlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.AcaciaPlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DarkOakPlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.MangrovePlanks, ObjectTypeMetadataData({ mass: 4500000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CopperBlock, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronBlock, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldBlock, ObjectTypeMetadataData({ mass: 14400000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DiamondBlock, ObjectTypeMetadataData({ mass: 45000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.NeptuniumBlock, ObjectTypeMetadataData({ mass: 45000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WheatSeed, ObjectTypeMetadataData({ mass: 0, energy: 10000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.PumpkinSeed, ObjectTypeMetadataData({ mass: 0, energy: 10000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.MelonSeed, ObjectTypeMetadataData({ mass: 0, energy: 10000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.OakSapling, ObjectTypeMetadataData({ mass: 0, energy: 148000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.BirchSapling, ObjectTypeMetadataData({ mass: 0, energy: 139000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.JungleSapling, ObjectTypeMetadataData({ mass: 0, energy: 300000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.SakuraSapling, ObjectTypeMetadataData({ mass: 0, energy: 187000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.AcaciaSapling, ObjectTypeMetadataData({ mass: 0, energy: 158000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.SpruceSapling, ObjectTypeMetadataData({ mass: 0, energy: 256000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.DarkOakSapling, ObjectTypeMetadataData({ mass: 0, energy: 202000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.MangroveSapling, ObjectTypeMetadataData({ mass: 0, energy: 232000000000000000 }));
  ObjectTypeMetadata.set(ObjectTypes.Furnace, ObjectTypeMetadataData({ mass: 108000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Workbench, ObjectTypeMetadataData({ mass: 17800000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Powerstone, ObjectTypeMetadataData({ mass: 3735000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.ForceField, ObjectTypeMetadataData({ mass: 3735000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Chest, ObjectTypeMetadataData({ mass: 35600000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SpawnTile, ObjectTypeMetadataData({ mass: 9135000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Bed, ObjectTypeMetadataData({ mass: 13350000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Snow, ObjectTypeMetadataData({ mass: 4000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Ice, ObjectTypeMetadataData({ mass: 4000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.SpiderWeb, ObjectTypeMetadataData({ mass: 100000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Bone, ObjectTypeMetadataData({ mass: 1000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.TextSign, ObjectTypeMetadataData({ mass: 17800000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WoodenPick, ObjectTypeMetadataData({ mass: 22250000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CopperPick, ObjectTypeMetadataData({ mass: 2033900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronPick, ObjectTypeMetadataData({ mass: 2033900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldPick, ObjectTypeMetadataData({ mass: 4808900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DiamondPick, ObjectTypeMetadataData({ mass: 15008900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.NeptuniumPick, ObjectTypeMetadataData({ mass: 15008900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WoodenAxe, ObjectTypeMetadataData({ mass: 22250000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CopperAxe, ObjectTypeMetadataData({ mass: 2033900000000000002, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronAxe, ObjectTypeMetadataData({ mass: 2033900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldAxe, ObjectTypeMetadataData({ mass: 4808900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.DiamondAxe, ObjectTypeMetadataData({ mass: 15008900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.NeptuniumAxe, ObjectTypeMetadataData({ mass: 15008900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WoodenWhacker, ObjectTypeMetadataData({ mass: 35600000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.CopperWhacker, ObjectTypeMetadataData({ mass: 4058900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronWhacker, ObjectTypeMetadataData({ mass: 4058900000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.WoodenHoe, ObjectTypeMetadataData({ mass: 17800000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.GoldBar, ObjectTypeMetadataData({ mass: 1600000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.IronBar, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Diamond, ObjectTypeMetadataData({ mass: 5000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.NeptuniumBar, ObjectTypeMetadataData({ mass: 5000000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Bucket, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 0 }));
  ObjectTypeMetadata.set(
    ObjectTypes.WaterBucket, ObjectTypeMetadataData({ mass: 675000000000000000, energy: 4000000000000000 })
  );
  ObjectTypeMetadata.set(ObjectTypes.Fuel, ObjectTypeMetadataData({ mass: 1000000000000000, energy: 5000000000000000 }));
  ObjectTypeMetadata.set(
    ObjectTypes.WheatSlop, ObjectTypeMetadataData({ mass: 1000000000000000, energy: 5000000000000000 })
  );
  ObjectTypeMetadata.set(ObjectTypes.Player, ObjectTypeMetadataData({ mass: 0, energy: 0 }));
  ObjectTypeMetadata.set(ObjectTypes.Fragment, ObjectTypeMetadataData({ mass: 0, energy: 0 }));
}
