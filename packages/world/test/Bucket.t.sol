// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "../src/types/EntityId.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";

import { MAX_ENTITY_INFLUENCE_RADIUS } from "../src/Constants.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract BucketTest is DustTest {
  function testFillBucket() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 waterCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    assertEq(TerrainLib.getBlockType(waterCoord), ObjectTypes.Water, "Water coord is not water");

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Bucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);

    vm.prank(alice);
    startGasReport("fill bucket");
    world.fillBucket(aliceEntityId, waterCoord, 0);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
  }

  function testWetFarmland() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    EntityId farmlandEntityId = setObjectAtCoord(farmlandCoord, ObjectTypes.Farmland);

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);

    vm.prank(alice);
    startGasReport("wet farmland");
    world.wetFarmland(aliceEntityId, farmlandCoord, 0);
    endGasReport();

    assertEq(
      EntityObjectType.get(farmlandEntityId), ObjectTypes.WetFarmland, "Farmland was not converted to wet farmland"
    );
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);
  }

  function testFillBucketFailsIfNotWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 nonWaterCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setTerrainAtCoord(nonWaterCoord, ObjectTypes.Dirt);
    assertEq(TerrainLib.getBlockType(nonWaterCoord), ObjectTypes.Dirt, "Non-water coord is not dirt");

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Bucket, 1);

    vm.prank(alice);
    vm.expectRevert("Not water");
    world.fillBucket(aliceEntityId, nonWaterCoord, 0);
  }

  function testFillBucketFailsIfNoBucket() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 waterCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    assertEq(TerrainLib.getBlockType(waterCoord), ObjectTypes.Water, "Water coord is not water");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Bucket, 0);

    vm.prank(alice);
    vm.expectRevert("Must use an empty Bucket");
    world.fillBucket(aliceEntityId, waterCoord, 0);
  }

  function testFillBucketFailsIfTooFar() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3 waterCoord = vec3(playerCoord.x() + int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, playerCoord.z());

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Bucket, 1);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.fillBucket(aliceEntityId, waterCoord, 0);
  }

  function testWetFarmlandFailsIfNotFarmland() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 nonFarmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(nonFarmlandCoord, ObjectTypes.Dirt);

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);

    vm.prank(alice);
    vm.expectRevert("Not farmland");
    world.wetFarmland(aliceEntityId, nonFarmlandCoord, 0);
  }

  function testWetFarmlandFailsIfNoWaterBucket() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 farmlandCoord = vec3(playerCoord.x() + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.Farmland);

    assertInventoryHasObject(aliceEntityId, ObjectTypes.WaterBucket, 0);

    vm.prank(alice);
    vm.expectRevert("Must use a Water Bucket");
    world.wetFarmland(aliceEntityId, farmlandCoord, 0);
  }

  function testWetFarmlandFailsIfTooFar() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 farmlandCoord = vec3(playerCoord.x() + int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, playerCoord.z());
    setObjectAtCoord(farmlandCoord, ObjectTypes.Farmland);

    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.WaterBucket, 1);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.wetFarmland(aliceEntityId, farmlandCoord, 0);
  }
}
