// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import {
  CannotTeleportHereGravityApplies,
  CannotTeleportToNonPassableBlock,
  CannotTeleportWherePlayerExists,
  DebugSystemOnlyInDevEnv,
  ToAddToolUseDebugAddToolToInventory
} from "../../Errors.sol";
import { Vec3, vec3 } from "../../types/Vec3.sol";

import { ReverseMovablePosition } from "../../utils/Vec3Storage.sol";

import { EntityId, EntityTypeLib } from "../../types/EntityId.sol";
import { ObjectType } from "../../types/ObjectType.sol";

import { ObjectTypes } from "../../types/ObjectType.sol";

import { MoveLib } from "../../systems/libraries/MoveLib.sol";
import { EntityUtils } from "../../utils/EntityUtils.sol";
import { InventoryUtils } from "../../utils/InventoryUtils.sol";
import { PlayerUtils } from "../../utils/PlayerUtils.sol";

// Only for debugging purposes, not deployed to production
contract DebugSystem is System {
  modifier onlyROOT() {
    AccessControl.requireOwner(ROOT_NAMESPACE_ID, _msgSender());
    _;
  }

  constructor() {
    if (block.chainid != 31337) revert DebugSystemOnlyInDevEnv(block.chainid);
  }

  function debugAddToInventory(EntityId owner, ObjectType objectType, uint16 numObjectsToAdd) public onlyROOT {
    if (objectType.isTool()) revert ToAddToolUseDebugAddToolToInventory(objectType);
    InventoryUtils.addObject(owner, objectType, numObjectsToAdd);
  }

  function debugAddToolToInventory(EntityId owner, ObjectType toolObjectType) public onlyROOT returns (EntityId) {
    EntityId tool = EntityUtils.createUniqueEntity(toolObjectType);
    InventoryUtils.addEntity(owner, tool);
    return tool;
  }

  function debugRemoveFromInventory(EntityId owner, ObjectType objectType, uint16 numObjectsToRemove) public onlyROOT {
    InventoryUtils.removeObject(owner, objectType, numObjectsToRemove);
  }

  function debugRemoveToolFromInventory(EntityId owner, EntityId tool) public onlyROOT {
    InventoryUtils.removeEntity(owner, tool);
  }

  function debugTeleportPlayer(address playerAddress, Vec3 finalCoord) public onlyROOT {
    EntityId player = EntityTypeLib.encodePlayer(playerAddress);
    player.activate();

    Vec3[] memory playerCoords = ObjectTypes.Player.getRelativeCoords(player._getPosition());
    EntityId[] memory players = _getPlayerEntityIds(player, playerCoords);
    if (MoveLib._gravityApplies(finalCoord)) revert CannotTeleportHereGravityApplies(finalCoord);

    for (uint256 i = 0; i < playerCoords.length; i++) {
      ReverseMovablePosition._deleteRecord(playerCoords[i]);
    }

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(finalCoord);
    for (uint256 i = 0; i < newPlayerCoords.length; i++) {
      Vec3 newCoord = newPlayerCoords[i];

      ObjectType newObjectType = EntityUtils.safeGetObjectTypeAt(newCoord);
      if (!newObjectType.isPassThrough()) revert CannotTeleportToNonPassableBlock(newObjectType);
      if (EntityUtils.getMovableEntityAt(newCoord)._exists()) {
        revert CannotTeleportWherePlayerExists(EntityUtils.getMovableEntityAt(newCoord));
      }

      EntityUtils.setMovableEntityAt(newCoord, players[i]);
    }
  }

  function _getPlayerEntityIds(EntityId basePlayer, Vec3[] memory playerCoords)
    private
    view
    returns (EntityId[] memory)
  {
    EntityId[] memory players = new EntityId[](playerCoords.length);
    players[0] = basePlayer;
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < playerCoords.length; i++) {
      players[i] = EntityUtils.getMovableEntityAt(playerCoords[i]);
    }
    return players;
  }
}
