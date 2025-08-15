// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  ACTION_MODIFIER_DENOMINATOR,
  BARE_HANDS_ACTION_ENERGY_COST,
  HIT_ACTION_MODIFIER,
  MAX_HIT_RADIUS,
  MAX_PLAYER_ENERGY,
  ORE_TOOL_BASE_MULTIPLIER,
  SPECIALIZATION_MULTIPLIER,
  TOOL_ACTION_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../src/Constants.sol";

import { ActivityType } from "../src/codegen/common.sol";
import { Energy } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { PlayerProgress } from "../src/codegen/tables/PlayerProgress.sol";

import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { EntityPosition } from "../src/utils/Vec3Storage.sol";
import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils, TestPlayerProgressUtils } from "./utils/TestUtils.sol";

contract HitPlayerTest is DustTest {
  // Test hitting without tool - partial damage
  function testHitPlayerWithoutToolPartialDamage() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set initial energy - both have plenty
    uint128 aliceInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST * 10;
    uint128 bobInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST * 10;
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);
    EnergyDataSnapshot memory bobSnapshot = getEnergyDataSnapshot(bobEntityId);

    // Hit Bob without tool
    vm.prank(alice);
    startGasReport("hit player without tool, partial damage");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
    endGasReport();

    // Calculate expected damage
    // Without tool: damage to Bob equals Alice's energy reduction (up to BARE_HANDS_ACTION_ENERGY_COST)
    uint128 expectedAliceReduction = BARE_HANDS_ACTION_ENERGY_COST;
    uint128 expectedTotalDamage = expectedAliceReduction; // No tool bonus

    // Verify energy changes
    assertEq(Energy.getEnergy(aliceEntityId), aliceInitialEnergy - expectedAliceReduction, "Alice energy incorrect");
    assertEq(Energy.getEnergy(bobEntityId), bobInitialEnergy - expectedTotalDamage, "Bob energy incorrect");

    // Verify energy flowed to local pools
    uint128 aliceEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
    assertEq(aliceEnergyLost, expectedAliceReduction, "Alice energy lost incorrect");

    uint128 bobEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(bobSnapshot);
    assertEq(bobEnergyLost, expectedTotalDamage, "Bob total damage incorrect");

    // Check player activity tracking
    uint256 hitPlayerProgress = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.HitPlayerDamage);
    assertEq(hitPlayerProgress, expectedTotalDamage, "Hit player damage activity not tracked correctly");
  }

  // Test hitting without tool - kill target
  function testHitPlayerWithoutToolKillsTarget() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set energy so Bob will die
    uint128 aliceInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST * 2;
    uint128 bobInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST / 2; // Less than damage
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    // Add items to Bob's inventory to test transfer
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.Stone, 10);
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.IronOre, 5);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);
    EnergyDataSnapshot memory bobSnapshot = getEnergyDataSnapshot(bobEntityId);

    // Hit Bob without tool
    vm.prank(alice);
    startGasReport("hit player without tool, kills target");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
    endGasReport();

    // Calculate expected damage - limited by Bob's remaining energy
    uint128 expectedAliceReduction = bobInitialEnergy; // Can only take what Bob has
    uint128 expectedTotalDamage = expectedAliceReduction;

    // Verify energy changes
    assertEq(Energy.getEnergy(aliceEntityId), aliceInitialEnergy - expectedAliceReduction, "Alice energy incorrect");
    assertEq(Energy.getEnergy(bobEntityId), 0, "Bob should be dead");

    // Verify energy flowed to local pools
    uint128 aliceEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
    assertEq(aliceEnergyLost, expectedAliceReduction, "Alice energy lost incorrect");

    uint128 bobEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(bobSnapshot);
    assertEq(bobEnergyLost, expectedTotalDamage, "Bob total damage incorrect");

    // Trigger player removal
    vm.prank(bob);
    world.activate(bobEntityId);

    // Verify Bob was removed from grid
    assertEq(EntityPosition.get(bobEntityId), vec3(0, 0, 0), "Bob position should be cleared");
  }

  // Test hitting with tool - partial damage
  function testHitPlayerWithToolPartialDamage() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);
    uint128 whackerMass = Mass.getMass(whacker);

    // Set Bob's energy very high so tool capacity is limiting (similar to HitMachine tests)
    uint128 bobInitialEnergy = whackerMass * 1000;
    uint128 aliceInitialEnergy = TOOL_ACTION_ENERGY_COST + 1;
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);
    EnergyDataSnapshot memory bobSnapshot = getEnergyDataSnapshot(bobEntityId);

    // Hit Bob with tool
    vm.prank(alice);
    startGasReport("hit player with copper whacker, partial damage");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    endGasReport();

    // Check energy reduction with whacker multiplier
    uint128 maxToolMassReduction = whackerMass / 10;
    uint128 expectedAliceReduction = TOOL_ACTION_ENERGY_COST;
    uint128 expectedTotalDamage;
    {
      uint128 expectedMultiplier = ORE_TOOL_BASE_MULTIPLIER * HIT_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;
      uint128 actionMassReduction = maxToolMassReduction * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;
      expectedTotalDamage = expectedAliceReduction + actionMassReduction;
    }

    // Verify energy changes
    assertEq(Energy.getEnergy(aliceEntityId), aliceInitialEnergy - expectedAliceReduction, "Alice energy incorrect");
    assertEq(Energy.getEnergy(bobEntityId), bobInitialEnergy - expectedTotalDamage, "Bob energy incorrect");

    // Verify energy flowed to local pools
    uint128 aliceEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
    assertEq(aliceEnergyLost, expectedAliceReduction, "Alice energy lost incorrect");

    uint128 bobEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(bobSnapshot);
    assertEq(bobEnergyLost, expectedTotalDamage, "Bob total damage incorrect");

    // Check tool mass reduction
    // When tool capacity is limiting, the exact maxToolMassReduction is used
    assertEq(Mass.getMass(whacker), whackerMass - maxToolMassReduction, "Tool mass reduction incorrect");
  }

  // Test hitting with tool - kill target (target energy limiting)
  function testHitPlayerWithToolKillsTarget() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);
    uint128 whackerMass = Mass.getMass(whacker);

    // Set Bob's energy so that remaining energy after player reduction is less than tool would normally do
    // Bob energy = TOOL_ACTION_ENERGY_COST + half of what tool would normally reduce
    uint256 multiplier = uint256(ORE_TOOL_BASE_MULTIPLIER) * HIT_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;

    uint128 remainingEnergy;
    {
      uint128 maxToolMassReduction = whackerMass / 10;
      uint128 maxActionMassReduction =
        uint128((uint256(maxToolMassReduction) * multiplier) / ACTION_MODIFIER_DENOMINATOR);
      remainingEnergy = maxActionMassReduction / 2;
    }

    uint128 bobInitialEnergy = TOOL_ACTION_ENERGY_COST + remainingEnergy;
    Energy.setEnergy(aliceEntityId, TOOL_ACTION_ENERGY_COST + 10);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    // Add items to Bob's inventory to test transfer
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.Stone, 10);
    TestInventoryUtils.addObject(bobEntityId, ObjectTypes.IronOre, 5);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);
    EnergyDataSnapshot memory bobSnapshot = getEnergyDataSnapshot(bobEntityId);

    // Hit Bob with tool
    vm.prank(alice);
    startGasReport("hit player with copper whacker, kills target");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    endGasReport();

    // Calculate expected tool mass reduction based on remaining energy
    uint128 expectedToolMassReduction;
    {
      uint256 massLeftScaled = uint256(remainingEnergy) * ACTION_MODIFIER_DENOMINATOR;
      expectedToolMassReduction = uint128((massLeftScaled + multiplier - 1) / multiplier); // divUp
    }

    // Verify Bob is dead
    assertEq(Energy.getEnergy(bobEntityId), 0, "Bob should be dead");
    assertEq(Energy.getEnergy(aliceEntityId), 10, "Alice energy incorrect");

    // Verify energy flowed to local pools
    uint128 aliceEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
    assertEq(aliceEnergyLost, TOOL_ACTION_ENERGY_COST, "Alice energy lost incorrect");

    uint128 bobEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(bobSnapshot);
    assertEq(bobEnergyLost, bobInitialEnergy, "Bob total damage incorrect");

    // Verify tool mass reduction was limited by remaining energy
    assertEq(Mass.getMass(whacker), whackerMass - expectedToolMassReduction, "Tool mass reduction incorrect");

    // Trigger player removal
    vm.prank(bob);
    world.activate(bobEntityId);

    // Verify Bob was removed from grid
    assertEq(EntityPosition.get(bobEntityId), vec3(0, 0, 0), "Bob position should be cleared");
  }

  // Test hitting without tool - attacker dies
  function testHitPlayerWithoutToolAttackerDies() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set Alice energy to exactly the hit cost
    uint128 aliceInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST;
    uint128 bobInitialEnergy = BARE_HANDS_ACTION_ENERGY_COST * 10;
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit should cause Alice to die
    vm.prank(alice);
    startGasReport("hit player without tool, attacker dies");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
    endGasReport();

    // Alice should be dead
    assertPlayerIsDead(aliceEntityId, aliceCoord);

    // Bob should not have taken damage
    assertEq(Energy.getEnergy(bobEntityId), bobInitialEnergy, "Bob should not take damage");

    // Verify Alice's energy flowed to her local pool
    assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
  }

  // Test hitting with tool - attacker dies
  function testHitPlayerWithToolAttackerDies() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    // Set Alice energy to exactly the tool hit cost
    uint128 aliceInitialEnergy = TOOL_ACTION_ENERGY_COST;
    uint128 bobInitialEnergy = TOOL_ACTION_ENERGY_COST * 10;
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit should cause Alice to die
    vm.prank(alice);
    startGasReport("hit player with tool, attacker dies");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    endGasReport();

    // Alice should be dead
    assertPlayerIsDead(aliceEntityId, aliceCoord);

    // Bob should not have taken damage
    assertEq(Energy.getEnergy(bobEntityId), bobInitialEnergy, "Bob should not take damage");

    // Verify Alice's energy flowed to her local pool
    assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
  }

  // Test hitting with non-whacker tool
  function testHitPlayerWithNonWhackerTool() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip a pick (not a whacker)
    EntityId pick = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, pick);
    uint128 pickMass = Mass.getMass(pick);

    // Set Bob's energy very high so tool capacity is limiting
    uint128 bobInitialEnergy = pickMass * 1000;
    uint128 aliceInitialEnergy = TOOL_ACTION_ENERGY_COST + 1;
    Energy.setEnergy(aliceEntityId, aliceInitialEnergy);
    Energy.setEnergy(bobEntityId, bobInitialEnergy);

    EnergyDataSnapshot memory aliceSnapshot = getEnergyDataSnapshot(aliceEntityId);
    EnergyDataSnapshot memory bobSnapshot = getEnergyDataSnapshot(bobEntityId);

    // Hit Bob with non-whacker tool
    vm.prank(alice);
    startGasReport("hit player with non-whacker tool");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
    endGasReport();

    // Check energy reduction without specialization bonus
    uint128 maxToolMassReduction = pickMass / 10;
    uint128 expectedAliceReduction = TOOL_ACTION_ENERGY_COST;
    uint128 expectedTotalDamage;
    {
      uint128 expectedMultiplier = WOODEN_TOOL_BASE_MULTIPLIER * HIT_ACTION_MODIFIER; // No specialization
      uint128 actionMassReduction = maxToolMassReduction * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;
      expectedTotalDamage = expectedAliceReduction + actionMassReduction;
    }

    // Verify energy changes
    assertEq(Energy.getEnergy(aliceEntityId), aliceInitialEnergy - expectedAliceReduction, "Alice energy incorrect");
    assertEq(Energy.getEnergy(bobEntityId), bobInitialEnergy - expectedTotalDamage, "Bob energy incorrect");

    // Verify energy flowed to local pools
    uint128 aliceEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(aliceSnapshot);
    assertEq(aliceEnergyLost, expectedAliceReduction, "Alice energy lost incorrect");

    uint128 bobEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(bobSnapshot);
    assertEq(bobEnergyLost, expectedTotalDamage, "Bob total damage incorrect");

    // Check tool mass reduction
    // When tool capacity is limiting, the exact maxToolMassReduction is used
    assertEq(Mass.getMass(pick), pickMass - maxToolMassReduction, "Tool mass reduction incorrect");
  }

  // Test hitting dead player
  function testHitDeadPlayer() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Kill Bob by setting energy to 0
    Energy.setEnergy(bobEntityId, 0);
    Energy.setEnergy(aliceEntityId, BARE_HANDS_ACTION_ENERGY_COST + 1000);

    uint128 aliceInitialEnergy = Energy.getEnergy(aliceEntityId);

    // Hitting a dead player should revert
    vm.prank(alice);
    vm.expectRevert("Target has no energy");
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));
  }

  // Test rate limiting
  function testHitPlayerRateLimit() public {
    // Setup two players
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(1, 0, 0);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);
    Energy.setEnergy(bobEntityId, MAX_PLAYER_ENERGY);

    // Player can hit up to 1 time per block
    // Hit once, next time should revert
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));

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
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create and equip whacker for Alice
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    // Set high energy so rate limit is hit before energy depletion
    Energy.setEnergy(aliceEntityId, MAX_PLAYER_ENERGY);
    Energy.setEnergy(bobEntityId, MAX_PLAYER_ENERGY);

    // Same rate limit applies with tool
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));

    // 6th hit should fail due to rate limit
    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));

    // Move to next block and verify can hit again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, slot, bytes(""));
  }

  // Test edge cases
  function testHitPlayerFailsIfTooFar() public {
    // Setup two players far apart
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = aliceCoord + vec3(int32(MAX_HIT_RADIUS + 1), 0, 0); // Too far
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

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
}
