// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../src/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";

import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import { LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import {
  CHUNK_SIZE, MACHINE_ENERGY_DRAIN_RATE, MAX_PLAYER_ENERGY, PLAYER_ENERGY_DRAIN_RATE
} from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { TestUtils } from "./utils/TestUtils.sol";
import { TestForceFieldUtils } from "./utils/TestUtils.sol";

contract EnergyTest is DustTest {
  function testPlayerLosesEnergyWhenIdle() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord);

    // pass some time
    vm.warp(block.timestamp + 2);
    world.activatePlayer(alice);

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord) - localEnergyPoolBefore;
    assertGt(energyGainedInPool, 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testMachineLosesEnergyWhenIdle() public {
    (,, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 forceFieldCoord = playerCoord + vec3(0, 0, 1);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 10000, drainRate: MACHINE_ENERGY_DRAIN_RATE })
    );

    uint128 forceFieldEnergyBefore = Energy.getEnergy(forceFieldEntityId);
    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord);

    // pass some time
    vm.warp(block.timestamp + 2);
    world.activate(forceFieldEntityId);

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord) - localEnergyPoolBefore;
    assertGt(energyGainedInPool, 0, "Local energy pool did not gain energy");
    assertEq(
      Energy.getEnergy(forceFieldEntityId), forceFieldEnergyBefore - energyGainedInPool, "Machine did not lose energy"
    );
  }

  function testEnergyTransferMultiplePlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(playerCoord + vec3(1, 0, 0));

    // Set up energy levels
    Energy.set(
      aliceEntityId,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: PLAYER_ENERGY_DRAIN_RATE })
    );

    Energy.set(
      bobEntityId,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 100, drainRate: PLAYER_ENERGY_DRAIN_RATE })
    );

    // Record initial energy levels
    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    uint128 bobEnergyBefore = Energy.getEnergy(bobEntityId);

    // Pass time and check energy transfer to local pool
    vm.warp(block.timestamp + 5);
    world.activatePlayer(alice);
    world.activatePlayer(bob);

    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 poolEnergy = LocalEnergyPool.get(shardCoord);
    assertGt(poolEnergy, 0, "Local energy pool should receive energy from both players");

    // Check that both players lost energy
    assertLt(Energy.getEnergy(aliceEntityId), aliceEnergyBefore, "Alice should lose energy");
    assertLt(Energy.getEnergy(bobEntityId), bobEnergyBefore, "Bob should lose energy");
  }

  function testPlayerEnergyDrain() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Pass time and activate player
    vm.warp(block.timestamp + 5);
    world.activatePlayer(alice);

    // Player energy should drain according to player-specific logic
    uint128 energyLost = MAX_PLAYER_ENERGY - Energy.getEnergy(aliceEntityId);
    assertEq(energyLost, PLAYER_ENERGY_DRAIN_RATE * 5, "Player energy should drain at player rate");
  }

  function testMachineEnergyDrain() public {
    Vec3 machineCoord = vec3(1, 1, 1);
    uint128 initialEnergy = MACHINE_ENERGY_DRAIN_RATE * 1000;
    EntityId machineEntityId = setupForceField(
      machineCoord,
      EnergyData({
        lastUpdatedTime: uint128(block.timestamp),
        energy: initialEnergy,
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Pass time and activate machine
    vm.warp(block.timestamp + 5);
    world.activate(machineEntityId);

    // Machine energy should drain according to machine-specific logic
    uint128 energyLost = initialEnergy - Energy.getEnergy(machineEntityId);
    assertEq(energyLost, MACHINE_ENERGY_DRAIN_RATE * 5, "Machine energy should drain at machine rate");
  }

  function testEnergyPoolDistribution() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    (address bob, EntityId bobEntityId) = createTestPlayer(playerCoord + vec3(1, 0, 0));

    Energy.setDrainRate(
      bobEntityId,
      PLAYER_ENERGY_DRAIN_RATE * 2 // Bob has double drain rate
    );

    // Record initial pool energy
    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 initialPoolEnergy = LocalEnergyPool.get(shardCoord);

    // Pass time and check energy distribution
    vm.warp(block.timestamp + 5);
    world.activatePlayer(alice);
    world.activatePlayer(bob);

    uint128 newPoolEnergy = LocalEnergyPool.get(shardCoord);
    uint128 energyAddedToPool = newPoolEnergy - initialPoolEnergy;

    // Bob should contribute more energy to the pool due to higher drain rate
    uint128 aliceEnergyLost = MAX_PLAYER_ENERGY - Energy.getEnergy(aliceEntityId);
    uint128 bobEnergyLost = MAX_PLAYER_ENERGY - Energy.getEnergy(bobEntityId);
    assertGt(bobEnergyLost, aliceEnergyLost, "Bob should lose more energy due to higher drain rate");
    assertEq(energyAddedToPool, aliceEnergyLost + bobEnergyLost, "Pool should receive all lost energy");
  }
}
