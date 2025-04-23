// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../src/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { Player } from "../src/codegen/tables/Player.sol";

import { PlayerStatus } from "../src/codegen/tables/PlayerStatus.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import {
  LocalEnergyPool,
  MovablePosition,
  Position,
  ReverseMovablePosition,
  ReversePosition
} from "../src/utils/Vec3Storage.sol";

import { BUILD_ENERGY_COST, CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract BuildTest is DustTest {
  function testBuildTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    assertEq(TerrainLib.getBlockType(buildCoord), ObjectTypes.Air, "Build coord is not air");
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertFalse(buildEntityId.exists(), "Build entity already exists");
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    vm.prank(alice);
    startGasReport("build terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    buildEntityId = ReversePosition.get(buildCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");

    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);
    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
    assertEq(
      Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Build entity mass is not correct"
    );
  }

  function testBuildNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    vm.prank(alice);
    startGasReport("build non-terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);
    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
    assertEq(
      Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Build entity mass is not correct"
    );
  }

  function testBuildMultiSize() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    Vec3 topCoord = buildCoord + vec3(0, 1, 0);
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    setObjectAtCoord(topCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.TextSign;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    EntityId topEntityId = ReversePosition.get(topCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertTrue(topEntityId.exists(), "Top entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the TextSign object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    vm.prank(alice);
    startGasReport("build multi-size");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertEq(EntityObjectType.get(topEntityId), buildObjectType, "Top entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);
    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
    assertEq(
      Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Build entity mass is not correct"
    );
    assertEq(Mass.getMass(topEntityId), 0, "Top entity mass is not correct");
  }

  function testJumpBuild() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    vm.prank(alice);
    startGasReport("jump build");
    world.jumpBuild(aliceEntityId, inventorySlot, "");
    endGasReport();

    Vec3 playerCoordAfter = MovablePosition.get(aliceEntityId);
    assertEq(playerCoordAfter, playerCoord + vec3(0, 1, 0), "Player coord is not correct");

    EntityId buildEntityId = ReversePosition.get(playerCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);
    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
    assertEq(
      Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Build entity mass is not correct"
    );
  }

  function testBuildPassThroughAtPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    (,, Vec3 bobCoord) = spawnPlayerOnAirChunk(aliceCoord + vec3(0, 0, 3));

    ObjectType buildObjectType = ObjectTypes.FescueGrass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 4);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 4);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    world.build(aliceEntityId, bobCoord, inventorySlot, "");

    EntityId buildEntityId = ReversePosition.get(bobCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertEq(
      Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Build entity mass is not correct"
    );

    Vec3 aboveBobCoord = bobCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, aboveBobCoord, inventorySlot, "");
    buildEntityId = ReversePosition.get(aboveBobCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Top entity mass is not correct");

    vm.prank(alice);
    world.build(aliceEntityId, aliceCoord, inventorySlot, "");
    buildEntityId = ReversePosition.get(aliceCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Top entity mass is not correct");

    Vec3 aboveAliceCoord = aliceCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, aboveAliceCoord, inventorySlot, "");
    buildEntityId = ReversePosition.get(aboveAliceCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectTypeMetadata.getMass(buildObjectType), "Top entity mass is not correct");
  }

  function testJumpBuildFailsIfPassThrough() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType buildObjectType = ObjectTypes.FescueGrass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot jump build on a pass-through block");
    world.jumpBuild(aliceEntityId, inventorySlot, "");
  }

  function testJumpBuildFailsIfNonAir() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    setObjectAtCoord(playerCoord + vec3(0, 2, 0), ObjectTypes.Grass);

    vm.prank(alice);
    vm.expectRevert("Cannot move through a non-passable block");
    world.jumpBuild(aliceEntityId, inventorySlot, "");
  }

  function testJumpBuildFailsIfPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    Vec3 bobCoord = aliceCoord + vec3(0, 2, 0);
    setObjectAtCoord(bobCoord, ObjectTypes.Air);
    setObjectAtCoord(bobCoord + vec3(0, 1, 0), ObjectTypes.Air);
    createTestPlayer(bobCoord);

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot move through a player");
    world.jumpBuild(aliceEntityId, inventorySlot, "");
  }

  function testBuildFailsIfNonAir() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Grass);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build on a non-air block");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    setObjectAtCoord(buildCoord, ObjectTypes.TextSign);

    Vec3 topCoord = buildCoord + vec3(0, 1, 0);

    vm.prank(alice);
    vm.expectRevert("Cannot build on a non-air block");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    vm.prank(alice);
    vm.expectRevert("Cannot build on a non-air block");
    world.build(aliceEntityId, topCoord, inventorySlot, "");
  }

  function testBuildFailsIfPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    (,, Vec3 bobCoord) = spawnPlayerOnAirChunk(aliceCoord + vec3(0, 0, 1));

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build on a movable entity");
    world.build(aliceEntityId, bobCoord, inventorySlot, "");

    vm.prank(alice);
    vm.expectRevert("Cannot build on a movable entity");
    world.build(aliceEntityId, bobCoord + vec3(0, 1, 0), inventorySlot, "");

    vm.prank(alice);
    vm.expectRevert("Cannot build on a movable entity");
    world.build(aliceEntityId, aliceCoord, inventorySlot, "");
  }

  function testBuildFailsInvalidBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.GoldBar;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the GoldBar object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build non-block object");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfHasDroppedObjects() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    EntityId airEntityId = setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    TestInventoryUtils.addObject(airEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build where there are dropped objects");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    buildCoord = playerCoord - vec3(CHUNK_SIZE / 2 + 1, 0, 0);

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildKillsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    Energy.set(aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1, drainRate: 0 }));

    vm.prank(alice);
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    assertPlayerIsDead(aliceEntityId, playerCoord);

    // Verify the block was not built
    assertEq(EntityObjectType.get(buildEntityId), ObjectTypes.Air, "Build entity is not air");
  }

  function testBuildFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint8 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    // Set player energy to exactly enough for one build operation
    uint128 exactEnergy = BUILD_ENERGY_COST;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: exactEnergy, drainRate: 0 })
    );

    vm.prank(alice);
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    assertPlayerIsDead(aliceEntityId, playerCoord);

    // TODO: we might want to build the block in this case
    // Verify the block was not built
    assertEq(EntityObjectType.get(buildEntityId), ObjectTypes.Air, "Build entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);
  }

  function testBuildFailsIfEmptySlot() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use a slot that doesn't have the required object
    uint8 inventorySlot = 0; // assuming slot 0 is empty or has another item

    vm.prank(alice);
    vm.expectRevert("Cannot build non-block object");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use any slot for this test
    uint8 inventorySlot = 0;

    vm.expectRevert("Caller not allowed");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use any slot for this test
    uint8 inventorySlot = 0;

    PlayerStatus.setBedEntityId(aliceEntityId, randomEntityId());

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }
}
