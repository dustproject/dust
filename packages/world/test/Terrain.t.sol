// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest } from "./DustTest.sol";

import {
  CHUNK_SIZE,
  INITIAL_ENERGY_PER_VEGETATION,
  INITIAL_LOCAL_ENERGY_BUFFER,
  MAX_FLUID_LEVEL,
  REGION_SIZE
} from "../src/Constants.sol";
import { EntityId, EntityTypeLib } from "../src/EntityId.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

import { EntityFluidLevel } from "../src/codegen/tables/EntityFluidLevel.sol";
import { RegionMerkleRoot } from "../src/codegen/tables/RegionMerkleRoot.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { BIOME_PADDING, SURFACE_PADDING, TerrainLib, VERSION_PADDING } from "../src/utils/TerrainLib.sol";
import { InitialEnergyPool, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";
import { MockChunk, MockVegetation } from "./mockData.sol";

import { TestEntityUtils } from "./utils/TestUtils.sol";
import { encodeChunk } from "./utils/encodeChunk.sol";

contract TerrainTest is DustTest {
  function testGetChunkCoord() public pure {
    Vec3 coord = vec3(1, 2, 2);
    Vec3 chunkCoord = coord.toChunkCoord();
    assertEq(chunkCoord, vec3(0, 0, 0));

    coord = vec3(16, 17, 18);
    chunkCoord = coord.toChunkCoord();
    assertEq(chunkCoord, vec3(1, 1, 1));

    coord = vec3(-1, -2, -3);
    chunkCoord = coord.toChunkCoord();
    assertEq(chunkCoord, vec3(-1, -1, -1));

    coord = vec3(16, -17, -18);
    chunkCoord = coord.toChunkCoord();
    assertEq(chunkCoord, vec3(1, -2, -2));
  }

  function testGetRelativeCoord() public pure {
    Vec3 coord = vec3(1, 2, 2);
    Vec3 relativeCoord = TerrainLib._getRelativeCoord(coord);
    assertEq(relativeCoord, vec3(1, 2, 2));

    coord = vec3(16, 17, 18);
    relativeCoord = TerrainLib._getRelativeCoord(coord);
    assertEq(relativeCoord, vec3(0, 1, 2));

    coord = vec3(-1, -2, -3);
    relativeCoord = TerrainLib._getRelativeCoord(coord);
    assertEq(relativeCoord, vec3(15, 14, 13));

    coord = vec3(16, -17, -18);
    relativeCoord = TerrainLib._getRelativeCoord(coord);
    assertEq(relativeCoord, vec3(0, 15, 14));
  }

  function testGetBlockIndex() public pure {
    Vec3 coord = vec3(1, 2, 2);
    uint256 index = TerrainLib._getBlockIndex(coord);
    assertEq(index, 1 * 256 + 2 * 16 + 2 + VERSION_PADDING + BIOME_PADDING + SURFACE_PADDING);

    coord = vec3(16, 17, 18);
    index = TerrainLib._getBlockIndex(coord);
    assertEq(index, 0 * 256 + 1 * 16 + 2 + VERSION_PADDING + BIOME_PADDING + SURFACE_PADDING);

    coord = vec3(-1, -2, -3);
    index = TerrainLib._getBlockIndex(coord);
    assertEq(index, 15 * 256 + 14 * 16 + 13 + VERSION_PADDING + BIOME_PADDING + SURFACE_PADDING);

    coord = vec3(16, -17, -18);
    index = TerrainLib._getBlockIndex(coord);
    assertEq(index, 0 * 256 + 15 * 16 + 14 + VERSION_PADDING + BIOME_PADDING + SURFACE_PADDING);
  }

  function testGetChunkSalt() public pure {
    Vec3 chunkCoord = vec3(1, 2, 3);
    bytes32 salt = TerrainLib._getChunkSalt(chunkCoord);
    assertEq(salt, bytes32(abi.encodePacked(bytes20(0), chunkCoord)));
    assertEq(salt, bytes32(uint256(uint96(bytes12(abi.encodePacked(chunkCoord))))));

    chunkCoord = vec3(-1, -2, -3);
    salt = TerrainLib._getChunkSalt(chunkCoord);
    assertEq(salt, bytes32(abi.encodePacked(bytes20(0), chunkCoord)));
    assertEq(salt, bytes32(uint256(uint96(bytes12(abi.encodePacked(chunkCoord))))));
  }

  function _getTestChunk() internal pure returns (uint8[][][] memory chunk, uint8 biome, bool isSurface) {
    chunk = new uint8[][][](uint256(int256(CHUNK_SIZE)));
    for (uint256 x = 0; x < uint256(int256(CHUNK_SIZE)); x++) {
      chunk[x] = new uint8[][](uint256(int256(CHUNK_SIZE)));
      for (uint256 y = 0; y < uint256(int256(CHUNK_SIZE)); y++) {
        chunk[x][y] = new uint8[](uint256(int256(CHUNK_SIZE)));
        for (uint256 z = 0; z < uint256(int256(CHUNK_SIZE)); z++) {
          chunk[x][y][z] = uint8(bytes1(keccak256(abi.encode(x, y, z)))); // random value between 0 and 255
        }
      }
    }
    biome = 1;
    isSurface = true;
  }

  function _setupTestChunk(Vec3 chunkCoord) internal returns (uint8[][][] memory chunk) {
    uint8 biome;
    bool isSurface;
    (chunk, biome, isSurface) = _getTestChunk();
    bytes memory encodedChunk = encodeChunk(biome, isSurface, chunk);
    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    RegionMerkleRoot.set(regionCoord.x(), regionCoord.z(), TerrainLib._getChunkLeafHash(chunkCoord, encodedChunk));
    bytes32[] memory merkleProof = new bytes32[](0);
    IWorld(worldAddress).exploreChunk(chunkCoord, encodedChunk, merkleProof);
  }

  function testExploreChunk() public {
    (uint8[][][] memory chunk, uint8 inputBiome, bool inputIsSurface) = _getTestChunk();
    bytes memory encodedChunk = encodeChunk(inputBiome, inputIsSurface, chunk);
    Vec3 chunkCoord = vec3(0, 0, 0);
    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    RegionMerkleRoot.set(regionCoord.x(), regionCoord.z(), TerrainLib._getChunkLeafHash(chunkCoord, encodedChunk));
    bytes32[] memory merkleProof = new bytes32[](0);

    startGasReport("TerrainLib.exploreChunk");
    IWorld(worldAddress).exploreChunk(chunkCoord, encodedChunk, merkleProof);
    endGasReport();

    Vec3 coord = vec3(1, 2, 3);
    startGasReport("TerrainLib.getBlockType (non-root)");
    ObjectType blockType = TerrainLib.getBlockType(coord);
    endGasReport();

    startGasReport("TerrainLib.getBlockType (root)");
    blockType = TerrainLib.getBlockType(coord, worldAddress);
    endGasReport();

    assertEq(_packObjectType(blockType), uint16(chunk[1][2][3]));

    startGasReport("TerrainLib.getBiome (non-root)");
    uint8 biome = TerrainLib.getBiome(coord);
    endGasReport();

    startGasReport("TerrainLib.getBiome (root)");
    biome = TerrainLib.getBiome(coord, worldAddress);
    endGasReport();

    assertEq(biome, inputBiome);

    startGasReport("TerrainLib.isSurfaceChunk (non-root)");
    bool isSurface = TerrainLib.isSurfaceChunk(coord.toChunkCoord());
    endGasReport();

    startGasReport("TerrainLib.isSurfaceChunk (root)");
    isSurface = TerrainLib.isSurfaceChunk(coord.toChunkCoord(), worldAddress);
    endGasReport();

    assertEq(isSurface, inputIsSurface);

    for (int32 x = 0; x < CHUNK_SIZE; x++) {
      for (int32 y = 0; y < CHUNK_SIZE; y++) {
        for (int32 z = 0; z < CHUNK_SIZE; z++) {
          coord = vec3(x, y, z);
          blockType = TerrainLib.getBlockType(coord);
          assertEq(
            _packObjectType(blockType), uint16(chunk[uint256(int256(x))][uint256(int256(y))][uint256(int256(z))])
          );
        }
      }
    }
  }

  function testExploreChunk_Fail_ChunkAlreadyExplored() public {
    Vec3 chunkCoord = vec3(0, 0, 0);
    (uint8[][][] memory chunk, uint8 biome, bool isSurface) = _getTestChunk();
    _setupTestChunk(chunkCoord);

    vm.expectRevert("Chunk already explored");
    IWorld(worldAddress).exploreChunk(chunkCoord, encodeChunk(biome, isSurface, chunk), new bytes32[](0));
  }

  function testGetBlockType() public {
    Vec3 chunkCoord = vec3(0, 0, 0);
    uint8[][][] memory chunk = _setupTestChunk(vec3(0, 0, 0));

    // Test we can get the block type for a voxel in the chunk
    Vec3 coord = vec3(1, 2, 3);
    ObjectType blockType = TerrainLib.getBlockType(coord);
    assertEq(_packObjectType(blockType), uint16(chunk[1][2][3]));

    // Test for chunks that are not at the origin
    chunkCoord = vec3(1, 2, 3);
    chunk = _setupTestChunk(chunkCoord);
    coord = vec3(16 + 1, 16 * 2 + 2, 16 * 3 + 3);
    blockType = TerrainLib.getBlockType(coord);
    assertEq(_packObjectType(blockType), uint16(chunk[1][2][3]));

    // Test for negative coordinates
    chunkCoord = vec3(-1, -2, -3);
    chunk = _setupTestChunk(chunkCoord);
    coord = vec3(-16 + 1, -16 * 2 + 2, -16 * 3 + 3);
    blockType = TerrainLib.getBlockType(coord);
    assertEq(_packObjectType(blockType), uint16(chunk[1][2][3]));
  }

  function testGetBlockType_ChunkNotExplored() public view {
    ObjectType blockType = TerrainLib.getBlockType(vec3(0, 0, 0));
    assertEq(blockType, ObjectTypes.Null);
  }

  /// forge-config: default.allow_internal_expect_revert = true
  function testGetBiome_Fail_ChunkNotExplored() public {
    vm.expectRevert("Chunk not explored");
    TerrainLib.getBiome(vec3(0, 0, 0));
  }

  function testVerifyChunkMerkleProof() public {
    (int32 x, int32 z) = MockChunk.getRegionCoord();
    RegionMerkleRoot.set(x, z, MockChunk.regionRoot);
    bytes memory encodedChunk = MockChunk.encodedChunk;
    bytes32[] memory proof = MockChunk.getProof();
    Vec3 chunkCoord = MockChunk.getChunkCoord();

    RegionMerkleRoot.set(x, z, MockChunk.regionRoot);

    IWorld(worldAddress).exploreChunk(chunkCoord, encodedChunk, proof);
  }

  function testVerifyChunkMerkleProof_Fail_InvalidProof() public {
    (int32 x, int32 z) = MockChunk.getRegionCoord();
    RegionMerkleRoot.set(x, z, MockChunk.regionRoot);
    bytes memory encodedChunk = MockChunk.encodedChunk;
    bytes32[] memory proof = MockChunk.getProof();
    Vec3 chunkCoord = MockChunk.getChunkCoord();
    RegionMerkleRoot.set(x, z, MockChunk.regionRoot);

    proof[0] = proof[0] ^ bytes32(uint256(1));
    vm.expectRevert("Invalid merkle proof");
    IWorld(worldAddress).exploreChunk(chunkCoord, encodedChunk, proof);

    vm.expectRevert("Invalid merkle proof");
    IWorld(worldAddress).exploreChunk(chunkCoord, encodedChunk, new bytes32[](0));
  }

  function testExploreRegionEnergy() public {
    (int32 x, int32 z) = MockVegetation.getRegionCoord();
    Vec3 regionCoord = vec3(x, 0, z);
    uint32 vegetationCount = MockVegetation.vegetationCount;
    bytes32[] memory merkleProof = MockVegetation.getProof();
    RegionMerkleRoot.set(x, z, MockVegetation.regionRoot);

    assertEq(InitialEnergyPool.get(regionCoord), 0);
    assertEq(LocalEnergyPool.get(regionCoord), 0);

    IWorld(worldAddress).exploreRegionEnergy(regionCoord, vegetationCount, merkleProof);

    uint128 energy = InitialEnergyPool.get(regionCoord);
    assertEq(energy, vegetationCount * INITIAL_ENERGY_PER_VEGETATION + 1);

    energy = LocalEnergyPool.get(regionCoord);
    assertEq(energy, INITIAL_LOCAL_ENERGY_BUFFER);
  }

  function testExploreRegionEnergy_Fail_RegionNotSeeded() public {
    RegionMerkleRoot.set(0, 0, bytes32(0));
    vm.expectRevert("Region not seeded");
    IWorld(worldAddress).exploreRegionEnergy(vec3(0, 0, 0), 100, new bytes32[](0));
  }

  function testExploreRegionEnergy_Fail_InvalidMerkleProof() public {
    vm.expectRevert("Invalid merkle proof");
    IWorld(worldAddress).exploreRegionEnergy(vec3(0, 0, 0), 100, new bytes32[](0));
  }

  // Fluid level tests
  function testGetFluidLevelForTerrainWaterBlocks() public {
    // Setup a test chunk with water blocks
    Vec3 chunkCoord = vec3(0, 0, 0);
    setupWaterChunk(chunkCoord);

    // Test that water blocks in terrain (not initialized as entities) return fluid level 15
    Vec3 waterCoord = chunkCoord.mul(CHUNK_SIZE) + vec3(8, 10, 8);
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(waterCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water terrain block should have max fluid level");

    // Verify the entity hasn't been initialized yet
    EntityId entityId = EntityTypeLib.encodeBlock(waterCoord);
    assertFalse(entityId.exists(), "Water block should not be initialized as entity yet");
  }

  function testGetFluidLevelForNonWaterTerrainBlocks() public {
    // Setup a flat chunk
    Vec3 chunkCoord = vec3(0, 0, 0);
    setupFlatChunk(chunkCoord);

    // Test that non-water blocks return fluid level 0
    Vec3 grassCoord = chunkCoord.mul(CHUNK_SIZE) + vec3(8, 12, 8);
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(grassCoord);
    assertEq(fluidLevel, 0, "Non-water terrain block should have 0 fluid level");
  }

  function testGetFluidLevelForAllSpawnsWithFluidTypes() public {
    setupAirChunk(vec3(0, 0, 0));

    // Test all object types that spawn with fluid
    ObjectType[5] memory fluidObjects =
      [ObjectTypes.Water, ObjectTypes.Lava, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae];

    for (uint256 i = 0; i < fluidObjects.length; i++) {
      Vec3 coord = vec3(int32(int256(i)), 0, 0);
      setTerrainAtCoord(coord, fluidObjects[i]);

      uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(coord);
      assertEq(fluidLevel, MAX_FLUID_LEVEL, "Terrain should have max fluid level");
    }
  }

  function testFluidLevelAfterEntityInitialization() public {
    // Setup water chunk
    Vec3 chunkCoord = vec3(0, 0, 0);
    setupWaterChunk(chunkCoord);

    Vec3 waterCoord = chunkCoord.mul(CHUNK_SIZE) + vec3(8, 10, 8);

    // Initialize the entity by calling getOrCreateBlockAt
    (EntityId entityId, ObjectType objectType) = TestEntityUtils.getOrCreateBlockAt(waterCoord);

    assertEq(objectType, ObjectTypes.Water, "Should be water block");
    assertTrue(entityId.exists(), "Entity should now exist");

    // Check fluid level is still 15 after initialization
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(waterCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Water entity should maintain max fluid level");

    // Verify it's stored in the table
    uint8 storedLevel = EntityFluidLevel.get(entityId);
    assertEq(storedLevel, MAX_FLUID_LEVEL, "Stored fluid level should be max");
  }

  function testNonFluidBlocksDoNotGetFluidLevel() public {
    Vec3 chunkCoord = vec3(0, 0, 0);
    setupFlatChunk(chunkCoord);

    Vec3 dirtCoord = vec3(0, 0, 0);

    // Initialize a dirt block entity
    (EntityId entityId, ObjectType objectType) = TestEntityUtils.getOrCreateBlockAt(dirtCoord);

    assertEq(objectType, ObjectTypes.Dirt, "Should be dirt block");

    // Check fluid level is 0
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(dirtCoord);
    assertEq(fluidLevel, 0, "Dirt block should have 0 fluid level");

    // Verify no fluid level is stored in the table (defaults to 0)
    uint8 storedLevel = EntityFluidLevel.get(entityId);
    assertEq(storedLevel, 0, "No fluid level should be stored for dirt");
  }
}
