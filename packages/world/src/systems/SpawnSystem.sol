// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { LibPRNG } from "solady/utils/LibPRNG.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { SurfaceChunkCount } from "../codegen/tables/SurfaceChunkCount.sol";

import { SurfaceChunkByIndex } from "../utils/Vec3Storage.sol";

import {
  CHUNK_SIZE,
  MAX_PLAYER_ENERGY,
  MAX_RESPAWN_HALF_WIDTH,
  PLAYER_ENERGY_DRAIN_RATE,
  SPAWN_TIME_RANGE
} from "../Constants.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { ProgramId } from "../types/ProgramId.sol";

import { ObjectTypes } from "../types/ObjectType.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";
import { removeEnergyFromLocalPool, updateMachineEnergy, updatePlayerEnergy } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { SpawnNotification, notify } from "../utils/NotifUtils.sol";

import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

import { EntityId } from "../types/EntityId.sol";
import { DrandData } from "../utils/DrandUtils.sol";

contract SpawnSystem is System {
  using LibPRNG for LibPRNG.PRNG;

  function getRandomSpawnCoord(uint256 randomness, address sender) public view returns (Vec3 spawnCoord) {
    Vec3 spawnChunk = getRandomSpawnChunk(randomness, sender);
    spawnCoord = spawnChunk.mul(CHUNK_SIZE);

    Vec3 backupSpawnCoord = vec3(0, 0, 0);
    bool backupSpawnCoordFound = false;

    // Loop through the chunk and find a valid spawn coord
    for (int32 x = 0; x < CHUNK_SIZE; x++) {
      // Start from the top of the chunk and work down
      for (int32 y = CHUNK_SIZE - 1; y >= 0; y--) {
        for (int32 z = 0; z < CHUNK_SIZE; z++) {
          Vec3 spawnCoordCandidate = spawnCoord + vec3(x, y, z);
          if (!isValidSpawn(spawnCoordCandidate)) continue;

          Vec3 belowCoord = spawnCoordCandidate - vec3(0, 1, 0);
          if (EntityUtils.getObjectTypeAt(belowCoord).isPreferredSpawn()) {
            return spawnCoordCandidate;
          } else if (!backupSpawnCoordFound) {
            backupSpawnCoord = spawnCoordCandidate;
            backupSpawnCoordFound = true;
          }
        }
      }
    }

    if (backupSpawnCoordFound) {
      return backupSpawnCoord;
    }

    revert("No valid spawn coord found in chunk");
  }

  function getRandomSpawnChunk(uint256 randomness, address sender) public view returns (Vec3 chunk) {
    uint256 exploredChunkCount = SurfaceChunkCount._get();
    require(exploredChunkCount > 0, "No surface chunks available");

    // Randomness used for the chunk index and relative coordinates
    LibPRNG.PRNG memory prng;
    prng.seed(uint256(keccak256(abi.encodePacked(randomness, sender))));
    uint256 chunkIndex = prng.uniform(exploredChunkCount);

    return SurfaceChunkByIndex._get(chunkIndex);
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
          belowType.isPassThrough() && !EntityUtils.getMovableEntityAt(belowCoord)._exists()
            && EntityUtils.getFluidLevelAt(belowCoord) == 0
        )
    ) {
      return false;
    }

    return true;
  }

  function randomSpawn(DrandData calldata drand, Vec3 spawnCoord) public returns (EntityId) {
    checkWorldStatus();
    drand.verifyWithinTimeRange(SPAWN_TIME_RANGE);

    spawnCoord = getRandomSpawnCoord(drand.getRandomness(), _msgSender());

    (EntityId forceField,) = ForceFieldUtils.getForceField(spawnCoord);
    require(!forceField._exists(), "Cannot spawn in force field");

    // 30% of max player energy
    uint128 spawnEnergy = (MAX_PLAYER_ENERGY * 3) / 10;

    // Extract energy from local pool (half of max player energy)
    removeEnergyFromLocalPool(spawnCoord, spawnEnergy);

    return _spawnPlayer(spawnCoord, spawnEnergy);
  }

  /// @notice deprecated
  function randomSpawn(uint256 blockNumber, Vec3 spawnCoord) public returns (EntityId) {
    revert("Deprecated, use randomSpawn with drand signature");
  }

  function spawn(EntityId spawnTile, Vec3 spawnCoord, uint128 spawnEnergy, bytes memory extraData)
    public
    returns (EntityId)
  {
    checkWorldStatus();
    require(spawnEnergy <= (MAX_PLAYER_ENERGY * 3) / 10, "Cannot spawn with more than 30% of max player energy");
    ObjectType objectType = spawnTile._getObjectType();
    require(objectType == ObjectTypes.SpawnTile, "Not a spawn tile");

    Vec3 spawnTileCoord = spawnTile._getPosition();
    require(spawnTileCoord.inSurroundingCube(spawnCoord, MAX_RESPAWN_HALF_WIDTH), "Spawn tile is too far away");

    ProgramId program = spawnTile._getProgram();

    (EntityId forceField,) = ForceFieldUtils.getForceField(spawnTileCoord);
    require(forceField._exists(), "Spawn tile is not inside a forcefield");
    EnergyData memory machineData = updateMachineEnergy(forceField);
    require(machineData.energy >= spawnEnergy, "Not enough energy in spawn tile forcefield");
    Energy._setEnergy(forceField, machineData.energy - spawnEnergy);

    EntityId player = _spawnPlayer(spawnCoord, spawnEnergy);

    program.hook({ caller: player, target: spawnTile, revertOnFailure: true, extraData: extraData }).onSpawn(
      spawnEnergy, spawnCoord
    );

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
