// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BiomesTest } from "./BiomesTest.sol";
import { EntityId } from "../src/EntityId.sol";
import { Chip } from "../src/codegen/tables/Chip.sol";
import { ExploredChunk } from "../src/codegen/tables/ExploredChunk.sol";
import { ExploredChunkCount } from "../src/codegen/tables/ExploredChunkCount.sol";
import { ExploredChunkByIndex } from "../src/codegen/tables/ExploredChunkByIndex.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { ForceField } from "../src/codegen/tables/ForceField.sol";
import { LocalEnergyPool } from "../src/codegen/tables/LocalEnergyPool.sol";
import { ReversePosition } from "../src/codegen/tables/ReversePosition.sol";
import { Player } from "../src/codegen/tables/Player.sol";
import { PlayerPosition } from "../src/codegen/tables/PlayerPosition.sol";
import { Position } from "../src/codegen/tables/Position.sol";
import { OreCommitment } from "../src/codegen/tables/OreCommitment.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { InventoryCount } from "../src/codegen/tables/InventoryCount.sol";
import { InventorySlots } from "../src/codegen/tables/InventorySlots.sol";
import { ObjectType } from "../src/codegen/tables/ObjectType.sol";
import { TotalMinedOreCount } from "../src/codegen/tables/TotalMinedOreCount.sol";
import { MinedOreCount } from "../src/codegen/tables/MinedOreCount.sol";
import { TotalBurnedOreCount } from "../src/codegen/tables/TotalBurnedOreCount.sol";
import { MinedOrePosition } from "../src/codegen/tables/MinedOrePosition.sol";
import { ForceFieldMetadata } from "../src/codegen/tables/ForceFieldMetadata.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { massToEnergy } from "../src/utils/EnergyUtils.sol";
import { PlayerObjectID, AirObjectID, WaterObjectID, DirtObjectID, SpawnTileObjectID, GrassObjectID, ForceFieldObjectID, SmartChestObjectID, TextSignObjectID } from "../src/ObjectTypeIds.sol";
import { ObjectTypeId } from "../src/ObjectTypeIds.sol";
import { CHUNK_SIZE, MAX_PLAYER_INFLUENCE_HALF_WIDTH, WORLD_BORDER_LOW_X } from "../src/Constants.sol";
import { VoxelCoord, VoxelCoordLib } from "../src/VoxelCoord.sol";
import { TestUtils } from "./utils/TestUtils.sol";

contract BuildTest is BiomesTest {
  using VoxelCoordLib for *;

  function testBuildTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = spawnPlayerOnFlatChunk();

    VoxelCoord memory buildCoord = VoxelCoord(
      playerCoord.x == CHUNK_SIZE - 1 ? playerCoord.x - 1 : playerCoord.x + 1,
      FLAT_CHUNK_GRASS_LEVEL + 1,
      playerCoord.z
    );
    assertTrue(ObjectTypeId.wrap(TerrainLib.getBlockType(buildCoord)) == AirObjectID, "Build coord is not air");
    ObjectTypeId buildObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, buildObjectTypeId, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord.x, buildCoord.y, buildCoord.z);
    assertTrue(!buildEntityId.exists(), "Build entity already exists");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 1, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);
    VoxelCoord memory forceFieldShardCoord = buildCoord.toForceFieldShardCoord();
    uint128 localMassBefore = ForceFieldMetadata.getTotalMassInside(
      forceFieldShardCoord.x,
      forceFieldShardCoord.y,
      forceFieldShardCoord.z
    );

    vm.prank(alice);
    startGasReport("build terrain");
    world.build(buildObjectTypeId, buildCoord);
    endGasReport();

    buildEntityId = ReversePosition.get(buildCoord.x, buildCoord.y, buildCoord.z);
    assertTrue(ObjectType.get(buildEntityId) == buildObjectTypeId, "Build entity is not build object type");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 0, "Inventory count is not 0");
    assertTrue(InventorySlots.get(aliceEntityId) == 0, "Inventory slots is not 0");
    assertTrue(
      !TestUtils.inventoryObjectsHasObjectType(aliceEntityId, buildObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertTrue(Energy.getEnergy(aliceEntityId) == aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
    assertTrue(
      Mass.getMass(buildEntityId) == ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Build entity mass is not correct"
    );
    assertTrue(
      ForceFieldMetadata.getTotalMassInside(forceFieldShardCoord.x, forceFieldShardCoord.y, forceFieldShardCoord.z) ==
        localMassBefore + ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Force field mass is not correct"
    );
  }

  function testBuildNonTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = spawnPlayerOnAirChunk();

    VoxelCoord memory buildCoord = VoxelCoord(
      playerCoord.x == CHUNK_SIZE - 1 ? playerCoord.x - 1 : playerCoord.x + 1,
      FLAT_CHUNK_GRASS_LEVEL + 1,
      playerCoord.z
    );
    setObjectAtCoord(buildCoord, AirObjectID);
    ObjectTypeId buildObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, buildObjectTypeId, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord.x, buildCoord.y, buildCoord.z);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 1, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);
    VoxelCoord memory forceFieldShardCoord = buildCoord.toForceFieldShardCoord();
    uint128 localMassBefore = ForceFieldMetadata.getTotalMassInside(
      forceFieldShardCoord.x,
      forceFieldShardCoord.y,
      forceFieldShardCoord.z
    );

    vm.prank(alice);
    startGasReport("build non-terrain");
    world.build(buildObjectTypeId, buildCoord);
    endGasReport();

    assertTrue(ObjectType.get(buildEntityId) == buildObjectTypeId, "Build entity is not build object type");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 0, "Inventory count is not 0");
    assertTrue(InventorySlots.get(aliceEntityId) == 0, "Inventory slots is not 0");
    assertTrue(
      !TestUtils.inventoryObjectsHasObjectType(aliceEntityId, buildObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertTrue(Energy.getEnergy(aliceEntityId) == aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
    assertTrue(
      Mass.getMass(buildEntityId) == ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Build entity mass is not correct"
    );
    assertTrue(
      ForceFieldMetadata.getTotalMassInside(forceFieldShardCoord.x, forceFieldShardCoord.y, forceFieldShardCoord.z) ==
        localMassBefore + ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Force field mass is not correct"
    );
  }

  function testBuildMultiSize() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = spawnPlayerOnAirChunk();

    VoxelCoord memory buildCoord = VoxelCoord(
      playerCoord.x == CHUNK_SIZE - 1 ? playerCoord.x - 1 : playerCoord.x + 1,
      FLAT_CHUNK_GRASS_LEVEL + 1,
      playerCoord.z
    );
    VoxelCoord memory topCoord = VoxelCoord(buildCoord.x, buildCoord.y + 1, buildCoord.z);
    setObjectAtCoord(buildCoord, AirObjectID);
    setObjectAtCoord(topCoord, AirObjectID);
    ObjectTypeId buildObjectTypeId = TextSignObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, buildObjectTypeId, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord.x, buildCoord.y, buildCoord.z);
    EntityId topEntityId = ReversePosition.get(topCoord.x, topCoord.y, topCoord.z);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertTrue(topEntityId.exists(), "Top entity does not exist");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 1, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);
    VoxelCoord memory forceFieldShardCoord = buildCoord.toForceFieldShardCoord();
    uint128 localMassBefore = ForceFieldMetadata.getTotalMassInside(
      forceFieldShardCoord.x,
      forceFieldShardCoord.y,
      forceFieldShardCoord.z
    );

    vm.prank(alice);
    startGasReport("build multi-size");
    world.build(buildObjectTypeId, buildCoord);
    endGasReport();

    assertTrue(ObjectType.get(buildEntityId) == buildObjectTypeId, "Build entity is not build object type");
    assertTrue(ObjectType.get(topEntityId) == buildObjectTypeId, "Top entity is not build object type");
    assertTrue(InventoryCount.get(aliceEntityId, buildObjectTypeId) == 0, "Inventory count is not 0");
    assertTrue(InventorySlots.get(aliceEntityId) == 0, "Inventory slots is not 0");
    assertTrue(
      !TestUtils.inventoryObjectsHasObjectType(aliceEntityId, buildObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertTrue(Energy.getEnergy(aliceEntityId) == aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
    assertTrue(
      Mass.getMass(buildEntityId) == ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Build entity mass is not correct"
    );
    assertTrue(Mass.getMass(topEntityId) == 0, "Top entity mass is not correct");
    assertTrue(
      ForceFieldMetadata.getTotalMassInside(forceFieldShardCoord.x, forceFieldShardCoord.y, forceFieldShardCoord.z) ==
        localMassBefore + ObjectTypeMetadata.getMass(buildObjectTypeId),
      "Force field mass is not correct"
    );
  }

  function testJumpBuild() public {}

  function testBuildFailsIfNonAir() public {}

  function testBuildFailsInvalidBlock() public {}

  function testBuildFailsIfHasDroppedObjects() public {}

  function testBuildFailsIfInvalidCoord() public {}

  function testBuildFailsIfNotEnoughEnergy() public {}

  function testBuildFailsIfDoesntHaveBlock() public {}

  function testBuildFailsIfNoPlayer() public {}

  function testBuildFailsIfLoggedOut() public {}
}
