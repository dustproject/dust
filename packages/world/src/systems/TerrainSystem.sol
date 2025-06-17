// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { CHUNK_SIZE, INITIAL_ENERGY_PER_VEGETATION, INITIAL_LOCAL_ENERGY_BUFFER, REGION_SIZE } from "../Constants.sol";

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
    require(ExploredChunk._get(chunkCoord) == address(0), "Chunk already explored");

    Vec3 regionCoord = chunkCoord.floorDiv(REGION_SIZE / CHUNK_SIZE);
    bytes32 regionRoot = RegionMerkleRoot._get(regionCoord.x(), regionCoord.z());
    require(regionRoot != bytes32(0), "Region not seeded");

    bytes32 leaf = TerrainLib._getChunkLeafHash(chunkCoord, chunkData);
    require(MerkleProof.verify(merkleProof, regionRoot, leaf), "Invalid merkle proof");

    SSTORE2.writeDeterministic(chunkData, TerrainLib._getChunkSalt(chunkCoord));

    ExploredChunk._set(chunkCoord, _msgSender());
    if (TerrainLib._isSurfaceChunk(chunkCoord)) {
      uint256 surfaceChunkCount = SurfaceChunkCount._get();
      SurfaceChunkByIndex._set(surfaceChunkCount, chunkCoord);
      SurfaceChunkCount._set(surfaceChunkCount + 1);
    }
  }

  function exploreRegionEnergy(Vec3 regionCoord, uint32 vegetationCount, bytes32[] memory merkleProof) public {
    require(regionCoord.y() == 0, "Energy pool chunks are 2D only");
    require(InitialEnergyPool._get(regionCoord) == 0, "Region energy already explored");

    bytes32 regionRoot = RegionMerkleRoot._get(regionCoord.x(), regionCoord.z());
    require(regionRoot != bytes32(0), "Region not seeded");

    bytes32 leaf = TerrainLib._getVegetationLeafHash(vegetationCount);
    require(MerkleProof.verify(merkleProof, regionRoot, leaf), "Invalid merkle proof");

    // Add +1 to be able to distinguish between unexplored and empty region
    InitialEnergyPool._set(regionCoord, vegetationCount * INITIAL_ENERGY_PER_VEGETATION + 1);

    LocalEnergyPool._set(regionCoord, INITIAL_LOCAL_ENERGY_BUFFER);
  }
}
