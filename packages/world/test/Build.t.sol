// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../src/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool, ReverseMovablePosition } from "../src/utils/Vec3Storage.sol";

import { BUILD_ENERGY_COST, CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH, MAX_FLUID_LEVEL } from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";
import { NonPassableBlock } from "../src/systems/libraries/MoveLib.sol";

import { EntityId, EntityTypeLib } from "../src/EntityId.sol";
import { Orientation } from "../src/Orientation.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { EntityFluidLevel } from "../src/codegen/tables/EntityFluidLevel.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
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

    Vec3 buildCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);
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

    // Grass is NOT waterloggable (it's solid)
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build non-waterloggable block on water terrain");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    (EntityId buildEntityId,) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(EntityObjectType.get(buildEntityId), buildObjectType, "Build entity should be grass");
    assertInventoryHasObject(aliceEntityId, buildObjectType, 0);

    // Non-waterloggable blocks should remove fluid level
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, 0, "Non-waterloggable block should have no fluid level");

    // Verify the fluid level was deleted from storage
    uint8 storedLevel = EntityFluidLevel.get(buildEntityId);
    assertEq(storedLevel, 0, "Fluid level should be deleted from storage");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(Mass.getMass(buildEntityId), ObjectPhysics.getMass(buildObjectType), "Build entity mass is not correct");
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

    // Non-waterloggable blocks should remove fluid level
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, 0, "Non-waterloggable block should have no fluid level");

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

    // Non-waterloggable block should remove fluid
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(playerCoord);
    assertEq(fluidLevel, 0, "Stone should have no fluid level");
  }

  // Water bucket placement tests
  function testBuildWaterWithBucketOnAir() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(1, 0, 0);
    assertEq(TestEntityUtils.getObjectTypeAt(buildCoord), ObjectTypes.Air, "Build coord should be air");

    // Add water bucket to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);

    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("build water with bucket on air");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    // Verify water was placed
    (EntityId waterEntityId, ObjectType waterType) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(waterType, ObjectTypes.Water, "Should have placed water");
    assertEq(EntityObjectType.get(waterEntityId), ObjectTypes.Water, "Entity should be water");

    // Verify fluid level
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water should have max fluid level");

    // Verify inventory: water bucket gone, empty bucket returned
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);

    // Verify bucket is in the same slot
    assertEq(
      InventorySlot.getObjectType(aliceEntityId, inventorySlot),
      ObjectTypes.Bucket,
      "Empty bucket should be in same slot"
    );

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testBuildWaterWithBucketOnWaterloggableBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(1, 0, 0);

    // Place a waterloggable block (Coral)
    setObjectAtCoord(buildCoord, ObjectTypes.Coral);
    assertEq(TestEntityUtils.getObjectTypeAt(buildCoord), ObjectTypes.Coral, "Build coord should be coral");

    // Add water bucket to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    vm.prank(alice);
    startGasReport("build water with bucket on waterloggable block");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
    endGasReport();

    // Verify coral remains but now has water
    (EntityId blockEntityId, ObjectType blockType) = TestEntityUtils.getBlockAt(buildCoord);
    assertEq(blockType, ObjectTypes.Coral, "Should still be coral");
    assertEq(EntityObjectType.get(blockEntityId), ObjectTypes.Coral, "Entity should still be coral");

    // Verify fluid level was added
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Coral should now have max fluid level");

    // Verify inventory updated
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);
  }

  function testBuildWaterWithBucketOnFullWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(1, 0, 0);
    assertEq(TerrainLib.getBlockType(buildCoord), ObjectTypes.Water, "Build coord should be water");

    // Verify water is already full (from terrain)
    assertEq(TestEntityUtils.getFluidLevelAt(buildCoord), MAX_FLUID_LEVEL, "Water should be full");

    // Add water bucket to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    // Should fail - water is already at max level
    vm.prank(alice);
    vm.expectRevert("Water is already at max level");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    // Verify inventory unchanged
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);
  }

  function testBuildWaterWithBucketOnNonWaterloggableBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(1, 0, 0);
    setObjectAtCoord(buildCoord, ObjectTypes.Stone);

    // Add water bucket to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    vm.prank(alice);
    vm.expectRevert("Can only build water on air or waterloggable blocks");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    // Verify inventory unchanged
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);
  }

  function testBuildWaterWithBucketMultipleTimes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Add multiple water buckets
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 3);

    // Place water three times
    for (uint256 i = 0; i < 3; i++) {
      Vec3 buildCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
      uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

      vm.prank(alice);
      world.build(aliceEntityId, buildCoord, slot, "");

      // Verify water placed
      assertEq(TestEntityUtils.getObjectTypeAt(buildCoord), ObjectTypes.Water, "Should be water");
      assertEq(TestEntityUtils.getFluidLevelAt(buildCoord), MAX_FLUID_LEVEL, "Should have max fluid");
    }

    // All water buckets should be converted to empty buckets
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 3);
  }

  function testBuildWaterWithBucketCreatesWaterSource() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 waterCoord = playerCoord + vec3(1, 0, 0);

    // Place water
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    vm.prank(alice);
    world.build(aliceEntityId, waterCoord, slot, "");

    // Now try to fill a bucket from the placed water
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Bucket, 1);
    uint16 bucketSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.Bucket);

    vm.prank(alice);
    world.fillBucket(aliceEntityId, waterCoord, bucketSlot);

    // Should have a water bucket again
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
  }

  function testCannotJumpBuildWithWaterBucket() public {
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Add water bucket
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    // Jump build gets the object type from slot (WaterBucket) which is not pass-through
    // So this should pass the initial check but fail when trying to build water
    vm.prank(alice);
    vm.expectRevert("Cannot jump build on a pass-through block");
    world.jumpBuild(aliceEntityId, slot, "");
  }

  function testBuildWaterOnDifferentTerrainTypes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test building water on various non-waterloggable terrain types
    ObjectType[5] memory invalidTerrains = [
      ObjectTypes.Grass,
      ObjectTypes.Stone,
      ObjectTypes.Dirt,
      ObjectTypes.Sand,
      ObjectTypes.FescueGrass // Pass-through but not waterloggable
    ];

    for (uint256 i = 0; i < invalidTerrains.length; i++) {
      Vec3 buildCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
      setObjectAtCoord(buildCoord, invalidTerrains[i]);

      TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
      uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

      vm.prank(alice);
      vm.expectRevert("Can only build water on air or waterloggable blocks");
      world.build(aliceEntityId, buildCoord, slot, "");

      // Remove the unused water bucket for next iteration
      TestInventoryUtils.removeObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    }
  }

  function testBuildWaterOnAllWaterloggableBlocks() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test building water on all waterloggable blocks
    ObjectType[3] memory waterloggableBlocks = [ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae];

    for (uint256 i = 0; i < waterloggableBlocks.length; i++) {
      Vec3 buildCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
      setObjectAtCoord(buildCoord, waterloggableBlocks[i]);

      TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
      uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

      vm.prank(alice);
      world.build(aliceEntityId, buildCoord, slot, "");

      // Verify the waterloggable block remains
      assertEq(
        TestEntityUtils.getObjectTypeAt(buildCoord),
        waterloggableBlocks[i],
        string.concat("Should still be ", vm.toString(uint16(ObjectType.unwrap(waterloggableBlocks[i]))))
      );

      // Verify fluid level was added
      assertEq(TestEntityUtils.getFluidLevelAt(buildCoord), MAX_FLUID_LEVEL, "Should have max fluid");

      // Verify inventory updated
      assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
      assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);

      // Remove bucket for next iteration
      TestInventoryUtils.removeObject(aliceEntityId, ObjectTypes.Bucket, 1);
    }
  }

  function testBuildWaterMaintainsFluidLevel() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 buildCoord = playerCoord + vec3(1, 0, 0);

    // Place water
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    vm.prank(alice);
    world.build(aliceEntityId, buildCoord, slot, "");

    // Get the entity and verify fluid level is stored
    EntityId waterEntity = EntityTypeLib.encodeBlock(buildCoord);
    uint8 storedFluidLevel = EntityFluidLevel.get(waterEntity);
    assertEq(storedFluidLevel, MAX_FLUID_LEVEL, "Fluid level should be stored as max");

    // Verify getFluidLevelAt also returns correct value
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(buildCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "getFluidLevelAt should return max fluid level");
  }

  function testBuildWaterPreservesWaterloggableBlockType() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Place each waterloggable block and add water to it
    Vec3 coralCoord = playerCoord + vec3(1, 0, 0);
    Vec3 anemonCoord = playerCoord + vec3(2, 0, 0);
    Vec3 algaeCoord = playerCoord + vec3(3, 0, 0);

    setObjectAtCoord(coralCoord, ObjectTypes.Coral);
    setObjectAtCoord(anemonCoord, ObjectTypes.SeaAnemone);
    setObjectAtCoord(algaeCoord, ObjectTypes.Algae);

    // Add water to each
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 3);

    // Water on coral
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);
    vm.prank(alice);
    world.build(aliceEntityId, coralCoord, slot, "");

    // Water on sea anemone
    slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);
    vm.prank(alice);
    world.build(aliceEntityId, anemonCoord, slot, "");

    // Water on algae
    slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);
    vm.prank(alice);
    world.build(aliceEntityId, algaeCoord, slot, "");

    // Verify all blocks maintained their original type
    assertEq(TestEntityUtils.getObjectTypeAt(coralCoord), ObjectTypes.Coral, "Coral should remain");
    assertEq(TestEntityUtils.getObjectTypeAt(anemonCoord), ObjectTypes.SeaAnemone, "Sea anemone should remain");
    assertEq(TestEntityUtils.getObjectTypeAt(algaeCoord), ObjectTypes.Algae, "Algae should remain");

    // All should have water
    assertEq(TestEntityUtils.getFluidLevelAt(coralCoord), MAX_FLUID_LEVEL, "Coral should have water");
    assertEq(TestEntityUtils.getFluidLevelAt(anemonCoord), MAX_FLUID_LEVEL, "Sea anemone should have water");
    assertEq(TestEntityUtils.getFluidLevelAt(algaeCoord), MAX_FLUID_LEVEL, "Algae should have water");
  }

  function testBuildWaterOnPartialWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 waterCoord = playerCoord + vec3(1, 0, 0);

    // Create water with partial fluid level
    setObjectAtCoord(waterCoord, ObjectTypes.Water);
    (EntityId waterEntityId,) = TestEntityUtils.getOrCreateBlockAt(waterCoord);
    EntityFluidLevel.set(waterEntityId, 7); // Half full

    // Verify it's partial
    assertEq(TestEntityUtils.getFluidLevelAt(waterCoord), 7, "Water should be half full");

    // Add water bucket
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    // Should be able to top it off
    vm.prank(alice);
    world.build(aliceEntityId, waterCoord, slot, "");

    // Verify water is now full
    assertEq(TestEntityUtils.getFluidLevelAt(waterCoord), MAX_FLUID_LEVEL, "Water should now be full");
    assertEq(TestEntityUtils.getObjectTypeAt(waterCoord), ObjectTypes.Water, "Should still be water");

    // Verify inventory updated
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);
  }

  function testCannotBuildWaterOnFullWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 waterCoord = playerCoord + vec3(1, 0, 0);

    // Verify water is already full
    assertEq(TestEntityUtils.getFluidLevelAt(waterCoord), MAX_FLUID_LEVEL, "Water should be full");

    // Add water bucket
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

    // Should fail - water is already full
    vm.prank(alice);
    vm.expectRevert("Water is already at max level");
    world.build(aliceEntityId, waterCoord, slot, "");

    // Verify inventory unchanged
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);
  }

  function testBuildWaterOnVariousFluidLevels() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test different fluid levels
    uint8[5] memory fluidLevels = [0, 3, 7, 10, 14];

    for (uint256 i = 0; i < fluidLevels.length; i++) {
      Vec3 waterCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);

      // Create water with specific fluid level
      setObjectAtCoord(waterCoord, ObjectTypes.Water);
      (EntityId waterEntityId,) = TestEntityUtils.getOrCreateBlockAt(waterCoord);
      EntityFluidLevel.set(waterEntityId, fluidLevels[i]);

      // Add water bucket
      TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
      uint16 slot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WaterBucket);

      // Should be able to fill it
      vm.prank(alice);
      world.build(aliceEntityId, waterCoord, slot, "");

      // Verify water is now full
      assertEq(
        TestEntityUtils.getFluidLevelAt(waterCoord),
        MAX_FLUID_LEVEL,
        string.concat("Water with level ", vm.toString(fluidLevels[i]), " should now be full")
      );
    }

    // All buckets should be converted
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 5);
  }
}
