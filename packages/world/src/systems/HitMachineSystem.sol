// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ERC165Checker } from "@latticexyz/world/src/ERC165Checker.sol";
import { VoxelCoord } from "../VoxelCoord.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Position } from "../codegen/tables/Position.sol";
import { Equipped } from "../codegen/tables/Equipped.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Chip } from "../codegen/tables/Chip.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { ActionType } from "../codegen/common.sol";

import { addToInventoryCount, removeFromInventoryCount, useEquipped } from "../utils/InventoryUtils.sol";
import { requireValidPlayer, requireInPlayerInfluence } from "../utils/PlayerUtils.sol";
import { updateMachineEnergyLevel } from "../utils/MachineUtils.sol";
import { getForceField } from "../utils/ForceFieldUtils.sol";
import { isWhacker } from "../utils/ObjectTypeUtils.sol";
import { positionDataToVoxelCoord } from "../Utils.sol";
import { callChip } from "../utils/callChip.sol";
import { notify, HitMachineNotifData } from "../utils/NotifUtils.sol";
import { IForceFieldChip } from "../prototypes/IForceFieldChip.sol";

import { EntityId } from "../EntityId.sol";

contract HitMachineSystem is System {
  function hitMachineCommon(
    EntityId playerEntityId,
    EntityId machineEntityId,
    VoxelCoord memory machineCoord
  ) internal {
    EnergyData memory machineData = updateMachineEnergyLevel(machineEntityId);
    if (machineData.energy == 0) {
      return;
    }

    uint16 objectTypeId = ObjectType._get(machineEntityId);

    EntityId equippedEntityId = Equipped._get(playerEntityId);
    require(equippedEntityId.exists(), "You must use a whacker to hit machines");
    uint16 equippedObjectTypeId = ObjectType._get(equippedEntityId);
    require(isWhacker(equippedObjectTypeId), "You must use a whacker to hit machines");

    // TODO: useEquipped

    // TODO: decrease energy

    notify(playerEntityId, HitMachineNotifData({ machineEntityId: machineEntityId, machineCoord: machineCoord }));

    callChip(
      machineEntityId.getChipAddress(),
      abi.encodeCall(IForceFieldChip.onForceFieldHit, (playerEntityId, machineEntityId))
    );
  }

  function hitMachine(EntityId entityId) public {
    (EntityId playerEntityId, VoxelCoord memory playerCoord) = requireValidPlayer(_msgSender());
    VoxelCoord memory entityCoord = requireInPlayerInfluence(playerCoord, entityId);
    EntityId baseEntityId = entityId.baseEntityId();

    hitMachineCommon(playerEntityId, baseEntityId, entityCoord);
  }

  function hitForceField(VoxelCoord memory entityCoord) public {
    (EntityId playerEntityId, VoxelCoord memory playerCoord) = requireValidPlayer(_msgSender());
    requireInPlayerInfluence(playerCoord, entityCoord);
    EntityId forceFieldEntityId = getForceField(entityCoord);
    require(forceFieldEntityId.exists(), "No force field at this location");
    VoxelCoord memory forceFieldCoord = positionDataToVoxelCoord(Position._get(forceFieldEntityId));
    hitMachineCommon(playerEntityId, forceFieldEntityId, forceFieldCoord);
  }
}
