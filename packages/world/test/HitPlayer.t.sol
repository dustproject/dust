// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  DEFAULT_HIT_ENERGY_COST,
  MAX_PLAYER_ENERGY,
  PLAYER_ENERGY_DRAIN_RATE,
  TOOL_HIT_ENERGY_COST
} from "../src/Constants.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract HitPlayerTest is DustTest {
  function testHitPlayerWithoutTool() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST + 1000);
    Energy.setEnergy(bobEntityId, DEFAULT_HIT_ENERGY_COST + 1000);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit Bob without tool
    vm.prank(alice);
    startGasReport("hit player without tool");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
    endGasReport();

    // Check energy reduction
    assertGt(Energy.getEnergy(bobEntityId), 0, "Bob should still have energy");
    assertGt(Energy.getEnergy(aliceEntityId), 0, "Alice should still have energy");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testHitPlayerWithTool() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, TOOL_HIT_ENERGY_COST + 1000);
    Energy.setEnergy(bobEntityId, TOOL_HIT_ENERGY_COST + 1000);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit Bob with tool
    vm.prank(alice);
    startGasReport("hit player with tool");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    endGasReport();

    // Check energy reduction - tool should do more damage
    assertGt(Energy.getEnergy(bobEntityId), 0, "Bob should still have energy");
    assertGt(Energy.getEnergy(aliceEntityId), 0, "Alice should still have energy");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testHitPlayerRateLimit() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);
    Energy.setEnergy(bobEntityId, MAX_PLAYER_ENERGY);

    // Player can hit up to 5 times per block (2.5 hits per second with 2 second blocks)
    // Try to hit 5 times, the 6th should revert
    for (uint256 i = 0; i < 5; i++) {
      vm.prank(alice);
      world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
    }

    // 6th hit should fail due to rate limit
    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));

    // Move to next block and verify can hit again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
  }

  function testHitPlayerRateLimitWithTool() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);
    Energy.setEnergy(bobEntityId, MAX_PLAYER_ENERGY);

    // Same rate limit applies with tool
    for (uint256 i = 0; i < 5; i++) {
      vm.prank(alice);
      world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    }

    // 6th hit should fail due to rate limit
    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));

    // Move to next block and verify can hit again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
  }

  function testHitPlayerFailsIfTooFar() public {
    // Setup two players far apart
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(3, 0, 0); // Too far
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
  }

  function testHitPlayerFailsIfSelfHit() public {
    // Setup player
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    vm.prank(alice);
    vm.expectRevert("Cannot hit yourself");
    world.hitPlayer(aliceEntityId, aliceEntityId, bytes(""));
  }

  function testHitPlayerFailsIfTargetNotPlayer() public {
    // Setup player and non-player entity
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 stoneCoord = aliceCoord + vec3(1, 0, 0);
    setObjectAtCoord(stoneCoord, ObjectTypes.Stone);

    EntityId stoneEntity = EntityTypeLib.encodeBlock(stoneCoord);

    vm.prank(alice);
    vm.expectRevert("Target is not a player");
    world.hitPlayer(aliceEntityId, stoneEntity, bytes(""));
  }

  function testHitDeadPlayer() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Kill Bob by setting energy to 0
    Energy.setEnergy(bobEntityId, 0);
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST + 1000);

    // Hit dead player should do nothing
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));

    // Alice should still have all her energy
    assertEq(Energy.getEnergy(aliceEntityId), DEFAULT_HIT_ENERGY_COST + 1000, "Alice energy should not change");
  }

  function testHitPlayerFatalForAttacker() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set Alice energy to exactly the hit cost
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST);
    Energy.setEnergy(bobEntityId, DEFAULT_HIT_ENERGY_COST + 1000);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit should cause Alice to die
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));

    // Alice should be dead
    assertPlayerIsDead(aliceEntityId, aliceCoord);

    // Bob should not have taken damage
    assertEq(Energy.getEnergy(bobEntityId), DEFAULT_HIT_ENERGY_COST + 1000, "Bob should not take damage");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testHitPlayerKillsTarget() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip strong whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.DiamondWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    // Set energy so Bob will die from hit
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);
    Energy.setEnergy(bobEntityId, TOOL_HIT_ENERGY_COST / 2); // Less than tool damage

    // Add items to Bob's inventory to test transfer
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.Stone, 10);
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.IronOre, 5);

    // Hit Bob with tool
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));

    // Bob should be dead
    assertEq(Energy.getEnergy(bobEntityId), 0, "Bob should be dead");

    // Trigger player removal
    vm.prank(bob);
    world.activate(bobEntityId);

    // Verify Bob was removed from grid
    assertEq(EntityPosition.get(bobEntityId), vec3(0, 0, 0), "Bob position should be cleared");
  }
}
