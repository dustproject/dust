// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC165 } from "@latticexyz/world/src/IERC165.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { TestEntityUtils } from "./utils/TestUtils.sol";

import { EntityId } from "../src/types/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";

import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest, console } from "./DustTest.sol";

import { LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import {
  CHUNK_SIZE, MACHINE_ENERGY_DRAIN_RATE, MAX_PLAYER_ENERGY, PLAYER_ENERGY_DRAIN_RATE
} from "../src/Constants.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";

import { ProgramId } from "../src/types/ProgramId.sol";

import { Vec3, vec3 } from "../src/types/Vec3.sol";

contract TestSpawnProgram is System {
  fallback() external { }
}

contract SpawnTest is DustTest {
  function testRandomSpawn() public {
    uint256 blockNumber = vm.getBlockNumber() - 5;
    address alice = vm.randomAddress();

    // Explore chunk at (0, 0, 0)
    setupFlatChunk(vec3(0, 0, 0));

    vm.prank(alice);
    Vec3 spawnCoord = world.getRandomSpawnCoord(blockNumber, alice);

    // Give energy for local shard
    Vec3 shardCoord = spawnCoord.toLocalEnergyPoolShardCoord();
    LocalEnergyPool.set(shardCoord, MAX_PLAYER_ENERGY);

    vm.prank(alice);
    startGasReport("randomSpawn");
    EntityId playerEntityId = world.randomSpawn(blockNumber, spawnCoord);
    endGasReport();
    assertTrue(playerEntityId.exists());

    assertEq(
      Energy.getEnergy(playerEntityId), MAX_PLAYER_ENERGY * 3 / 10, "Player energy is not correct after random spawn"
    );
  }

  function testRandomSpawnPaused() public {
    WorldStatus.setIsPaused(true);
    vm.expectRevert("DUST is paused. Try again later");
    world.randomSpawn(vm.getBlockNumber(), vec3(0, 0, 0));
  }

  function testRandomSpawnFailsDueToOldBlock() public {
    uint256 pastBlock = vm.getBlockNumber() - 21;
    vm.expectRevert("Can only choose past 20 blocks");
    world.randomSpawn(pastBlock, vec3(0, 0, 0));
  }

  function testSpawnTile() public {
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 1, 0);
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    setupAirChunk(spawnCoord);

    // Set forcefield
    setupForceField(
      spawnTileCoord,
      EnergyData({
        energy: MAX_PLAYER_ENERGY,
        lastUpdatedTime: uint128(block.timestamp),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Set below entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    TestSpawnProgram program = new TestSpawnProgram();
    bytes14 namespace = "programNS";
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, program, false);
    world.transferOwnership(namespaceId, address(0));

    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(spawnTileCoord - vec3(1, 0, 0));
    vm.prank(bob);
    world.attachProgram(bobEntityId, spawnTileEntityId, ProgramId.wrap(programSystemId.unwrap()), "");

    // Spawn alice
    vm.prank(alice);
    startGasReport("spawn with spawn tile");
    EntityId playerEntityId = world.spawn(spawnTileEntityId, spawnCoord, 1, "");
    endGasReport();
    assertTrue(playerEntityId.exists());
  }

  function testSpawnFailsIfNoValidSpawnCoord() public {
    uint256 blockNumber = vm.getBlockNumber() - 5;
    address alice = vm.randomAddress();

    setupAirChunk(vec3(0, 0, 0));

    vm.prank(alice);
    vm.expectRevert("No valid spawn coord found in chunk");
    world.getRandomSpawnCoord(blockNumber, alice);
  }

  function testSpawnFailsIfNoSpawnTile() public {
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 0, 0);

    // Use a random entity for (non) spawn tile
    EntityId spawnTileEntityId = randomEntityId();

    vm.prank(alice);
    vm.expectRevert("Not a spawn tile");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }

  function testSpawnFailsIfNotInSpawnArea() public {
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 0, 0);
    Vec3 spawnTileCoord = vec3(500, 0, 0);

    setupAirChunk(spawnCoord);

    // Set forcefield
    setupForceField(spawnTileCoord);

    // Set Far away entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    vm.prank(alice);
    vm.expectRevert("Spawn tile is too far away");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }

  function testSpawnFailsIfNoForceField() public {
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 0, 0);
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    setupAirChunk(spawnCoord);

    // Set below entity to spawn tile (no forcefield)
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    vm.prank(alice);
    vm.expectRevert("Spawn tile is not inside a forcefield");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }

  function testSpawnFailsIfNotEnoughForceFieldEnergy() public {
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 0, 0);
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    setupAirChunk(spawnCoord);

    // Set forcefield with no energy
    setupForceField(spawnTileCoord);

    // Set below entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    vm.prank(alice);
    vm.expectRevert("Not enough energy in spawn tile forcefield");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }

  function testSpawnAfterDeath() public {
    // This should setup a player with energy
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 spawnCoord = playerCoord;
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    // Drain energy from player
    vm.warp(vm.getBlockTimestamp() + (MAX_PLAYER_ENERGY / PLAYER_ENERGY_DRAIN_RATE) + 1);

    // Set forcefield
    EntityId forceFieldEntityId = setupForceField(spawnTileCoord);
    Energy.set(
      forceFieldEntityId,
      EnergyData({
        energy: MAX_PLAYER_ENERGY,
        lastUpdatedTime: uint128(block.timestamp),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Set below entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    // Spawn player
    vm.prank(alice);
    EntityId playerEntityId = world.spawn(spawnTileEntityId, spawnCoord, 1, "");

    assertEq(playerEntityId, aliceEntityId, "Player entity doesn't match");
  }

  function testSpawnFailsIfNotDead() public {
    // This should setup a player with energy
    (address alice,, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 spawnCoord = playerCoord;
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    // Set forcefield
    EntityId forceFieldEntityId = setupForceField(spawnTileCoord);
    Energy.set(
      forceFieldEntityId,
      EnergyData({
        energy: MAX_PLAYER_ENERGY,
        lastUpdatedTime: uint128(block.timestamp),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Set below entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    // Spawn player should fail as the player has energy
    vm.prank(alice);
    vm.expectRevert("Player already spawned");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }

  function testRandomSpawnAfterDeath() public {
    // This should setup a player with energy
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Drain energy from player
    vm.warp(vm.getBlockTimestamp() + (MAX_PLAYER_ENERGY / PLAYER_ENERGY_DRAIN_RATE) + 1);

    uint256 blockNumber = vm.getBlockNumber() - 5;

    vm.prank(alice);
    Vec3 spawnCoord = world.getRandomSpawnCoord(blockNumber, alice);

    // Give energy for local shard
    Vec3 shardCoord = spawnCoord.toLocalEnergyPoolShardCoord();
    LocalEnergyPool.set(shardCoord, MAX_PLAYER_ENERGY);

    vm.prank(alice);
    EntityId playerEntityId = world.randomSpawn(blockNumber, spawnCoord);
    assertEq(playerEntityId, aliceEntityId, "Player entity doesn't match");
  }

  function testRandomSpawnFailsIfNotDead() public {
    // This should setup a player with energy
    (address alice,,) = setupFlatChunkWithPlayer();

    uint256 blockNumber = vm.getBlockNumber() - 5;

    vm.prank(alice);
    Vec3 spawnCoord = world.getRandomSpawnCoord(blockNumber, alice);

    // Give energy for local shard
    Vec3 shardCoord = spawnCoord.toLocalEnergyPoolShardCoord();
    LocalEnergyPool.set(shardCoord, MAX_PLAYER_ENERGY);

    // Spawn player should fail as the player has energy
    vm.prank(alice);
    vm.expectRevert("Player already spawned");
    world.randomSpawn(blockNumber, spawnCoord);
  }

  function testSpawnRespawn() public {
    // Set up player and spawn tile
    address alice = vm.randomAddress();
    Vec3 spawnCoord = vec3(0, 1, 0);
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);

    setupAirChunk(spawnCoord);

    // Set below entity to spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    // Set forcefield with energy
    EntityId forceFieldEntityId = setupForceField(spawnTileCoord + vec3(0, 0, 1));
    Energy.set(
      forceFieldEntityId,
      EnergyData({
        energy: MAX_PLAYER_ENERGY,
        lastUpdatedTime: uint128(block.timestamp),
        drainRate: MACHINE_ENERGY_DRAIN_RATE
      })
    );

    // Create original player
    vm.prank(alice);
    EntityId playerEntityId = world.spawn(spawnTileEntityId, spawnCoord, 1, "");
    assertTrue(playerEntityId.exists());

    // Kill player by depleting energy
    vm.warp(vm.getBlockTimestamp() + 1);

    // Player should be able to respawn
    vm.prank(alice);
    EntityId respawnedPlayerId = world.spawn(spawnTileEntityId, spawnCoord, 1, "");
    assertEq(respawnedPlayerId, playerEntityId, "Player's entity Id is different after respawn");
  }

  function testSpawnOccupiedCoordinateFromSpawnTile() public {
    address alice = vm.randomAddress();
    address bob = vm.randomAddress();

    Vec3 spawnCoord = vec3(0, 2, 0);
    Vec3 spawnTileCoord = spawnCoord - vec3(0, 1, 0);
    Vec3 forceFieldCoord = spawnTileCoord - vec3(0, 1, 0);

    setupAirChunk(spawnCoord);

    // Set forcefield with energy
    setupForceField(
      forceFieldCoord,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: MAX_PLAYER_ENERGY, drainRate: 0 })
    );

    // Set spawn tile
    EntityId spawnTileEntityId = setObjectAtCoord(spawnTileCoord, ObjectTypes.SpawnTile);

    // First player spawns
    vm.prank(alice);
    EntityId aliceEntityId = world.spawn(spawnTileEntityId, spawnCoord, 1, "");
    assertTrue(aliceEntityId.exists());

    // Second player tries to spawn at the same coordinates
    vm.prank(bob);
    vm.expectRevert("Cannot spawn on a non-passable block");
    world.spawn(spawnTileEntityId, spawnCoord, 1, "");
  }
}
