// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { DEFAULT_HIT_ENERGY_COST, SPECIALIZED_ORE_TOOL_MULTIPLIER, TOOL_HIT_ENERGY_COST } from "../src/Constants.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
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
}
