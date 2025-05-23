// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";

import { Machine } from "../src/codegen/tables/Machine.sol";
import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";

import { BurnedResourceCount } from "../src/codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import {
  ChunkCommitment,
  EntityPosition,
  LocalEnergyPool,
  ResourcePosition,
  ReverseMovablePosition
} from "../src/utils/Vec3Storage.sol";

import {
  CHUNK_SIZE,
  DEFAULT_MINE_ENERGY_COST,
  DEFAULT_WOODEN_TOOL_MULTIPLIER,
  MACHINE_ENERGY_DRAIN_RATE,
  MAX_ENTITY_INFLUENCE_HALF_WIDTH,
  PLAYER_ENERGY_DRAIN_RATE,
  SPECIALIZED_WOODEN_TOOL_MULTIPLIER,
  TOOL_MINE_ENERGY_COST
} from "../src/Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypes } from "../src/ObjectType.sol";

import { EntityId } from "../src/EntityId.sol";

import { Orientation } from "../src/Orientation.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { TestEntityUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract MineTest is DustTest {
  function testMineTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = TerrainLib.getBlockType(mineCoord);
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("mine terrain with hand, entirely mined");
    world.mine(aliceEntityId, mineCoord, "");
    endGasReport();

    (EntityId mineEntityId, ObjectType objectType) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(objectType, ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMineTerrainRequiresMultipleMines() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = TerrainLib.getBlockType(mineCoord);
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction * 2);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("mine terrain with hand, partially mined");
    world.mine(aliceEntityId, mineCoord, "");
    endGasReport();

    (EntityId mineEntityId, ObjectType objectType) = TestEntityUtils.getBlockAt(mineCoord);

    assertEq(objectType, mineObjectType, "Mine entity is not mined object");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);

    snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    assertEq(TestEntityUtils.getObjectTypeAt(mineCoord), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMineRequiresMultipleMinesUntilDestroyed() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = TerrainLib.getBlockType(mineCoord);
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction * 2);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, mineCoord, "");

    (EntityId mineEntityId, ObjectType objectType) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(objectType, ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMineResource() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());

    setTerrainAtCoord(mineCoord, ObjectTypes.UnrevealedOre);
    ObjectType o = TerrainLib.getBlockType(mineCoord);
    assertEq(o, ObjectTypes.UnrevealedOre, "Didn't work");
    assertInventoryHasObject(aliceEntityId, ObjectTypes.UnrevealedOre, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);
    ObjectAmount[] memory oreAmounts = inventoryGetOreAmounts(aliceEntityId);
    assertEq(oreAmounts.length, 0, "Existing ores in inventory");
    assertEq(ResourceCount.get(ObjectTypes.UnrevealedOre), 0, "Mined resource count is not 0");

    vm.prank(alice);
    world.chunkCommit(aliceEntityId, mineCoord.toChunkCoord());

    vm.roll(vm.getBlockNumber() + 2);

    vm.prank(alice);
    startGasReport("mine Ore with hand, entirely mined");
    world.mineUntilDestroyed(aliceEntityId, mineCoord, "");
    endGasReport();

    (EntityId mineEntityId, ObjectType objectType) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(objectType, ObjectTypes.Air, "Entity should be air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, ObjectTypes.UnrevealedOre, 0);
    oreAmounts = inventoryGetOreAmounts(aliceEntityId);
    assertEq(oreAmounts.length, 1, "No ores in inventory");
    assertEq(oreAmounts[0].amount, 1, "Did not get exactly one ore");
    assertEq(ResourceCount.get(oreAmounts[0].objectType), 1, "Resource count was not updated");
    assertEq(ResourceCount.get(ObjectTypes.UnrevealedOre), 1, "Total resource count was not updated");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMineResourceTypeIsFixedAfterPartialMine() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());

    setTerrainAtCoord(mineCoord, ObjectTypes.UnrevealedOre);
    ObjectType o = TerrainLib.getBlockType(mineCoord);
    assertEq(o, ObjectTypes.UnrevealedOre, "Didn't work");

    vm.prank(alice);
    world.chunkCommit(aliceEntityId, mineCoord.toChunkCoord());

    vm.roll(vm.getBlockNumber() + 2);

    // First mining attempt - partially mines the ore
    vm.prank(alice);
    startGasReport("mine Ore with hand, partially mined");
    world.mine(aliceEntityId, mineCoord, "");
    endGasReport();

    // Check that the type has been set to specific resource
    (EntityId mineEntityId, ObjectType resourceType) = TestEntityUtils.getBlockAt(mineCoord);
    assertNotEq(resourceType, ObjectTypes.UnrevealedOre, "Resource type should have been set to a specific resource");

    // Verify mass has been set to the resource's
    uint128 mass = Mass.getMass(mineEntityId);
    uint128 expectedMass = ObjectPhysics.getMass(resourceType) - DEFAULT_MINE_ENERGY_COST;
    assertEq(mass, expectedMass, "Mass was not set correctly");

    // Roll forward many blocks to ensure the commitment expires
    vm.roll(vm.getBlockNumber() + 1000);

    // Try to mine again after commitment expired
    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    // Verify the resource type hasn't changed even though commitment expired
    resourceType = EntityObjectType.get(mineEntityId);
    assertNotEq(
      resourceType, ObjectTypes.UnrevealedOre, "Resource type should remain consistent after commitment expired"
    );

    // Verify mass has been set to the resource's
    mass = Mass.getMass(mineEntityId);
    expectedMass -= DEFAULT_MINE_ENERGY_COST;
    assertEq(mass, expectedMass, "Mass should decrease after another mining attempt");
  }

  function testMineNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("mine non-terrain with hand, entirely mined");
    world.mine(aliceEntityId, mineCoord, "");
    endGasReport();

    (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMineBedWithPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    // Give objects to the player to test that transfers work
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 1);
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.IronPick);

    Vec3 bedCoord = coord + vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to fully deplete after 1000 seconds (with 1 sleeping player)
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 1000;

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield
    setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: initialTimestamp,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Create bed
    EntityId bed = setObjectAtCoord(bedCoord, ObjectTypes.Bed, Orientation.wrap(44));

    vm.prank(alice);
    world.sleep(aliceEntityId, bed, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait more time so the player's energy is FULLY depleted in this period
    // + 1 so the player is fully drained
    uint128 playerDrainTime = initialPlayerEnergy / PLAYER_ENERGY_DRAIN_RATE + 1;
    uint128 timeDelta = 1000 seconds + playerDrainTime;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    (address bob, EntityId bobEntityId) = createTestPlayer(bedCoord - vec3(1, 0, 0));

    // Remove alice and drop inventory in the original coord
    vm.prank(bob);
    startGasReport("mine bed with player");
    world.mineUntilDestroyed(bobEntityId, bedCoord, "");
    endGasReport();

    // Check that the player got killed
    assertPlayerIsDead(aliceEntityId, coord);

    // bed entity id should now be air and contain the inventory
    assertEq(EntityObjectType.get(bed), ObjectTypes.Air, "Top entity is not air");
    assertInventoryHasObject(bed, ObjectTypes.Grass, 1);
    assertInventoryHasObject(bed, ObjectTypes.IronPick, 1);
  }

  function testMineMultiSize() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = ObjectTypes.TextSign;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);
    Vec3 topCoord = mineCoord + vec3(0, 1, 0);
    (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    (EntityId topEntityId,) = TestEntityUtils.getBlockAt(topCoord);
    assertTrue(TestEntityUtils.exists(mineEntityId), "Mine entity does not exist");
    assertTrue(TestEntityUtils.exists(topEntityId), "Top entity does not exist");
    assertEq(EntityObjectType.get(mineEntityId), mineObjectType, "Mine entity is not mine object type");
    assertEq(EntityObjectType.get(topEntityId), mineObjectType, "Top entity is not air");
    assertEq(Mass.getMass(mineEntityId), ObjectPhysics.getMass(mineObjectType), "Mine entity mass is not correct");
    assertEq(Mass.getMass(topEntityId), 0, "Top entity mass is not correct");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("mine multi-size with hand, entirely mined");
    world.mine(aliceEntityId, mineCoord, "");
    endGasReport();

    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertEq(EntityObjectType.get(topEntityId), ObjectTypes.Air, "Top entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not correct");
    assertEq(Mass.getMass(topEntityId), 0, "Top entity mass is not correct");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);

    uint16 signSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.TextSign);

    // Mine again but with a non-base coord
    vm.prank(alice);
    world.build(aliceEntityId, mineCoord, signSlot, "");

    (mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    (topEntityId,) = TestEntityUtils.getBlockAt(topCoord);
    assertTrue(TestEntityUtils.exists(mineEntityId), "Mine entity does not exist");
    assertTrue(TestEntityUtils.exists(topEntityId), "Top entity does not exist");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    vm.prank(alice);
    world.mine(aliceEntityId, topCoord, "");

    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertEq(EntityObjectType.get(topEntityId), ObjectTypes.Air, "Top entity is not air");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);
  }

  function testMineMultiSizeWithOrientation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = ObjectTypes.Bed;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType, Orientation.wrap(1));
    Vec3 relativeCoord = mineCoord - vec3(1, 0, 0);
    (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    (EntityId relativeEntityId,) = TestEntityUtils.getBlockAt(relativeCoord);
    assertTrue(TestEntityUtils.exists(mineEntityId), "Mine entity does not exist");
    assertTrue(TestEntityUtils.exists(relativeEntityId), "Relative entity does not exist");
    assertEq(EntityObjectType.get(mineEntityId), mineObjectType, "Mine entity is not mine object type");
    assertEq(EntityObjectType.get(relativeEntityId), mineObjectType, "Relative entity is not air");
    assertEq(Mass.getMass(mineEntityId), ObjectPhysics.getMass(mineObjectType), "Mine entity mass is not correct");
    assertEq(Mass.getMass(relativeEntityId), 0, "Relative entity mass is not correct");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, mineCoord, "");
    endGasReport();

    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertEq(EntityObjectType.get(relativeEntityId), ObjectTypes.Air, "Relative entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not correct");
    assertEq(Mass.getMass(relativeEntityId), 0, "Relative entity mass is not correct");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);

    uint16 bedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.Bed);

    // Mine again but with a non-base coord
    vm.prank(alice);
    world.buildWithOrientation(aliceEntityId, mineCoord, bedSlot, Orientation.wrap(1), "");

    (mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    (relativeEntityId,) = TestEntityUtils.getBlockAt(relativeCoord);
    assertTrue(TestEntityUtils.exists(mineEntityId), "Mine entity does not exist");
    assertTrue(TestEntityUtils.exists(relativeEntityId), "Top entity does not exist");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    vm.prank(alice);
    world.mine(aliceEntityId, relativeCoord, "");

    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertEq(EntityObjectType.get(relativeEntityId), ObjectTypes.Air, "Top entity is not air");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);
  }

  function testMineFailsIfInvalidBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = ObjectTypes.Air;
    setObjectAtCoord(mineCoord, mineObjectType);

    vm.prank(alice);
    vm.expectRevert("Object is not mineable");
    world.mine(aliceEntityId, mineCoord, "");

    setObjectAtCoord(mineCoord, ObjectTypes.Water);

    vm.prank(alice);
    vm.expectRevert("Object is not mineable");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    setObjectAtCoord(mineCoord, mineObjectType);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.mine(aliceEntityId, mineCoord, "");

    mineCoord = playerCoord - vec3(CHUNK_SIZE / 2 + 1, 0, 0);

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineKillsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    setObjectAtCoord(mineCoord, mineObjectType);

    Energy.set(aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1, drainRate: 0 }));

    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    assertPlayerIsDead(aliceEntityId, playerCoord);
  }

  function testMineFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Set player energy to exactly enough for one mine operation
    uint128 exactEnergy = DEFAULT_MINE_ENERGY_COST;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: exactEnergy, drainRate: 0 })
    );

    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    assertPlayerIsDead(aliceEntityId, playerCoord);
  }

  function testMineFailsIfInventoryFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    TestInventoryUtils.addObject(
      aliceEntityId, mineObjectType, ObjectTypes.Player.getMaxInventorySlots() * mineObjectType.getStackable()
    );

    vm.prank(alice);
    vm.expectRevert("Inventory is full");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    setObjectAtCoord(mineCoord, mineObjectType);

    vm.expectRevert("Caller not allowed");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.Dirt;
    setObjectAtCoord(mineCoord, mineObjectType);

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfHasEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(1, 0, 0);
    ObjectType mineObjectType = ObjectTypes.ForceField;
    EntityId mineEntityId = setObjectAtCoord(mineCoord, mineObjectType);
    Energy.set(mineEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 10000, drainRate: 0 }));

    vm.prank(alice);
    vm.expectRevert("Cannot mine a machine that has energy");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineAtChunkBoundary() public {
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Place player at chunk boundary
    Vec3 boundaryCoord = vec3(CHUNK_SIZE - 1, FLAT_CHUNK_GRASS_LEVEL, CHUNK_SIZE - 1);
    EntityPosition.set(aliceEntityId, boundaryCoord);

    // Try to mine block in adjacent chunk
    Vec3 mineCoord = vec3(CHUNK_SIZE, FLAT_CHUNK_GRASS_LEVEL, CHUNK_SIZE);

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineWithInsufficientEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Drain player's energy
    Energy.setEnergy(aliceEntityId, 0);

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());

    vm.prank(alice);
    vm.expectRevert("Entity has no energy");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineWithFullInventory() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Fill inventory
    for (uint256 i = 0; i < ObjectTypes.Player.getMaxInventorySlots(); i++) {
      TestInventoryUtils.addObjectToSlot(aliceEntityId, ObjectTypes.Dirt, 1, uint16(i));
    }

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    // Set a different object so it doesn't fit in the inventory
    setObjectAtCoord(mineCoord, ObjectTypes.Grass);

    vm.prank(alice);
    vm.expectRevert("Inventory is full");
    world.mineUntilDestroyed(aliceEntityId, mineCoord, "");
  }

  function testMineWithInvalidCoordinates() public {
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Try to mine at invalid coordinates
    Vec3 invalidCoord = vec3(type(int32).max, type(int32).max, type(int32).max);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.mine(aliceEntityId, invalidCoord, "");
  }

  function testMineWithMultiplePlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(playerCoord + vec3(1, 0, 1));

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = TerrainLib.getBlockType(mineCoord);
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction * 2);

    // First player mines partially
    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    // Second player tries to mine the same block
    vm.prank(bob);
    world.mine(bobEntityId, mineCoord, "");

    (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Block should be fully mined");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);
    assertInventoryHasObject(bobEntityId, mineObjectType, 1);
  }

  function testMineWithToolMultipliers() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    {
      Vec3 stoneCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
      ObjectType stoneType = ObjectTypes.Bedrock; // Has pick multiplier
      setObjectAtCoord(stoneCoord, stoneType);

      // Test pick on stone (should apply pick multiplier)
      uint128 pickMass = ObjectPhysics.getMass(ObjectTypes.WoodenPick);
      uint128 stoneMass = ObjectPhysics.getMass(stoneType);
      EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);
      uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);
      vm.prank(alice);
      world.mine(aliceEntityId, stoneCoord, slot, "");

      (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(stoneCoord);
      uint128 massReduction = TOOL_MINE_ENERGY_COST + pickMass / 10 * SPECIALIZED_WOODEN_TOOL_MULTIPLIER;
      uint128 expectedMass = stoneMass - massReduction;
      assertEq(Mass.getMass(mineEntityId), expectedMass, "Mass reduction incorrect for wooden pick on stone");
    }

    {
      Vec3 logCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 1);
      ObjectType logType = ObjectTypes.OakLog; // Has axe multiplier

      // Test axe on log (should apply axe multiplier)
      uint128 axeMass = ObjectPhysics.getMass(ObjectTypes.WoodenAxe);
      // Set a manual mass so that it is only partially mined
      uint128 logMass = axeMass * 1000;
      ObjectPhysics.setMass(logType, logMass);
      setObjectAtCoord(logCoord, logType);

      EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenAxe);
      uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);
      vm.prank(alice);
      world.mine(aliceEntityId, logCoord, slot, "");

      (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(logCoord);
      uint128 massReduction = TOOL_MINE_ENERGY_COST + axeMass / 10 * SPECIALIZED_WOODEN_TOOL_MULTIPLIER;
      uint128 expectedMass = logMass - massReduction;
      assertEq(Mass.getMass(mineEntityId), expectedMass, "Mass reduction incorrect for wooden axe on log");
    }

    {
      Vec3 stoneCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 2);
      ObjectType stoneType = ObjectTypes.Bedrock; // No multiplier
      setObjectAtCoord(stoneCoord, stoneType);

      // Test axe on stone (should apply default multiplier)
      uint128 axeMass = ObjectPhysics.getMass(ObjectTypes.WoodenAxe);
      uint128 stoneMass = ObjectPhysics.getMass(stoneType);
      EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenAxe);
      uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);
      vm.prank(alice);
      world.mine(aliceEntityId, stoneCoord, slot, "");

      (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(stoneCoord);
      uint128 massReduction = TOOL_MINE_ENERGY_COST + axeMass / 10 * DEFAULT_WOODEN_TOOL_MULTIPLIER;
      uint128 expectedMass = stoneMass - massReduction;
      assertEq(Mass.getMass(mineEntityId), expectedMass, "Mass reduction incorrect for wooden axe on stone");
    }
  }

  function testMineSmartEntity() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.NeptuniumPick);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = ObjectTypes.SpawnTile;
    setObjectAtCoord(mineCoord, mineObjectType);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    ResourceCount.set(ObjectTypes.NeptuniumOre, 3);

    vm.prank(alice);
    startGasReport("mine smart entity with tool, entirely mined");
    world.mineUntilDestroyed(aliceEntityId, mineCoord, slot, "");
    endGasReport();

    (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(mineCoord);
    assertEq(EntityObjectType.get(mineEntityId), ObjectTypes.Air, "Mine entity is not air");
    assertEq(Mass.getMass(mineEntityId), 0, "Mine entity mass is not 0");
    assertInventoryHasObject(aliceEntityId, mineObjectType, 1);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }
}
