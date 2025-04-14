// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ObjectTypeMetadata, ObjectTypeMetadataData } from "../src/codegen/tables/ObjectTypeMetadata.sol";

import { MAX_PLAYER_ENERGY } from "../src/Constants.sol";
import { ObjectTypes } from "../src/ObjectTypes.sol";

function initObjects() {
  ObjectTypeMetadata.set(
    ObjectTypes.Air,
    ObjectTypeMetadataData({
      stackable: 0,
      maxInventorySlots: type(uint16).max,
      mass: 0,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Water,
    ObjectTypeMetadataData({
      stackable: 0,
      maxInventorySlots: type(uint16).max,
      mass: 0,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Lava,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Stone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Bedrock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 50000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Deepslate,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 40000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Granite,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 15000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Tuff,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 15000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Calcite,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 75000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Basalt,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 75000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SmoothBasalt,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 75000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Andesite,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 15000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Diorite,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 18000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Cobblestone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 22500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MossyCobblestone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Obsidian,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 9000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Dripstone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 75000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Blackstone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 50000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CobbledDeepslate,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 100000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Amethyst,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 100000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Glowstone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AnyOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 10000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Grass,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 3000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Dirt,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 2400000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Moss,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Podzol,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DirtPath,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Farmland,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 3000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Mud,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.PackedMud,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Gravel,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 2400000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Sand,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RedSand,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Sandstone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 30000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RedSandstone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Clay,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 2400000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Terracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 18000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BrownTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 22500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OrangeTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 30000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WhiteTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 22500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.LightGrayTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 30000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.YellowTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 30000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RedTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 30000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.LightBlueTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CyanTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BlackTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.PurpleTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BlueTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MagentaTerracotta,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BirchLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.JungleLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SakuraLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AcaciaLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpruceLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DarkOakLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangroveLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BirchLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.JungleLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SakuraLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpruceLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AcaciaLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DarkOakLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangroveLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangroveRoots,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 400000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MuddyMangroveRoots,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 400000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AzaleaLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FloweringAzaleaLeaf,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 500000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AzaleaFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BellFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DandelionFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DaylilyFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.LilacFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RoseFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FireFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MorninggloryFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.PeonyFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Ultraviolet,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SunFlower,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FlyTrap,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FescueGrass,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SwitchGrass,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CottonBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BambooBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.VinesBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IvyVine,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.HempBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldenMushroom,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RedMushroom,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CoffeeBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.StrawberryBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RaspberryBush,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Cactus,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1300000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Pumpkin,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1300000000000000,
      energy: 55000000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Melon,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1300000000000000,
      energy: 55000000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.RedMushroomBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BrownMushroomBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MushroomStem,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Wheat,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 500000000000000,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Coral,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 400000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SeaAnemone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 400000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Algae,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.HornCoralBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.FireCoralBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.TubeCoralBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BubbleCoralBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BrainCoralBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Snow,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Ice,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 200000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpiderWeb,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 300000000000000,
      energy: 0,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Bone,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 37500000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.BirchPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.JunglePlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SakuraPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SprucePlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AcaciaPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DarkOakPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.MangrovePlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 4450000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Furnace,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 12000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Workbench,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Powerstone,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 16000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CoalOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 540000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CopperOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1600000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DiamondOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.NeptuniumOre,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CopperBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1600000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DiamondBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.NeptuniumBlock,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WetFarmland,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 3000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WheatSeed,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 0,
      energy: 10000000000000000,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.OakSapling,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 0,
      energy: 100000000000000000,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpruceSapling,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: type(uint16).max,
      mass: 0,
      energy: 100000000000000000,
      canPassThrough: true
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.ForceField,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 687000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Chest,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 27,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.TextSign,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.SpawnTile,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1362000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Bed,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 36,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WoodenPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WoodenAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WoodenWhacker,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WoodenHoe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CopperPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CopperAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.CopperWhacker,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronWhacker,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 678125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 1603125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 1603125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DiamondPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 5003125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.DiamondAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 5003125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.NeptuniumPick,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 5003125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.NeptuniumAxe,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 5003125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.GoldBar,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 1600000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.IronBar,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Diamond,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.NeptuniumBar,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 5000000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Bucket,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.WaterBucket,
    ObjectTypeMetadataData({
      stackable: 1,
      maxInventorySlots: 0,
      mass: 675000000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Fuel,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 0,
      energy: 100000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.Player,
    ObjectTypeMetadataData({
      stackable: 0,
      maxInventorySlots: 36,
      mass: 0,
      energy: MAX_PLAYER_ENERGY,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AnyLog,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 12500000000000000,
      energy: 5300000000000000,
      canPassThrough: false
    })
  );
  ObjectTypeMetadata.set(
    ObjectTypes.AnyPlanks,
    ObjectTypeMetadataData({
      stackable: 99,
      maxInventorySlots: 0,
      mass: 3125000000000000,
      energy: 0,
      canPassThrough: false
    })
  );
}
