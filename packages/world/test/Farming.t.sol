// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../src/codegen/tables/SeedGrowth.sol";

import { LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { EntityPosition } from "../src/utils/Vec3Storage.sol";

import {
  BUILD_ENERGY_COST,
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_ENTITY_INFLUENCE_RADIUS,
  TILL_ENERGY_COST
} from "../src/Constants.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { DustTest } from "./DustTest.sol";
import { TestEntityUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract FarmingTest is DustTest {
  function testTillDirt() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenHoe);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("till dirt");
    world.till(aliceEntityId, dirtCoord, 0);
    endGasReport();

    (EntityId dirtEntityId,) = TestEntityUtils.getBlockAt(dirtCoord);
    assertTrue(dirtEntityId.exists(), "Dirt entity doesn't exist after tilling");
    assertEq(EntityObjectType.get(dirtEntityId), ObjectTypes.Farmland, "Dirt was not converted to farmland");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testTillGrass() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 grassCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(grassCoord, ObjectTypes.Grass);
    (EntityId grassEntityId,) = TestEntityUtils.getBlockAt(grassCoord);
    assertFalse(grassEntityId.exists(), "Grass entity already exists");

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenHoe);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("till grass");
    world.till(aliceEntityId, grassCoord, 0);
    endGasReport();

    assertTrue(grassEntityId.exists(), "Grass entity doesn't exist after tilling");
    assertEq(EntityObjectType.get(grassEntityId), ObjectTypes.Farmland, "Grass was not converted to farmland");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testTillWithDifferentHoes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    ObjectType[] memory hoeTypes = new ObjectType[](1);
    hoeTypes[0] = ObjectTypes.WoodenHoe;

    for (uint256 i = 0; i < hoeTypes.length; i++) {
      Vec3 testCoord = dirtCoord + vec3(int32(int256(i)), 0, 0);
      setObjectAtCoord(testCoord, ObjectTypes.Dirt);

      TestInventoryUtils.addEntity(aliceEntityId, hoeTypes[i]);

      vm.prank(alice);
      world.till(aliceEntityId, testCoord, 0);

      (EntityId farmlandEntityId,) = TestEntityUtils.getBlockAt(testCoord);
      assertTrue(farmlandEntityId.exists(), "Farmland entity doesn't exist after tilling");
      assertEq(EntityObjectType.get(farmlandEntityId), ObjectTypes.Farmland, "Dirt was not converted to farmland");
    }
  }

  function testTillFailsIfNotTillable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 nonDirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(nonDirtCoord, ObjectTypes.Stone);

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenHoe);

    vm.prank(alice);
    vm.expectRevert("Not tillable");
    world.till(aliceEntityId, nonDirtCoord, 0);
  }

  function testTillFailsIfNoHoeEquipped() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    // No hoe equipped

    vm.prank(alice);
    vm.expectRevert("Must equip a hoe");
    world.till(aliceEntityId, dirtCoord, 0);

    // Equipped but not a hoe
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.IronPick);

    vm.prank(alice);
    vm.expectRevert("Must equip a hoe");
    world.till(aliceEntityId, dirtCoord, 0);
  }

  function testTillFailsIfTooFar() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenHoe);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.till(aliceEntityId, dirtCoord, 0);
  }

  function testTillKillsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenHoe);

    // Set player energy to less than required
    uint128 toolMass = 0; // Assuming tool mass is 0 for simplicity
    uint128 energyCost = TILL_ENERGY_COST + toolMass;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: energyCost - 1, drainRate: 0 })
    );

    vm.prank(alice);
    world.till(aliceEntityId, dirtCoord, 0);

    assertPlayerIsDead(aliceEntityId, playerCoord);
  }

  function testPlantWheatSeeds() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    // Check initial local energy pool
    uint128 initialLocalEnergy = LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord());

    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    // Plant wheat seeds
    vm.prank(alice);
    world.build(aliceEntityId, farmlandCoord + vec3(0, 1, 0), seedSlot, "");

    // Verify seeds were planted
    (EntityId cropEntityId,) = TestEntityUtils.getBlockAt(farmlandCoord + vec3(0, 1, 0));
    assertTrue(cropEntityId.exists(), "Crop entity doesn't exist after planting");
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.WheatSeed, "Wheat seeds were not planted correctly");

    assertEq(
      LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord()),
      initialLocalEnergy + BUILD_ENERGY_COST - ObjectTypes.WheatSeed.getGrowableEnergy(),
      "Energy not correctly taken from local pool"
    );

    // Verify build time was set
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);
    assertTrue(fullyGrownAt > 0, "FullyGrownAt not set correctly");
    assertEq(
      fullyGrownAt, uint128(block.timestamp) + ObjectTypes.WheatSeed.getTimeToGrow(), "Incorrect fullyGrownAt set"
    );

    // Verify seeds were removed from inventory
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 0);
  }

  function testPlantSeedsFailsIfNotOnWetFarmland() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    // Try to plant on dirt (not farmland)
    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(dirtCoord, ObjectTypes.Dirt);

    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    vm.prank(alice);
    vm.expectRevert("Cannot plant on this block");
    world.build(aliceEntityId, dirtCoord + vec3(0, 1, 0), seedSlot, "");

    // Try to plant on farmland (not wet)
    Vec3 farmlandCoord = vec3(playerCoord.x() + 2, 0, playerCoord.z());
    setTerrainAtCoord(farmlandCoord, ObjectTypes.Farmland);

    seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);

    vm.prank(alice);
    vm.expectRevert("Cannot plant on this block");
    world.build(aliceEntityId, farmlandCoord + vec3(0, 1, 0), seedSlot, "");
  }

  function testHarvestMatureWheatCrop() public {
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

    // Advance time beyond the growth period
    vm.warp(fullyGrownAt);
    vm.prank(alice);
    world.growSeed(aliceEntityId, cropCoord);

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 0, "Wheat seeds should be added to circulation after growing");

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, cropCoord, bytes32(0));

    // Check local energy pool before harvesting
    uint128 initialLocalEnergy = LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord());

    // Harvest the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, farmlandCoord + vec3(0, 1, 0), "");

    // Verify wheat and seeds were obtained
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 1);
    // TODO: test randomness
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    // Verify crop no longer exists
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.Air, "Crop wasn't removed after harvesting");
    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 1, "Seed was removed from circulation");

    // Verify local energy pool has changed (from the player's energy cost)
    assertEq(
      LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord()),
      initialLocalEnergy + ObjectPhysics.getMass(ObjectTypes.Wheat),
      "Local energy pool shouldn't change after harvesting mature crop"
    );
  }

  function testHarvestImmatureWheatCrop() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

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

    // Advance time but not enough for full growth
    vm.warp(fullyGrownAt - 1); // 1 second before full growth

    // Update player's energy and transfer to pool
    world.activatePlayer(alice);

    // Set up chunk commitment for randomness when mining
    Vec3 chunkCoord = cropCoord.toChunkCoord();
    vm.prank(alice);
    world.chunkCommit(aliceEntityId, chunkCoord);
    // Move forward a block to make the commitment valid
    vm.roll(block.number + 1);

    // Check local energy pool before harvesting
    uint128 beforeHarvestEnergy = LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord());

    // Harvest the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, cropCoord, "");

    // Verify original seeds were returned (not wheat)
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 0);

    // Verify crop no longer exists
    assertEq(EntityObjectType.get(cropEntityId), ObjectTypes.Air, "Crop wasn't removed after harvesting");

    // Verify energy was returned to local pool
    // Note: currently player's energy is only decreased if the
    assertEq(
      LocalEnergyPool.get(farmlandCoord.toLocalEnergyPoolShardCoord()),
      beforeHarvestEnergy + ObjectTypes.WheatSeed.getGrowableEnergy(),
      "Energy not correctly returned to local pool"
    );
  }

  function testMiningFescueGrassDropsWheatSeeds() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Verify no wheat seeds in inventory initially
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 0);

    Vec3 grassCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());

    // Try up to 10 times to get wheat seeds (there's a 40% chance of getting 0 seeds)
    for (uint256 i = 0; i < 100; i++) {
      // Create FescueGrass
      setObjectAtCoord(grassCoord, ObjectTypes.FescueGrass);

      newCommit(alice, aliceEntityId, grassCoord, keccak256(abi.encode(i)));

      // Harvest the FescueGrass
      vm.prank(alice);
      world.mineUntilDestroyed(aliceEntityId, grassCoord, "");

      // Check if we got seeds
      uint256 seedCount = getObjectAmount(aliceEntityId, ObjectTypes.WheatSeed);

      if (seedCount > 0) break;
    }

    // Verify wheat seeds were obtained in at least one attempt
    assertGt(getObjectAmount(aliceEntityId, ObjectTypes.WheatSeed), 0, "Should have at least one wheat seed");
  }

  function testCropGrowthLifecycle() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.WetFarmland);

    ResourceCount.set(ObjectTypes.WheatSeed, 1);

    // Add wheat seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WheatSeed, 1);

    Vec3 cropCoord = farmlandCoord + vec3(0, 1, 0);
    // Plant wheat seeds
    uint16 seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);
    vm.prank(alice);
    world.build(aliceEntityId, cropCoord, seedSlot, "");

    // Verify seeds were planted
    (EntityId cropEntityId,) = TestEntityUtils.getBlockAt(cropCoord);
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);

    // Mid-growth - Try harvesting before fully grown
    vm.warp(fullyGrownAt - 1);

    vm.prank(alice);
    vm.expectRevert("Seed cannot be grown yet");
    world.growSeed(aliceEntityId, cropCoord);

    // Mine the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, cropCoord, "");

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 1, "Seeds should not be added to circulation if not grown");

    // We get seeds back, not wheat
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 0);

    // Reset test by planting again
    seedSlot = TestInventoryUtils.findObjectType(aliceEntityId, ObjectTypes.WheatSeed);
    vm.prank(alice);
    world.build(aliceEntityId, cropCoord, seedSlot, "");

    (cropEntityId,) = TestEntityUtils.getBlockAt(cropCoord);
    fullyGrownAt = SeedGrowth.getFullyGrownAt(cropEntityId);

    console.log(ResourceCount.get(ObjectTypes.WheatSeed));
    // Full growth - Warp past the full growth time
    vm.roll(vm.getBlockNumber() + CHUNK_COMMIT_EXPIRY_BLOCKS + 1);
    vm.warp(fullyGrownAt + 1);
    vm.prank(alice);
    world.growSeed(aliceEntityId, cropCoord);

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 0, "Seeds should be added to circulation after growing");

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, cropCoord, bytes32(0));

    // Mine the crop
    vm.prank(alice);
    world.mineUntilDestroyed(aliceEntityId, cropCoord, "");

    assertEq(ResourceCount.get(ObjectTypes.WheatSeed), 1, "Seeds should be added to circulation if received as a drop");

    // Now we get wheat and seeds
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Wheat, 1);
    // TODO: test randomness
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WheatSeed, 1);
  }
}
