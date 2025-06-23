// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { CHUNK_SIZE } from "../../Constants.sol";

import { ChunkNotExploredYet, UnsupportedChunkEncodingVersion } from "../../Errors.sol";
import { ObjectType } from "../../types/ObjectType.sol";
import { ObjectTypes } from "../../types/ObjectType.sol";
import { Vec3, vec3 } from "../../types/Vec3.sol";
import { SSTORE2 } from "../../utils/SSTORE2.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

uint256 constant VERSION_PADDING = 1;
uint256 constant BIOME_PADDING = 1;
uint256 constant SURFACE_PADDING = 1;

library TerrainLib {
  using SSTORE2 for address;

  bytes1 constant _VERSION = 0x00;
  bytes32 constant _VEGETATION_KEY = keccak256(abi.encode("region.vegetation"));

  /// @notice Get the terrain block type of a voxel coordinate.
  /// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
  /// @dev Assumes to be called from a root system.
  function _getBlockType(Vec3 coord) public view returns (ObjectType) {
    return getBlockType(coord, address(this));
  }

  /// @notice Get the terrain block type of a voxel coordinate.
  /// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
  /// @dev Can be called from either a root or non-root system, but consumes slightly more gas.
  function getBlockType(Vec3 coord) internal view returns (ObjectType) {
    return getBlockType(coord, WorldContextConsumerLib._world());
  }

  /// @notice Get the terrain block type of a voxel coordinate.
  /// @dev Returns ObjectTypes.Null if the chunk is not explored yet.
  function getBlockType(Vec3 coord, address world) internal view returns (ObjectType) {
    Vec3 chunkCoord = coord.toChunkCoord();
    if (!_isChunkExplored(chunkCoord, world)) {
      return ObjectTypes.Null;
    }

    address chunkPointer = _getChunkPointer(chunkCoord, world);
    bytes1 version = chunkPointer.readBytes1(0);
    if (version != _VERSION) revert UnsupportedChunkEncodingVersion(uint16(uint8(version)), uint16(uint8(_VERSION)));

    uint256 index = _getBlockIndex(coord);
    bytes1 blockType = chunkPointer.readBytes1(index);

    return ObjectType.wrap(uint16(uint8(blockType)));
  }

  /// @notice Get the biome of a voxel coordinate.
  /// @dev Assumes to be called from a root system.
  function _getBiome(Vec3 coord) internal view returns (uint8) {
    return getBiome(coord, address(this));
  }

  /// @notice Get the biome of a voxel coordinate.
  /// @dev Can be called from either a root or non-root system, but consumes slightly more gas.
  function getBiome(Vec3 coord) internal view returns (uint8) {
    return getBiome(coord, WorldContextConsumerLib._world());
  }

  /// @notice Get the biome of a voxel coordinate.
  function getBiome(Vec3 coord, address world) internal view returns (uint8) {
    Vec3 chunkCoord = coord.toChunkCoord();
    if (!_isChunkExplored(chunkCoord, world)) revert ChunkNotExploredYet(chunkCoord);

    address chunkPointer = _getChunkPointer(chunkCoord, world);
    bytes1 version = chunkPointer.readBytes1(0);
    if (version != _VERSION) revert UnsupportedChunkEncodingVersion(uint16(uint8(version)), uint16(uint8(_VERSION)));

    bytes1 biome = chunkPointer.readBytes1(1);
    return uint8(biome);
  }

  /// @notice Returns true if the chunk is the highest non-air chunk in this X/Z column
  /// @dev Assumes to be called from a root system.
  function _isSurfaceChunk(Vec3 chunkCoord) internal view returns (bool) {
    return isSurfaceChunk(chunkCoord, address(this));
  }

  /// @notice Returns true if the chunk is the highest non-air chunk in this X/Z column
  /// @dev Can be called from either a root or non-root system, but consumes slightly more gas.
  function isSurfaceChunk(Vec3 chunkCoord) internal view returns (bool) {
    return isSurfaceChunk(chunkCoord, WorldContextConsumerLib._world());
  }

  /// @notice Returns true if the chunk is the highest non-air chunk in this X/Z column
  function isSurfaceChunk(Vec3 chunkCoord, address world) internal view returns (bool) {
    if (!_isChunkExplored(chunkCoord, world)) revert ChunkNotExploredYet(chunkCoord);

    address chunkPointer = _getChunkPointer(chunkCoord, world);
    bytes1 version = chunkPointer.readBytes1(0);
    if (version != _VERSION) revert UnsupportedChunkEncodingVersion(uint16(uint8(version)), uint16(uint8(_VERSION)));

    bytes1 isSurface = chunkPointer.readBytes1(2);
    return uint8(isSurface) == 1;
  }

  /// @dev Get the relative coordinate of a voxel coordinate within a chunk
  function _getRelativeCoord(Vec3 coord) internal pure returns (Vec3) {
    return coord.mod(CHUNK_SIZE);
  }

  /// @dev Get the index of a voxel coordinate within the encoded chunk
  function _getBlockIndex(Vec3 coord) internal pure returns (uint256) {
    Vec3 relativeCoord = _getRelativeCoord(coord);
    return VERSION_PADDING + BIOME_PADDING + SURFACE_PADDING
      + uint256(
        int256(relativeCoord.x()) * CHUNK_SIZE ** 2 + int256(relativeCoord.y()) * CHUNK_SIZE + int256(relativeCoord.z())
      );
  }

  /// @dev Get the salt for a chunk coordinate
  function _getChunkSalt(Vec3 coord) internal pure returns (bytes32) {
    // TODO: check if this is correct, we seem to be getting revert for collisions
    return bytes32(uint256(Vec3.unwrap(coord)));
  }

  /// @dev Get the address of the chunk pointer based on its deterministic CREATE3 address
  function _getChunkPointer(Vec3 coord, address world) internal pure returns (address) {
    return SSTORE2.predictDeterministicAddress(_getChunkSalt(coord), world);
  }

  /// @dev Returns true if the chunk pointer contains data, else false
  function _isChunkExplored(Vec3 coord, address world) internal view returns (bool isDefined) {
    address chunkPointer = _getChunkPointer(coord, world);
    assembly {
      isDefined := gt(extcodesize(chunkPointer), 0)
    }
  }

  /// @dev Get the leaf hash of a chunk
  function _getChunkLeafHash(Vec3 chunkCoord, bytes memory chunk) internal pure returns (bytes32) {
    return keccak256(bytes.concat(keccak256(abi.encode(chunkCoord, chunk))));
  }

  /// @dev Get the vegetation leaf hash
  function _getVegetationLeafHash(uint32 vegetationCount) internal pure returns (bytes32) {
    return keccak256(bytes.concat(keccak256(abi.encode(_VEGETATION_KEY, vegetationCount))));
  }
}
