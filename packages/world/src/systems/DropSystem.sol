// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ReversePosition } from "../codegen/tables/ReversePosition.sol";
import { PlayerActionNotif, PlayerActionNotifData } from "../codegen/tables/PlayerActionNotif.sol";
import { ActionType } from "../codegen/common.sol";

import { AirObjectID } from "../ObjectTypeIds.sol";
import { inWorldBorder, getUniqueEntity } from "../Utils.sol";
import { transferInventoryNonTool, transferInventoryTool } from "../utils/InventoryUtils.sol";
import { requireValidPlayer, requireInPlayerInfluence } from "../utils/PlayerUtils.sol";
import { EntityId } from "../EntityId.sol";

// TODO: combine the tool and non-tool drop functions
contract DropSystem is System {
  function dropCommon(VoxelCoord memory coord) internal returns (EntityId, EntityId) {
    require(inWorldBorder(coord), "Cannot drop outside the world border");
    (EntityId playerEntityId, VoxelCoord memory playerCoord) = requireValidPlayer(_msgSender());
    requireInPlayerInfluence(playerCoord, coord);

    EntityId entityId = ReversePosition._get(coord.x, coord.y, coord.z);
    require(entityId.exists(), "Cannot drop on an unrevealed block");
    require(ObjectType._get(entityId) == AirObjectID, "Cannot drop on non-air block");

    return (playerEntityId, entityId);
  }

  function drop(uint16 dropObjectTypeId, uint16 numToDrop, VoxelCoord memory coord) public {
    (EntityId playerEntityId, EntityId entityId) = dropCommon(coord);
    transferInventoryNonTool(playerEntityId, entityId, AirObjectID, dropObjectTypeId, numToDrop);

    PlayerActionNotif._set(
      playerEntityId,
      PlayerActionNotifData({
        actionType: ActionType.Drop,
        entityId: entityId,
        objectTypeId: dropObjectTypeId,
        coordX: coord.x,
        coordY: coord.y,
        coordZ: coord.z,
        amount: numToDrop
      })
    );
  }

  function dropTool(EntityId toolEntityId, VoxelCoord memory coord) public {
    (EntityId playerEntityId, EntityId entityId) = dropCommon(coord);
    uint16 toolObjectTypeId = transferInventoryTool(playerEntityId, entityId, AirObjectID, toolEntityId);

    PlayerActionNotif._set(
      playerEntityId,
      PlayerActionNotifData({
        actionType: ActionType.Drop,
        entityId: entityId,
        objectTypeId: toolObjectTypeId,
        coordX: coord.x,
        coordY: coord.y,
        coordZ: coord.z,
        amount: 1
      })
    );
  }

  function dropTools(EntityId[] memory toolEntityIds, VoxelCoord memory coord) public {
    require(toolEntityIds.length > 0, "Must drop at least one tool");

    (EntityId playerEntityId, EntityId entityId) = dropCommon(coord);

    uint16 toolObjectTypeId;
    for (uint i = 0; i < toolEntityIds.length; i++) {
      uint16 currentToolObjectTypeId = transferInventoryTool(playerEntityId, entityId, AirObjectID, toolEntityIds[i]);
      if (i > 0) {
        require(toolObjectTypeId == currentToolObjectTypeId, "All tools must be of the same type");
      } else {
        toolObjectTypeId = currentToolObjectTypeId;
      }
    }

    PlayerActionNotif._set(
      playerEntityId,
      PlayerActionNotifData({
        actionType: ActionType.Drop,
        entityId: entityId,
        objectTypeId: toolObjectTypeId,
        coordX: coord.x,
        coordY: coord.y,
        coordZ: coord.z,
        amount: toolEntityIds.length
      })
    );
  }
}
