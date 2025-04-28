// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { GasReporter } from "@latticexyz/gas-report/src/GasReporter.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";

import {
  CHUNK_SIZE, MAX_PLAYER_ENERGY, MINE_ENERGY_COST, PLAYER_ENERGY_DRAIN_RATE, REGION_SIZE
} from "../src/Constants.sol";
import { EntityId } from "../src/EntityId.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";

import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";
import { Machine } from "../src/codegen/tables/Machine.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { Player } from "../src/codegen/tables/Player.sol";

import { RegionMerkleRoot } from "../src/codegen/tables/RegionMerkleRoot.sol";
import { ReversePlayer } from "../src/codegen/tables/ReversePlayer.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { encodeChunk } from "./utils/encodeChunk.sol";

import {
  LocalEnergyPool,
  MovablePosition,
  Position,
  ReverseMovablePosition,
  ReversePosition
} from "../src/utils/Vec3Storage.sol";

import { DustAssertions } from "./DustAssertions.sol";
import { TestEnergyUtils, TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract DustTest is MudTest, GasReporter, DustAssertions {
  IWorld internal world;
  int32 constant FLAT_CHUNK_GRASS_LEVEL = 4;
  uint128 playerHandMassReduction = MINE_ENERGY_COST;

  function setUp() public virtual override {
    super.setUp();

    world = IWorld(worldAddress);

    // Transfer root ownership to this test contract
    ResourceId rootNamespace = WorldResourceIdLib.encodeNamespace(bytes14(0));
    address owner = NamespaceOwner.get(rootNamespace);
    vm.prank(owner);
    world.transferOwnership(rootNamespace, address(this));
    TestInventoryUtils.init(address(TestInventoryUtils));
    TestForceFieldUtils.init(address(TestForceFieldUtils));
    TestEnergyUtils.init(address(TestEnergyUtils));
  }

  function randomEntityId() internal returns (EntityId) {
    return EntityId.wrap(bytes32(vm.randomUint()));
  }

  // Create a valid player that can perform actions
  function createTestPlayer(Vec3 coord) internal returns (address, EntityId) {
    address playerAddress = vm.randomAddress();
    EntityId playerEntityId = randomEntityId();
    EntityObjectType.set(playerEntityId, ObjectTypes.Player);
    MovablePosition.set(playerEntityId, coord);
    ReverseMovablePosition.set(coord, playerEntityId);

    Vec3[] memory relativePositions = ObjectTypes.Player.getObjectTypeSchema();
    for (uint256 i = 0; i < relativePositions.length; i++) {
      Vec3 relativeCoord = coord + relativePositions[i];
      EntityId relativePlayerEntityId = randomEntityId();
      EntityObjectType.set(relativePlayerEntityId, ObjectTypes.Player);
      MovablePosition.set(relativePlayerEntityId, relativeCoord);
      ReverseMovablePosition.set(relativeCoord, relativePlayerEntityId);
      BaseEntity.set(relativePlayerEntityId, playerEntityId);
    }

    Player.set(playerAddress, playerEntityId);
    ReversePlayer.set(playerEntityId, playerAddress);

    Energy.set(
      playerEntityId,
      EnergyData({
        lastUpdatedTime: uint128(block.timestamp),
        energy: MAX_PLAYER_ENERGY,
        drainRate: PLAYER_ENERGY_DRAIN_RATE
      })
    );

    return (playerAddress, playerEntityId);
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

  function randomSpawnPlayer(int32 y) internal returns (address, EntityId, Vec3) {
    uint256 blockNumber = block.number - 5;

    address alice = vm.randomAddress();
    vm.prank(alice);
    EntityId aliceEntityId = world.randomSpawn(blockNumber, y);

    Vec3 playerCoord = MovablePosition.get(aliceEntityId);

    return (alice, aliceEntityId, playerCoord);
  }

  function _packObjectType(ObjectType objectType) internal pure returns (uint8 packed) {
    uint16 category = objectType.category();
    uint16 index = objectType.index();
    require((category >> 8) < 16 && index < 16, "Type can't be packed");
    packed = uint8(category >> 4) | uint8(index);
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

  function _getAirChunk() internal pure returns (uint8[][][] memory chunk) {
    chunk = _getChunk(ObjectTypes.Air);
  }

  function setupAirChunk(Vec3 coord) internal {
    uint8[][][] memory chunk = _getAirChunk();
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

  function _getWaterChunk() internal pure returns (uint8[][][] memory chunk) {
    chunk = _getChunk(ObjectTypes.Water);
  }

  function setupWaterChunk(Vec3 coord) internal {
    uint8[][][] memory chunk = _getWaterChunk();
    uint8 biome = 2;
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
    Vec3 chunkCoord = coord.toChunkCoord();
    if (!TerrainLib._isChunkExplored(chunkCoord, worldAddress)) {
      setupAirChunk(coord);
    }

    EntityId entityId = randomEntityId();
    EntityObjectType.set(entityId, objectType);
    Position.set(entityId, coord);
    ReversePosition.set(coord, entityId);
    Mass.set(entityId, ObjectPhysics.getMass(objectType));

    Vec3[] memory coords = objectType.getRelativeCoords(coord);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      EntityId relativeEntityId = randomEntityId();
      EntityObjectType.set(relativeEntityId, objectType);
      Position.set(relativeEntityId, relativeCoord);
      ReversePosition.set(relativeCoord, relativeEntityId);
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
    return spawnPlayerOnAirChunk(vec3(0, 1, 0));
  }

  function spawnPlayerOnAirChunk(Vec3 spawnCoord) internal returns (address, EntityId, Vec3) {
    Vec3 belowCoord = spawnCoord - vec3(0, 1, 0);
    setTerrainAtCoord(spawnCoord, ObjectTypes.Air);
    setTerrainAtCoord(spawnCoord + vec3(0, 1, 0), ObjectTypes.Air);
    setTerrainAtCoord(belowCoord, ObjectTypes.Dirt);

    (address alice, EntityId aliceEntityId) = createTestPlayer(spawnCoord);
    Vec3 playerCoord = MovablePosition.get(aliceEntityId);

    return (alice, aliceEntityId, playerCoord);
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

  // Helper function to find the inventory slot with a specific object type
  function findInventorySlotWithObjectType(EntityId entityId, ObjectType objectType) internal view returns (uint8) {
    uint256 numSlots = Inventory.length(entityId);
    for (uint8 i = 0; i < numSlots; i++) {
      // Assuming 36 inventory slots
      ObjectType slotObjectType = InventorySlot.getObjectType(entityId, Inventory.getItem(entityId, i));
      if (slotObjectType == objectType) {
        return i;
      }
    }
    revert("Object type not found in inventory");
  }
}
