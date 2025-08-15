// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";

import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";
import { SeedGrowth } from "../src/codegen/tables/SeedGrowth.sol";

import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";

import { ActivityType } from "../src/codegen/common.sol";
import { Death } from "../src/codegen/tables/Death.sol";
import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";

import { DustTest } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import {
  ACTION_MODIFIER_DENOMINATOR,
  BARE_HANDS_ACTION_ENERGY_COST,
  BARE_HANDS_ACTION_ENERGY_COST,
  CHUNK_SIZE,
  MACHINE_ENERGY_DRAIN_RATE,
  MAX_ENTITY_INFLUENCE_RADIUS,
  MAX_FLUID_LEVEL,
  MAX_PLAYER_ENERGY,
  MINE_ACTION_MODIFIER,
  PLAYER_ENERGY_DRAIN_RATE,
  SPECIALIZATION_MULTIPLIER,
  TOOL_ACTION_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../src/Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";

import { EntityFluidLevel } from "../src/codegen/tables/EntityFluidLevel.sol";
import { EntityId } from "../src/types/EntityId.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { TestEntityUtils, TestInventoryUtils, TestPlayerProgressUtils } from "./utils/TestUtils.sol";

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
    Energy.set(
      aliceEntityId,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: MAX_PLAYER_ENERGY * 1000, drainRate: 0 })
    );

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

  function testMineImmatureSeed() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

    Vec3 seedCoord = farmlandCoord + vec3(0, 1, 0);

    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    // Check initial local energy pool
    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    // Plant wheat seeds
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, seedSlot, "");

    // Verify seeds were planted
    (EntityId cropEntityId,) = TestEntityUtils.getBlockAt(seedCoord);
    assertTrue(cropEntityId.exists(), "Crop entity doesn't exist after planting");
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.WheatSeed, "Wheat seeds were not planted correctly");

    // Verify build time was set
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);
    assertEq(
      fullyGrownAt, uint128(block.timestamp) + ObjectTypes.WheatSeed.getTimeToGrow(), "Incorrect fullyGrownAt set"
    );

    // Attempt to mine the not grown seed
    vm.prank(alice);
    startGasReport("mine immature seed with hand");
    world.mineUntilDestroyed(aliceEntityId, seedCoord, "");
    endGasReport();

    // Verify seeds were added to inventory
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 0);
  }

  function testMineMatureSeed() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

    // Set seed count to 1 so we can grow it
    ResourceCount.set(ObjectTypes.WheatSeed, 1);
    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    Vec3 cropCoord = farmlandCoord + vec3(0, 1, 0);

    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    // Plant wheat seeds
    vm.prank(alice);
    world.build(aliceEntityId, cropCoord, seedSlot, "");

    // Verify seeds were planted
    (EntityId cropEntityId,) = TestEntityUtils.getBlockAt(cropCoord);
    assertTrue(cropEntityId.exists(), "Crop entity doesn't exist after planting");

    // Get growth time required for the crop
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);

    // Advance time beyond the growth period but don't grow it manually
    vm.warp(fullyGrownAt);

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, cropCoord, bytes32(0));

    // Check local energy pool before harvesting
    uint128 initialLocalEnergy = LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord());

    // Harvest the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, farmlandCoord + vec3(0, 1, 0), "");

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 2, "Wheat seeds were not removed from circulation");

    // Verify drops
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 2);

    // Verify crop no longer exists
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.Air, "Crop wasn't removed after harvesting");

    // Verify local energy pool has changed (from player's energy cost)
    assertEq(
      LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord()),
      initialLocalEnergy + ObjectPhysics.getMass(ObjectTypes.Wheat),
      "Local energy pool shouldn't change after harvesting mature crop"
    );
  }

  function testMineBelowGrowable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

    // Set seed count to 1 so we can grow it
    ResourceCount.set(ObjectTypes.WheatSeed, 1);
    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    Vec3 cropCoord = farmlandCoord + vec3(0, 1, 0);

    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    // Plant wheat seeds
    vm.prank(alice);
    world.build(aliceEntityId, cropCoord, seedSlot, "");

    // Verify seeds were planted
    (EntityId cropEntityId,) = TestEntityUtils.getBlockAt(cropCoord);
    assertTrue(cropEntityId.exists(), "Crop entity doesn't exist after planting");

    // Get growth time required for the crop
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);

    // Advance time beyond the growth period but don't grow it manually
    vm.warp(fullyGrownAt);

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, cropCoord, bytes32(0));

    // Harvest the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, farmlandCoord, "");

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 2, "Seed drop was not removed from circulation");

    // Verify drops
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 2);

    // Verify crop no longer exists
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.Air, "Crop wasn't removed after harvesting");
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
    uint128 expectedMass = ObjectPhysics.getMass(resourceType) - BARE_HANDS_ACTION_ENERGY_COST;
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
    expectedMass -= BARE_HANDS_ACTION_ENERGY_COST;
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

  function testMineBedWithDeadPlayer() public {
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

  function testMineBedWithSleepingPlayerWithEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    // Give objects to the player to test that transfers work
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 1);
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.IronPick);

    Vec3 bedCoord = coord + vec3(2, 0, 0);

    // Set a high forcefield energy so it doesn't deplete
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 10000;

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

    // Advance time but not enough to deplete player energy
    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Verify player still has energy
    uint128 playerEnergy = Energy.getEnergy(aliceEntityId);
    assertGt(playerEnergy, 0, "Player should still have energy");

    (address bob, EntityId bobEntityId) = createTestPlayer(bedCoord - vec3(1, 0, 0));

    // Try to mine the bed with sleeping player
    vm.prank(bob);
    startGasReport("mine bed with sleeping player with energy");
    world.mineUntilDestroyed(bobEntityId, bedCoord, "");
    endGasReport();

    // Check that the player is not dead but spawned at bed position
    assertFalse(Death.getLastDiedAt(aliceEntityId) > 0, "Player should not be dead");

    // Player should be at bed position
    Vec3 playerPos = EntityPosition.get(aliceEntityId);
    assertEq(playerPos.x(), bedCoord.x(), "Player should be at bed x position");
    assertEq(playerPos.y(), bedCoord.y(), "Player should be at bed y position");
    assertEq(playerPos.z(), bedCoord.z(), "Player should be at bed z position");

    // bed entity id should now be air
    assertEq(EntityObjectType.get(bed), ObjectTypes.Air, "Bed entity is not air");

    // Player should still have their inventory
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
  }

  function testMineBedWithBlockedSpawnPosition() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord + vec3(2, 0, 0);

    // Set a high forcefield energy so it doesn't deplete
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 10000;

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

    // Block the spawn position above the bed
    setObjectAtCoord(bedCoord + vec3(0, 1, 0), ObjectTypes.Stone);

    vm.prank(alice);
    world.sleep(aliceEntityId, bed, "");

    // Advance time slightly
    vm.warp(vm.getBlockTimestamp() + 100 seconds);

    (address bob, EntityId bobEntityId) = createTestPlayer(bedCoord - vec3(1, 0, 0));

    // Try to mine the bed - should fail because spawn position is blocked
    vm.prank(bob);
    vm.expectRevert("Cannot spawn on a non-passable block");
    world.mineUntilDestroyed(bobEntityId, bedCoord, "");

    // Bed should still exist
    assertEq(EntityObjectType.get(bed), ObjectTypes.Bed, "Bed should still exist");

    // Player should still be sleeping
    assertEq(PlayerBed.getBedEntityId(aliceEntityId), bed, "Player should still be in bed");
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
    assertTrue(mineEntityId.exists(), "Mine entity does not exist");
    assertTrue(topEntityId.exists(), "Top entity does not exist");
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
    assertTrue(mineEntityId.exists(), "Mine entity does not exist");
    assertTrue(topEntityId.exists(), "Top entity does not exist");
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
    assertTrue(mineEntityId.exists(), "Mine entity does not exist");
    assertTrue(relativeEntityId.exists(), "Relative entity does not exist");
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
    assertTrue(mineEntityId.exists(), "Mine entity does not exist");
    assertTrue(relativeEntityId.exists(), "Top entity does not exist");
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

    setObjectAtCoord(mineCoord, ObjectTypes.Bedrock);

    vm.prank(alice);
    vm.expectRevert("Object is not mineable");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 mineCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, 0);
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
    uint128 exactEnergy = BARE_HANDS_ACTION_ENERGY_COST;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: exactEnergy, drainRate: 0 })
    );

    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    assertPlayerIsDead(aliceEntityId, playerCoord);
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

  function testMinePaused() public {
    WorldStatus.setIsPaused(true);

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 mineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    ObjectType mineObjectType = TerrainLib.getBlockType(mineCoord);
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    assertInventoryHasObject(aliceEntityId, mineObjectType, 0);

    vm.prank(alice);
    vm.expectRevert("DUST is paused. Try again later");
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
    vm.expectRevert("Coordinate is not reachable");
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
    world.mineUntilDestroyed(aliceEntityId, mineCoord, "");
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Dirt, ObjectTypes.Player.getMaxInventorySlots());
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 0);

    (EntityId mined,) = TestEntityUtils.getBlockAt(mineCoord);
    assertInventoryHasObject(mined, ObjectTypes.Grass, 1);
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
      ObjectType stoneType = ObjectTypes.Obsidian; // Has pick multiplier
      setObjectAtCoord(stoneCoord, stoneType);

      // Test pick on stone (should apply pick multiplier)
      uint128 pickMass = ObjectPhysics.getMass(ObjectTypes.WoodenPick);
      uint128 stoneMass = ObjectPhysics.getMass(stoneType);
      EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);
      uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);
      vm.prank(alice);
      world.mine(aliceEntityId, stoneCoord, slot, "");

      (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(stoneCoord);
      // Calculate expected multiplier: wooden base (3) * mine modifier (1) * specialization (3) = 9
      uint128 expectedMultiplier = WOODEN_TOOL_BASE_MULTIPLIER * MINE_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;
      uint128 massReduction = TOOL_ACTION_ENERGY_COST + pickMass / 10 * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;
      uint128 expectedMass = stoneMass - massReduction;
      assertEq(Mass.getMass(mineEntityId), expectedMass, "Mass reduction incorrect for wooden pick on stone");

      // Check player activity tracking
      uint256 pickActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MinePickMass);
      assertEq(pickActivity, massReduction, "Pick mining activity not tracked correctly");
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
      // Calculate expected multiplier: wooden base (3) * mine modifier (1) * specialization (3) = 9
      uint128 expectedMultiplier = WOODEN_TOOL_BASE_MULTIPLIER * MINE_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;
      uint128 massReduction = TOOL_ACTION_ENERGY_COST + axeMass / 10 * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;
      uint128 expectedMass = logMass - massReduction;
      assertEq(Mass.getMass(mineEntityId), expectedMass, "Mass reduction incorrect for wooden axe on log");

      // Check player activity tracking
      uint256 axeActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineAxeMass);
      assertEq(axeActivity, massReduction, "Axe mining activity not tracked correctly");
    }

    {
      Vec3 stoneCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 2);
      ObjectType stoneType = ObjectTypes.Obsidian; // No multiplier
      setObjectAtCoord(stoneCoord, stoneType);

      // Test axe on stone (should apply default multiplier)
      uint128 axeMass = ObjectPhysics.getMass(ObjectTypes.WoodenAxe);
      uint128 stoneMass = ObjectPhysics.getMass(stoneType);
      EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenAxe);
      uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);
      vm.prank(alice);
      world.mine(aliceEntityId, stoneCoord, slot, "");

      (EntityId mineEntityId,) = TestEntityUtils.getBlockAt(stoneCoord);
      // Calculate expected multiplier: wooden base (3) * mine modifier (1) * no specialization = 3
      uint128 expectedMultiplier = WOODEN_TOOL_BASE_MULTIPLIER * MINE_ACTION_MODIFIER;
      uint128 massReduction = TOOL_ACTION_ENERGY_COST + axeMass / 10 * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;
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

  // Water/fluid tests for mining
  function testMineUnderwaterBlockReplacesWithWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Place an algae block underwater
    Vec3 algaeCoord = playerCoord + vec3(1, 0, 0);
    // This will set initial fluid level to max
    setObjectAtCoord(algaeCoord, ObjectTypes.Algae);

    // Verify fluid level is set
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(algaeCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Algae should have max fluid level");

    // Mine the algae
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, algaeCoord, "");

    // Check that the block is replaced with water, not air
    (EntityId minedEntityId, ObjectType minedType) = TestEntityUtils.getBlockAt(algaeCoord);
    assertEq(minedType, ObjectTypes.Water, "Mined underwater block should be replaced with water");
    assertEq(EntityObjectType.get(minedEntityId), ObjectTypes.Water, "Entity should be water");

    // Fluid level should still be max
    fluidLevel = TestEntityUtils.getFluidLevelAt(algaeCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water replacement should have max fluid level");
  }

  function testMineDryBlockReplacedWithAir() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Place a algae block in air
    Vec3 algaeCoord = playerCoord + vec3(1, 0, 0);
    setObjectAtCoord(algaeCoord, ObjectTypes.Algae);

    (EntityId algaeEntityId,) = TestEntityUtils.getBlockAt(algaeCoord);
    EntityFluidLevel.set(algaeEntityId, 0); // Set fluid level to 0 to simulate dry block

    // Mine the algae
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, algaeCoord, "");

    // Check that the block is replaced with air
    (EntityId minedEntityId, ObjectType minedType) = TestEntityUtils.getBlockAt(algaeCoord);
    assertEq(minedType, ObjectTypes.Air, "Mined dry block should be replaced with air");
    assertEq(EntityObjectType.get(minedEntityId), ObjectTypes.Air, "Entity should be air");
  }

  function testMineBlockWithFluidFromTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Find a water block from terrain that hasn't been initialized as entity
    Vec3 waterCoord = playerCoord + vec3(2, 0, 0);

    // Place a mineable block there
    setTerrainAtCoord(waterCoord, ObjectTypes.Algae);

    // Verify fluid level comes from terrain type
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(waterCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Algae should have max fluid level from terrain");

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, waterCoord, "");

    // Should be replaced with water
    (, ObjectType minedType) = TestEntityUtils.getBlockAt(waterCoord);
    assertEq(minedType, ObjectTypes.Water, "Should be replaced with water");
  }

  function testMineBlockThatSpawnsWithFluidNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test each block type that spawns with fluid
    ObjectType[3] memory fluidBlocks = [ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae];

    for (uint256 i = 0; i < fluidBlocks.length; i++) {
      Vec3 blockCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
      ObjectType blockType = fluidBlocks[i];

      // Place the block
      setObjectAtCoord(blockCoord, blockType);

      // Verify it has fluid level
      uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(blockCoord);
      assertEq(fluidLevel, MAX_FLUID_LEVEL, "Block that spawns with fluid should have max level");

      // Mine it
      vm.prank(alice);
      world.mineUntilDestroyed(aliceEntityId, blockCoord, "");

      // Should be replaced with water (except for water itself which becomes air)
      (, ObjectType minedType) = TestEntityUtils.getBlockAt(blockCoord);
      assertEq(minedType, ObjectTypes.Water, "Blocks with fluid should be replaced with water when mined");
    }
  }

  // Reachability tests

  function testMineFailsWhenCompletelyEnclosed() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create a block completely surrounded by solid blocks
    Vec3 targetCoord = playerCoord + vec3(5, 0, 0);

    // Place solid blocks on all 6 sides
    setObjectAtCoord(targetCoord + vec3(1, 0, 0), ObjectTypes.Stone); // Right
    setObjectAtCoord(targetCoord + vec3(-1, 0, 0), ObjectTypes.Stone); // Left
    setObjectAtCoord(targetCoord + vec3(0, 1, 0), ObjectTypes.Stone); // Above
    setObjectAtCoord(targetCoord + vec3(0, -1, 0), ObjectTypes.Stone); // Below
    setObjectAtCoord(targetCoord + vec3(0, 0, 1), ObjectTypes.Stone); // Front
    setObjectAtCoord(targetCoord + vec3(0, 0, -1), ObjectTypes.Stone); // Back

    // Place target block
    setObjectAtCoord(targetCoord, ObjectTypes.Dirt);

    // Move player close enough to mine
    EntityPosition.set(aliceEntityId, targetCoord + vec3(2, 0, 0));

    // Try to mine - should fail
    vm.prank(alice);
    vm.expectRevert("Coordinate is not reachable");
    world.mine(aliceEntityId, targetCoord, "");
  }

  function testMineSucceedsWithSingleAirNeighbor() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create a block with 5 solid neighbors and 1 air
    Vec3 targetCoord = playerCoord + vec3(5, 0, 0);

    // Place solid blocks on 5 sides
    setObjectAtCoord(targetCoord + vec3(1, 0, 0), ObjectTypes.Stone); // Right
    setObjectAtCoord(targetCoord + vec3(-1, 0, 0), ObjectTypes.Stone); // Left
    setObjectAtCoord(targetCoord + vec3(0, 1, 0), ObjectTypes.Stone); // Above
    setObjectAtCoord(targetCoord + vec3(0, -1, 0), ObjectTypes.Stone); // Below
    setObjectAtCoord(targetCoord + vec3(0, 0, 1), ObjectTypes.Stone); // Front
    // Back is air (not set)

    // Place target block
    setObjectAtCoord(targetCoord, ObjectTypes.Dirt);

    // Move player close enough to mine
    EntityPosition.set(aliceEntityId, targetCoord + vec3(2, 0, 0));

    // Try to mine - should succeed
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, targetCoord, "");

    // Verify it was mined
    assertEq(TestEntityUtils.getObjectTypeAt(targetCoord), ObjectTypes.Air, "Block should be mined");
  }

  function testMineSucceedsWithWaterNeighbor() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create a block with solid neighbors except one water
    Vec3 targetCoord = playerCoord + vec3(5, 0, 0);

    // Place solid blocks on 5 sides
    setObjectAtCoord(targetCoord + vec3(1, 0, 0), ObjectTypes.Stone); // Right
    setObjectAtCoord(targetCoord + vec3(-1, 0, 0), ObjectTypes.Stone); // Left
    setObjectAtCoord(targetCoord + vec3(0, 1, 0), ObjectTypes.Stone); // Above
    setObjectAtCoord(targetCoord + vec3(0, -1, 0), ObjectTypes.Stone); // Below
    setObjectAtCoord(targetCoord + vec3(0, 0, 1), ObjectTypes.Stone); // Front
    setObjectAtCoord(targetCoord + vec3(0, 0, -1), ObjectTypes.Water); // Back is water

    // Place target block
    setObjectAtCoord(targetCoord, ObjectTypes.Dirt);

    // Move player close enough to mine
    EntityPosition.set(aliceEntityId, targetCoord + vec3(2, 0, 0));

    // Try to mine - should succeed
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, targetCoord, "");

    // Verify it was mined
    assertEq(TestEntityUtils.getObjectTypeAt(targetCoord), ObjectTypes.Air, "Block should be mined");
  }

  function testMineSucceedsWithVariousPassthroughNeighbors() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Test different passthrough types
    ObjectType[4] memory passthroughTypes =
      [ObjectTypes.Torch, ObjectTypes.WheatSeed, ObjectTypes.FescueGrass, ObjectTypes.OakSapling];

    for (uint256 i = 0; i < passthroughTypes.length; i++) {
      Vec3 targetCoord = playerCoord + vec3(5, int32(int256(i * 2)), 0);

      // Place solid blocks on all sides except one
      setObjectAtCoord(targetCoord + vec3(1, 0, 0), ObjectTypes.Stone);
      setObjectAtCoord(targetCoord + vec3(-1, 0, 0), ObjectTypes.Stone);
      setObjectAtCoord(targetCoord + vec3(0, 1, 0), ObjectTypes.Stone);
      setObjectAtCoord(targetCoord + vec3(0, -1, 0), ObjectTypes.Stone);
      setObjectAtCoord(targetCoord + vec3(0, 0, 1), ObjectTypes.Stone);

      // Place passthrough neighbor
      setObjectAtCoord(targetCoord + vec3(0, 0, -1), passthroughTypes[i]);

      // Place target block
      setObjectAtCoord(targetCoord, ObjectTypes.Dirt);

      // Move player close enough
      EntityPosition.set(aliceEntityId, targetCoord + vec3(2, 0, 0));

      // Should succeed
      vm.prank(alice);
      world.mineUntilDestroyed(aliceEntityId, targetCoord, "");

      assertEq(
        TestEntityUtils.getObjectTypeAt(targetCoord),
        ObjectTypes.Air,
        "Block should be minable with passthrough neighbor"
      );
    }
  }

  function testMineReachabilityAtDifferentHeights() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Test underground (negative Y)
    Vec3 undergroundCoord = vec3(playerCoord.x() + 5, -10, playerCoord.z());

    // Surround with stone except top
    setObjectAtCoord(undergroundCoord + vec3(1, 0, 0), ObjectTypes.Stone);
    setObjectAtCoord(undergroundCoord + vec3(-1, 0, 0), ObjectTypes.Stone);
    setObjectAtCoord(undergroundCoord + vec3(0, -1, 0), ObjectTypes.Stone);
    setObjectAtCoord(undergroundCoord + vec3(0, 0, 1), ObjectTypes.Stone);
    setObjectAtCoord(undergroundCoord + vec3(0, 0, -1), ObjectTypes.Stone);
    // Top is air

    setObjectAtCoord(undergroundCoord, ObjectTypes.Dirt);
    EntityPosition.set(aliceEntityId, undergroundCoord + vec3(2, 0, 0));

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, undergroundCoord, "");
    assertEq(TestEntityUtils.getObjectTypeAt(undergroundCoord), ObjectTypes.Air, "Underground block should be minable");

    // Test high altitude
    Vec3 skyCoord = vec3(playerCoord.x() + 5, 100, playerCoord.z());

    // Only place bottom neighbor as solid
    setObjectAtCoord(skyCoord + vec3(0, -1, 0), ObjectTypes.Stone);
    // All other sides are air

    setObjectAtCoord(skyCoord, ObjectTypes.Dirt);
    EntityPosition.set(aliceEntityId, skyCoord + vec3(1, 0, 0));

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, skyCoord, "");
    assertEq(TestEntityUtils.getObjectTypeAt(skyCoord), ObjectTypes.Air, "Sky block should be minable");
  }

  function testMineMixedNeighborTypes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 targetCoord = playerCoord + vec3(5, 0, 0);

    // Mix of solid blocks, air, water, and small objects
    setObjectAtCoord(targetCoord + vec3(1, 0, 0), ObjectTypes.Stone); // Solid
    setObjectAtCoord(targetCoord + vec3(-1, 0, 0), ObjectTypes.Water); // Passthrough
    setObjectAtCoord(targetCoord + vec3(0, 1, 0), ObjectTypes.OakLog); // Solid
    setObjectAtCoord(targetCoord + vec3(0, -1, 0), ObjectTypes.Torch); // Passthrough
    setObjectAtCoord(targetCoord + vec3(0, 0, 1), ObjectTypes.IronOre); // Solid
    // Back is air (passthrough)

    setObjectAtCoord(targetCoord, ObjectTypes.Dirt);
    EntityPosition.set(aliceEntityId, targetCoord + vec3(2, 0, 0));

    // Should succeed because has multiple passthrough neighbors
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, targetCoord, "");

    assertEq(
      TestEntityUtils.getObjectTypeAt(targetCoord), ObjectTypes.Air, "Block with mixed neighbors should be minable"
    );
  }

  function testMineReachabilityEdgeCases() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Test a chain of unreachable blocks
    Vec3 baseCoord = playerCoord + vec3(10, 0, 0);

    // Create a 3x3x3 cube of solid blocks
    for (int32 x = -1; x <= 1; x++) {
      for (int32 y = -1; y <= 1; y++) {
        for (int32 z = -1; z <= 1; z++) {
          setObjectAtCoord(baseCoord + vec3(x, y, z), ObjectTypes.Stone);
        }
      }
    }

    // Try to mine the center block
    EntityPosition.set(aliceEntityId, baseCoord + vec3(3, 0, 0));

    vm.prank(alice);
    vm.expectRevert("Coordinate is not reachable");
    world.mine(aliceEntityId, baseCoord, "");

    // Now make one neighbor passthrough and it should work
    setObjectAtCoord(baseCoord + vec3(0, 0, -1), ObjectTypes.Air);

    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, baseCoord, "");
    assertEq(
      TestEntityUtils.getObjectTypeAt(baseCoord), ObjectTypes.Air, "Block should be minable after adding air neighbor"
    );
  }

  function testMineRateLimit() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);

    // Player can mine up to 20 times per block (10 mines per second with 2 second blocks)
    // Try to mine 20 times, the 21st should revert
    for (uint256 i = 0; i < 20; i++) {
      Vec3 mineCoord =
        vec3(playerCoord.x() + int32(int256(i % 5 + 1)), FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + int32(int256(i / 5)));
      setObjectAtCoord(mineCoord, ObjectTypes.Dirt);
      ObjectPhysics.setMass(ObjectTypes.Dirt, 1); // Minimal mass so it mines in one hit

      vm.prank(alice);
      world.mine(aliceEntityId, mineCoord, "");
    }

    // 21st mine should fail due to rate limit
    Vec3 finalMineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 5);
    setObjectAtCoord(finalMineCoord, ObjectTypes.Dirt);

    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.mine(aliceEntityId, finalMineCoord, "");

    // Move to next block and verify can mine again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.mine(aliceEntityId, finalMineCoord, "");
  }

  function testMineRateLimitWithTool() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create and equip pick
    EntityId pick = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, pick);

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);

    // Same rate limit applies with tool
    for (uint256 i = 0; i < 20; i++) {
      Vec3 mineCoord =
        vec3(playerCoord.x() + int32(int256(i % 5 + 1)), FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + int32(int256(i / 5)));
      setObjectAtCoord(mineCoord, ObjectTypes.Stone);
      ObjectPhysics.setMass(ObjectTypes.Stone, 1); // Minimal mass so it mines in one hit

      vm.prank(alice);
      world.mine(aliceEntityId, mineCoord, slot, "");
    }

    // 21st mine should fail due to rate limit
    Vec3 finalMineCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 5);
    setObjectAtCoord(finalMineCoord, ObjectTypes.Stone);

    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.mine(aliceEntityId, finalMineCoord, slot, "");

    // Move to next block and verify can mine again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.mine(aliceEntityId, finalMineCoord, slot, "");
  }

  // Crop mining activity tracking tests

  function testMineCropTracksActivity() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test mining wheat
    Vec3 wheatCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    ObjectType wheatType = ObjectTypes.Wheat;
    setObjectAtCoord(wheatCoord, wheatType);

    uint128 wheatMass = ObjectPhysics.getMass(wheatType);

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, wheatCoord, bytes32(0));

    // Mine wheat without tool (bare hands)
    vm.prank(alice);
    world.mine(aliceEntityId, wheatCoord, "");

    // Check that crop mining was tracked
    uint256 cropActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineCropMass);

    // Activity should track the actual mass of the wheat mined
    assertEq(cropActivity, wheatMass, "Crop mining activity not tracked correctly");

    // Should have no tool-based mining activity
    uint256 pickActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MinePickMass);
    assertEq(pickActivity, 0, "Pick mining should be zero for crops");

    uint256 axeActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineAxeMass);
    assertEq(axeActivity, 0, "Axe mining should be zero for crops");
  }

  function testMultipleCropsTracked() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Mine multiple crop types
    ObjectType[4] memory cropTypes = [ObjectTypes.Wheat, ObjectTypes.Melon, ObjectTypes.Pumpkin, ObjectTypes.CottonBush];

    uint256 totalCropMass = 0;

    for (uint256 i = 0; i < cropTypes.length; i++) {
      Vec3 cropCoord = vec3(playerCoord.x() + int32(int256(i)) + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
      setObjectAtCoord(cropCoord, cropTypes[i]);

      // Set up chunk commitment for randomness when mining
      newCommit(alice, aliceEntityId, cropCoord, bytes32(uint256(i)));

      vm.prank(alice);
      world.mineUntilDestroyed(aliceEntityId, cropCoord, "");

      totalCropMass += ObjectPhysics.getMass(cropTypes[i]);
    }

    // Check total crop mining activity
    uint256 cropActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineCropMass);
    assertEq(cropActivity, totalCropMass, "Total crop mining activity not tracked correctly");
  }

  function testCropMiningWithTool() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Add a tool to inventory
    EntityId tool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenAxe);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, tool);

    // Mine wheat with tool
    Vec3 wheatCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    setObjectAtCoord(wheatCoord, ObjectTypes.Wheat);

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, wheatCoord, bytes32(0));

    vm.prank(alice);
    world.mine(aliceEntityId, wheatCoord, slot, "");

    // Even with a tool, crop mining should be tracked as MineCropMass
    uint256 cropActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineCropMass);
    assertTrue(cropActivity > 0, "Crop mining activity should be tracked even with tool");

    // Should not have axe mining activity for crops
    uint256 axeActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.MineAxeMass);
    assertEq(axeActivity, 0, "Axe mining should be zero for crops");
  }
}
