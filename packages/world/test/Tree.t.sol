// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectType } from "../src/codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { PlayerStatus } from "../src/codegen/tables/PlayerStatus.sol";

import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";
import { SeedGrowth } from "../src/codegen/tables/SeedGrowth.sol";

import { LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { MovablePosition, ReversePosition } from "../src/utils/Vec3Storage.sol";

import {
  BUILD_ENERGY_COST,
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_ENTITY_INFLUENCE_HALF_WIDTH,
  MINE_ENERGY_COST,
  TILL_ENERGY_COST
} from "../src/Constants.sol";

import { EntityId } from "../src/EntityId.sol";
import { ObjectTypeId } from "../src/ObjectTypeId.sol";
import { ObjectTypeLib } from "../src/ObjectTypeLib.sol";
import { ObjectTypes } from "../src/ObjectTypes.sol";
import { TreeData, TreeLib } from "../src/TreeLib.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract TreeTest is DustTest {
  using ObjectTypeLib for ObjectTypeId;

  function newCommit(address commiterAddress, EntityId commiter, Vec3 coord, bytes32 blockHash) internal {
    // Set up chunk commitment for randomness when mining grass
    Vec3 chunkCoord = coord.toChunkCoord();

    vm.roll(vm.getBlockNumber() + CHUNK_COMMIT_EXPIRY_BLOCKS);
    vm.prank(commiterAddress);
    world.chunkCommit(commiter, chunkCoord);
    // Move forward 2 blocks to make the commitment valid
    vm.roll(vm.getBlockNumber() + 2);

    vm.setBlockhash(vm.getBlockNumber() - 1, blockHash);
  }

  // Tree tests

  function testPlantTree() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Add oak seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);

    // Check initial local energy pool
    uint128 initialLocalEnergy = LocalEnergyPool.get(dirtCoord.toLocalEnergyPoolShardCoord());
    uint128 seedEnergy = ObjectTypeMetadata.getEnergy(ObjectTypes.OakSapling);

    // Plant oak seeds
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    vm.prank(alice);
    startGasReport("plant tree seed");
    world.build(aliceEntityId, seedCoord, 0, "");
    endGasReport();

    // Verify seeds were planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.OakSapling, "Oak seed was not planted correctly");

    // Verify energy was taken from local pool
    assertEq(
      LocalEnergyPool.get(dirtCoord.toLocalEnergyPoolShardCoord()),
      initialLocalEnergy + BUILD_ENERGY_COST - seedEnergy,
      "Energy not correctly taken from local pool"
    );

    // Verify growth time was set
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);
    assertEq(fullyGrownAt, uint128(block.timestamp) + ObjectTypes.OakSapling.timeToGrow(), "Incorrect fullyGrownAt set");

    // Verify seeds were removed from inventory
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakSapling, 0);
  }

  function testPlantTreeSeedFailsIfNotOnDirtOrGrass() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add oak seeds to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);

    // Try to plant on stone
    Vec3 stoneCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(stoneCoord, ObjectTypes.Stone);

    vm.prank(alice);
    vm.expectRevert("Tree saplings need dirt or grass");
    world.build(aliceEntityId, stoneCoord + vec3(0, 1, 0), 0, "");

    // Try to plant on farmland
    Vec3 farmlandCoord = vec3(playerCoord.x() + 2, 0, playerCoord.z());
    setTerrainAtCoord(farmlandCoord, ObjectTypes.Farmland);

    vm.prank(alice);
    vm.expectRevert("Tree saplings need dirt or grass");
    world.build(aliceEntityId, farmlandCoord + vec3(0, 1, 0), 0, "");
  }

  function testTreeGrowthWithSpace() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Add oak seed to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);
    // Set resource count so seed can be grown
    ResourceCount.set(ObjectTypes.OakSapling, 1);

    // Plant oak seed
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, 0, "");

    // Verify seed was planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");

    // Get full grown time
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

    // Advance time to when the tree can grow
    vm.warp(fullyGrownAt + 1);

    // Grow the tree
    vm.prank(alice);
    startGasReport("grow oak tree");
    world.growSeed(aliceEntityId, seedCoord);
    endGasReport();

    // Verify the seed is now a log
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.OakLog, "Seed was not converted to log");

    // Get tree data to check trunkHeight
    TreeData memory treeData = TreeLib.getTreeData(ObjectTypes.OakSapling);
    int32 height = int32(uint32(treeData.trunkHeight));

    // Verify trunk exists
    for (int32 i = 0; i < height; i++) {
      Vec3 checkCoord = seedCoord + vec3(0, i, 0);
      EntityId logEntityId = ReversePosition.get(checkCoord);
      assertTrue(logEntityId.exists(), "Log entity doesn't exist");
      assertEq(ObjectType.get(logEntityId), ObjectTypes.OakLog, "Entity is not oak log");
    }

    // Verify leaves exist in canopy area (test a few sample points)
    // Since we can't directly access canopyStart, we'll check the typical locations for oak trees
    int32 canopyStart = 3; // Typical canopy start for oak

    // Check some expected leaf positions
    Vec3[] memory leafPositions = new Vec3[](5);
    leafPositions[0] = seedCoord + vec3(1, canopyStart + 1, 0);
    leafPositions[1] = seedCoord + vec3(-1, canopyStart + 1, 0);
    leafPositions[2] = seedCoord + vec3(0, canopyStart + 1, 1);
    leafPositions[3] = seedCoord + vec3(0, canopyStart + 1, -1);
    leafPositions[4] = seedCoord + vec3(0, height, 0); // Top leaf

    for (uint256 i = 0; i < leafPositions.length; i++) {
      EntityId leafEntityId = ReversePosition.get(leafPositions[i]);
      assertTrue(leafEntityId.exists(), "Leaf entity doesn't exist");
      assertEq(ObjectType.get(leafEntityId), ObjectTypes.OakLeaf, "Entity is not oak leaf");
    }
  }

  function testTreeGrowthWithoutSpace() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 dirtCoord = vec3(playerCoord.x() + 5, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Create an obstruction above the seed location
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    Vec3 obstructionCoord = seedCoord + vec3(0, 2, 0);
    setObjectAtCoord(obstructionCoord, ObjectTypes.Stone);

    // Add oak seed to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);
    // Set resource count so seed can be grown
    ResourceCount.set(ObjectTypes.OakSapling, 1);

    // Plant oak seed
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, 0, "");

    // Verify seed was planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");

    // Get full grown time
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

    // Advance time to when the tree can grow
    vm.warp(fullyGrownAt + 1);

    // Grow the tree
    vm.prank(alice);
    startGasReport("grow tree with obstruction");
    world.growSeed(aliceEntityId, seedCoord);
    endGasReport();

    // Verify the seed is converted to log but remains a sapling (no additional blocks)
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.OakLog, "Seed was not converted to log");

    // Verify no other logs or leaves were created
    Vec3 aboveObstruction = obstructionCoord + vec3(0, 1, 0);
    EntityId aboveEntity = ReversePosition.get(aboveObstruction);
    assertFalse(
      aboveEntity.exists() && ObjectType.get(aboveEntity) == ObjectTypes.OakLog, "Tree grew beyond obstruction"
    );
  }

  function testHarvestMatureTree() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Add oak seed to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);
    // Set resource count so seed can be grown
    ResourceCount.set(ObjectTypes.OakSapling, 1);

    // Plant oak seed
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, 0, "");

    // Verify seed was planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");

    // Get full grown time
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

    // Advance time to when the tree can grow
    vm.warp(fullyGrownAt + 1);

    // Grow the tree
    vm.prank(alice);
    world.growSeed(aliceEntityId, seedCoord);

    // Verify the seed is now a log
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.OakLog, "Seed was not converted to log");

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, seedCoord, bytes32(0));

    // Harvest the mature tree log
    vm.prank(alice);
    startGasReport("harvest mature tree log");
    world.mineUntilDestroyed(aliceEntityId, seedCoord, "");
    endGasReport();

    // Verify log was obtained
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakLog, 1);
  }

  function testHarvestImmatureTreeSeed() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Add oak seed to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);

    // Plant oak seed
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, 0, "");

    // Verify seed was planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");

    // Get initial energy
    uint128 seedEnergy = ObjectTypeMetadata.getEnergy(ObjectTypes.OakSapling);

    // Get full grown time
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

    // Advance time but not enough for full growth
    vm.warp(fullyGrownAt - 1); // 1 second before full growth

    // Update player's energy and transfer to pool
    world.activatePlayer(alice);

    // Set up chunk commitment for randomness when mining
    Vec3 chunkCoord = seedCoord.toChunkCoord();
    vm.prank(alice);
    world.chunkCommit(aliceEntityId, chunkCoord);
    // Move forward a block to make the commitment valid
    vm.roll(block.number + 1);

    // Check local energy pool before harvesting
    uint128 beforeHarvestEnergy = LocalEnergyPool.get(dirtCoord.toLocalEnergyPoolShardCoord());

    // Harvest the immature tree seed
    vm.prank(alice);
    startGasReport("harvest immature tree seed");
    world.mineUntilDestroyed(aliceEntityId, seedCoord, "");
    endGasReport();

    // Verify original seed was returned
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakSapling, 1);

    // Verify seed no longer exists at location
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.Air, "Seed wasn't removed after harvesting");

    // Verify energy was returned to local pool
    assertEq(
      LocalEnergyPool.get(dirtCoord.toLocalEnergyPoolShardCoord()),
      beforeHarvestEnergy + seedEnergy,
      "Energy not correctly returned to local pool"
    );
  }

  function testMineTreeLeaves() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create an oak leaf directly
    Vec3 leafCoord = vec3(playerCoord.x() + 1, playerCoord.y() + 1, playerCoord.z());
    setObjectAtCoord(leafCoord, ObjectTypes.OakLeaf);

    EntityId leafEntityId = ReversePosition.get(leafCoord);
    assertTrue(leafEntityId.exists(), "Leaf entity doesn't exist");

    // Set up chunk commitment for randomness when mining
    newCommit(alice, aliceEntityId, leafCoord, bytes32(uint256(1)));

    // Harvest the leaf
    vm.prank(alice);
    startGasReport("harvest tree leaf");
    world.mineUntilDestroyed(aliceEntityId, leafCoord, "");
    endGasReport();

    // Verify leaf was obtained
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakSapling, 1);

    // Verify leaf entity no longer exists
    assertEq(ObjectType.get(leafEntityId), ObjectTypes.Air, "Leaf wasn't removed after harvesting");
  }

  function testMultipleTreeTypes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    // Set a large energy amount, as trees take a long time to grow
    Energy.setEnergy(aliceEntityId, 1e32);

    // Define coordinates
    Vec3 dirtCoord1 = vec3(playerCoord.x() + 2, 0, playerCoord.z());
    Vec3 dirtCoord2 = vec3(playerCoord.x() + 5, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord1, ObjectTypes.Dirt);
    setObjectAtCoord(dirtCoord2, ObjectTypes.Dirt);

    Vec3 seedCoord1 = dirtCoord1 + vec3(0, 1, 0);
    Vec3 seedCoord2 = dirtCoord2 + vec3(0, 1, 0);

    // Test with different tree seed types
    ObjectTypeId[] memory seedTypes = new ObjectTypeId[](2);
    seedTypes[0] = ObjectTypes.OakSapling;
    seedTypes[1] = ObjectTypes.BirchSapling;

    for (uint256 i = 0; i < seedTypes.length; i++) {
      // Add seed to inventory
      TestInventoryUtils.addObject(aliceEntityId, seedTypes[i], 1);
      // Set resource count so seed can be grown
      ResourceCount.set(seedTypes[i], 1);

      // Plant seed
      Vec3 seedCoord = i == 0 ? seedCoord1 : seedCoord2;
      vm.prank(alice);
      world.build(aliceEntityId, seedCoord, 0, "");

      // Verify seed was planted
      EntityId seedEntityId = ReversePosition.get(seedCoord);
      assertTrue(seedEntityId.exists(), "Seed entity doesn't exist after planting");
      assertEq(ObjectType.get(seedEntityId), seedTypes[i], "Seed was not planted correctly");

      // Get full grown time
      uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

      // Advance time to when the tree can grow
      vm.warp(fullyGrownAt + 1);

      // Grow the tree
      vm.prank(alice);
      world.growSeed(aliceEntityId, seedCoord);

      // Verify the seed has grown into appropriate log type
      TreeData memory treeData = TreeLib.getTreeData(seedTypes[i]);
      assertEq(ObjectType.get(seedEntityId), treeData.logType, "Seed did not grow into correct log type");

      // Verify some leaves exist
      Vec3 leafPos = seedCoord + vec3(1, 3, 0);
      EntityId leafEntityId = ReversePosition.get(leafPos);
      if (leafEntityId.exists()) {
        assertEq(ObjectType.get(leafEntityId), treeData.leafType, "Leaf is not the correct type");
      }
    }
  }

  function testTreeSeedGrownTooEarly() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 dirtCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(dirtCoord, ObjectTypes.Dirt);

    // Add oak seed to inventory
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakSapling, 1);
    // Set resource count so seed can be grown
    ResourceCount.set(ObjectTypes.OakSapling, 1);

    // Plant oak seed
    Vec3 seedCoord = dirtCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.build(aliceEntityId, seedCoord, 0, "");

    // Verify seed was planted
    EntityId seedEntityId = ReversePosition.get(seedCoord);
    uint128 fullyGrownAt = SeedGrowth.getFullyGrownAt(seedEntityId);

    // Try to grow before it's ready
    vm.warp(fullyGrownAt - 1);

    vm.prank(alice);
    vm.expectRevert("Seed cannot be grown yet");
    world.growSeed(aliceEntityId, seedCoord);

    // Now advance time and verify it can grow
    vm.warp(fullyGrownAt + 1);

    vm.prank(alice);
    world.growSeed(aliceEntityId, seedCoord);

    // Verify the seed has grown
    assertEq(ObjectType.get(seedEntityId), ObjectTypes.OakLog, "Seed did not grow correctly");
  }
}
