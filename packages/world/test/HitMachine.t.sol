// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { DEFAULT_HIT_ENERGY_COST, SPECIALIZED_ORE_TOOL_MULTIPLIER, TOOL_HIT_ENERGY_COST } from "../src/Constants.sol";
import { EntityId } from "../src/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ForceFieldUtils } from "../src/utils/ForceFieldUtils.sol";
import { EntityPosition } from "../src/utils/Vec3Storage.sol";
import { DustTest } from "./DustTest.sol";

import { TestEnergyUtils, TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract HitMachineTest is DustTest {
  function testHitForceFieldWithoutTool() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST + 1);
    Energy.setEnergy(forceField, DEFAULT_HIT_ENERGY_COST);

    // Hit force field without tool
    vm.prank(alice);
    startGasReport("hit force field without tool");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // Check energy reduction
    assertEq(Energy.getEnergy(forceField), 0);
    assertEq(Energy.getEnergy(aliceEntityId), 1);
  }

  function testHitForceFieldWithoutToolFatal() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST);
    Energy.setEnergy(forceField, DEFAULT_HIT_ENERGY_COST);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit force field without tool
    vm.prank(alice);
    startGasReport("hit force field without tool");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // Check energy didn't change because player died
    assertEq(Energy.getEnergy(forceField), DEFAULT_HIT_ENERGY_COST);

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
    uint128 aliceEnergy = TOOL_HIT_ENERGY_COST + 1;

    // Set a manual energy so that it is not fully depleted
    Energy.setEnergy(forceField, forceFieldEnergy);
    Energy.setEnergy(aliceEntityId, aliceEnergy);

    // Hit force field with whacker
    vm.prank(alice);
    startGasReport("hit force field with whacker");
    world.hitForceField(aliceEntityId, forceFieldCoord, slot);
    endGasReport();

    // Check energy reduction with whacker multiplier
    uint128 massReduction = whackerMass / 10;
    uint128 energyReduction = TOOL_HIT_ENERGY_COST + massReduction * SPECIALIZED_ORE_TOOL_MULTIPLIER;
    assertEq(Energy.getEnergy(forceField), forceFieldEnergy - energyReduction);
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergy - TOOL_HIT_ENERGY_COST);

    // Check tool mass reduction
    assertEq(Mass.getMass(whacker), whackerMass - massReduction); // Assuming initial mass is 100
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
    Energy.setEnergy(aliceEntityId, DEFAULT_HIT_ENERGY_COST - 1);
    Energy.setEnergy(forceField, DEFAULT_HIT_ENERGY_COST);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    // Hit should still succeed but player energy should be 0
    vm.prank(alice);
    startGasReport("hit force field with insufficient energy");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // ForceField energy didn't change
    assertEq(Energy.getEnergy(forceField), DEFAULT_HIT_ENERGY_COST);

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
    // Force field: TOOL_HIT_ENERGY_COST + 90 (enough for 10 mass reduction before fix)
    // After player reduction: 90 remaining (enough for exactly 10 mass)
    Energy.setEnergy(forceField, TOOL_HIT_ENERGY_COST + 90);
    Energy.setEnergy(aliceEntityId, TOOL_HIT_ENERGY_COST + 100);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // After fix: tool damage based on remaining 90 energy
    // Tool can use: 90 / 9 = 10 mass exactly
    // Tool damage: 10 * 9 = 90
    assertEq(Energy.getEnergy(forceField), 0);
    assertEq(Energy.getEnergy(aliceEntityId), 100);
    assertEq(Mass.getMass(whacker), whackerMass - 10);
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
    // Force field energy = TOOL_HIT_ENERGY_COST + half of what tool would normally reduce
    Energy.setEnergy(forceField, TOOL_HIT_ENERGY_COST + (whackerMass / 10 * SPECIALIZED_ORE_TOOL_MULTIPLIER) / 2);
    Energy.setEnergy(aliceEntityId, TOOL_HIT_ENERGY_COST + 10);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Verify energy reductions
    assertEq(Energy.getEnergy(forceField), 0); // Should be fully depleted
    assertEq(Energy.getEnergy(aliceEntityId), 10);

    // Verify tool mass reduction was limited by remaining energy
    uint128 remainingAfterPlayer = (whackerMass / 10 * SPECIALIZED_ORE_TOOL_MULTIPLIER) / 2;
    assertEq(Mass.getMass(whacker), whackerMass - remainingAfterPlayer / SPECIALIZED_ORE_TOOL_MULTIPLIER);
  }

  function testHitForceFieldWithExactPlayerEnergyForReduction() public {
    // Test when force field has exactly enough energy for player reduction
    // This tests that tool damage is correctly calculated when player uses all force field energy

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);

    uint128 whackerMass = Mass.getMass(whacker);

    // Set force field to exactly TOOL_HIT_ENERGY_COST
    // Player reduction will be limited to this amount, leaving nothing for tool
    Energy.setEnergy(aliceEntityId, TOOL_HIT_ENERGY_COST + 100);
    Energy.setEnergy(forceField, TOOL_HIT_ENERGY_COST);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Force field should be fully depleted (player used all of it)
    assertEq(Energy.getEnergy(forceField), 0);
    // Player should have reduced by TOOL_HIT_ENERGY_COST
    assertEq(Energy.getEnergy(aliceEntityId), 100);
    // Tool should not have been used (no energy left)
    assertEq(Mass.getMass(whacker), whackerMass);
  }

  function testHitForceFieldWhenForceFieldEnergyLessThanPlayerReduction() public {
    // Test when force field has less energy than player would normally reduce

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    EntityId forceField = setupForceField(playerCoord + vec3(1, 0, 0));

    // Set force field energy less than TOOL_HIT_ENERGY_COST
    Energy.setEnergy(forceField, TOOL_HIT_ENERGY_COST / 2);
    Energy.setEnergy(aliceEntityId, TOOL_HIT_ENERGY_COST + 10);

    // Create and equip whacker
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.findEntity(aliceEntityId, whacker);
    uint128 initialWhackerMass = Mass.getMass(whacker);

    // Hit force field with whacker
    vm.prank(alice);
    world.hitForceField(aliceEntityId, playerCoord + vec3(1, 0, 0), slot);

    // Player energy reduction should be limited by force field energy
    assertEq(Energy.getEnergy(aliceEntityId), TOOL_HIT_ENERGY_COST + 10 - TOOL_HIT_ENERGY_COST / 2);

    // Force field should be fully depleted
    assertEq(Energy.getEnergy(forceField), 0);

    // Tool should not have been used since remaining energy after player reduction is 0
    assertEq(Mass.getMass(whacker), initialWhackerMass);
  }
}
