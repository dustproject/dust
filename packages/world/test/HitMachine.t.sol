// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { HIT_ENERGY_COST, WHACKER_MULTIPLIER } from "../src/Constants.sol";
import { EntityId } from "../src/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ForceFieldUtils } from "../src/utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../src/utils/InventoryUtils.sol";
import { Position } from "../src/utils/Vec3Storage.sol";
import { DustTest } from "./DustTest.sol";

import { TestEnergyUtils, TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract HitMachineTest is DustTest {
  function testHitForceFieldWithoutTool() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy._setEnergy(aliceEntityId, 1000);
    Energy._setEnergy(forceField, 1000);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    // Hit force field without tool
    vm.prank(alice);
    startGasReport("hit force field without tool");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // Check energy reduction
    assertEq(Energy._getEnergy(forceField), 1000 - HIT_ENERGY_COST);
    assertEq(Energy._getEnergy(aliceEntityId), 1000 - HIT_ENERGY_COST);

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testHitForceFieldWithWhacker() public {
    // Setup player and force field
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 forceFieldCoord = playerCoord + vec3(1, 0, 0);
    EntityId forceField = setupForceField(forceFieldCoord);

    // Set initial energy
    Energy._setEnergy(aliceEntityId, 1000);
    Energy._setEnergy(forceField, 1000);

    // Create and equip whacker
    EntityId whacker = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.CopperWhacker);
    uint16 slot = TestInventoryUtils.getEntitySlot(aliceEntityId, whacker);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    // Hit force field with whacker
    vm.prank(alice);
    startGasReport("hit force field with whacker");
    world.hitForceField(aliceEntityId, forceFieldCoord, slot);
    endGasReport();

    // Check energy reduction with whacker multiplier
    uint128 expectedReduction = HIT_ENERGY_COST * WHACKER_MULTIPLIER;
    assertEq(Energy.getEnergy(forceField), 1000 - expectedReduction);
    assertEq(Energy.getEnergy(aliceEntityId), 1000 - HIT_ENERGY_COST);

    // Check tool mass reduction
    assertEq(Mass.getMass(whacker), 99); // Assuming initial mass is 100

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
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
    Energy.setEnergy(aliceEntityId, HIT_ENERGY_COST - 1);
    Energy.setEnergy(forceField, HIT_ENERGY_COST);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    // Hit should still succeed but player energy should be 0
    vm.prank(alice);
    startGasReport("hit force field with insufficient energy");
    world.hitForceField(aliceEntityId, forceFieldCoord);
    endGasReport();

    // ForceField energy didn't change
    assertEq(Energy.getEnergy(forceField), HIT_ENERGY_COST);

    // Player died
    assertPlayerIsDead(aliceEntityId, playerCoord);

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }
}
