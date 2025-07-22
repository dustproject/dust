// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "../src/types/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { DustTest } from "./DustTest.sol";

import { EntityPosition } from "../src/utils/Vec3Storage.sol";

import { BUILD_ENERGY_COST, CHUNK_SIZE, MAX_ENTITY_INFLUENCE_RADIUS, MAX_FLUID_LEVEL } from "../src/Constants.sol";
import { ObjectType } from "../src/types/ObjectType.sol";

import { NonPassableBlock } from "../src/systems/libraries/MoveLib.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { TestEntityUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract BuildTest is DustTest {
  function testBuildTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    assertEq(TerrainLib.getBlockType(buildCoord), ObjectTypes.Air, "Build coord is not air");
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertFalse(buildEntityId.exists(), "Build entity already exists");
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");

    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
  }

  function testBuildNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build non-terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
  }

  function testBuildMultiSize() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    Vec3 topCoord = buildCoord + vec3(0, 1, 0);
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    setObjectAtCoord(topCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.TextSign;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    (EntityId topEntityId,) = TestEntityUtils.getBlockAt(topCoord);
    assertTrue(topEntityId.exists(), "Top entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the TextSign object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build multi-size");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertEq(EntityObjectType.get(topEntityId), buildObjectType, "Top entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
    assertEq(Mass.getMass(topEntityId), 0, "Top entity mass is not correct");
  }

  function testBuildMultiSizeWithOrientation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    Vec3 negativeXCoord = buildCoord - vec3(1, 0, 0);
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    setObjectAtCoord(negativeXCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Bed;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    (EntityId negativeXEntity,) = TestEntityUtils.getBlockAt(negativeXCoord);
    assertTrue(negativeXEntity.exists(), "NegativeX entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the TextSign object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build multi-size");
    // Build with NegativeX orientation
    world.buildWithOrientation(aliceEntityId, buildCoord, inventorySlot, Orientation.wrap(1), "");
    endGasReport();

    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertEq(EntityObjectType.get(negativeXEntity), buildObjectType, "NegativeX entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
    assertEq(Mass.getMass(negativeXEntity), 0, "NegativeX entity mass is not correct");
  }

  function testJumpBuild() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("jump build");
    world.jumpBuild(aliceEntityId, inventorySlot, "");
    endGasReport();

    Vec3 playerCoordAfter = EntityPosition.get(aliceEntityId);
    assertEq(playerCoordAfter, playerCoord + vec3(0, 1, 0), "Player coord is not correct");

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(playerCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
  }

  function testBuildPassThroughAtPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    (,, Vec3 bobCoord) = spawnPlayerOnAirChunk(aliceCoord + vec3(0, 0, 3));

    ObjectType buildObjectType = ObjectTypes.FescueGrass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 4);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 4);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    world.build(aliceEntityId, bobCoord, inventorySlot, "");

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(bobCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");

    Vec3 aboveBobCoord = bobCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, aboveBobCoord, inventorySlot, "");
    (buildEntityId,) = TestEntityUtils.getBlockAt(aboveBobCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Top entity mass is not correct");

    vm.prank(alice);
    world.build(aliceEntityId, aliceCoord, inventorySlot, "");
    (buildEntityId,) = TestEntityUtils.getBlockAt(aliceCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Top entity mass is not correct");

    Vec3 aboveAliceCoord = aliceCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, aboveAliceCoord, inventorySlot, "");
    (buildEntityId,) = TestEntityUtils.getBlockAt(aboveAliceCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Top entity is not build object type");
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Top entity mass is not correct");
  }

  function testJumpBuildFailsIfPassThrough() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType buildObjectType = ObjectTypes.FescueGrass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    setObjectAtCoord(playerCoord + vec3(0, 2, 0), ObjectTypes.Grass);

    vm.prank(alice);
    vm.expectPartialRevert(NonPassableBlock.selector);
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
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Can only build on air or water");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    setObjectAtCoord(buildCoord, ObjectTypes.TextSign);

    Vec3 topCoord = buildCoord + vec3(0, 1, 0);

    vm.prank(alice);
    vm.expectRevert("Can only build on air or water");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    vm.prank(alice);
    vm.expectRevert("Can only build on air or water");
    world.build(aliceEntityId, topCoord, inventorySlot, "");
  }

  function testBuildFailsIfPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    (,, Vec3 bobCoord) = spawnPlayerOnAirChunk(aliceCoord + vec3(0, 0, 1));

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the GoldBar object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    TestInventoryUtils.addObject(airEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build where there are dropped objects");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, 0);
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Find the inventory slot with the Grass object
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

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
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use a slot that doesn't have the required object
    uint16 inventorySlot = 0; // assuming slot 0 is empty or has another item

    vm.prank(alice);
    vm.expectRevert("Cannot build non-block object");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use any slot for this test
    uint16 inventorySlot = 0;

    vm.expectRevert("Caller not allowed");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Air);
    ObjectType buildObjectType = ObjectTypes.Grass;
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertTrue(buildEntityId.exists(), "Build entity does not exist");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Use any slot for this test
    uint16 inventorySlot = 0;

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  // Water building tests
  function testBuildWaterloggableBlockOnWaterTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Find a water block from terrain
    Vec3 buildCoord = vec3(playerCoord.x() + 1, playerCoord.y(), playerCoord.z());
    assertEq(TerrainLib.getBlockType(buildCoord), ObjectTypes.Water, "Build coord should be water from terrain");

    // Verify it has fluid level from terrain
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water should have max fluid level");

    // Algae is waterloggable
    ObjectType buildObjectType = ObjectTypes.Algae;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build waterloggable block on water terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity should be algae");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Waterloggable blocks should maintain fluid level
    fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Waterloggable block should maintain water's fluid level");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
  }

  function testBuildNonWaterloggableBlockOnWaterTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, playerCoord.y(), playerCoord.z());
    assertEq(TerrainLib.getBlockType(buildCoord), ObjectTypes.Water, "Build coord should be water from terrain");

    // FescueGrass is NOT waterloggable
    ObjectType buildObjectType = ObjectTypes.FescueGrass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    vm.expectRevert("Cannot build on water with non-waterloggable block");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildWaterloggableBlockOnWaterNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create a water block as entity (not terrain)
    Vec3 buildCoord = vec3(playerCoord.x() + 1, playerCoord.y(), playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Water);

    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water entity should have max fluid level");

    ObjectType buildObjectType = ObjectTypes.Algae;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build waterloggable block on water non-terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity should be algae");

    // Waterloggable blocks should maintain fluid level
    fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Waterloggable block should maintain water's fluid level");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testBuildNonWaterloggableBlockOnWaterNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = vec3(playerCoord.x() + 1, playerCoord.y(), playerCoord.z());
    setObjectAtCoord(buildCoord, ObjectTypes.Water);

    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build non-waterloggable block on water non-terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity should be grass");

    // Non-waterloggable blocks should NOT remove fluid level
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Non-waterloggable block should have fluid level");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testJumpBuildOnWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Player is in water, try to jump build
    ObjectType buildObjectType = ObjectTypes.Stone;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    world.jumpBuild(aliceEntityId, inventorySlot, "");

    // Verify player moved up
    Vec3 newPlayerCoord = EntityPosition.get(aliceEntityId);
    assertEq(newPlayerCoord, playerCoord + vec3(0, 1, 0), "Player should move up");

    // Verify block was built at original position
    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(playerCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity should be stone");

    // Non-waterloggable block should NOT remove fluid
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(playerCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Stone should have fluid level");
  }
}
