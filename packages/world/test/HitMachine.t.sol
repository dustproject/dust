// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  ACTION_MODIFIER_DENOMINATOR,
  BARE_HANDS_ACTION_ENERGY_COST,
  HIT_ACTION_MODIFIER,
  ORE_TOOL_BASE_MULTIPLIER,
  SPECIALIZATION_MULTIPLIER,
  TOOL_ACTION_ENERGY_COST
} from "../src/Constants.sol";

import { ActivityType } from "../src/codegen/common.sol";
import { Energy } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityId } from "../src/types/EntityId.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { DustTest } from "./DustTest.sol";

import { TestInventoryUtils, TestPlayerProgressUtils } from "./utils/TestUtils.sol";

contract HitMachineTest is DustTest {
  function testHitForceFieldWithoutTool() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, BARE_HANDS_ACTION_ENERGY_COST + 1);
    Energy.setEnergy(forceField, BARE_HANDS_ACTION_ENERGY_COST);

    // Hit force field without tool
    vm.prank(alice);
    startGasReport("hit force field without tool");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // Check energy reduction
    assertEq(Energy.getEnergy(forceField), 0);
    assertEq(Energy.getEnergy(aliceEntityId), 1);

    // Check player activity tracking
    uint256 hitMachineActivity = TestPlayerProgressUtils.getProgress(aliceEntityId, ActivityType.HitMachineDamage);
    assertEq(hitMachineActivity, BARE_HANDS_ACTION_ENERGY_COST, "Hit machine damage activity not tracked correctly");
  }

  function testRateLimitHitMachineDoesNotAffectHitPlayerSameBlock() public {
    // Setup player, force field, and target player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);
    Vec3 bobCoord = playerCoord + vec3(0, 0, 1);
    (, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Give energies high enough for both actions
    Energy.setEnergy(aliceEntityId, BARE_HANDS_ACTION_ENERGY_COST * 10);
    Energy.setEnergy(forceField, BARE_HANDS_ACTION_ENERGY_COST * 2);
    Energy.setEnergy(bobEntityId, BARE_HANDS_ACTION_ENERGY_COST * 2);

    // Hit machine then player in the same block
    vm.prank(alice);
    world.hitForceField(aliceEntityId, forceFieldCoord);

    uint128 bobEnergyBefore = Energy.getEnergy(bobEntityId);
    vm.prank(alice);
    world.hitPlayer(aliceEntityId, bobEntityId, bytes(""));

    // Verify both actions succeeded independently (no combined rate limit)
    assertLt(Energy.getEnergy(forceField), BARE_HANDS_ACTION_ENERGY_COST * 2, "Forcefield should be damaged");
    assertLt(Energy.getEnergy(bobEntityId), bobEnergyBefore, "Bob should be damaged");
  }

  function testHitForceFieldWithoutToolFatal() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, BARE_HANDS_ACTION_ENERGY_COST);
    Energy.setEnergy(forceField, BARE_HANDS_ACTION_ENERGY_COST);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit force field without tool
    vm.prank(alice);
    startGasReport("hit force field without tool");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // Check energy didn't change because player died
    assertEq(Energy.getEnergy(forceField), BARE_HANDS_ACTION_ENERGY_COST);

    assertPlayerIsDead(aliceEntityId, playerCoord);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testHitForceFieldWithWhacker() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Create and equip whacker
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    uint128 whackerMass = Mass.getMass(whacker);
    uint128 forceFieldEnergy = whackerMass * 1000;
    uint128 aliceEnergy = TOOL_ACTION_ENERGY_COST + 1;

    // Set a manual energy so that it is not fully depleted
    Energy.setEnergy(forceField, forceFieldEnergy);
    Energy.setEnergy(aliceEntityId, aliceEnergy);

    // Hit force field with whacker
    vm.prank(alice);
    startGasReport("hit force field with whacker");
    world.hitForceField(aliceEntityId, forceFieldCoord, slot);
    endGasReport();

    // Check energy reduction with whacker multiplier
    uint128 maxToolMassReduction = whackerMass / 10;
    uint128 expectedMultiplier = ORE_TOOL_BASE_MULTIPLIER * HIT_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;

    uint128 actionMassReduction = maxToolMassReduction * expectedMultiplier / ACTION_MODIFIER_DENOMINATOR;

    uint128 actualForceFieldEnergy = Energy.getEnergy(forceField);
    uint128 expectedForceFieldEnergy = forceFieldEnergy - TOOL_ACTION_ENERGY_COST - actionMassReduction;
    assertEq(actualForceFieldEnergy, expectedForceFieldEnergy);
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergy - TOOL_ACTION_ENERGY_COST);

    // Check tool mass reduction
    // When tool capacity is limiting, the exact maxToolMassReduction is used
    assertEq(Mass.getMass(whacker), whackerMass - maxToolMassReduction);
  }

  function testHitDepletedForceField() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Deplete force field energy
    Energy.setEnergy(forceField, 0);

    // Attempt to hit depleted force field
    vm.prank(alice);
    vm.expectRevert("Cannot hit depleted forcefield");
    world.hitForceField(aliceEntityId, forceFieldCoord);
  }

  function testHitNonExistentForceField() public {
    // Setup player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Try to hit at position with no force field
    Vec3 emptyPos = playerCoord + vec3(2, 0, 0);
    vm.prank(alice);
    vm.expectRevert("No force field at this location");
    world.hitForceField(aliceEntityId, emptyPos);
  }

  function testHitForceFieldWithInsufficientEnergy() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set player energy below hit cost
    Energy.setEnergy(aliceEntityId, BARE_HANDS_ACTION_ENERGY_COST - 1);
    Energy.setEnergy(forceField, BARE_HANDS_ACTION_ENERGY_COST);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit should still succeed but player energy should be 0
    vm.prank(alice);
    startGasReport("hit force field with insufficient energy");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // ForceField energy didn't change
    assertEq(Energy.getEnergy(forceField), BARE_HANDS_ACTION_ENERGY_COST);

    // Player died
    assertPlayerIsDead(aliceEntityId, playerCoord);

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testHitForceFieldEnergyReductionOrder() public {
    // This test verifies that tool mass reduction is calculated based on remaining energy
    // after player energy reduction, not the total force field energy
    // This would fail before the fix where it passed full force field energy to tool.use()

    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));

    // Create and equip whacker
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    uint128 whackerMass = Mass.getMass(whacker);

    // Set force field to have high total energy but low remaining after player reduction
    // Force field: TOOL_ACTION_ENERGY_COST + 90 (enough for 10 mass reduction before fix)
    // After player reduction: 90 remaining (enough for exactly 10 mass)
    uint128 remainingEnergy = 90;
    Energy.setEnergy(forceField, TOOL_ACTION_ENERGY_COST + remainingEnergy);
    Energy.setEnergy(aliceEntityId, TOOL_ACTION_ENERGY_COST + 100);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Calculate expected tool mass reduction based on remaining energy
    uint256 multiplier = uint256(ORE_TOOL_BASE_MULTIPLIER) * HIT_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;
    uint128 maxToolMassReduction = whackerMass / 10;

    // Calculate using the same logic as ToolUtils
    uint256 maxReductionScaled = uint256(maxToolMassReduction) * multiplier;
    uint256 massLeftScaled = uint256(remainingEnergy) * ACTION_MODIFIER_DENOMINATOR;

    uint128 expectedToolMassReduction;
    if (maxReductionScaled <= massLeftScaled) {
      expectedToolMassReduction = maxToolMassReduction;
    } else {
      expectedToolMassReduction = uint128((massLeftScaled + multiplier - 1) / multiplier); // divUp
    }

    assertEq(Energy.getEnergy(forceField), 0);
    assertEq(Energy.getEnergy(aliceEntityId), 100);
    assertEq(Mass.getMass(whacker), whackerMass - expectedToolMassReduction);
  }

  function testHitForceFieldWhenToolMassReductionExceedsRemainingEnergy() public {
    // Test case where the tool would normally reduce more mass than the remaining energy allows

    // Setup
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    uint128 whackerMass = Mass.getMass(whacker);

    // Set force field energy so that remaining energy after player reduction is less than tool mass reduction
    // Force field energy = TOOL_ACTION_ENERGY_COST + half of what tool would normally reduce
    // Calculate expected multiplier for ore whacker
    uint256 multiplier = uint256(ORE_TOOL_BASE_MULTIPLIER) * HIT_ACTION_MODIFIER * SPECIALIZATION_MULTIPLIER;
    uint128 maxToolMassReduction = whackerMass / 10;
    uint128 maxActionMassReduction = uint128((uint256(maxToolMassReduction) * multiplier) / ACTION_MODIFIER_DENOMINATOR);
    uint128 remainingEnergy = maxActionMassReduction / 2;

    Energy.setEnergy(forceField, TOOL_ACTION_ENERGY_COST + remainingEnergy);
    Energy.setEnergy(aliceEntityId, TOOL_ACTION_ENERGY_COST + 10);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Calculate expected tool mass reduction based on remaining energy
    uint256 massLeftScaled = uint256(remainingEnergy) * ACTION_MODIFIER_DENOMINATOR;
    uint128 expectedToolMassReduction = uint128((massLeftScaled + multiplier - 1) / multiplier); // divUp

    // Verify energy reductions
    assertEq(Energy.getEnergy(forceField), 0); // Should be fully depleted
    assertEq(Energy.getEnergy(aliceEntityId), 10);

    // Verify tool mass reduction was limited by remaining energy
    assertEq(Mass.getMass(whacker), whackerMass - expectedToolMassReduction);
  }

  function testHitForceFieldWithExactPlayerEnergyForReduction() public {
    // Test when force field has exactly enough energy for player reduction
    // This tests that tool damage is correctly calculated when player uses all force field energy

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    uint128 whackerMass = Mass.getMass(whacker);

    // Set force field to exactly TOOL_ACTION_ENERGY_COST
    // Player reduction will be limited to this amount, leaving nothing for tool
    Energy.setEnergy(aliceEntityId, TOOL_ACTION_ENERGY_COST + 100);
    Energy.setEnergy(forceField, TOOL_ACTION_ENERGY_COST);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Force field should be fully depleted (player used all of it)
    assertEq(Energy.getEnergy(forceField), 0);
    // Player should have reduced by TOOL_ACTION_ENERGY_COST
    assertEq(Energy.getEnergy(aliceEntityId), 100);
    // Tool should not have been used (no energy left)
    assertEq(Mass.getMass(whacker), whackerMass);
  }

  function testHitForceFieldWhenForceFieldEnergyLessThanPlayerReduction() public {
    // Test when force field has less energy than player would normally reduce

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));

    // Set force field energy less than TOOL_ACTION_ENERGY_COST
    Energy.setEnergy(forceField, TOOL_ACTION_ENERGY_COST / 2);
    Energy.setEnergy(aliceEntityId, TOOL_ACTION_ENERGY_COST + 10);

    // Create and equip whacker
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);
    uint128 initialWhackerMass = Mass.getMass(whacker);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Player energy reduction should be limited by force field energy
    assertEq(Energy.getEnergy(aliceEntityId), TOOL_ACTION_ENERGY_COST + 10 - TOOL_ACTION_ENERGY_COST / 2);

    // Force field should be fully depleted
    assertEq(Energy.getEnergy(forceField), 0);

    // Tool should not have been used since remaining energy after player reduction is 0
    assertEq(Mass.getMass(whacker), initialWhackerMass);
  }
}
