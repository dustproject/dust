// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelCoordDirectionVonNeumann } from "../../Types.sol";
import { transformVoxelCoordVonNeumann, inVonNeumannNeighborhood } from "../../utils/VoxelCoordUtils.sol";

import { ObjectType } from "../../codegen/tables/ObjectType.sol";
import { BaseEntity } from "../../codegen/tables/BaseEntity.sol";
import { Position } from "../../codegen/tables/Position.sol";
import { ReversePosition } from "../../codegen/tables/ReversePosition.sol";
import { Chip } from "../../codegen/tables/Chip.sol";
import { Energy, EnergyData } from "../../codegen/tables/Energy.sol";
import { ObjectTypeMetadata } from "../../codegen/tables/ObjectTypeMetadata.sol";
import { ObjectCategory } from "../../codegen/common.sol";

import { PlayerObjectID, PipeObjectID, ForceFieldObjectID, ChipBatteryObjectID } from "../../ObjectTypeIds.sol";
import { positionDataToVoxelCoord, safeCallChip } from "../../Utils.sol";
import { ChipOnPipeTransferData, PipeTransferData, PipeTransferCommonContext } from "../../Types.sol";
import { updateMachineEnergyLevel } from "../../utils/MachineUtils.sol";
import { getForceField } from "../../utils/ForceFieldUtils.sol";
import { isStorageContainer } from "../../utils/ObjectTypeUtils.sol";
import { transferInventoryEntity, transferInventoryNonEntity, addToInventoryCount, removeFromInventoryCount } from "../../utils/InventoryUtils.sol";

import { IForceFieldChip } from "../../prototypes/IForceFieldChip.sol";
import { EntityId } from "../../EntityId.sol";

contract PipeTransferHelperSystem is System {
  function requireValidPath(
    VoxelCoord memory srcCoord,
    VoxelCoord memory dstCoord,
    VoxelCoordDirectionVonNeumann[] memory path
  ) internal view {
    require(path.length > 0, "Path must be greater than 0");
    VoxelCoord[] memory pathCoords = new VoxelCoord[](path.length);
    for (uint i = 0; i < path.length; i++) {
      pathCoords[i] = transformVoxelCoordVonNeumann(i == 0 ? srcCoord : pathCoords[i - 1], path[i]);
      EntityId pathEntityId = ReversePosition._get(pathCoords[i].x, pathCoords[i].y, pathCoords[i].z);
      require(pathEntityId.exists(), "Path coord is not in the world");
      require(ObjectType._get(pathEntityId) == PipeObjectID, "Path coord is not a pipe");
    }

    // check if last coord and dstCoord are in von neumann distance of 1
    require(
      inVonNeumannNeighborhood(pathCoords[path.length - 1], dstCoord),
      "Last path coord is not in von neumann distance of 1 from destination coord"
    );
  }

  function pipeTransferCommon(
    EntityId callerEntityId,
    uint16 callerObjectTypeId,
    VoxelCoord memory callerCoord,
    bool isDeposit,
    PipeTransferData memory pipeTransferData
  ) public payable returns (PipeTransferCommonContext memory) {
    require(pipeTransferData.targetEntityId != callerEntityId, "Cannot transfer to self");
    require(pipeTransferData.transferData.numToTransfer > 0, "Amount must be greater than 0");
    VoxelCoord memory targetCoord = positionDataToVoxelCoord(Position._get(pipeTransferData.targetEntityId));
    uint16 targetObjectTypeId = ObjectType._get(pipeTransferData.targetEntityId);
    address chipAddress = Chip._get(pipeTransferData.targetEntityId);
    uint128 machineEnergyLevel = 0;
    EntityId targetForceFieldEntityId = getForceField(targetCoord);
    if (targetForceFieldEntityId.exists()) {
      EnergyData memory machineData = updateMachineEnergyLevel(targetForceFieldEntityId);
      machineEnergyLevel = machineData.energy;
    }

    requireValidPath(
      isDeposit ? callerCoord : targetCoord,
      isDeposit ? targetCoord : callerCoord,
      pipeTransferData.path
    );

    // TODO: Apply cost for using pipes

    if (pipeTransferData.transferData.toolEntityIds.length == 0) {
      require(
        ObjectTypeMetadata._getObjectCategory(pipeTransferData.transferData.objectTypeId) == ObjectCategory.Block,
        "Object type is not a block"
      );
      require(pipeTransferData.transferData.numToTransfer > 0, "Amount must be greater than 0");

      if (isDeposit) {
        removeFromInventoryCount(
          callerEntityId,
          pipeTransferData.transferData.objectTypeId,
          pipeTransferData.transferData.numToTransfer
        );

        if (isStorageContainer(targetObjectTypeId)) {
          addToInventoryCount(
            pipeTransferData.targetEntityId,
            targetObjectTypeId,
            pipeTransferData.transferData.objectTypeId,
            pipeTransferData.transferData.numToTransfer
          );
        } else if (targetObjectTypeId == ForceFieldObjectID) {
          require(
            pipeTransferData.transferData.objectTypeId == ChipBatteryObjectID,
            "Force field can only accept chip batteries"
          );
          uint128 newEnergyLevel = machineEnergyLevel + (uint128(pipeTransferData.transferData.numToTransfer) * 10);

          Energy._set(
            pipeTransferData.targetEntityId,
            EnergyData({ energy: newEnergyLevel, lastUpdatedTime: uint128(block.timestamp) })
          );

          safeCallChip(
            chipAddress,
            abi.encodeCall(
              IForceFieldChip.onPowered,
              (callerEntityId, pipeTransferData.targetEntityId, pipeTransferData.transferData.numToTransfer)
            )
          );
        } else {
          revert("Target object type is not valid");
        }
      } else {
        addToInventoryCount(
          callerEntityId,
          callerObjectTypeId,
          pipeTransferData.transferData.objectTypeId,
          pipeTransferData.transferData.numToTransfer
        );

        if (isStorageContainer(targetObjectTypeId)) {
          removeFromInventoryCount(
            pipeTransferData.targetEntityId,
            pipeTransferData.transferData.objectTypeId,
            pipeTransferData.transferData.numToTransfer
          );
        } else {
          revert("Target object type is not valid");
        }
      }
    } else {
      require(pipeTransferData.transferData.toolEntityIds.length > 0, "No tools to transfer");
      require(
        pipeTransferData.transferData.toolEntityIds.length == pipeTransferData.transferData.numToTransfer,
        "Number of tools to transfer must match number of tools"
      );

      for (uint i = 0; i < pipeTransferData.transferData.toolEntityIds.length; i++) {
        uint16 toolObjectTypeId = transferInventoryEntity(
          isDeposit ? callerEntityId : pipeTransferData.targetEntityId,
          isDeposit ? pipeTransferData.targetEntityId : callerEntityId,
          isDeposit ? targetObjectTypeId : callerObjectTypeId,
          pipeTransferData.transferData.toolEntityIds[i]
        );
        require(toolObjectTypeId == pipeTransferData.transferData.objectTypeId, "All tools must be of the same type");
      }
    }

    return
      PipeTransferCommonContext({
        targetCoord: targetCoord,
        chipAddress: chipAddress,
        machineEnergyLevel: machineEnergyLevel,
        targetObjectTypeId: targetObjectTypeId
      });
  }
}
