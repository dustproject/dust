// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC165 } from "@latticexyz/world/src/IERC165.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { TestEnergyUtils, TestEntityUtils, TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

import { BedPlayer, BedPlayerData } from "../src/codegen/tables/BedPlayer.sol";
import { Fragment } from "../src/codegen/tables/Fragment.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { Machine } from "../src/codegen/tables/Machine.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest, console } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { CHUNK_SIZE, MACHINE_ENERGY_DRAIN_RATE, PLAYER_ENERGY_DRAIN_RATE } from "../src/Constants.sol";
import { EntityId, EntityIdLib } from "../src/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/ObjectType.sol";

import { Orientation } from "../src/Orientation.sol";
import { ProgramId } from "../src/ProgramId.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

contract TestBedProgram is System {
  fallback() external { }
}

contract BedTest is DustTest {
  function createBed(Vec3 bedCoord) internal returns (EntityId) {
    // Set entity to bed
    EntityId bed = setObjectAtCoord(bedCoord, ObjectTypes.Bed, Orientation.wrap(44));
    return bed;
  }

  function attachTestProgram(EntityId bedEntityId) internal {
    TestBedProgram program = new TestBedProgram();
    bytes14 namespace = "programNS";
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, program, false);

    Vec3 bedCoord = EntityPosition.get(bedEntityId);

    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(bedCoord - vec3(1, 0, 0));
    vm.prank(bob);
    world.attachProgram(bobEntityId, bedEntityId, ProgramId.wrap(programSystemId.unwrap()), "");
  }

  function testSleep() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());
    // Set forcefield
    setupForceField(
      bedCoord, EnergyData({ energy: 1000, lastUpdatedTime: initialTimestamp, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    (EntityId forceField, EntityId fragment) = TestForceFieldUtils.getForceField(bedCoord);

    EntityId bedEntityId = createBed(bedCoord);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Checks
    BedPlayerData memory bedPlayerData = BedPlayer.get(bedEntityId);
    assertEq(bedPlayerData.playerEntityId.unwrap(), aliceEntityId.unwrap(), "Bed's player entity is not alice");
    assertEq(bedPlayerData.lastDepletedTime, initialTimestamp, "Wrong lastDepletedTime");
    assertEq(
      PlayerBed.getBedEntityId(aliceEntityId).unwrap(), bedEntityId.unwrap(), "Player's bed entity is not the bed"
    );
    assertEq(Fragment.getExtraDrainRate(fragment), PLAYER_ENERGY_DRAIN_RATE);
    assertEq(Energy.getDrainRate(forceField), MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE);
  }

  function testSleepFailsIfNoBed() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Use a random entity for (non) bed
    EntityId bedEntityId = randomEntityId();

    vm.prank(alice);
    vm.expectRevert("Not a bed");
    world.sleep(aliceEntityId, bedEntityId, "");
  }

  function testSleepFailsIfNotInPlayerInfluence() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();

    Vec3 bedCoord = coord + vec3(500, 0, 0);

    // Set forcefield
    setupForceField(bedCoord + vec3(4, 0, 0));

    // Set entity to bed
    EntityId bedEntityId = createBed(bedCoord);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.sleep(aliceEntityId, bedEntityId, "");
  }

  function testSleepFailsIfNoForceField() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    // Set entity to bed
    EntityId bedEntityId = createBed(bedCoord);

    vm.prank(alice);
    vm.expectRevert("Bed is not inside a forcefield");
    world.sleep(aliceEntityId, bedEntityId, "");
  }

  function testWakeup() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    uint128 initialForcefieldEnergy = 1_000_000 * 10 ** 14;
    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: uint128(vm.getBlockTimestamp()),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId fragment = TestEntityUtils.getFragmentAt(bedCoord.toFragmentCoord());

    assertEq(Fragment.getExtraDrainRate(fragment), 0);

    EntityId bedEntityId = createBed(bedCoord);

    // Building a bed does not increase the drain rate
    assertEq(Fragment.getExtraDrainRate(fragment), 0);

    attachTestProgram(bedEntityId);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    assertEq(Fragment.getExtraDrainRate(fragment), PLAYER_ENERGY_DRAIN_RATE);

    uint128 timeDelta = 1000 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    assertEq(
      ffEnergyData.energy,
      initialForcefieldEnergy - timeDelta * (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE),
      "Forcefield energy wasn't drained correctly"
    );

    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");

    assertEq(Energy.getEnergy(aliceEntityId), initialPlayerEnergy, "Player energy was drained while sleeping");
    assertEq(Fragment.getExtraDrainRate(fragment), 0);
  }

  function testWakeupWithDepletedForcefield() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to fully deplete after 1000 seconds (with 1 sleeping player)
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 1000;

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: initialTimestamp,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    attachTestProgram(bedEntityId);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait for 500 more seconds so the player's energy is also depleted in this period
    uint128 timeDelta = 1000 seconds + 500 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy wasn't drained correctly");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for 500 seconds
    assertEq(depletedTime, 500 + initialTimestamp, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the 1000 seconds that the forcefield was off
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - PLAYER_ENERGY_DRAIN_RATE * 500 seconds,
      "Player energy was not drained"
    );
  }

  function testWakeupWithDepletedAndRechargedForcefield() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to fully deplete after 1000 seconds (with 1 sleeping player)
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 1000;

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: initialTimestamp,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    attachTestProgram(bedEntityId);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait for 500 more seconds so the player's energy is also depleted in this period
    vm.warp(vm.getBlockTimestamp() + 1000 seconds + 500 seconds);

    // Then we charge it again with the initial charge
    TestEnergyUtils.updateMachineEnergy(forcefieldEntityId);
    Energy.setEnergy(forcefieldEntityId, initialForcefieldEnergy);

    // Then we wait for another 1000 seconds so the forcefield is fully depleted again
    vm.warp(vm.getBlockTimestamp() + 1000 seconds);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy wasn't drained correctly");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for 500 seconds
    assertEq(depletedTime, 500 + initialTimestamp, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the 1000 seconds that the forcefield was off,
    // but not after recharging
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - PLAYER_ENERGY_DRAIN_RATE * 500 seconds,
      "Player energy was not drained"
    );
  }

  function testWakeupFailsIfPlayerDied() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to fully deplete after 1000 seconds (with 1 sleeping player)
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 1000;

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: initialTimestamp,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    attachTestProgram(bedEntityId);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait for the player to also get fully depleted
    // + 1 so the player is fully drained
    uint128 playerDrainTime = initialPlayerEnergy / PLAYER_ENERGY_DRAIN_RATE + 1;
    vm.warp(vm.getBlockTimestamp() + 1000 seconds + playerDrainTime);

    // Wakeup in the original coord
    vm.prank(alice);
    vm.expectRevert("Player died while sleeping");
    world.wakeup(aliceEntityId, coord, "");

    TestEnergyUtils.updateMachineEnergy(forcefieldEntityId);

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy wasn't drained correctly");
    assertEq(
      ffEnergyData.drainRate,
      MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE,
      "Forcefield drain rate does not include player"
    );
    // The forcefield had 0 energy for 500 seconds
    assertEq(depletedTime, playerDrainTime + initialTimestamp, "Forcefield depletedTime was not computed correctly");
  }

  function testRemoveDeadPlayerFromBed() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord + vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to fully deplete after 1000 seconds (with 1 sleeping player)
    uint128 initialForcefieldEnergy = (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * 1000;

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord + vec3(1, 0, 0),
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: initialTimestamp,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    attachTestProgram(bedEntityId);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait more time so the player's energy is FULLY depleted in this period
    // + 1 so the player is fully drained
    uint128 playerDrainTime = initialPlayerEnergy / PLAYER_ENERGY_DRAIN_RATE + 1;
    uint128 timeDelta = 1000 seconds + playerDrainTime;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Remove alice and drop inventory in the original coord
    world.removeDeadPlayerFromBed(aliceEntityId, coord);

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy wasn't drained correctly");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for playerDrainTime seconds
    assertEq(depletedTime, playerDrainTime + initialTimestamp, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the playerDrainTime seconds that the forcefield was off
    assertEq(Energy.getEnergy(aliceEntityId), 0, "Player energy was not drained");
  }

  function testSleepWakeupSleep() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    uint128 initialForcefieldEnergy = 1_000_000 * 10 ** 14;
    // Set forcefield
    EntityId forcefieldEntityId = setupForceField(
      bedCoord,
      EnergyData({
        energy: initialForcefieldEnergy,
        lastUpdatedTime: uint128(vm.getBlockTimestamp()),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    attachTestProgram(bedEntityId);

    // Give objects to the player to test that transfers work
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 1);
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.IronPick);

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(bedEntityId), 0, "Wrong number of occupied inventory slots");

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(bedEntityId), 0, "Wrong number of occupied inventory slots");

    uint128 timeDelta = 1000 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(bedEntityId), 0, "Wrong number of occupied inventory slots");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    assertEq(
      ffEnergyData.energy,
      initialForcefieldEnergy - timeDelta * (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE),
      "Forcefield energy wasn't drained correctly"
    );

    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    assertEq(Energy.getEnergy(aliceEntityId), initialPlayerEnergy, "Player energy was drained while sleeping");

    // Sleep again
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(bedEntityId), 0, "Wrong number of occupied inventory slots");

    BedPlayerData memory bedPlayerData = BedPlayer.get(bedEntityId);
    assertEq(bedPlayerData.playerEntityId.unwrap(), aliceEntityId.unwrap(), "Bed's player entity is not alice");
    assertEq(
      PlayerBed.getBedEntityId(aliceEntityId).unwrap(), bedEntityId.unwrap(), "Player's bed entity is not the bed"
    );
  }
}
