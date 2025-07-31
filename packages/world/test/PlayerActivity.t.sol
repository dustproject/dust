// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ActivityType } from "../src/codegen/common.sol";
import { Death } from "../src/codegen/tables/Death.sol";
import { PlayerActivity } from "../src/codegen/tables/PlayerActivity.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { DustTest } from "./DustTest.sol";

import { TestInventoryUtils, TestPlayerActivityUtils } from "./utils/TestUtils.sol";

contract PlayerActivityTest is DustTest {
  function testActivityResetsOnDeath() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Build something to track activity
    Vec3 buildCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());
    ObjectType buildObjectType = ObjectTypes.Stone;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    uint16 inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    // Verify activity was tracked
    uint256 buildMass = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.BuildMass);
    assertTrue(buildMass > 0, "Build mass should be tracked");

    // Simulate death by incrementing death count
    uint256 deathsBefore = Death.getDeaths(aliceEntityId);
    Death.setDeaths(aliceEntityId, deathsBefore + 1);

    // Check that activity is now zero for the new life
    uint256 buildMassAfterDeath = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.BuildMass);
    assertEq(buildMassAfterDeath, 0, "Build mass should be reset after death");

    // Build again and verify it tracks for the new life
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    inventorySlot = TestInventoryUtils.findObjectType(aliceEntityId, buildObjectType);

    vm.prank(alice);
    world.build(aliceEntityId, buildCoord + vec3(1, 0, 0), inventorySlot, "");

    uint256 newBuildMass = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.BuildMass);
    assertTrue(newBuildMass > 0, "Build mass should be tracked for new life");
    assertEq(newBuildMass, buildMass, "Build mass should be the same as first life");
  }

  function testMultipleActivityTypesTracked() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Move to track walk steps
    Vec3[] memory moveCoords = new Vec3[](3);
    for (uint256 i = 0; i < 3; i++) {
      moveCoords[i] = playerCoord + vec3(0, 0, int32(int256(i)) + 1);
    }

    vm.prank(alice);
    world.move(aliceEntityId, moveCoords);

    // Mine with pick
    Vec3 stoneCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z() + 3);
    ObjectType stoneType = ObjectTypes.Stone;
    setObjectAtCoord(stoneCoord, stoneType);

    EntityId pickTool = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);
    uint16 pickSlot = TestInventoryUtils.findEntity(aliceEntityId, pickTool);

    vm.prank(alice);
    world.mine(aliceEntityId, stoneCoord, pickSlot, "");

    // Verify multiple activities are tracked
    uint256 walkSteps = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.MoveWalkSteps);
    assertEq(walkSteps, 3, "Walk steps should be tracked");

    uint256 pickMass = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.MinePickMass);
    assertTrue(pickMass > 0, "Pick mining should be tracked");

    uint256 axeMass = TestPlayerActivityUtils.getActivityValue(aliceEntityId, ActivityType.MineAxeMass);
    assertEq(axeMass, 0, "Axe mining should be zero");
  }
}
