// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ObjectTypeMetadata, ObjectTypeMetadataData } from "./tables/ObjectTypeMetadata.sol";
import { Recipes, RecipesData } from "./tables/Recipes.sol";
import { InitialEnergyPool } from "./tables/InitialEnergyPool.sol";
import { ObjectType } from "./tables/ObjectType.sol";
import { Position, PositionData } from "./tables/Position.sol";
import { ReversePosition } from "./tables/ReversePosition.sol";
import { PlayerPosition, PlayerPositionData } from "./tables/PlayerPosition.sol";
import { ReversePlayerPosition } from "./tables/ReversePlayerPosition.sol";
import { Orientation } from "./tables/Orientation.sol";
import { Mass } from "./tables/Mass.sol";
import { Energy, EnergyData } from "./tables/Energy.sol";
import { LocalEnergyPool } from "./tables/LocalEnergyPool.sol";
import { ExploredChunk } from "./tables/ExploredChunk.sol";
import { SurfaceChunkByIndex, SurfaceChunkByIndexData } from "./tables/SurfaceChunkByIndex.sol";
import { SurfaceChunkCount } from "./tables/SurfaceChunkCount.sol";
import { RegionMerkleRoot } from "./tables/RegionMerkleRoot.sol";
import { InventorySlots } from "./tables/InventorySlots.sol";
import { InventoryObjects } from "./tables/InventoryObjects.sol";
import { InventoryCount } from "./tables/InventoryCount.sol";
import { InventoryEntity } from "./tables/InventoryEntity.sol";
import { ReverseInventoryEntity } from "./tables/ReverseInventoryEntity.sol";
import { Equipped } from "./tables/Equipped.sol";
import { Player } from "./tables/Player.sol";
import { ReversePlayer } from "./tables/ReversePlayer.sol";
import { BedPlayer, BedPlayerData } from "./tables/BedPlayer.sol";
import { PlayerStatus } from "./tables/PlayerStatus.sol";
import { PlayerActivity } from "./tables/PlayerActivity.sol";
import { Program } from "./tables/Program.sol";
import { ForceFieldFragment, ForceFieldFragmentData } from "./tables/ForceFieldFragment.sol";
import { ForceFieldFragmentPosition, ForceFieldFragmentPositionData } from "./tables/ForceFieldFragmentPosition.sol";
import { ForceField } from "./tables/ForceField.sol";
import { DisplayContent, DisplayContentData } from "./tables/DisplayContent.sol";
import { OreCommitment } from "./tables/OreCommitment.sol";
import { TotalMinedOreCount } from "./tables/TotalMinedOreCount.sol";
import { MinedOrePosition, MinedOrePositionData } from "./tables/MinedOrePosition.sol";
import { MinedOreCount } from "./tables/MinedOreCount.sol";
import { TotalBurnedOreCount } from "./tables/TotalBurnedOreCount.sol";
import { SeedGrowth } from "./tables/SeedGrowth.sol";
import { PlayerActionNotif, PlayerActionNotifData } from "./tables/PlayerActionNotif.sol";
import { WorldStatus } from "./tables/WorldStatus.sol";
import { UniqueEntity } from "./tables/UniqueEntity.sol";
import { BaseEntity } from "./tables/BaseEntity.sol";
