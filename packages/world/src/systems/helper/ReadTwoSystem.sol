// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../../Types.sol";
import { staticCallInternalSystem } from "../../utils/CallUtils.sol";

import { ObjectType } from "../../codegen/tables/ObjectType.sol";
import { BaseEntity } from "../../codegen/tables/BaseEntity.sol";
import { Position } from "../../codegen/tables/Position.sol";
import { ReversePosition } from "../../codegen/tables/ReversePosition.sol";
import { LastKnownPosition } from "../../codegen/tables/LastKnownPosition.sol";
import { Player } from "../../codegen/tables/Player.sol";
import { PlayerActivity } from "../../codegen/tables/PlayerActivity.sol";
import { PlayerStatus } from "../../codegen/tables/PlayerStatus.sol";
import { ObjectTypeMetadata } from "../../codegen/tables/ObjectTypeMetadata.sol";
import { InventoryCount } from "../../codegen/tables/InventoryCount.sol";
import { InventoryObjects } from "../../codegen/tables/InventoryObjects.sol";
import { Equipped } from "../../codegen/tables/Equipped.sol";
import { Mass } from "../../codegen/tables/Mass.sol";
import { Energy, EnergyData } from "../../codegen/tables/Energy.sol";
import { Chip } from "../../codegen/tables/Chip.sol";
import { Commitment, CommitmentData } from "../../codegen/tables/Commitment.sol";

import { lastKnownPositionDataToVoxelCoord, positionDataToVoxelCoord } from "../../Utils.sol";
import { getEntityInventory } from "../../utils/ReadUtils.sol";
import { InventoryObject, PlayerEntityData, BlockEntityData } from "../../Types.sol";

import { IReadSystem } from "../../codegen/world/IReadSystem.sol";
import { EntityId } from "../../EntityId.sol";

// Public getters so clients can read the world state more easily
contract ReadTwoSystem is System {
  function getPlayerEntityData(address player) public view returns (PlayerEntityData memory) {
    EntityId entityId = Player._get(player);
    if (!entityId.exists()) {
      return
        PlayerEntityData({
          playerAddress: player,
          entityId: EntityId.wrap(0),
          position: VoxelCoord(0, 0, 0),
          isLoggedOff: false,
          equippedEntityId: EntityId.wrap(0),
          inventory: new InventoryObject[](0),
          mass: 0,
          energy: EnergyData({ energy: 0, lastUpdatedTime: 0 }),
          lastActionTime: 0,
          commitment: CommitmentData({ hasCommitted: false, x: 0, y: 0, z: 0 })
        });
    }

    bool isLoggedOff = PlayerStatus._getIsLoggedOff(entityId);
    VoxelCoord memory playerPos = isLoggedOff
      ? lastKnownPositionDataToVoxelCoord(LastKnownPosition._get(entityId))
      : positionDataToVoxelCoord(Position._get(entityId));

    return
      PlayerEntityData({
        playerAddress: player,
        entityId: entityId,
        position: playerPos,
        isLoggedOff: isLoggedOff,
        equippedEntityId: Equipped._get(entityId),
        inventory: getEntityInventory(entityId),
        mass: Mass._get(entityId),
        energy: Energy._get(entityId),
        lastActionTime: PlayerActivity._get(entityId),
        commitment: Commitment._get(entityId)
      });
  }

  function getPlayersEntityData(address[] memory players) public view returns (PlayerEntityData[] memory) {
    PlayerEntityData[] memory playersEntityData = new PlayerEntityData[](players.length);
    for (uint256 i = 0; i < players.length; i++) {
      playersEntityData[i] = getPlayerEntityData(players[i]);
    }
    return playersEntityData;
  }

  function getBlockEntityData(EntityId entityId) public view returns (BlockEntityData memory) {
    if (!entityId.exists()) {
      return
        BlockEntityData({
          entityId: EntityId.wrap(0),
          baseEntityId: EntityId.wrap(0),
          objectTypeId: 0,
          position: VoxelCoord(0, 0, 0),
          inventory: new InventoryObject[](0),
          chipAddress: address(0)
        });
    }

    EntityId baseEntityId = entityId.baseEntityId();
    return
      BlockEntityData({
        entityId: entityId,
        baseEntityId: baseEntityId,
        objectTypeId: ObjectType._get(entityId),
        position: positionDataToVoxelCoord(Position._get(entityId)),
        inventory: getEntityInventory(baseEntityId),
        chipAddress: Chip._getChipAddress(baseEntityId)
      });
  }

  function getBlocksEntityData(EntityId[] memory entityIds) public view returns (BlockEntityData[] memory) {
    BlockEntityData[] memory blocksEntityData = new BlockEntityData[](entityIds.length);
    for (uint256 i = 0; i < entityIds.length; i++) {
      blocksEntityData[i] = getBlockEntityData(entityIds[i]);
    }
    return blocksEntityData;
  }
}
