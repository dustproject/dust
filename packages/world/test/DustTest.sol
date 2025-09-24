// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { GasReporter } from "@latticexyz/gas-report/src/GasReporter.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";

import {
  BARE_HANDS_ACTION_ENERGY_COST,
  CHUNK_COMMIT_EXPIRY_TIME,
  CHUNK_SIZE,
  MAX_FLUID_LEVEL,
  MAX_PLAYER_ENERGY,
  PLAYER_ENERGY_DRAIN_RATE,
  REGION_SIZE
} from "../src/Constants.sol";
import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";
import { ObjectType } from "../src/types/ObjectType.sol";

import { ObjectTypes } from "../src/types/ObjectType.sol";

import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";
import { EntityFluidLevel } from "../src/codegen/tables/EntityFluidLevel.sol";
import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { ChunkCommitment } from "../src/codegen/tables/ChunkCommitment.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { EntityOrientation } from "../src/codegen/tables/EntityOrientation.sol";

import { Machine } from "../src/codegen/tables/Machine.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { RegionMerkleRoot } from "../src/codegen/tables/RegionMerkleRoot.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { encodeChunk } from "./utils/encodeChunk.sol";

import { EntityPosition, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { DustAssertions } from "./DustAssertions.sol";

import { TestDrandEvmnet } from "./utils/TestDrandEvmnet.sol";
import {
  TestDrandUtils,
  TestEnergyUtils,
  TestEntityUtils,
  TestForceFieldUtils,
  TestInventoryUtils,
  TestPlayerProgressUtils,
  TestPlayerSkillUtils,
  TestPlayerUtils,
  TestToolUtils
} from "./utils/TestUtils.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract DustTest is MudTest, GasReporter, DustAssertions {
  IWorld internal world;
  int32 constant FLAT_CHUNK_GRASS_LEVEL = 4;
  uint128 playerHandMassReduction = BARE_HANDS_ACTION_ENERGY_COST;

  function setUp() public virtual override {
    super.setUp();

    world = IWorld(worldAddress);

    // Transfer root ownership to this test contract
    ResourceId rootNamespace = WorldResourceIdLib.encodeNamespace(bytes14(0));
    address owner = NamespaceOwner.get(rootNamespace);
    vm.prank(owner);
    world.transferOwnership(rootNamespace, address(this));
    TestEntityUtils.init(address(TestEntityUtils));
    TestPlayerUtils.init(address(TestPlayerUtils));
    TestInventoryUtils.init(address(TestInventoryUtils));
    TestToolUtils.init(address(TestToolUtils));
    TestForceFieldUtils.init(address(TestForceFieldUtils));
    TestEnergyUtils.init(address(TestEnergyUtils));
    TestPlayerProgressUtils.init(address(TestPlayerProgressUtils));
    TestPlayerSkillUtils.init(address(TestPlayerSkillUtils));
    TestDrandUtils.init(address(TestDrandUtils));
  }

  function randomEntityId() internal returns (EntityId) {
    return EntityId.wrap(bytes32(vm.randomUint()));
  }

  // Create a valid player that can perform actions
  function createTestPlayer(Vec3 coord) internal returns (address, EntityId) {
    address playerAddress = vm.randomAddress();
    EntityId player = EntityTypeLib.encodePlayer(playerAddress);

    if (!TerrainLib._isChunkExplored(coord.toChunkCoord(), worldAddress)) {
      setupAirChunk(coord);
    }

    EntityObjectType.set(player, ObjectTypes.Player);

    TestPlayerUtils.addPlayerToGrid(player, coord);

    Energy.set(
      player,
      EnergyData({
        lastUpdatedTime: uint128(block.timestamp),
        energy: MAX_PLAYER_ENERGY,
        drainRate: PLAYER_ENERGY_DRAIN_RATE
      })
    );

    return (playerAddress, player);
  }

  function _getFlatChunk() internal pure returns (uint8[][][] memory chunk) {
    chunk = new uint8[][][](uint256(int256(CHUNK_SIZE)));
    for (uint256 x = 0; x < uint256(int256(CHUNK_SIZE)); x++) {
      chunk[x] = new uint8[][](uint256(int256(CHUNK_SIZE)));
      for (uint256 y = 0; y < uint256(int256(CHUNK_SIZE)); y++) {
        chunk[x][y] = new uint8[](uint256(int256(CHUNK_SIZE)));
        for (uint256 z = 0; z < uint256(int256(CHUNK_SIZE)); z++) {
          if (y < uint256(int256(FLAT_CHUNK_GRASS_LEVEL))) {
            chunk[x][y][z] = _packObjectType(ObjectTypes.Dirt);
          } else if (y == uint256(int256(FLAT_CHUNK_GRASS_LEVEL))) {
            chunk[x][y][z] = _packObjectType(ObjectTypes.Grass);
          } else {
            chunk[x][y][z] = _packObjectType(ObjectTypes.Air);
          }
        }
      }
    }
  }

  function setupFlatChunk(Vec3 coord) internal {
    uint8[][][] memory chunk = _getFlatChunk();
    uint8 biome = 1;
    bool isSurface = true;
    bytes memory encodedChunk = encodeChunk(biome, isSurface, chunk);
    Vec3 chunkCoord = coord.toChunkCoord();
    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    RegionMerkleRoot.set(regionCoord.x(), regionCoord.z(), TerrainLib._getChunkLeafHash(chunkCoord, encodedChunk));
    bytes32[] memory merkleProof = new bytes32[](0);

    world.exploreChunk(chunkCoord, encodedChunk, merkleProof);

    Vec3 shardCoord = coord.toLocalEnergyPoolShardCoord();
    LocalEnergyPool.set(shardCoord, 1e18);
  }

  function setupFlatChunkWithPlayer() internal returns (address, EntityId, Vec3) {
    setupFlatChunk(vec3(0, 0, 0));
    Vec3 coord = vec3(CHUNK_SIZE / 2, FLAT_CHUNK_GRASS_LEVEL + 1, CHUNK_SIZE / 2);
    (address alice, EntityId aliceEntityId) = createTestPlayer(coord);
    return (alice, aliceEntityId, coord);
  }

  function randomSpawnPlayer(Vec3 spawnCoord) internal returns (address, EntityId, Vec3) {
    uint256 blockNumber = block.number - 5;

    address alice = vm.randomAddress();
    vm.prank(alice);
    EntityId aliceEntityId = world.randomSpawn(blockNumber, spawnCoord);

    Vec3 playerCoord = EntityPosition.get(aliceEntityId);

    return (alice, aliceEntityId, playerCoord);
  }

  function _packObjectType(ObjectType objectType) internal pure returns (uint8) {
    return uint8(objectType.unwrap());
  }

  function _getChunk(ObjectType objectType) internal pure returns (uint8[][][] memory chunk) {
    uint8 packed = _packObjectType(objectType);
    chunk = new uint8[][][](uint256(int256(CHUNK_SIZE)));
    for (uint256 x = 0; x < uint256(int256(CHUNK_SIZE)); x++) {
      chunk[x] = new uint8[][](uint256(int256(CHUNK_SIZE)));
      for (uint256 y = 0; y < uint256(int256(CHUNK_SIZE)); y++) {
        chunk[x][y] = new uint8[](uint256(int256(CHUNK_SIZE)));
        for (uint256 z = 0; z < uint256(int256(CHUNK_SIZE)); z++) {
          chunk[x][y][z] = packed;
        }
      }
    }
  }

  function setupAirChunk(Vec3 coord) internal {
    setupChunk(coord, 1, ObjectTypes.Air);
  }

  function _getWaterChunk() internal pure returns (uint8[][][] memory chunk) {
    chunk = _getChunk(ObjectTypes.Water);
  }

  function setupChunk(Vec3 coord, uint8 biome, ObjectType objectType) internal {
    uint8[][][] memory chunk = _getChunk(objectType);
    bool isSurface = true;
    bytes memory encodedChunk = encodeChunk(biome, isSurface, chunk);
    Vec3 chunkCoord = coord.toChunkCoord();
    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    RegionMerkleRoot.set(regionCoord.x(), regionCoord.z(), TerrainLib._getChunkLeafHash(chunkCoord, encodedChunk));
    bytes32[] memory merkleProof = new bytes32[](0);

    world.exploreChunk(chunkCoord, encodedChunk, merkleProof);

    Vec3 shardCoord = coord.toLocalEnergyPoolShardCoord();
    LocalEnergyPool.set(shardCoord, 1e18);
  }

  function setupWaterChunk(Vec3 coord) internal {
    setupChunk(coord, 2, ObjectTypes.Water);
  }

  function setTerrainAtCoord(Vec3 coord, ObjectType objectType) internal {
    Vec3 chunkCoord = coord.toChunkCoord();
    if (!TerrainLib._isChunkExplored(chunkCoord, worldAddress)) {
      setupAirChunk(coord);
    }
    address chunkPointer = TerrainLib._getChunkPointer(chunkCoord, worldAddress);
    uint256 blockIndex = TerrainLib._getBlockIndex(coord);

    bytes memory chunk = chunkPointer.code;
    // Add SSTORE2 offset
    chunk[blockIndex + 1] = bytes1(_packObjectType(objectType));

    vm.etch(chunkPointer, chunk);
  }

  function setObjectAtCoord(Vec3 coord, ObjectType objectType) internal returns (EntityId) {
    return setObjectAtCoord(coord, objectType, Orientation.wrap(0));
  }

  function setObjectAtCoord(Vec3 coord, ObjectType objectType, Orientation orientation) internal returns (EntityId) {
    Vec3 chunkCoord = coord.toChunkCoord();
    if (!TerrainLib._isChunkExplored(chunkCoord, worldAddress)) {
      setupAirChunk(coord);
    }

    EntityId entityId = EntityTypeLib.encodeBlock(coord);
    EntityOrientation.set(entityId, orientation);

    EntityObjectType.set(entityId, objectType);
    EntityPosition.set(entityId, coord);
    Mass.set(entityId, ObjectPhysics.getMass(objectType));
    if (objectType.spawnsWithFluid()) {
      EntityFluidLevel.set(entityId, MAX_FLUID_LEVEL);
    }

    Vec3[] memory coords = objectType.getRelativeCoords(coord, orientation);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      EntityId relativeEntityId = EntityTypeLib.encodeBlock(relativeCoord);
      EntityObjectType.set(relativeEntityId, objectType);
      BaseEntity.set(relativeEntityId, entityId);
    }
    return entityId;
  }

  function setupAirChunkWithPlayer() internal returns (address, EntityId, Vec3) {
    setupAirChunk(vec3(0, 0, 0));
    return spawnPlayerOnAirChunk(vec3(CHUNK_SIZE / 2, 1, CHUNK_SIZE / 2));
  }

  function setupWaterChunkWithPlayer() internal returns (address, EntityId, Vec3) {
    setupWaterChunk(vec3(0, 0, 0));
    Vec3 spawnCoord = vec3(0, 1, 0);
    (address alice, EntityId aliceEntityId) = createTestPlayer(spawnCoord);
    return (alice, aliceEntityId, spawnCoord);
  }

  function spawnPlayerOnAirChunk(Vec3 spawnCoord) internal returns (address, EntityId, Vec3) {
    Vec3 belowCoord = spawnCoord - vec3(0, 1, 0);
    setTerrainAtCoord(spawnCoord, ObjectTypes.Air);
    setTerrainAtCoord(spawnCoord + vec3(0, 1, 0), ObjectTypes.Air);
    setTerrainAtCoord(belowCoord, ObjectTypes.Dirt);

    (address alice, EntityId aliceEntityId) = createTestPlayer(spawnCoord);

    return (alice, aliceEntityId, spawnCoord);
  }

  function setupForceField(Vec3 coord) internal returns (EntityId) {
    // Set forcefield with no energy
    EntityId forceFieldEntityId = setObjectAtCoord(coord, ObjectTypes.ForceField);
    TestForceFieldUtils.setupForceField(forceFieldEntityId, coord);
    return forceFieldEntityId;
  }

  function setupForceField(Vec3 coord, EnergyData memory energyData) internal returns (EntityId) {
    EntityId forceFieldEntityId = setupForceField(coord);
    Energy.set(forceFieldEntityId, energyData);
    return forceFieldEntityId;
  }

  function setupForceField(Vec3 coord, EnergyData memory energyData, uint128 depletedTime) internal returns (EntityId) {
    EntityId forceFieldEntityId = setupForceField(coord, energyData);
    Machine.setDepletedTime(forceFieldEntityId, depletedTime);
    return forceFieldEntityId;
  }

  function newCommit(address commiterAddress, EntityId commiter, Vec3 coord, uint256 randomness) internal {
    // Set up chunk commitment for randomness when mining grass
    Vec3 chunkCoord = coord.toChunkCoord();

    vm.warp(vm.getBlockTimestamp() + CHUNK_COMMIT_EXPIRY_TIME + 5 seconds);
    vm.prank(commiterAddress);
    world.initChunkCommit(commiter, chunkCoord);

    ChunkCommitment.setRandomness(chunkCoord.x(), chunkCoord.y(), chunkCoord.z(), randomness);
  }
}
