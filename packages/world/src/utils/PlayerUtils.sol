// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Mass } from "../codegen/tables/Mass.sol";

import { Death, DeathData } from "../codegen/tables/Death.sol";
import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { EntityPosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { ObjectType } from "../types/ObjectType.sol";

import { checkWorldStatus } from "../Utils.sol";
import { ObjectTypes } from "../types/ObjectType.sol";

import { EntityUtils } from "./EntityUtils.sol";
import { InventoryUtils } from "./InventoryUtils.sol";

import { FRAGMENT_SIZE, PLAYER_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";
import { EntityIdLib } from "./EntityIdLib.sol";

import { DeathNotification, notify } from "./NotifUtils.sol";

library PlayerUtils {
  function addPlayerToGrid(EntityId player, Vec3 playerCoord) internal {
    // Check if the spawn location is valid
    ObjectType terrainObjectType = EntityUtils.safeGetObjectTypeAt(playerCoord);
    require(
      terrainObjectType.isPassThrough() && !EntityUtils.getMovableEntityAt(playerCoord)._exists(),
      "Cannot spawn on a non-passable block"
    );

    // Set the player at the base coordinate
    EntityUtils.setMovableEntityAt(playerCoord, player);

    // Handle the player's body parts
    Vec3[] memory coords = ObjectTypes.Player.getRelativeCoords(playerCoord);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      ObjectType relativeTerrainObjectType = EntityUtils.safeGetObjectTypeAt(relativeCoord);
      require(
        relativeTerrainObjectType.isPassThrough() && !EntityUtils.getMovableEntityAt(relativeCoord)._exists(),
        "Cannot spawn on a non-passable block"
      );
      EntityId relativePlayer = EntityUtils.createUniqueEntity(ObjectTypes.Player);
      EntityUtils.setMovableEntityAt(relativeCoord, relativePlayer);
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
      EntityId relativePlayer = EntityUtils.getMovableEntityAt(relativeCoord);
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
    // We use getOrCreateBlockAt because when moving the block entity might not be set
    (EntityId to,) = EntityUtils.getOrCreateBlockAt(coord);
    InventoryUtils.transferAll(player, to);
    removePlayerFromGrid(player, coord);
    Death.set(player, DeathData({ lastDiedAt: uint128(block.timestamp), deaths: Death.getDeaths(player) + 1 }));
    notify(player, DeathNotification({ deathCoord: coord }));
  }
}
