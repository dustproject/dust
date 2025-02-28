// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BiomesTest } from "./BiomesTest.sol";
import { EntityId } from "../src/EntityId.sol";
import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";
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
import { ReversePlayerPosition } from "../src/codegen/tables/ReversePlayerPosition.sol";
import { Position } from "../src/codegen/tables/Position.sol";
import { OreCommitment } from "../src/codegen/tables/OreCommitment.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { InventoryCount } from "../src/codegen/tables/InventoryCount.sol";
import { InventorySlots } from "../src/codegen/tables/InventorySlots.sol";
import { ObjectType } from "../src/codegen/tables/ObjectType.sol";
import { TotalMinedOreCount } from "../src/codegen/tables/TotalMinedOreCount.sol";
import { MinedOreCount } from "../src/codegen/tables/MinedOreCount.sol";
import { TotalBurnedOreCount } from "../src/codegen/tables/TotalBurnedOreCount.sol";
import { MinedOrePosition } from "../src/codegen/tables/MinedOrePosition.sol";
import { InventoryEntity } from "../src/codegen/tables/InventoryEntity.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { PlayerStatus } from "../src/codegen/tables/PlayerStatus.sol";

import { massToEnergy } from "../src/utils/EnergyUtils.sol";
import { PlayerObjectID, AirObjectID, WaterObjectID, DirtObjectID, SpawnTileObjectID, GrassObjectID, ForceFieldObjectID, ChestObjectID, TextSignObjectID, WoodenPickObjectID, WoodenAxeObjectID } from "../src/ObjectTypeIds.sol";
import { ObjectTypeId } from "../src/ObjectTypeIds.sol";
import { CHUNK_SIZE, MAX_PLAYER_INFLUENCE_HALF_WIDTH, WORLD_BORDER_LOW_X } from "../src/Constants.sol";
import { VoxelCoord, VoxelCoordLib } from "../src/VoxelCoord.sol";
import { PickupData } from "../src/Types.sol";
import { TestUtils } from "./utils/TestUtils.sol";

contract DropTest is BiomesTest {
  using VoxelCoordLib for *;

  function testDropTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    setTerrainAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    uint16 numToTransfer = 10;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, numToTransfer);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), numToTransfer, "Inventory count is not 1");
    EntityId airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertFalse(airEntityId.exists(), "Drop entity already exists");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("drop terrain");
    world.drop(transferObjectTypeId, numToTransfer, dropCoord);
    endGasReport();

    airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertTrue(airEntityId.exists(), "Drop entity does not exist");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), numToTransfer, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 0, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 1, "Inventory slots is not 0");
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testDropNonTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    uint16 numToTransfer = 10;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, numToTransfer);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), numToTransfer, "Inventory count is not 1");
    EntityId airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertTrue(airEntityId.exists(), "Drop entity doesn't exist");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("drop non-terrain");
    world.drop(transferObjectTypeId, numToTransfer, dropCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), numToTransfer, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 0, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 1, "Inventory slots is not 0");
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testDropToolTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    setTerrainAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = WoodenPickObjectID;
    EntityId toolEntityId = addToolToInventory(aliceEntityId, transferObjectTypeId);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    EntityId airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertFalse(airEntityId.exists(), "Drop entity already exists");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("drop tool terrain");
    world.dropTool(toolEntityId, dropCoord);
    endGasReport();

    airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertTrue(airEntityId.exists(), "Drop entity does not exist");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 0, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 1, "Inventory slots is not 0");
    assertTrue(InventoryEntity.get(toolEntityId) == airEntityId, "Inventory entity is not air");
    assertFalse(
      TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId),
      "Inventory entity is not chest"
    );
    assertTrue(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId), "Inventory entity is not air");
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testDropToolNonTerrain() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = WoodenPickObjectID;
    EntityId toolEntityId = addToolToInventory(aliceEntityId, transferObjectTypeId);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    EntityId airEntityId = ReversePosition.get(dropCoord.x, dropCoord.y, dropCoord.z);
    assertTrue(airEntityId.exists(), "Drop entity already exists");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("drop tool non-terrain");
    world.dropTool(toolEntityId, dropCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 0, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 1, "Inventory slots is not 0");
    assertTrue(InventoryEntity.get(toolEntityId) == airEntityId, "Inventory entity is not air");
    assertFalse(
      TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId),
      "Inventory entity is not chest"
    );
    assertTrue(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId), "Inventory entity is not air");
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickup() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    uint16 numToPickup = 10;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, numToPickup);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), numToPickup, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("pickup");
    world.pickup(transferObjectTypeId, numToPickup, pickupCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), numToPickup, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 1, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 0, "Inventory slots is not 0");
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickupTool() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = WoodenPickObjectID;
    EntityId toolEntityId = addToolToInventory(airEntityId, transferObjectTypeId);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("pickup tool");
    world.pickupTool(toolEntityId, pickupCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 1, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 0, "Inventory slots is not 0");
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(InventoryEntity.get(toolEntityId) == aliceEntityId, "Inventory entity is not air");
    assertTrue(TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId), "Inventory entity is not chest");
    assertFalse(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId), "Inventory entity is not air");

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickupMultiple() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId objectObjectTypeId = GrassObjectID;
    uint16 numToPickup = 10;
    ObjectTypeId toolObjectTypeId = WoodenPickObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, objectObjectTypeId, numToPickup);
    EntityId toolEntityId = addToolToInventory(airEntityId, toolObjectTypeId);
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, toolObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, objectObjectTypeId), numToPickup, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("pickup multiple");
    PickupData[] memory pickupObjects = new PickupData[](1);
    pickupObjects[0] = PickupData({ objectTypeId: objectObjectTypeId, numToPickup: numToPickup });
    EntityId[] memory pickupTools = new EntityId[](1);
    pickupTools[0] = toolEntityId;
    world.pickupMultiple(pickupObjects, pickupTools, pickupCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, objectObjectTypeId), numToPickup, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, objectObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(aliceEntityId, toolObjectTypeId), 1, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 2, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 0, "Inventory slots is not 0");
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, objectObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, objectObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, toolObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, toolObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(InventoryEntity.get(toolEntityId) == aliceEntityId, "Inventory entity is not air");
    assertTrue(TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId), "Inventory entity is not chest");
    assertFalse(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId), "Inventory entity is not air");

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickupAll() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId objectObjectTypeId = GrassObjectID;
    uint16 numToPickup = 10;
    ObjectTypeId toolObjectTypeId1 = WoodenPickObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, objectObjectTypeId, numToPickup);
    EntityId toolEntityId1 = addToolToInventory(airEntityId, toolObjectTypeId1);
    ObjectTypeId toolObjectTypeId2 = WoodenAxeObjectID;
    EntityId toolEntityId2 = addToolToInventory(airEntityId, toolObjectTypeId2);
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId1), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId2), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(airEntityId, objectObjectTypeId), numToPickup, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    startGasReport("pickup all");
    world.pickupAll(pickupCoord);
    endGasReport();

    assertEq(InventoryCount.get(aliceEntityId, objectObjectTypeId), numToPickup, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, objectObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(aliceEntityId, toolObjectTypeId1), 1, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId1), 0, "Inventory count is not 0");
    assertEq(InventoryCount.get(aliceEntityId, toolObjectTypeId2), 1, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, toolObjectTypeId2), 0, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 3, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 0, "Inventory slots is not 0");
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, objectObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, objectObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, toolObjectTypeId1),
      "Inventory objects still has build object type"
    );
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, toolObjectTypeId2),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, toolObjectTypeId1),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(airEntityId, toolObjectTypeId2),
      "Inventory objects still has build object type"
    );
    assertTrue(InventoryEntity.get(toolEntityId1) == aliceEntityId, "Inventory entity is not air");
    assertTrue(InventoryEntity.get(toolEntityId2) == aliceEntityId, "Inventory entity is not air");
    assertTrue(
      TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId1),
      "Inventory entity is not chest"
    );
    assertFalse(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId1), "Inventory entity is not air");
    assertTrue(
      TestUtils.reverseInventoryEntityHasEntity(aliceEntityId, toolEntityId2),
      "Inventory entity is not chest"
    );
    assertFalse(TestUtils.reverseInventoryEntityHasEntity(airEntityId, toolEntityId2), "Inventory entity is not air");

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickupMinedChestDrops() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory chestCoord = VoxelCoord(playerCoord.x, playerCoord.y, playerCoord.z + 1);
    ObjectTypeMetadata.setMass(ChestObjectID, uint32(playerHandMassReduction - 1));
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ChestObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    uint16 numToPickup = 10;
    TestUtils.addToInventoryCount(chestEntityId, ChestObjectID, transferObjectTypeId, numToPickup);
    assertEq(InventoryCount.get(chestEntityId, transferObjectTypeId), numToPickup, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    vm.prank(alice);
    world.mine(chestCoord);

    EntityId airEntityId = ReversePosition.get(chestCoord.x, chestCoord.y, chestCoord.z);
    assertTrue(airEntityId.exists(), "Drop entity does not exist");
    assertTrue(ObjectType.get(airEntityId) == AirObjectID, "Drop entity is not air");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), numToPickup, "Inventory count is not 0");

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    VoxelCoord memory shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z);

    vm.prank(alice);
    world.pickupAll(chestCoord);

    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), numToPickup, "Inventory count is not 0");
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 0, "Inventory count is not 0");
    assertEq(InventorySlots.get(aliceEntityId), 2, "Inventory slots is not 0");
    assertEq(InventorySlots.get(airEntityId), 0, "Inventory slots is not 0");
    assertTrue(
      TestUtils.inventoryObjectsHasObjectType(aliceEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    assertFalse(
      TestUtils.inventoryObjectsHasObjectType(chestEntityId, transferObjectTypeId),
      "Inventory objects still has build object type"
    );
    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord.x, 0, shardCoord.z) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testPickupFailsIfInventoryFull() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    TestUtils.addToInventoryCount(
      aliceEntityId,
      PlayerObjectID,
      transferObjectTypeId,
      ObjectTypeMetadata.getMaxInventorySlots(PlayerObjectID) * ObjectTypeMetadata.getStackable(transferObjectTypeId)
    );
    assertEq(
      InventorySlots.get(aliceEntityId),
      ObjectTypeMetadata.getMaxInventorySlots(PlayerObjectID),
      "Inventory slots is not max"
    );

    vm.prank(alice);
    vm.expectRevert("Inventory is full");
    world.pickup(transferObjectTypeId, 1, pickupCoord);
  }

  function testDropFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;

    EntityId toolEntityId = randomEntityId();

    vm.prank(alice);
    vm.expectRevert("Not enough objects in the inventory");
    world.drop(GrassObjectID, 1, dropCoord);

    vm.prank(alice);
    vm.expectRevert("Entity does not own inventory item");
    world.dropTool(toolEntityId, dropCoord);
  }

  function testPickupFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;

    EntityId toolEntityId = randomEntityId();

    vm.prank(alice);
    vm.expectRevert("Not enough objects in the inventory");
    world.pickup(GrassObjectID, 1, dropCoord);

    vm.prank(alice);
    vm.expectRevert("Entity does not own inventory item");
    world.pickupTool(toolEntityId, dropCoord);
  }

  function testPickupFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(
      playerCoord.x + MAX_PLAYER_INFLUENCE_HALF_WIDTH + 1,
      playerCoord.y + 1,
      playerCoord.z
    );
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    vm.prank(alice);
    vm.expectRevert("Player is too far");
    world.pickup(transferObjectTypeId, 1, pickupCoord);

    pickupCoord = VoxelCoord(WORLD_BORDER_LOW_X - 1, playerCoord.y + 1, playerCoord.z);

    vm.prank(alice);
    vm.expectRevert("Cannot pickup outside the world border");
    world.pickup(transferObjectTypeId, 1, pickupCoord);
  }

  function testDropFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(
      playerCoord.x + MAX_PLAYER_INFLUENCE_HALF_WIDTH + 1,
      playerCoord.y + 1,
      playerCoord.z
    );
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");

    vm.prank(alice);
    vm.expectRevert("Player is too far");
    world.drop(transferObjectTypeId, 1, dropCoord);

    dropCoord = VoxelCoord(WORLD_BORDER_LOW_X - 1, playerCoord.y + 1, playerCoord.z);

    vm.prank(alice);
    vm.expectRevert("Cannot drop outside the world border");
    world.drop(transferObjectTypeId, 1, dropCoord);

    dropCoord = VoxelCoord(playerCoord.x - 1, playerCoord.y + 1, playerCoord.z);

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.drop(transferObjectTypeId, 1, dropCoord);
  }

  function testDropFailsIfNonAirBlock() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    setObjectAtCoord(dropCoord, DirtObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");

    vm.prank(alice);
    vm.expectRevert("Cannot drop on a non-air block");
    world.drop(transferObjectTypeId, 1, dropCoord);
  }

  function testPickupFailsIfNonAirBlock() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    setTerrainAtCoord(pickupCoord, AirObjectID);
    EntityId airEntityId = ReversePosition.get(pickupCoord.x, pickupCoord.y, pickupCoord.z);
    assertFalse(airEntityId.exists(), "Drop entity doesn't exists");

    vm.prank(alice);
    vm.expectRevert("No entity at pickup location");
    world.pickup(GrassObjectID, 1, pickupCoord);

    EntityId chestEntityId = setObjectAtCoord(pickupCoord, ChestObjectID);
    TestUtils.addToInventoryCount(chestEntityId, ChestObjectID, GrassObjectID, 1);

    vm.prank(alice);
    vm.expectRevert("Cannot pickup from a non-air block");
    world.pickup(GrassObjectID, 1, pickupCoord);
  }

  function testPickupFailsIfInvalidArgs() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    vm.prank(alice);
    vm.expectRevert("Object type is not a block or item");
    world.pickup(WoodenPickObjectID, 1, pickupCoord);

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.pickup(transferObjectTypeId, 0, pickupCoord);
  }

  function testDropFailsIfInvalidArgs() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    EntityId toolEntityId1 = addToolToInventory(aliceEntityId, WoodenPickObjectID);
    EntityId toolEntityId2 = addToolToInventory(aliceEntityId, WoodenAxeObjectID);

    vm.prank(alice);
    vm.expectRevert("Object type is not a block or item");
    world.drop(WoodenPickObjectID, 1, dropCoord);

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.drop(transferObjectTypeId, 0, dropCoord);

    vm.prank(alice);
    vm.expectRevert("Must drop at least one tool");
    world.dropTools(new EntityId[](0), dropCoord);

    vm.prank(alice);
    EntityId[] memory toolEntityIds = new EntityId[](2);
    toolEntityIds[0] = toolEntityId1;
    toolEntityIds[1] = toolEntityId2;
    vm.expectRevert("All tools must be of the same type");
    world.dropTools(toolEntityIds, dropCoord);
  }

  function testPickupFailsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    Energy.setEnergy(aliceEntityId, 1);

    vm.prank(alice);
    vm.expectRevert("Not enough energy");
    world.pickup(transferObjectTypeId, 1, pickupCoord);
  }

  function testDropFailsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");

    Energy.setEnergy(aliceEntityId, 1);

    vm.prank(alice);
    vm.expectRevert("Not enough energy");
    world.drop(transferObjectTypeId, 1, dropCoord);
  }

  function testPickupFailsIfNoPlayer() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    vm.expectRevert("Player does not exist");
    world.pickup(transferObjectTypeId, 1, pickupCoord);
  }

  function testDropFailsIfNoPlayer() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");

    vm.expectRevert("Player does not exist");
    world.drop(transferObjectTypeId, 1, dropCoord);
  }

  function testPickupFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory pickupCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(airEntityId, AirObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(airEntityId, transferObjectTypeId), 1, "Inventory count is not 1");
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 0, "Inventory count is not 0");

    PlayerStatus.setBedEntityId(aliceEntityId, randomEntityId());

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.pickup(transferObjectTypeId, 1, pickupCoord);
  }

  function testDropFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, VoxelCoord memory playerCoord) = setupAirChunkWithPlayer();

    VoxelCoord memory dropCoord = VoxelCoord(playerCoord.x, playerCoord.y + 1, playerCoord.z + 1);
    setObjectAtCoord(dropCoord, AirObjectID);
    ObjectTypeId transferObjectTypeId = GrassObjectID;
    TestUtils.addToInventoryCount(aliceEntityId, PlayerObjectID, transferObjectTypeId, 1);
    assertEq(InventoryCount.get(aliceEntityId, transferObjectTypeId), 1, "Inventory count is not 1");

    PlayerStatus.setBedEntityId(aliceEntityId, randomEntityId());

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.drop(transferObjectTypeId, 1, dropCoord);
  }
}
