// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IMachineSystem } from "./world/IMachineSystem.sol";
import { ITransferSystem } from "./world/ITransferSystem.sol";
import { Vec3, vec3 } from "../Vec3.sol";
import { Orientation } from "../Orientation.sol";
import { ObjectType, ObjectAmount } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";

library ObjectTypeLib {
  function unwrap(ObjectType self) internal pure returns (uint16) {
    return ObjectType.unwrap(self);
  }

  /// @dev True if this is the null object
  function isNull(ObjectType self) internal pure returns (bool) {
    return self.unwrap() == 0;
  }

  // Direct Category Checks

function isNonSolid(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x6), 1)
        ok := bit
      }
  }
}


function isAny(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32794..33049]
    {
      let off := sub(self, 32794)
      let bit := and(shr(off, 0xf), 1)
      ok := bit
    }
  }
}


function isBlock(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1ffffffffff7ffffffffffffffffffffffffff0), 1)
        ok := bit
      }
  }
}


function isTerracotta(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x3ffe000000000), 1)
        ok := bit
      }
  }
}


function isOre(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0xfc0000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isLog(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x3fc000000000000), 1)
        ok := bit
      }
  }
}


function isLeaf(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0xffc00000000000000), 1)
        ok := bit
      }
  }
}


function isPlank(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1fe000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isSeed(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1c000000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isSapling(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1fe0000000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isSmartEntity(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1e000001000000000000000000000000000000), 1)
        ok := bit
      }

    // IDs in [32799..33054]
    {
      let off := sub(self, 32799)
      let bit := and(shr(off, 0x1), 1)
      ok := or(ok, bit)
    }
  }
}


function isStation(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0xe0000000000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isPick(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32768..33023]
    {
      let off := sub(self, 32768)
      let bit := and(shr(off, 0x3f), 1)
      ok := bit
    }
  }
}


function isAxe(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32774..33029]
    {
      let off := sub(self, 32774)
      let bit := and(shr(off, 0x3f), 1)
      ok := bit
    }
  }
}


function isHoe(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32783..33038]
    {
      let off := sub(self, 32783)
      let bit := and(shr(off, 0x1), 1)
      ok := bit
    }
  }
}


function isWhacker(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32780..33035]
    {
      let off := sub(self, 32780)
      let bit := and(shr(off, 0x7), 1)
      ok := bit
    }
  }
}


function isOreBar(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32784..33039]
    {
      let off := sub(self, 32784)
      let bit := and(shr(off, 0xf), 1)
      ok := bit
    }
  }
}


function isFood(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32790..33045]
    {
      let off := sub(self, 32790)
      let bit := and(shr(off, 0x7), 1)
      ok := bit
    }
  }
}


function isFuel(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32793..33048]
    {
      let off := sub(self, 32793)
      let bit := and(shr(off, 0x1), 1)
      ok := bit
    }
  }
}


function isPlayer(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32798..33053]
    {
      let off := sub(self, 32798)
      let bit := and(shr(off, 0x1), 1)
      ok := bit
    }
  }
}


function hasExtraDrops(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0xd00c0009fc00000000000000), 1)
        ok := bit
      }
  }
}


function hasAxeMultiplier(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x13c0001ff00001fc000003ffffc000000000000), 1)
        ok := bit
      }
  }
}


function hasPickMultiplier(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0xc2003e00fc0000000000000003ffe0001ffff0), 1)
        ok := bit
      }
  }
}


function isPassThrough(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x101ffc0000000e83fffffc00000000000000006), 1)
        ok := bit
      }
  }
}


function isGrowable(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1ffc000000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function isLandbound(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1ffc000000000100000000000000000000000), 1)
        ok := bit
      }
  }
}


function isUniqueObject(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x1a000000000000000000000000000000000000), 1)
        ok := bit
      }

    // IDs in [32768..33023]
    {
      let off := sub(self, 32768)
      let bit := and(shr(off, 0x30ffff), 1)
      ok := or(ok, bit)
    }
  }
}


function isTool(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
    // IDs in [32768..33023]
    {
      let off := sub(self, 32768)
      let bit := and(shr(off, 0xffff), 1)
      ok := bit
    }
  }
}


function isTillable(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x600000), 1)
        ok := bit
      }
  }
}


function isMachine(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x2000000000000000000000000000000000000), 1)
        ok := bit
      }
  }
}


function spawnsWithFluid(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x9fe0000000000000000000000004), 1)
        ok := bit
      }
  }
}


function isWaterloggable(ObjectType self) internal pure returns (bool ok) {
  /// @solidity memory-safe-assembly
  assembly {
    
      // IDs in [0..255]
      {
        let bit := and(shr(self, 0x16e003ffffe5fe00000003fffffffff8dfffff0), 1)
        ok := bit
      }
  }
}


// Category getters
function getNonSolidTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water];
  }
function getAnyTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.AnyPlank, ObjectTypes.AnyLog, ObjectTypes.AnyLeaf, ObjectTypes.AnyTerracotta];
  }
function getBlockTypes() internal pure returns (ObjectType[148] memory) {
    return [ObjectTypes.Stone, ObjectTypes.Deepslate, ObjectTypes.Granite, ObjectTypes.Tuff, ObjectTypes.Calcite, ObjectTypes.Basalt, ObjectTypes.SmoothBasalt, ObjectTypes.Andesite, ObjectTypes.Diorite, ObjectTypes.Cobblestone, ObjectTypes.MossyCobblestone, ObjectTypes.Obsidian, ObjectTypes.Dripstone, ObjectTypes.Blackstone, ObjectTypes.CobbledDeepslate, ObjectTypes.Amethyst, ObjectTypes.Glowstone, ObjectTypes.Grass, ObjectTypes.Dirt, ObjectTypes.Moss, ObjectTypes.Podzol, ObjectTypes.DirtPath, ObjectTypes.Mud, ObjectTypes.PackedMud, ObjectTypes.Farmland, ObjectTypes.WetFarmland, ObjectTypes.Snow, ObjectTypes.Ice, ObjectTypes.UnrevealedOre, ObjectTypes.CoalOre, ObjectTypes.CopperOre, ObjectTypes.IronOre, ObjectTypes.GoldOre, ObjectTypes.DiamondOre, ObjectTypes.NeptuniumOre, ObjectTypes.Gravel, ObjectTypes.Sand, ObjectTypes.RedSand, ObjectTypes.Sandstone, ObjectTypes.RedSandstone, ObjectTypes.Clay, ObjectTypes.Terracotta, ObjectTypes.BrownTerracotta, ObjectTypes.OrangeTerracotta, ObjectTypes.WhiteTerracotta, ObjectTypes.LightGrayTerracotta, ObjectTypes.YellowTerracotta, ObjectTypes.RedTerracotta, ObjectTypes.LightBlueTerracotta, ObjectTypes.CyanTerracotta, ObjectTypes.BlackTerracotta, ObjectTypes.PurpleTerracotta, ObjectTypes.BlueTerracotta, ObjectTypes.MagentaTerracotta, ObjectTypes.OakLog, ObjectTypes.BirchLog, ObjectTypes.JungleLog, ObjectTypes.SakuraLog, ObjectTypes.AcaciaLog, ObjectTypes.SpruceLog, ObjectTypes.DarkOakLog, ObjectTypes.MangroveLog, ObjectTypes.OakLeaf, ObjectTypes.BirchLeaf, ObjectTypes.JungleLeaf, ObjectTypes.SakuraLeaf, ObjectTypes.SpruceLeaf, ObjectTypes.AcaciaLeaf, ObjectTypes.DarkOakLeaf, ObjectTypes.AzaleaLeaf, ObjectTypes.FloweringAzaleaLeaf, ObjectTypes.MangroveLeaf, ObjectTypes.MangroveRoots, ObjectTypes.MuddyMangroveRoots, ObjectTypes.AzaleaFlower, ObjectTypes.BellFlower, ObjectTypes.DandelionFlower, ObjectTypes.DaylilyFlower, ObjectTypes.LilacFlower, ObjectTypes.RoseFlower, ObjectTypes.FireFlower, ObjectTypes.MorninggloryFlower, ObjectTypes.PeonyFlower, ObjectTypes.Ultraviolet, ObjectTypes.SunFlower, ObjectTypes.FlyTrap, ObjectTypes.FescueGrass, ObjectTypes.SwitchGrass, ObjectTypes.VinesBush, ObjectTypes.IvyVine, ObjectTypes.HempBush, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae, ObjectTypes.HornCoralBlock, ObjectTypes.FireCoralBlock, ObjectTypes.TubeCoralBlock, ObjectTypes.BubbleCoralBlock, ObjectTypes.BrainCoralBlock, ObjectTypes.SpiderWeb, ObjectTypes.Bone, ObjectTypes.GoldenMushroom, ObjectTypes.RedMushroom, ObjectTypes.CoffeeBush, ObjectTypes.StrawberryBush, ObjectTypes.RaspberryBush, ObjectTypes.Wheat, ObjectTypes.CottonBush, ObjectTypes.Pumpkin, ObjectTypes.Melon, ObjectTypes.RedMushroomBlock, ObjectTypes.BrownMushroomBlock, ObjectTypes.MushroomStem, ObjectTypes.BambooBush, ObjectTypes.Cactus, ObjectTypes.OakPlanks, ObjectTypes.BirchPlanks, ObjectTypes.JunglePlanks, ObjectTypes.SakuraPlanks, ObjectTypes.SprucePlanks, ObjectTypes.AcaciaPlanks, ObjectTypes.DarkOakPlanks, ObjectTypes.MangrovePlanks, ObjectTypes.CopperBlock, ObjectTypes.IronBlock, ObjectTypes.GoldBlock, ObjectTypes.DiamondBlock, ObjectTypes.NeptuniumBlock, ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed, ObjectTypes.OakSapling, ObjectTypes.BirchSapling, ObjectTypes.JungleSapling, ObjectTypes.SakuraSapling, ObjectTypes.AcaciaSapling, ObjectTypes.SpruceSapling, ObjectTypes.DarkOakSapling, ObjectTypes.MangroveSapling, ObjectTypes.Furnace, ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.Bed, ObjectTypes.TextSign, ObjectTypes.Torch];
  }
function getTerracottaTypes() internal pure returns (ObjectType[13] memory) {
    return [ObjectTypes.Terracotta, ObjectTypes.BrownTerracotta, ObjectTypes.OrangeTerracotta, ObjectTypes.WhiteTerracotta, ObjectTypes.LightGrayTerracotta, ObjectTypes.YellowTerracotta, ObjectTypes.RedTerracotta, ObjectTypes.LightBlueTerracotta, ObjectTypes.CyanTerracotta, ObjectTypes.BlackTerracotta, ObjectTypes.PurpleTerracotta, ObjectTypes.BlueTerracotta, ObjectTypes.MagentaTerracotta];
  }
function getOreTypes() internal pure returns (ObjectType[6] memory) {
    return [ObjectTypes.CoalOre, ObjectTypes.CopperOre, ObjectTypes.IronOre, ObjectTypes.GoldOre, ObjectTypes.DiamondOre, ObjectTypes.NeptuniumOre];
  }
function getLogTypes() internal pure returns (ObjectType[8] memory) {
    return [ObjectTypes.OakLog, ObjectTypes.BirchLog, ObjectTypes.JungleLog, ObjectTypes.SakuraLog, ObjectTypes.AcaciaLog, ObjectTypes.SpruceLog, ObjectTypes.DarkOakLog, ObjectTypes.MangroveLog];
  }
function getLeafTypes() internal pure returns (ObjectType[10] memory) {
    return [ObjectTypes.OakLeaf, ObjectTypes.BirchLeaf, ObjectTypes.JungleLeaf, ObjectTypes.SakuraLeaf, ObjectTypes.SpruceLeaf, ObjectTypes.AcaciaLeaf, ObjectTypes.DarkOakLeaf, ObjectTypes.MangroveLeaf, ObjectTypes.AzaleaLeaf, ObjectTypes.FloweringAzaleaLeaf];
  }
function getPlankTypes() internal pure returns (ObjectType[8] memory) {
    return [ObjectTypes.OakPlanks, ObjectTypes.BirchPlanks, ObjectTypes.JunglePlanks, ObjectTypes.SakuraPlanks, ObjectTypes.SprucePlanks, ObjectTypes.AcaciaPlanks, ObjectTypes.DarkOakPlanks, ObjectTypes.MangrovePlanks];
  }
function getSeedTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed];
  }
function getSaplingTypes() internal pure returns (ObjectType[8] memory) {
    return [ObjectTypes.OakSapling, ObjectTypes.BirchSapling, ObjectTypes.JungleSapling, ObjectTypes.SakuraSapling, ObjectTypes.AcaciaSapling, ObjectTypes.SpruceSapling, ObjectTypes.DarkOakSapling, ObjectTypes.MangroveSapling];
  }
function getSmartEntityTypes() internal pure returns (ObjectType[6] memory) {
    return [ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.Bed, ObjectTypes.Fragment, ObjectTypes.TextSign];
  }
function getStationTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.Furnace];
  }
function getPickTypes() internal pure returns (ObjectType[6] memory) {
    return [ObjectTypes.WoodenPick, ObjectTypes.CopperPick, ObjectTypes.IronPick, ObjectTypes.GoldPick, ObjectTypes.DiamondPick, ObjectTypes.NeptuniumPick];
  }
function getAxeTypes() internal pure returns (ObjectType[6] memory) {
    return [ObjectTypes.WoodenAxe, ObjectTypes.CopperAxe, ObjectTypes.IronAxe, ObjectTypes.GoldAxe, ObjectTypes.DiamondAxe, ObjectTypes.NeptuniumAxe];
  }
function getHoeTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.WoodenHoe];
  }
function getWhackerTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WoodenWhacker, ObjectTypes.CopperWhacker, ObjectTypes.IronWhacker];
  }
function getOreBarTypes() internal pure returns (ObjectType[4] memory) {
    return [ObjectTypes.GoldBar, ObjectTypes.IronBar, ObjectTypes.Diamond, ObjectTypes.NeptuniumBar];
  }
function getFoodTypes() internal pure returns (ObjectType[3] memory) {
    return [ObjectTypes.WheatSlop, ObjectTypes.PumpkinSoup, ObjectTypes.MelonSmoothie];
  }
function getFuelTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Battery];
  }
function getPlayerTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.Player];
  }
function getExtraDropsTypes() internal pure returns (ObjectType[13] memory) {
    return [ObjectTypes.OakLeaf, ObjectTypes.BirchLeaf, ObjectTypes.JungleLeaf, ObjectTypes.SakuraLeaf, ObjectTypes.SpruceLeaf, ObjectTypes.AcaciaLeaf, ObjectTypes.DarkOakLeaf, ObjectTypes.MangroveLeaf, ObjectTypes.Wheat, ObjectTypes.Pumpkin, ObjectTypes.Melon, ObjectTypes.FescueGrass, ObjectTypes.SwitchGrass];
  }
function getAxeMultiplierTypes() internal pure returns (ObjectType[41] memory) {
    return [ObjectTypes.OakLog, ObjectTypes.BirchLog, ObjectTypes.JungleLog, ObjectTypes.SakuraLog, ObjectTypes.AcaciaLog, ObjectTypes.SpruceLog, ObjectTypes.DarkOakLog, ObjectTypes.MangroveLog, ObjectTypes.OakLeaf, ObjectTypes.BirchLeaf, ObjectTypes.JungleLeaf, ObjectTypes.SakuraLeaf, ObjectTypes.SpruceLeaf, ObjectTypes.AcaciaLeaf, ObjectTypes.DarkOakLeaf, ObjectTypes.AzaleaLeaf, ObjectTypes.FloweringAzaleaLeaf, ObjectTypes.MangroveLeaf, ObjectTypes.MangroveRoots, ObjectTypes.MuddyMangroveRoots, ObjectTypes.OakPlanks, ObjectTypes.BirchPlanks, ObjectTypes.JunglePlanks, ObjectTypes.SakuraPlanks, ObjectTypes.SprucePlanks, ObjectTypes.AcaciaPlanks, ObjectTypes.DarkOakPlanks, ObjectTypes.MangrovePlanks, ObjectTypes.Pumpkin, ObjectTypes.Melon, ObjectTypes.RedMushroomBlock, ObjectTypes.BrownMushroomBlock, ObjectTypes.MushroomStem, ObjectTypes.BambooBush, ObjectTypes.Cactus, ObjectTypes.Chest, ObjectTypes.Workbench, ObjectTypes.SpawnTile, ObjectTypes.Bed, ObjectTypes.TextSign, ObjectTypes.Torch];
  }
function getPickMultiplierTypes() internal pure returns (ObjectType[44] memory) {
    return [ObjectTypes.CoalOre, ObjectTypes.CopperOre, ObjectTypes.IronOre, ObjectTypes.GoldOre, ObjectTypes.DiamondOre, ObjectTypes.NeptuniumOre, ObjectTypes.Amethyst, ObjectTypes.Glowstone, ObjectTypes.Stone, ObjectTypes.Deepslate, ObjectTypes.Granite, ObjectTypes.Tuff, ObjectTypes.Calcite, ObjectTypes.Basalt, ObjectTypes.SmoothBasalt, ObjectTypes.Andesite, ObjectTypes.Diorite, ObjectTypes.Cobblestone, ObjectTypes.MossyCobblestone, ObjectTypes.Obsidian, ObjectTypes.Dripstone, ObjectTypes.Blackstone, ObjectTypes.CobbledDeepslate, ObjectTypes.Terracotta, ObjectTypes.BrownTerracotta, ObjectTypes.OrangeTerracotta, ObjectTypes.WhiteTerracotta, ObjectTypes.LightGrayTerracotta, ObjectTypes.YellowTerracotta, ObjectTypes.RedTerracotta, ObjectTypes.LightBlueTerracotta, ObjectTypes.CyanTerracotta, ObjectTypes.BlackTerracotta, ObjectTypes.PurpleTerracotta, ObjectTypes.BlueTerracotta, ObjectTypes.MagentaTerracotta, ObjectTypes.CopperBlock, ObjectTypes.IronBlock, ObjectTypes.GoldBlock, ObjectTypes.DiamondBlock, ObjectTypes.NeptuniumBlock, ObjectTypes.Powerstone, ObjectTypes.Furnace, ObjectTypes.ForceField];
  }
function getPassThroughTypes() internal pure returns (ObjectType[42] memory) {
    return [ObjectTypes.Air, ObjectTypes.Water, ObjectTypes.AzaleaFlower, ObjectTypes.BellFlower, ObjectTypes.DandelionFlower, ObjectTypes.DaylilyFlower, ObjectTypes.LilacFlower, ObjectTypes.RoseFlower, ObjectTypes.FireFlower, ObjectTypes.MorninggloryFlower, ObjectTypes.PeonyFlower, ObjectTypes.Ultraviolet, ObjectTypes.SunFlower, ObjectTypes.FlyTrap, ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed, ObjectTypes.OakSapling, ObjectTypes.BirchSapling, ObjectTypes.JungleSapling, ObjectTypes.SakuraSapling, ObjectTypes.AcaciaSapling, ObjectTypes.SpruceSapling, ObjectTypes.DarkOakSapling, ObjectTypes.MangroveSapling, ObjectTypes.FescueGrass, ObjectTypes.SwitchGrass, ObjectTypes.VinesBush, ObjectTypes.IvyVine, ObjectTypes.HempBush, ObjectTypes.GoldenMushroom, ObjectTypes.RedMushroom, ObjectTypes.CoffeeBush, ObjectTypes.StrawberryBush, ObjectTypes.RaspberryBush, ObjectTypes.Wheat, ObjectTypes.CottonBush, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae, ObjectTypes.Torch, ObjectTypes.BambooBush];
  }
function getGrowableTypes() internal pure returns (ObjectType[11] memory) {
    return [ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed, ObjectTypes.OakSapling, ObjectTypes.BirchSapling, ObjectTypes.JungleSapling, ObjectTypes.SakuraSapling, ObjectTypes.AcaciaSapling, ObjectTypes.SpruceSapling, ObjectTypes.DarkOakSapling, ObjectTypes.MangroveSapling];
  }
function getLandboundTypes() internal pure returns (ObjectType[12] memory) {
    return [ObjectTypes.Wheat, ObjectTypes.WheatSeed, ObjectTypes.PumpkinSeed, ObjectTypes.MelonSeed, ObjectTypes.OakSapling, ObjectTypes.BirchSapling, ObjectTypes.JungleSapling, ObjectTypes.SakuraSapling, ObjectTypes.AcaciaSapling, ObjectTypes.SpruceSapling, ObjectTypes.DarkOakSapling, ObjectTypes.MangroveSapling];
  }
function getUniqueObjectTypes() internal pure returns (ObjectType[21] memory) {
    return [ObjectTypes.WoodenPick, ObjectTypes.CopperPick, ObjectTypes.IronPick, ObjectTypes.GoldPick, ObjectTypes.DiamondPick, ObjectTypes.NeptuniumPick, ObjectTypes.WoodenAxe, ObjectTypes.CopperAxe, ObjectTypes.IronAxe, ObjectTypes.GoldAxe, ObjectTypes.DiamondAxe, ObjectTypes.NeptuniumAxe, ObjectTypes.WoodenWhacker, ObjectTypes.CopperWhacker, ObjectTypes.IronWhacker, ObjectTypes.WoodenHoe, ObjectTypes.Bucket, ObjectTypes.WaterBucket, ObjectTypes.ForceField, ObjectTypes.Bed, ObjectTypes.SpawnTile];
  }
function getToolTypes() internal pure returns (ObjectType[16] memory) {
    return [ObjectTypes.WoodenPick, ObjectTypes.CopperPick, ObjectTypes.IronPick, ObjectTypes.GoldPick, ObjectTypes.DiamondPick, ObjectTypes.NeptuniumPick, ObjectTypes.WoodenAxe, ObjectTypes.CopperAxe, ObjectTypes.IronAxe, ObjectTypes.GoldAxe, ObjectTypes.DiamondAxe, ObjectTypes.NeptuniumAxe, ObjectTypes.WoodenWhacker, ObjectTypes.CopperWhacker, ObjectTypes.IronWhacker, ObjectTypes.WoodenHoe];
  }
function getTillableTypes() internal pure returns (ObjectType[2] memory) {
    return [ObjectTypes.Dirt, ObjectTypes.Grass];
  }
function getMachineTypes() internal pure returns (ObjectType[1] memory) {
    return [ObjectTypes.ForceField];
  }
function getSpawnsWithFluidTypes() internal pure returns (ObjectType[10] memory) {
    return [ObjectTypes.Lava, ObjectTypes.Water, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae, ObjectTypes.HornCoralBlock, ObjectTypes.FireCoralBlock, ObjectTypes.TubeCoralBlock, ObjectTypes.BubbleCoralBlock, ObjectTypes.BrainCoralBlock];
  }
function getWaterloggableTypes() internal pure returns (ObjectType[98] memory) {
    return [ObjectTypes.Stone, ObjectTypes.Deepslate, ObjectTypes.Granite, ObjectTypes.Tuff, ObjectTypes.Calcite, ObjectTypes.Basalt, ObjectTypes.SmoothBasalt, ObjectTypes.Andesite, ObjectTypes.Diorite, ObjectTypes.Cobblestone, ObjectTypes.MossyCobblestone, ObjectTypes.Obsidian, ObjectTypes.Dripstone, ObjectTypes.Blackstone, ObjectTypes.CobbledDeepslate, ObjectTypes.Amethyst, ObjectTypes.Glowstone, ObjectTypes.Grass, ObjectTypes.Dirt, ObjectTypes.Moss, ObjectTypes.Podzol, ObjectTypes.Mud, ObjectTypes.PackedMud, ObjectTypes.Ice, ObjectTypes.CoalOre, ObjectTypes.CopperOre, ObjectTypes.IronOre, ObjectTypes.GoldOre, ObjectTypes.DiamondOre, ObjectTypes.NeptuniumOre, ObjectTypes.Gravel, ObjectTypes.Sand, ObjectTypes.RedSand, ObjectTypes.Sandstone, ObjectTypes.RedSandstone, ObjectTypes.Clay, ObjectTypes.Terracotta, ObjectTypes.BrownTerracotta, ObjectTypes.OrangeTerracotta, ObjectTypes.WhiteTerracotta, ObjectTypes.LightGrayTerracotta, ObjectTypes.YellowTerracotta, ObjectTypes.RedTerracotta, ObjectTypes.LightBlueTerracotta, ObjectTypes.CyanTerracotta, ObjectTypes.BlackTerracotta, ObjectTypes.PurpleTerracotta, ObjectTypes.BlueTerracotta, ObjectTypes.MagentaTerracotta, ObjectTypes.OakLog, ObjectTypes.BirchLog, ObjectTypes.JungleLog, ObjectTypes.SakuraLog, ObjectTypes.AcaciaLog, ObjectTypes.SpruceLog, ObjectTypes.DarkOakLog, ObjectTypes.MangroveLog, ObjectTypes.OakLeaf, ObjectTypes.BirchLeaf, ObjectTypes.JungleLeaf, ObjectTypes.SakuraLeaf, ObjectTypes.SpruceLeaf, ObjectTypes.AcaciaLeaf, ObjectTypes.DarkOakLeaf, ObjectTypes.AzaleaLeaf, ObjectTypes.FloweringAzaleaLeaf, ObjectTypes.MangroveLeaf, ObjectTypes.MangroveRoots, ObjectTypes.MuddyMangroveRoots, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae, ObjectTypes.HornCoralBlock, ObjectTypes.FireCoralBlock, ObjectTypes.TubeCoralBlock, ObjectTypes.BubbleCoralBlock, ObjectTypes.BrainCoralBlock, ObjectTypes.Bone, ObjectTypes.OakPlanks, ObjectTypes.BirchPlanks, ObjectTypes.JunglePlanks, ObjectTypes.SakuraPlanks, ObjectTypes.SprucePlanks, ObjectTypes.AcaciaPlanks, ObjectTypes.DarkOakPlanks, ObjectTypes.MangrovePlanks, ObjectTypes.CopperBlock, ObjectTypes.IronBlock, ObjectTypes.GoldBlock, ObjectTypes.DiamondBlock, ObjectTypes.NeptuniumBlock, ObjectTypes.Workbench, ObjectTypes.Powerstone, ObjectTypes.ForceField, ObjectTypes.Chest, ObjectTypes.SpawnTile, ObjectTypes.TextSign, ObjectTypes.Torch];
  }

  // Specialized getters

  // TODO: these are currently part of the codegen, but we should define them in Solidity and import them here
  function getObjectTypeSchema(ObjectType self) internal pure returns (Vec3[] memory) {
    if (self == ObjectTypes.Player) {
      Vec3[] memory playerRelativePositions = new Vec3[](1);
      playerRelativePositions[0] = vec3(0, 1, 0);
      return playerRelativePositions;
    }

    if (self == ObjectTypes.Bed) {
      Vec3[] memory bedRelativePositions = new Vec3[](1);
      bedRelativePositions[0] = vec3(1, 0, 0);
      return bedRelativePositions;
    }

    if (self == ObjectTypes.TextSign) {
      Vec3[] memory textSignRelativePositions = new Vec3[](1);
      textSignRelativePositions[0] = vec3(0, 1, 0);
      return textSignRelativePositions;
    }

    return new Vec3[](0);
  }

  /// @dev Get relative schema coords, including base coord
  function getRelativeCoords(ObjectType self, Vec3 baseCoord, Orientation orientation)
    internal
    pure
    returns (Vec3[] memory)
  {
    require(isOrientationSupported(self, orientation), "Orientation not supported");

    Vec3[] memory schemaCoords = getObjectTypeSchema(self);
    Vec3[] memory coords = new Vec3[](schemaCoords.length + 1);

    coords[0] = baseCoord;

    for (uint256 i = 0; i < schemaCoords.length; i++) {
      coords[i + 1] = baseCoord + schemaCoords[i].applyOrientation(orientation);
    }

    return coords;
  }

  function isOrientationSupported(ObjectType self, Orientation orientation) internal pure returns (bool) {
    if (self == ObjectTypes.TextSign) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.ForceField) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.Chest) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.SpawnTile) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.Bed) {
          return orientation == Orientation.wrap(1) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.Workbench) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.Powerstone) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }
    if (self == ObjectTypes.Furnace) {
          return orientation == Orientation.wrap(0) || orientation == Orientation.wrap(1) || orientation == Orientation.wrap(40) || orientation == Orientation.wrap(44);
        }

    return orientation == Orientation.wrap(0);
  }

  function getRelativeCoords(ObjectType self, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(self, baseCoord, Orientation.wrap(0));
  }

  function isActionAllowed(ObjectType self, bytes4 sig) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    if (self == ObjectTypes.Chest) {
      return sig == ITransferSystem.transfer.selector || sig == IMachineSystem.fuelMachine.selector;
    }

    return false;
  }

  function getMaxInventorySlots(ObjectType self) internal pure returns (uint16) {
    if (self == ObjectTypes.Player) return 36;
    if (self == ObjectTypes.Chest) return 27;
    if (self.isPassThrough()) return type(uint16).max;
    return 0;
  }

  function getStackable(ObjectType self) internal pure returns (uint16) {
    if (self.isUniqueObject()) return 1;
    if (self.isNonSolid() || self.isPlayer()) return 0;
    return 99;
  }

  function getOreAmount(ObjectType self) internal pure returns(ObjectAmount memory) {
    if (self == ObjectTypes.CopperPick) return ObjectAmount(ObjectTypes.CopperOre, 3);
    if (self == ObjectTypes.IronPick) return ObjectAmount(ObjectTypes.IronOre, 3);
    if (self == ObjectTypes.GoldPick) return ObjectAmount(ObjectTypes.GoldOre, 3);
    if (self == ObjectTypes.DiamondPick) return ObjectAmount(ObjectTypes.DiamondOre, 3);
    if (self == ObjectTypes.NeptuniumPick) return ObjectAmount(ObjectTypes.NeptuniumOre, 3);
    if (self == ObjectTypes.CopperAxe) return ObjectAmount(ObjectTypes.CopperOre, 3);
    if (self == ObjectTypes.IronAxe) return ObjectAmount(ObjectTypes.IronOre, 3);
    if (self == ObjectTypes.GoldAxe) return ObjectAmount(ObjectTypes.GoldOre, 3);
    if (self == ObjectTypes.DiamondAxe) return ObjectAmount(ObjectTypes.DiamondOre, 3);
    if (self == ObjectTypes.NeptuniumAxe) return ObjectAmount(ObjectTypes.NeptuniumOre, 3);
    if (self == ObjectTypes.CopperWhacker) return ObjectAmount(ObjectTypes.CopperOre, 6);
    if (self == ObjectTypes.IronWhacker) return ObjectAmount(ObjectTypes.IronOre, 6);
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function getPlankAmount(ObjectType self) internal pure returns(uint16) {
    if (self == ObjectTypes.WoodenPick) return 5;
    if (self == ObjectTypes.CopperPick) return 2;
    if (self == ObjectTypes.IronPick) return 2;
    if (self == ObjectTypes.GoldPick) return 2;
    if (self == ObjectTypes.DiamondPick) return 2;
    if (self == ObjectTypes.NeptuniumPick) return 2;
    if (self == ObjectTypes.WoodenAxe) return 5;
    if (self == ObjectTypes.CopperAxe) return 2;
    if (self == ObjectTypes.IronAxe) return 2;
    if (self == ObjectTypes.GoldAxe) return 2;
    if (self == ObjectTypes.DiamondAxe) return 2;
    if (self == ObjectTypes.NeptuniumAxe) return 2;
    if (self == ObjectTypes.WoodenWhacker) return 8;
    if (self == ObjectTypes.CopperWhacker) return 2;
    if (self == ObjectTypes.IronWhacker) return 2;
    if (self == ObjectTypes.WoodenHoe) return 4;
    return 0;
  }

  function getCrop(ObjectType self) internal pure returns(ObjectType) {
    if (self == ObjectTypes.WheatSeed) return ObjectTypes.Wheat;
    if (self == ObjectTypes.PumpkinSeed) return ObjectTypes.Pumpkin;
    if (self == ObjectTypes.MelonSeed) return ObjectTypes.Melon;
    return ObjectTypes.Null;
  }

  function getSapling(ObjectType self) internal pure returns(ObjectType) {
    if (self == ObjectTypes.OakLeaf) return ObjectTypes.OakSapling;
    if (self == ObjectTypes.BirchLeaf) return ObjectTypes.BirchSapling;
    if (self == ObjectTypes.JungleLeaf) return ObjectTypes.JungleSapling;
    if (self == ObjectTypes.SakuraLeaf) return ObjectTypes.SakuraSapling;
    if (self == ObjectTypes.SpruceLeaf) return ObjectTypes.SpruceSapling;
    if (self == ObjectTypes.AcaciaLeaf) return ObjectTypes.AcaciaSapling;
    if (self == ObjectTypes.DarkOakLeaf) return ObjectTypes.DarkOakSapling;
    return ObjectTypes.Null;
  }

  function getTimeToGrow(ObjectType self) internal pure returns(uint128) {
    if (self == ObjectTypes.WheatSeed) return 900;
    if (self == ObjectTypes.PumpkinSeed) return 3600;
    if (self == ObjectTypes.MelonSeed) return 3600;
    if (self == ObjectTypes.OakSapling) return 345600;
    if (self == ObjectTypes.BirchSapling) return 345600;
    if (self == ObjectTypes.JungleSapling) return 345600;
    if (self == ObjectTypes.SakuraSapling) return 345600;
    if (self == ObjectTypes.AcaciaSapling) return 345600;
    if (self == ObjectTypes.SpruceSapling) return 345600;
    if (self == ObjectTypes.DarkOakSapling) return 345600;
    if (self == ObjectTypes.MangroveSapling) return 345600;
    return 0;
  }

  function getGrowableEnergy(ObjectType self) public pure returns(uint128) {
    if (self == ObjectTypes.WheatSeed) return 4300000000000000;
    if (self == ObjectTypes.PumpkinSeed) return 34300000000000000;
    if (self == ObjectTypes.MelonSeed) return 34300000000000000;
    if (self == ObjectTypes.OakSapling) return 148000000000000000;
    if (self == ObjectTypes.BirchSapling) return 139000000000000000;
    if (self == ObjectTypes.JungleSapling) return 300000000000000000;
    if (self == ObjectTypes.SakuraSapling) return 187000000000000000;
    if (self == ObjectTypes.AcaciaSapling) return 158000000000000000;
    if (self == ObjectTypes.SpruceSapling) return 256000000000000000;
    if (self == ObjectTypes.DarkOakSapling) return 202000000000000000;
    if (self == ObjectTypes.MangroveSapling) return 232000000000000000;
    return 0;
  }

  function isPlantableOn(ObjectType self, ObjectType on) internal pure returns (bool) {
    if(self.isSeed()) {
      return on == ObjectTypes.WetFarmland;
    }
    if(self.isSapling()) {
      return on == ObjectTypes.Dirt || on == ObjectTypes.Grass;
    }
    return false;
  }

  function matches(ObjectType self, ObjectType other) internal pure returns (bool) {
    if (!self.isAny()) return self == other;

    return (self == ObjectTypes.AnyLog && other.isLog())
      || (self == ObjectTypes.AnyPlank && other.isPlank())
      || (self == ObjectTypes.AnyLeaf && other.isLeaf());
  }
}

