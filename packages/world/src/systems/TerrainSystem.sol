// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { CHUNK_SIZE, INITIAL_ENERGY_PER_VEGETATION, INITIAL_LOCAL_ENERGY_BUFFER, REGION_SIZE } from "../Constants.sol";

import {
  ChunkAlreadyExplored,
  EnergyPoolChunksAre2DOnly,
  InvalidMerkleProof,
  RegionEnergyAlreadyExplored,
  RegionNotSeeded
} from "../Errors.sol";
import { RegionMerkleRoot } from "../codegen/tables/RegionMerkleRoot.sol";
import { SurfaceChunkCount } from "../codegen/tables/SurfaceChunkCount.sol";
import { Vec3 } from "../types/Vec3.sol";
import { SSTORE2 } from "../utils/SSTORE2.sol";
import { ExploredChunk, InitialEnergyPool, LocalEnergyPool, SurfaceChunkByIndex } from "../utils/Vec3Storage.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import { TerrainLib } from "./libraries/TerrainLib.sol";

contract TerrainSystem is System {
  function exploreChunk(Vec3 chunkCoord, bytes memory chunkData, bytes32[] memory merkleProof) public {
    if (ExploredChunk._get(chunkCoord) != address(0)) revert ChunkAlreadyExplored(chunkCoord);

    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    bytes32 regionRoot = RegionMerkleRoot._get(regionCoord.x(), regionCoord.z());
    if (regionRoot == bytes32(0)) revert RegionNotSeeded(regionCoord);

    bytes32 leaf = TerrainLib._getChunkLeafHash(chunkCoord, chunkData);
    if (!MerkleProof.verify(merkleProof, regionRoot, leaf)) revert InvalidMerkleProof();

    SSTORE2.writeDeterministic(chunkData, TerrainLib._getChunkSalt(chunkCoord));

    ExploredChunk._set(chunkCoord, _msgSender());
    if (TerrainLib._isSurfaceChunk(chunkCoord)) {
      uint256 surfaceChunkCount = SurfaceChunkCount._get();
      SurfaceChunkByIndex._set(surfaceChunkCount, chunkCoord);
      SurfaceChunkCount._set(surfaceChunkCount + 1);
    }
  }

  function exploreRegionEnergy(Vec3 regionCoord, uint32 vegetationCount, bytes32[] memory merkleProof) public {
    if (regionCoord.y() != 0) revert EnergyPoolChunksAre2DOnly(int16(regionCoord.y()));
    if (InitialEnergyPool._get(regionCoord) != 0) revert RegionEnergyAlreadyExplored(regionCoord);

    bytes32 regionRoot = RegionMerkleRoot._get(regionCoord.x(), regionCoord.z());
    if (regionRoot == bytes32(0)) revert RegionNotSeeded(regionCoord);

    bytes32 leaf = TerrainLib._getVegetationLeafHash(vegetationCount);
    if (!MerkleProof.verify(merkleProof, regionRoot, leaf)) revert InvalidMerkleProof();

    // Add +1 to be able to distinguish between unexplored and empty region
    InitialEnergyPool._set(regionCoord, vegetationCount * INITIAL_ENERGY_PER_VEGETATION + 1);

    LocalEnergyPool._set(regionCoord, INITIAL_LOCAL_ENERGY_BUFFER);
  }
}
