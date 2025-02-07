// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@biomesaw/utils/src/Types.sol";

import { Player } from "../codegen/tables/Player.sol";
import { ReversePlayer } from "../codegen/tables/ReversePlayer.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { Position } from "../codegen/tables/Position.sol";
import { ReversePosition } from "../codegen/tables/ReversePosition.sol";
import { PlayerActivity } from "../codegen/tables/PlayerActivity.sol";
import { PlayerActionNotif, PlayerActionNotifData } from "../codegen/tables/PlayerActionNotif.sol";
import { ActionType } from "../codegen/common.sol";

import { IN_MAINTENANCE } from "../Constants.sol";
import { AirObjectID, PlayerObjectID } from "../ObjectTypeIds.sol";
import { getUniqueEntity, gravityApplies, inWorldBorder, inSpawnArea } from "../Utils.sol";
import { transferAllInventoryEntities } from "../utils/InventoryUtils.sol";

contract SpawnSystem is System {
  function spawnPlayer(VoxelCoord memory spawnCoord) public returns (bytes32) {
    require(!IN_MAINTENANCE, "Biomes is in maintenance mode. Try again later");
    require(inWorldBorder(spawnCoord), "Cannot spawn outside the world border");
    require(inSpawnArea(spawnCoord), "Cannot spawn outside the spawn area");

    address newPlayer = _msgSender();
    require(Player._get(newPlayer) == bytes32(0), "Player already spawned");

    bytes32 playerEntityId = getUniqueEntity();
    bytes32 existingEntityId = ReversePosition._get(spawnCoord.x, spawnCoord.y, spawnCoord.z);
    require(existingEntityId != bytes32(0), "Cannot spawn on an unrevealed block");
    require(ObjectType._get(existingEntityId) == AirObjectID, "Cannot spawn on a non-air block");

    // Transfer any dropped items
    transferAllInventoryEntities(existingEntityId, playerEntityId, PlayerObjectID);

    Position._deleteRecord(existingEntityId);

    // Create new entity
    Position._set(playerEntityId, spawnCoord.x, spawnCoord.y, spawnCoord.z);
    ReversePosition._set(spawnCoord.x, spawnCoord.y, spawnCoord.z, playerEntityId);

    // Set object type to player
    ObjectType._set(playerEntityId, PlayerObjectID);
    Player._set(newPlayer, playerEntityId);
    ReversePlayer._set(playerEntityId, newPlayer);

    // TODO: set initial mass and energy

    PlayerActivity._set(playerEntityId, block.timestamp);
    require(!gravityApplies(spawnCoord), "Cannot spawn player with gravity");

    PlayerActionNotif._set(
      playerEntityId,
      PlayerActionNotifData({
        actionType: ActionType.Spawn,
        entityId: playerEntityId,
        objectTypeId: PlayerObjectID,
        coordX: spawnCoord.x,
        coordY: spawnCoord.y,
        coordZ: spawnCoord.z,
        amount: 1
      })
    );

    return playerEntityId;
  }
}
