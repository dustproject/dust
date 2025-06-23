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
import { Machine } from "../src/codegen/tables/Machine.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest, console } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { CHUNK_SIZE, MACHINE_ENERGY_DRAIN_RATE, PLAYER_ENERGY_DRAIN_RATE } from "../src/Constants.sol";
import { EntityId, EntityIdLib } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";

import { Orientation } from "../src/types/Orientation.sol";
import { ProgramId } from "../src/types/ProgramId.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import {
  NotABed,
  EntityIsTooFar,
  BedNotInsideForceField,
  CannotMineForceFieldWithSleepingPlayers
} from "../src/Errors.sol";

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
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();

    // Use a random entity for (non) bed
    (EntityId bedEntityId,) = TestEntityUtils.getBlockAt(coord + vec3(1, 0, 0));

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(NotABed.selector, ObjectTypes.Air));
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
    vm.expectRevert(abi.encodeWithSelector(EntityIsTooFar.selector, coord, bedCoord));
    world.sleep(aliceEntityId, bedEntityId, "");
  }

  function testSleepFailsIfNoForceField() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    // Set entity to bed
    EntityId bedEntityId = createBed(bedCoord);

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(BedNotInsideForceField.selector, bedEntityId));
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

  function testSleepInDepletedForcefield() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to 0
    uint128 initialForcefieldEnergy = 0;

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

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy should be 0");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for 100 seconds
    assertEq(depletedTime, initialTimestamp + timeDelta, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the time they slept
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - PLAYER_ENERGY_DRAIN_RATE * timeDelta,
      "Player energy was not drained"
    );
  }

  function testSleepInChargedAndDepletedForcefield() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to 0
    uint128 initialForcefieldEnergy = 100 * MACHINE_ENERGY_DRAIN_RATE;

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

    // First deplete the forcefield
    uint128 timeDelta = initialForcefieldEnergy / MACHINE_ENERGY_DRAIN_RATE;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    EntityId bedEntityId = createBed(bedCoord);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    uint128 sleepTimeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + sleepTimeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy should be 0");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy while the player slept
    assertEq(depletedTime, initialTimestamp + sleepTimeDelta, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the time they slept
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - PLAYER_ENERGY_DRAIN_RATE * (timeDelta + sleepTimeDelta),
      "Player energy was not drained"
    );
  }

  function testSleepInDepletedForcefieldFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set the forcefield's energy to 0
    uint128 initialForcefieldEnergy = 0;

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

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    uint128 timeDelta = initialPlayerEnergy / PLAYER_ENERGY_DRAIN_RATE + 1;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy should be 0");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for 100 seconds
    assertEq(depletedTime, initialTimestamp + timeDelta, "Forcefield depletedTime was not computed correctly");

    assertPlayerIsDead(aliceEntityId, coord);
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

  function testWakeupIfPlayerDied() public {
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

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // After 1000 seconds, the forcefield should be depleted
    // We wait for the player to also get fully depleted
    // + 1 so the player is fully drained
    uint128 playerDrainTime = initialPlayerEnergy / PLAYER_ENERGY_DRAIN_RATE + 1;
    vm.warp(vm.getBlockTimestamp() + 1000 seconds + playerDrainTime);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    EnergyData memory ffEnergyData = Energy.get(forcefieldEntityId);
    uint128 depletedTime = Machine.getDepletedTime(forcefieldEntityId);
    assertEq(ffEnergyData.energy, 0, "Forcefield energy wasn't drained correctly");
    assertEq(ffEnergyData.drainRate, MACHINE_ENERGY_DRAIN_RATE, "Forcefield drain rate was not restored");
    // The forcefield had 0 energy for playerDrainTime seconds
    assertEq(depletedTime, playerDrainTime + initialTimestamp, "Forcefield depletedTime was not computed correctly");

    // Check that the player energy was drained during the playerDrainTime seconds that the forcefield was off
    assertEq(Energy.getEnergy(aliceEntityId), 0, "Player energy was not drained");
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

    // Give objects to the player to test that transfers work
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 1);
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.IronPick);

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);

    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);

    uint128 timeDelta = 1000 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Wakeup in the original coord
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronPick, 1);
    assertInventoryHasObject(bedEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(bedEntityId, ObjectTypes.IronPick, 0);

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

    BedPlayerData memory bedPlayerData = BedPlayer.get(bedEntityId);
    assertEq(bedPlayerData.playerEntityId.unwrap(), aliceEntityId.unwrap(), "Bed's player entity is not alice");
    assertEq(
      PlayerBed.getBedEntityId(aliceEntityId).unwrap(), bedEntityId.unwrap(), "Player's bed entity is not the bed"
    );
  }

  function testCannotMineForcefieldWithSleepingPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    Vec3 bedCoord = coord - vec3(2, 0, 0);
    Vec3 forcefieldCoord = bedCoord + vec3(1, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);
    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield with no energy (depleted)
    EntityId forcefieldEntityId = setupForceField(
      forcefieldCoord,
      EnergyData({ energy: 0, lastUpdatedTime: initialTimestamp, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    EntityId bedEntityId = createBed(bedCoord);

    // Alice goes to sleep
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Wait some time
    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Bob tries to mine the forcefield, but it should fail
    // Set the mass of the existing forcefield instance, not the object type
    Mass.setMass(forcefieldEntityId, playerHandMassReduction - 1);
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(CannotMineForceFieldWithSleepingPlayers.selector, PLAYER_ENERGY_DRAIN_RATE));
    world.mine(bobEntityId, forcefieldCoord, "");

    // Alice can still wake up normally
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    // Check that player energy was drained (forcefield had no energy)
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - (PLAYER_ENERGY_DRAIN_RATE * timeDelta),
      "Player energy should be drained when forcefield has no energy"
    );
  }

  function testCannotMineDepletedForcefieldWithSleepingPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    Vec3 bedCoord = coord - vec3(2, 0, 0);
    Vec3 forcefieldCoord = bedCoord + vec3(1, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);
    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield with NO energy (depleted)
    setupForceField(
      forcefieldCoord,
      EnergyData({ energy: 0, lastUpdatedTime: initialTimestamp, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    EntityId bedEntityId = createBed(bedCoord);

    // Alice goes to sleep in depleted forcefield
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Wait some time while sleeping
    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Bob tries to mine the forcefield, but it should fail
    // Set the mass of the existing forcefield instance, not the object type
    (EntityId forcefieldEntityId,) = TestEntityUtils.getBlockAt(forcefieldCoord);
    Mass.setMass(forcefieldEntityId, playerHandMassReduction - 1);
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(CannotMineForceFieldWithSleepingPlayers.selector, PLAYER_ENERGY_DRAIN_RATE));
    world.mine(bobEntityId, forcefieldCoord, "");

    // Alice can still wake up normally
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    // Check that player energy was correctly drained for time in depleted forcefield
    uint128 expectedEnergy = initialPlayerEnergy - (PLAYER_ENERGY_DRAIN_RATE * timeDelta);
    assertEq(
      Energy.getEnergy(aliceEntityId),
      expectedEnergy,
      "Player energy should be drained for sleep duration in depleted forcefield"
    );
  }

  function testCannotMinePartiallyDepletedForcefieldWithSleepingPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    Vec3 bedCoord = coord - vec3(2, 0, 0);
    Vec3 forcefieldCoord = bedCoord + vec3(1, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);

    // Set forcefield with energy that will deplete after 50 seconds
    uint128 forcefieldLifetime = 50 seconds;
    setupForceField(
      forcefieldCoord,
      EnergyData({
        energy: (MACHINE_ENERGY_DRAIN_RATE + PLAYER_ENERGY_DRAIN_RATE) * forcefieldLifetime,
        lastUpdatedTime: uint128(vm.getBlockTimestamp()),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    EntityId bedEntityId = createBed(bedCoord);

    // Alice goes to sleep
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Wait until forcefield depletes plus extra time
    vm.warp(vm.getBlockTimestamp() + forcefieldLifetime + 30 seconds);

    // Bob tries to mine the forcefield, but it should fail
    // Set the mass of the existing forcefield instance, not the object type
    (EntityId forcefieldEntityId,) = TestEntityUtils.getBlockAt(forcefieldCoord);
    Mass.setMass(forcefieldEntityId, playerHandMassReduction - 1);
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(CannotMineForceFieldWithSleepingPlayers.selector, PLAYER_ENERGY_DRAIN_RATE));
    world.mine(bobEntityId, forcefieldCoord, "");

    // Alice can still wake up
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    // Check that player energy was correctly drained only for depleted time
    // Player loses energy for: 30 seconds after forcefield depleted
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialPlayerEnergy - (PLAYER_ENERGY_DRAIN_RATE * 30 seconds),
      "Player energy should be drained only for time forcefield was depleted"
    );
  }

  function testMineBedWithSleepingPlayerAfterForcefieldDestroyed() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(5, 0, 0));

    Vec3 bedCoord = coord - vec3(2, 0, 0);
    Vec3 forcefieldCoord = bedCoord + vec3(1, 0, 0);

    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield with no energy
    EntityId forceField = setupForceField(
      forcefieldCoord,
      EnergyData({ energy: 0, lastUpdatedTime: initialTimestamp, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    EntityId bedEntityId = createBed(bedCoord);

    // Alice goes to sleep
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Wait some time
    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Bob tries to mine the forcefield, but it should fail because there's a sleeping player
    // Set the mass of the existing forcefield instance, not the object type
    Mass.setMass(forceField, playerHandMassReduction - 1);
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(CannotMineForceFieldWithSleepingPlayers.selector, PLAYER_ENERGY_DRAIN_RATE));
    world.mine(bobEntityId, forcefieldCoord, "");
  }

  function testCannotMineForcefieldWithMultipleSleepingPlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));
    (address charlie, EntityId charlieEntityId) = createTestPlayer(coord + vec3(2, 0, 0));

    console.log(coord.toString());

    Vec3 bed1Coord = coord - vec3(2, 0, 0);
    Vec3 bed2Coord = coord - vec3(4, 0, 0);
    Vec3 forcefieldCoord = coord - vec3(1, 0, 0);

    uint128 initialAliceEnergy = Energy.getEnergy(aliceEntityId);
    uint128 initialCharlieEnergy = Energy.getEnergy(charlieEntityId);

    // Set forcefield with no energy
    setupForceField(
      forcefieldCoord,
      EnergyData({ energy: 0, lastUpdatedTime: uint128(vm.getBlockTimestamp()), drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    // Create two beds and sleep
    {
      EntityId bed1 = createBed(bed1Coord);
      vm.prank(alice);
      world.sleep(aliceEntityId, bed1, "");
    }

    {
      EntityId bed2 = createBed(bed2Coord);
      vm.prank(charlie);
      world.sleep(charlieEntityId, bed2, "");
    }

    // Wait some time
    vm.warp(vm.getBlockTimestamp() + 100 seconds);

    // Bob tries to mine forcefield, but it should fail
    (EntityId forcefieldEntityId,) = TestEntityUtils.getBlockAt(forcefieldCoord);
    Mass.setMass(forcefieldEntityId, playerHandMassReduction - 1);
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(CannotMineForceFieldWithSleepingPlayers.selector, PLAYER_ENERGY_DRAIN_RATE));
    world.mine(bobEntityId, forcefieldCoord, "");

    // Both players can still wake up
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    vm.prank(charlie);
    world.wakeup(charlieEntityId, coord + vec3(2, 0, 0), "");

    // Check energy drain
    uint128 totalTime = 100 seconds;
    assertEq(
      Energy.getEnergy(aliceEntityId),
      initialAliceEnergy - (PLAYER_ENERGY_DRAIN_RATE * totalTime),
      "Alice's energy should be drained correctly"
    );
    assertEq(
      Energy.getEnergy(charlieEntityId),
      initialCharlieEnergy - (PLAYER_ENERGY_DRAIN_RATE * totalTime),
      "Charlie's energy should be drained correctly"
    );
  }

  function testWakeupAfterForcefieldDestroyedConservativeEstimate() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupFlatChunkWithPlayer();

    Vec3 bedCoord = coord - vec3(2, 0, 0);
    Vec3 forcefieldCoord = bedCoord + vec3(1, 0, 0);

    uint128 initialPlayerEnergy = Energy.getEnergy(aliceEntityId);
    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());

    // Set forcefield with no energy
    EntityId forceField = setupForceField(
      forcefieldCoord,
      EnergyData({ energy: 0, lastUpdatedTime: initialTimestamp, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    EntityId bedEntityId = createBed(bedCoord);

    // Alice goes to sleep
    vm.prank(alice);
    world.sleep(aliceEntityId, bedEntityId, "");

    // Wait some time
    uint128 timeDelta = 100 seconds;
    vm.warp(vm.getBlockTimestamp() + timeDelta);

    // Manually clear the Machine table to simulate forcefield being mined
    // This tests the conservative estimation case in updateSleepingPlayerEnergy
    Machine._deleteRecord(forceField);

    // Also clear Energy table to fully simulate mined state
    Energy._deleteRecord(forceField);

    // Wait more time after forcefield is "mined"
    uint128 timeAfterMining = 50 seconds;
    vm.warp(vm.getBlockTimestamp() + timeAfterMining);

    // Alice wakes up
    vm.prank(alice);
    world.wakeup(aliceEntityId, coord, "");

    // The conservative estimate should drain energy for the entire time since sleeping
    // (timeDelta + timeAfterMining) = 150 seconds total
    uint128 expectedEnergy = initialPlayerEnergy - (PLAYER_ENERGY_DRAIN_RATE * (timeDelta + timeAfterMining));
    assertEq(
      Energy.getEnergy(aliceEntityId),
      expectedEnergy,
      "Player energy should be drained conservatively for entire sleep duration"
    );
  }
}
