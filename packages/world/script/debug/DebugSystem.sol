// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import { Vec3, vec3 } from "../../src/Vec3.sol";

import { ReverseMovablePosition } from "../../src/utils/Vec3Storage.sol";

import { EntityId, EntityTypeLib } from "../../src/EntityId.sol";
import { ObjectType } from "../../src/ObjectType.sol";

import { ObjectTypes } from "../../src/ObjectType.sol";

import { MoveLib } from "../../src/systems/libraries/MoveLib.sol";
import { EntityUtils } from "../../src/utils/EntityUtils.sol";
import { InventoryUtils } from "../../src/utils/InventoryUtils.sol";
import { PlayerUtils } from "../../src/utils/PlayerUtils.sol";

// Only for debugging purposes, not deployed to production
contract DebugSystem is System {
  modifier onlyGuardian() {
    AccessControl.requireOwner(ROOT_NAMESPACE_ID, _msgSender());
    _;
  }

  function debugAddToInventory(EntityId owner, ObjectType objectType, uint16 numObjectsToAdd) public onlyGuardian {
    require(!objectType.isTool(), "To add a tool, you must use debugAddToolToInventory");
    InventoryUtils.addObject(owner, objectType, numObjectsToAdd);
  }

  function debugAddToolToInventory(EntityId owner, ObjectType toolObjectType) public onlyGuardian returns (EntityId) {
    EntityId tool = EntityUtils.createUniqueEntity(toolObjectType);
    InventoryUtils.addEntity(owner, tool);
    return tool;
  }

  function debugRemoveFromInventory(EntityId owner, ObjectType objectType, uint16 numObjectsToRemove)
    public
    onlyGuardian
  {
    InventoryUtils.removeObject(owner, objectType, numObjectsToRemove);
  }

  function debugRemoveToolFromInventory(EntityId owner, EntityId tool) public onlyGuardian {
    InventoryUtils.removeEntity(owner, tool);
  }

  function debugTeleportPlayer(address playerAddress, Vec3 finalCoord) public onlyGuardian {
    EntityId player = EntityTypeLib.encodePlayer(playerAddress);
    player.activate();

    Vec3[] memory playerCoords = ObjectTypes.Player.getRelativeCoords(player._getPosition());
    EntityId[] memory players = _getPlayerEntityIds(player, playerCoords);
    require(!MoveLib._gravityApplies(finalCoord), "Cannot teleport here as gravity applies");

    for (uint256 i = 0; i < playerCoords.length; i++) {
      ReverseMovablePosition._deleteRecord(playerCoords[i]);
    }

    Vec3[] memory newPlayerCoords = ObjectTypes.Player.getRelativeCoords(finalCoord);
    for (uint256 i = 0; i < newPlayerCoords.length; i++) {
      Vec3 newCoord = newPlayerCoords[i];

      ObjectType newObjectType = EntityUtils.safeGetObjectTypeAt(newCoord);
      require(newObjectType.isPassThrough(), "Cannot teleport to a non-passable block");
      require(!EntityUtils.getMovableEntityAt(newCoord)._exists(), "Cannot teleport where a player already exists");

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
