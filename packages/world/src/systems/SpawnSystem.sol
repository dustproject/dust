// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { LibPRNG } from "solady/utils/LibPRNG.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { Mass } from "../codegen/tables/Mass.sol";

import { SurfaceChunkCount } from "../codegen/tables/SurfaceChunkCount.sol";

import { ExploredChunk, ReverseMovablePosition, SurfaceChunkByIndex } from "../utils/Vec3Storage.sol";

import {
  CHUNK_SIZE,
  MAX_PLAYER_ENERGY,
  MAX_RESPAWN_HALF_WIDTH,
  PLAYER_ENERGY_DRAIN_RATE,
  SPAWN_BLOCK_RANGE
} from "../Constants.sol";
import { ObjectType } from "../ObjectType.sol";

import { checkWorldStatus } from "../Utils.sol";
import { ObjectTypes } from "../codegen/ObjectTypes.sol";

import { Vec3, vec3 } from "../Vec3.sol";
import { removeEnergyFromLocalPool, updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { SpawnNotification, notify } from "../utils/NotifUtils.sol";

import { MoveLib } from "../utils/MoveLib.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { TerrainLib } from "../utils/TerrainLib.sol";

import { EntityId } from "../EntityId.sol";
import { ISpawnHook } from "../ProgramInterfaces.sol";

contract SpawnSystem is System {
  using LibPRNG for LibPRNG.PRNG;

  function getAllRandomSpawnCoords(address sender)
    public
    view
    returns (Vec3[] memory spawnCoords, uint256[] memory blockNumbers)
  {
    spawnCoords = new Vec3[](SPAWN_BLOCK_RANGE);
    blockNumbers = new uint256[](SPAWN_BLOCK_RANGE);
    for (uint256 i = 0; i < SPAWN_BLOCK_RANGE; i++) {
      uint256 blockNumber = block.number - (i + 1);
      spawnCoords[i] = getRandomSpawnCoord(blockNumber, sender);
      blockNumbers[i] = blockNumber;
    }
    return (spawnCoords, blockNumbers);
  }

  function getRandomSpawnCoord(uint256 blockNumber, address sender) public view returns (Vec3 spawnCoord) {
    uint256 exploredChunkCount = SurfaceChunkCount._get();
    require(exploredChunkCount > 0, "No surface chunks available");

    // Randomness used for the chunk index and relative coordinates
    LibPRNG.PRNG memory prng;
    prng.seed(uint256(keccak256(abi.encodePacked(blockhash(blockNumber), sender))));
    uint256 chunkIndex = prng.uniform(exploredChunkCount);
    Vec3 chunk = SurfaceChunkByIndex._get(chunkIndex);

    // Convert chunk coordinates to world coordinates and add random offset
    Vec3 coord = chunk.mul(CHUNK_SIZE);

    // Convert CHUNK_SIZE from int32 to uint256
    uint256 chunkSize = uint256(int256(CHUNK_SIZE));

    // Get random position within the chunk (0 to CHUNK_SIZE-1)
    int32 relativeX = int32(int256(prng.next() % chunkSize));
    int32 relativeZ = int32(int256(prng.next() % chunkSize));

    return coord + vec3(relativeX, 0, relativeZ);
  }

  function isValidSpawn(Vec3 spawnCoord) public view returns (bool) {
    Vec3 belowCoord = spawnCoord - vec3(0, 1, 0);
    Vec3 aboveCoord = spawnCoord + vec3(0, 1, 0);

    ObjectType spawnType = EntityUtils.getObjectTypeAt(spawnCoord);
    if (spawnType.isNull() || !spawnType.isPassThrough() || EntityUtils.getMovableEntityAt(spawnCoord)._exists()) {
      return false;
    }

    ObjectType aboveType = EntityUtils.getObjectTypeAt(aboveCoord);
    if (aboveType.isNull() || !aboveType.isPassThrough() || EntityUtils.getMovableEntityAt(aboveCoord)._exists()) {
      return false;
    }

    ObjectType belowType = EntityUtils.getObjectTypeAt(belowCoord);
    if (
      belowType.isNull()
        || (
          belowType != ObjectTypes.Water && belowType.isPassThrough()
            && !EntityUtils.getMovableEntityAt(belowCoord)._exists()
        )
    ) {
      return false;
    }

    return true;
  }

  function getValidSpawnY(Vec3 spawnCoordCandidate) public view returns (Vec3 spawnCoord) {
    for (int32 i = CHUNK_SIZE - 1; i >= 0; i--) {
      spawnCoord = spawnCoordCandidate + vec3(0, i, 0);
      if (isValidSpawn(spawnCoord)) {
        return spawnCoord;
      }
    }

    revert("No valid spawn Y found in chunk");
  }

  function randomSpawn(uint256 blockNumber, int32 y) public returns (EntityId) {
    checkWorldStatus();
    require(
      blockNumber < block.number && blockNumber >= block.number - SPAWN_BLOCK_RANGE, "Can only choose past 10 blocks"
    );

    Vec3 spawnCoord = getRandomSpawnCoord(blockNumber, _msgSender());

    require(spawnCoord.y() <= y && y < spawnCoord.y() + CHUNK_SIZE, "y coordinate outside of spawn chunk");

    // Use the y coordinate given by the player
    spawnCoord = vec3(spawnCoord.x(), y, spawnCoord.z());

    (EntityId forceField,) = ForceFieldUtils.getForceField(spawnCoord);
    require(!forceField._exists(), "Cannot spawn in force field");

    // 30% of max player energy
    uint128 spawnEnergy = MAX_PLAYER_ENERGY * 3 / 10;

    // Extract energy from local pool (half of max player energy)
    removeEnergyFromLocalPool(spawnCoord, spawnEnergy);

    return _spawnPlayer(spawnCoord, spawnEnergy);
  }

  function spawn(EntityId spawnTile, Vec3 spawnCoord, uint128 spawnEnergy, bytes memory extraData)
    public
    returns (EntityId)
  {
    checkWorldStatus();
    require(spawnEnergy <= MAX_PLAYER_ENERGY * 3 / 10, "Cannot spawn with more than 30% of max player energy");
    ObjectType objectType = spawnTile._getObjectType();
    require(objectType == ObjectTypes.SpawnTile, "Not a spawn tile");

    Vec3 spawnTileCoord = spawnTile._getPosition();
    require(spawnTileCoord.inSurroundingCube(spawnCoord, MAX_RESPAWN_HALF_WIDTH), "Spawn tile is too far away");

    (EntityId forceField,) = ForceFieldUtils.getForceField(spawnTileCoord);
    require(forceField._exists(), "Spawn tile is not inside a forcefield");
    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    require(machineData.energy >= spawnEnergy, "Not enough energy in spawn tile forcefield");
    Energy._setEnergy(forceField, machineData.energy - spawnEnergy);

    EntityId player = _spawnPlayer(spawnCoord, spawnEnergy);

    bytes memory onSpawn = abi.encodeCall(ISpawnHook.onSpawn, (player, spawnTile, spawnEnergy, extraData));
    spawnTile._getProgram().callOrRevert(onSpawn);

    return player;
  }

  function _spawnPlayer(Vec3 spawnCoord, uint128 spawnEnergy) internal returns (EntityId) {
    require(!MoveLib._gravityApplies(spawnCoord), "Cannot spawn player here as gravity applies");

    EntityId player = EntityUtils.getOrCreatePlayer();
    SpawnLib._requirePlayerDead(player);

    // Position the player at the given coordinates
    PlayerUtils.addPlayerToGrid(player, spawnCoord);

    Energy._set(
      player,
      EnergyData({ energy: spawnEnergy, lastUpdatedTime: uint128(block.timestamp), drainRate: PLAYER_ENERGY_DRAIN_RATE })
    );

    notify(player, SpawnNotification({ spawnCoord: spawnCoord }));

    return player;
  }
}

library SpawnLib {
  function _requirePlayerDead(EntityId player) public {
    require(updatePlayerEnergy(player).energy == 0, "Player already spawned");
  }
}
