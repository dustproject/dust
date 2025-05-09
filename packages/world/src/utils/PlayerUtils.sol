// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";

import { Player } from "../codegen/tables/Player.sol";
import { PlayerBed } from "../codegen/tables/PlayerBed.sol";
import { ReversePlayer } from "../codegen/tables/ReversePlayer.sol";

import { EntityPosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";
import { checkWorldStatus } from "../Utils.sol";
import { updatePlayerEnergy } from "./EnergyUtils.sol";

import {
  getMovableEntityAt,
  getOrCreateEntityAt,
  getUniqueEntity,
  safeGetObjectTypeAt,
  setMovableEntityAt
} from "./EntityUtils.sol";
import { InventoryUtils } from "./InventoryUtils.sol";

import { FRAGMENT_SIZE, PLAYER_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { Vec3, vec3 } from "../Vec3.sol";

import { DeathNotification, notify } from "./NotifUtils.sol";

library PlayerUtils {
  function getOrCreatePlayer() internal returns (EntityId) {
    address playerAddress = WorldContextConsumerLib._msgSender();
    EntityId player = Player._get(playerAddress);
    if (!player.exists()) {
      player = getUniqueEntity();

      Player._set(playerAddress, player);
      ReversePlayer._set(player, playerAddress);

      // Set the player object type first
      EntityObjectType._set(player, ObjectTypes.Player);
    }

    return player;
  }

  function addPlayerToGrid(EntityId player, Vec3 playerCoord) internal {
    // Check if the spawn location is valid
    ObjectType terrainObjectType = safeGetObjectTypeAt(playerCoord);
    require(
      terrainObjectType.isPassThrough() && !getMovableEntityAt(playerCoord).exists(),
      "Cannot spawn on a non-passable block"
    );

    // Set the player at the base coordinate
    setMovableEntityAt(playerCoord, player);

    // Handle the player's body parts
    Vec3[] memory coords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      ObjectType relativeTerrainObjectType = safeGetObjectTypeAt(relativeCoord);
      require(
        relativeTerrainObjectType.isPassThrough() && !getMovableEntityAt(relativeCoord).exists(),
        "Cannot spawn on a non-passable block"
      );
      EntityId relativePlayer = getUniqueEntity();
      EntityObjectType._set(relativePlayer, ObjectTypes.Player);
      setMovableEntityAt(relativeCoord, relativePlayer);
      BaseEntity._set(relativePlayer, player);
    }
  }

  function removePlayerFromGrid(EntityId player, Vec3 playerCoord) internal {
    EntityPosition._deleteRecord(player);
    ReverseMovablePosition._deleteRecord(playerCoord);

    Vec3[] memory coords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      EntityId relativePlayer = getMovableEntityAt(relativeCoord);
      EntityPosition._deleteRecord(relativePlayer);
      ReverseMovablePosition._deleteRecord(relativeCoord);
      EntityObjectType._deleteRecord(relativePlayer);
      BaseEntity._deleteRecord(relativePlayer);
    }
  }

  function removePlayerFromBed(EntityId player, EntityId bed) internal {
    PlayerBed._deleteRecord(player);
    BedPlayer._deleteRecord(bed);
  }

  /// @dev Kills the player, it assumes the player is not sleeping
  // If the player was already killed, it will return early
  function killPlayer(EntityId player, Vec3 coord) internal {
    if (ReverseMovablePosition._get(coord) != player) {
      return;
    }
    (EntityId to,) = getOrCreateEntityAt(coord);
    InventoryUtils.transferAll(player, to);
    removePlayerFromGrid(player, coord);
    notify(player, DeathNotification({ deathCoord: coord }));
  }
}
