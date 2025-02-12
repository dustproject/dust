// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { callInternalSystem } from "../utils/CallUtils.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";
import { Position } from "../codegen/tables/Position.sol";
import { Chip } from "../codegen/tables/Chip.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { ChipOnPipeTransferData, PipeTransferData, PipeTransferCommonContext } from "../Types.sol";
import { ForceFieldObjectID } from "../ObjectTypeIds.sol";
import { checkWorldStatus, positionDataToVoxelCoord } from "../Utils.sol";
import { isStorageContainer } from "../utils/ObjectTypeUtils.sol";
import { updateMachineEnergyLevel } from "../utils/MachineUtils.sol";
import { getForceField } from "../utils/ForceFieldUtils.sol";

import { IChestChip } from "../prototypes/IChestChip.sol";
import { IPipeTransferHelperSystem } from "../codegen/world/IPipeTransferHelperSystem.sol";
import { EntityId } from "../EntityId.sol";

contract PipeTransferSystem is System {
  function requireAllowed(
    address chipAddress,
    uint256 machineEnergyLevel,
    ChipOnPipeTransferData memory chipOnPipeTransferData
  ) internal {
    if (chipAddress != address(0) && machineEnergyLevel > 0) {
      // Don't safe call here as we want to revert if the chip doesn't allow the transfer
      bool transferAllowed = IChestChip(chipAddress).onPipeTransfer{ value: _msgValue() }(chipOnPipeTransferData);
      require(transferAllowed, "Transfer not allowed by chip");
    }
  }

  function pipeTransfer(
    EntityId callerEntityId,
    bool isDeposit,
    PipeTransferData memory pipeTransferData
  ) public payable {
    checkWorldStatus();
    uint16 callerObjectTypeId = ObjectType._get(callerEntityId);
    require(isStorageContainer(callerObjectTypeId), "Source object type is not a chest");

    VoxelCoord memory callerCoord = positionDataToVoxelCoord(Position._get(callerEntityId));
    address chipAddress = Chip._get(callerEntityId);
    uint256 machineEnergyLevel = 0;
    EntityId callerForceFieldEntityId = getForceField(callerCoord);
    if (callerForceFieldEntityId.exists()) {
      EnergyData memory machineData = updateMachineEnergyLevel(callerForceFieldEntityId);
      machineEnergyLevel = machineData.energy;
    }
    require(chipAddress == _msgSender(), "Caller is not the chip of the smart item");
    require(machineEnergyLevel > 0, "Caller has no charge");

    PipeTransferCommonContext memory pipeCtx = abi.decode(
      callInternalSystem(
        abi.encodeCall(
          IPipeTransferHelperSystem.pipeTransferCommon,
          (callerEntityId, callerObjectTypeId, callerCoord, isDeposit, pipeTransferData)
        ),
        0
      ),
      (PipeTransferCommonContext)
    );

    if (pipeCtx.targetObjectTypeId != ForceFieldObjectID) {
      requireAllowed(
        pipeCtx.chipAddress,
        pipeCtx.machineEnergyLevel,
        ChipOnPipeTransferData({
          playerEntityId: EntityId.wrap(0), // this is a transfer initiated by a chest, not a player
          targetEntityId: pipeTransferData.targetEntityId,
          callerEntityId: callerEntityId,
          isDeposit: isDeposit,
          path: pipeTransferData.path,
          transferData: pipeTransferData.transferData,
          extraData: pipeTransferData.extraData
        })
      );
    }
  }
}
