// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@biomesaw/utils/src/Types.sol";
import { inSurroundingCube } from "@biomesaw/utils/src/VoxelCoordUtils.sol";
import { callInternalSystem } from "@biomesaw/utils/src/CallUtils.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { Equipped } from "../codegen/tables/Equipped.sol";
import { Position } from "../codegen/tables/Position.sol";
import { ReversePosition } from "../codegen/tables/ReversePosition.sol";
import { Stamina } from "../codegen/tables/Stamina.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Chip, ChipData } from "../codegen/tables/Chip.sol";

import { MAX_PLAYER_STAMINA, MAX_PLAYER_BUILD_MINE_HALF_WIDTH, PLAYER_HAND_DAMAGE } from "../Constants.sol";
import { AirObjectID, WaterObjectID, PlayerObjectID } from "../ObjectTypeIds.sol";
import { callGravity, inWorldBorder, inSpawnArea, getTerrainObjectTypeId, getUniqueEntity } from "../Utils.sol";
import { addToInventoryCount, useEquipped } from "../utils/InventoryUtils.sol";
import { requireValidPlayer } from "../utils/PlayerUtils.sol";

import { IForceFieldSystem } from "../codegen/world/IForceFieldSystem.sol";

contract MineSystem is System {
  function mine(VoxelCoord memory coord, bytes memory extraData) public payable {
    require(inWorldBorder(coord), "MineSystem: cannot mine outside world border");
    require(!inSpawnArea(coord), "MineSystem: cannot mine at spawn area");

    (bytes32 playerEntityId, VoxelCoord memory playerCoord) = requireValidPlayer(_msgSender());
    require(inSurroundingCube(playerCoord, MAX_PLAYER_BUILD_MINE_HALF_WIDTH, coord), "Player is too far");

    bytes32 entityId = ReversePosition._get(coord.x, coord.y, coord.z);
    uint8 mineObjectTypeId;
    if (entityId == bytes32(0)) {
      // Check terrain block type
      mineObjectTypeId = getTerrainObjectTypeId(coord);

      // Create new entity
      entityId = getUniqueEntity();
      Position._set(entityId, coord.x, coord.y, coord.z);
      ReversePosition._set(coord.x, coord.y, coord.z, entityId);
    } else {
      mineObjectTypeId = ObjectType._get(entityId);

      require(Chip._getChipAddress(entityId) == address(0), "MineSystem: chip must be detached first");
    }
    require(ObjectTypeMetadata._getIsBlock(mineObjectTypeId), "MineSystem: object type is not a block");
    require(mineObjectTypeId != AirObjectID, "MineSystem: cannot mine air");
    require(mineObjectTypeId != WaterObjectID, "MineSystem: cannot mine water");

    bytes32 equippedEntityId = Equipped._get(playerEntityId);
    uint32 equippedToolDamage = PLAYER_HAND_DAMAGE;
    if (equippedEntityId != bytes32(0)) {
      equippedToolDamage = ObjectTypeMetadata._getDamage(ObjectType._get(equippedEntityId));
    }

    // Note: stamina is spent in the ForceFieldSystem.requireMineAllowed call

    useEquipped(playerEntityId, equippedEntityId);

    ObjectType._set(entityId, AirObjectID);
    addToInventoryCount(playerEntityId, PlayerObjectID, mineObjectTypeId, 1);

    callInternalSystem(
      abi.encodeCall(
        IForceFieldSystem.requireMineAllowed,
        (playerEntityId, equippedToolDamage, entityId, mineObjectTypeId, coord, extraData)
      )
    );

    // Apply gravity
    {
      VoxelCoord memory aboveCoord = VoxelCoord(coord.x, coord.y + 1, coord.z);
      bytes32 aboveEntityId = ReversePosition._get(aboveCoord.x, aboveCoord.y, aboveCoord.z);
      if (aboveEntityId != bytes32(0) && ObjectType._get(aboveEntityId) == PlayerObjectID) {
        callGravity(aboveEntityId, aboveCoord);
      }
    }
  }

  function mine(VoxelCoord memory coord) public payable {
    mine(coord, new bytes(0));
  }
}
