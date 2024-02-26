// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";

import { Player } from "../codegen/tables/Player.sol";
import { PlayerMetadata } from "../codegen/tables/PlayerMetadata.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Position } from "../codegen/tables/Position.sol";
import { ReversePosition } from "../codegen/tables/ReversePosition.sol";
import { Stamina } from "../codegen/tables/Stamina.sol";
import { Inventory, InventoryTableId } from "../codegen/tables/Inventory.sol";
import { InventoryCount } from "../codegen/tables/InventoryCount.sol";

import { VoxelCoord } from "../Types.sol";
import { AirObjectID, PlayerObjectID, MAX_PLAYER_BUILD_MINE_HALF_WIDTH } from "../Constants.sol";
import { positionDataToVoxelCoord, inSurroundingCube, addToInventoryCount, removeFromInventoryCount } from "../Utils.sol";

contract MoveSystem is System {
  function move(VoxelCoord[] memory newCoords) public {
    // TODO increase stamina + health

    bytes32 playerEntityId = Player.get(_msgSender());
    require(playerEntityId != bytes32(0), "MoveSystem: player does not exist");

    VoxelCoord memory playerCoord = positionDataToVoxelCoord(Position.get(playerEntityId));
    VoxelCoord memory oldCoord = playerCoord;
    for (uint256 i = 0; i < newCoords.length; i++) {
      VoxelCoord memory newCoord = newCoords[i];
      move(playerEntityId, oldCoord, newCoord);
      oldCoord = newCoord;
    }
  }

  function move(bytes32 playerEntityId, VoxelCoord memory oldCoord, VoxelCoord memory newCoord) internal {
    require(inSurroundingCube(oldCoord, 1, newCoord), "MoveSystem: new coord is not in surrounding cube of old coord");

    bytes32 oldEntityId = ReversePosition.get(oldCoord.x, oldCoord.y, oldCoord.z);
    require(oldEntityId != bytes32(0), "MoveSystem: no entity at old coord");

    bytes32 newEntityId = ReversePosition.get(newCoord.x, newCoord.y, newCoord.z);
    if (newEntityId == bytes32(0)) {
      // Check terrain block type
      (bool success, bytes memory occurrence) = _world().staticcall(
        bytes.concat(ObjectTypeMetadata.getOccurence(AirObjectID), abi.encode(newCoord))
      );
      require(
        success && occurrence.length > 0 && abi.decode(occurrence, (bytes32)) == AirObjectID,
        "MoveSystem: cannot move to non-air block"
      );

      // Create new entity
      newEntityId = getUniqueEntity();
      ObjectType.set(newEntityId, AirObjectID);
    } else {
      require(ObjectType.get(newEntityId) == AirObjectID, "MoveSystem: cannot move to non-air block");

      // Transfer any dropped items
      (bytes memory staticData, PackedCounter encodedLengths, bytes memory dynamicData) = Inventory.encode(newEntityId);
      bytes32[] memory droppedInventoryEntityIds = getKeysWithValue(
        InventoryTableId,
        staticData,
        encodedLengths,
        dynamicData
      );
      for (uint256 i = 0; i < droppedInventoryEntityIds.length; i++) {
        bytes32 droppedObjectTypeId = ObjectType.get(droppedInventoryEntityIds[i]);
        addToInventoryCount(playerEntityId, PlayerObjectID, droppedObjectTypeId, 1);
        removeFromInventoryCount(newEntityId, droppedObjectTypeId, 1);
        Inventory.set(droppedInventoryEntityIds[i], playerEntityId);
      }
    }

    // Swap entity ids
    ReversePosition.set(oldCoord.x, oldCoord.y, oldCoord.z, newEntityId);
    Position.set(newEntityId, oldCoord.x, oldCoord.y, oldCoord.z);

    Position.set(oldEntityId, newCoord.x, newCoord.y, newCoord.z);
    ReversePosition.set(newCoord.x, newCoord.y, newCoord.z, oldEntityId);

    uint32 numMovesInBlock = PlayerMetadata.getNumMovesInBlock(playerEntityId);
    if (PlayerMetadata.getLastMoveBlock(playerEntityId) != block.number) {
      numMovesInBlock = 1;
      PlayerMetadata.set(playerEntityId, block.number, numMovesInBlock);
    } else {
      numMovesInBlock += 1;
      PlayerMetadata.setNumMovesInBlock(playerEntityId, numMovesInBlock);
    }

    // Inventory mass
    uint32 inventoryTotalMass = 0;
    {
      (bytes memory staticData, PackedCounter encodedLengths, bytes memory dynamicData) = Inventory.encode(
        playerEntityId
      );
      bytes32[] memory inventoryEntityIds = getKeysWithValue(InventoryTableId, staticData, encodedLengths, dynamicData);
      for (uint256 i = 0; i < inventoryEntityIds.length; i++) {
        bytes32 inventoryObjectTypeId = ObjectType.get(inventoryEntityIds[i]);
        inventoryTotalMass += ObjectTypeMetadata.getMass(inventoryObjectTypeId);
      }
    }

    uint32 staminaRequired = ObjectTypeMetadata.getMass(PlayerObjectID);
    staminaRequired += inventoryTotalMass / 50;
    staminaRequired = staminaRequired * (numMovesInBlock ** 2);

    uint32 currentStamina = Stamina.getStamina(playerEntityId);
    require(currentStamina >= staminaRequired, "MoveSystem: not enough stamina");
    Stamina.setStamina(playerEntityId, currentStamina - staminaRequired);

    // TODO apply gravity
  }
}
