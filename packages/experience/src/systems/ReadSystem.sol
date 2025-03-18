// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IWorld } from "@biomesaw/world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { EntityId } from "@biomesaw/world/src/EntityId.sol";
import { EntityData } from "@biomesaw/world/src/Types.sol";

import { ProgramAttachment } from "../codegen/tables/ProgramAttachment.sol";
import { ProgramAdmin } from "../codegen/tables/ProgramAdmin.sol";
import { SmartItemMetadata, SmartItemMetadataData } from "../codegen/tables/SmartItemMetadata.sol";
import { GateApprovals, GateApprovalsData } from "../codegen/tables/GateApprovals.sol";
import { ExchangeInfo, ExchangeInfoData } from "../codegen/tables/ExchangeInfo.sol";
import { Exchanges } from "../codegen/tables/Exchanges.sol";
import { PipeAccess } from "../codegen/tables/PipeAccess.sol";
import { PipeAccessList } from "../codegen/tables/PipeAccessList.sol";
import { ExperienceEntityData, PipeAccessDataWithEntityId, ExchangeInfoDataWithExchangeId } from "../Types.sol";

contract ReadSystem is System {
  function getEntityData(EntityId entityId) public view returns (ExperienceEntityData memory) {
    EntityData memory worldEntityData = IWorld(_world()).getEntityData(entityId);
    bytes32[] memory exchangeIds = Exchanges.get(entityId);
    ExchangeInfoDataWithExchangeId[] memory exchangeInfoData = new ExchangeInfoDataWithExchangeId[](exchangeIds.length);
    for (uint256 i = 0; i < exchangeIds.length; i++) {
      exchangeInfoData[i] = ExchangeInfoDataWithExchangeId({
        exchangeId: exchangeIds[i],
        exchangeInfoData: ExchangeInfo.get(entityId, exchangeIds[i])
      });
    }
    bytes32[] memory approvedEntityIdsForPipeTransfer = PipeAccessList.get(entityId);
    PipeAccessDataWithEntityId[] memory pipeAccessDataList = new PipeAccessDataWithEntityId[](
      approvedEntityIdsForPipeTransfer.length
    );
    for (uint256 i = 0; i < approvedEntityIdsForPipeTransfer.length; i++) {
      EntityId approvedEntityId = EntityId.wrap(approvedEntityIdsForPipeTransfer[i]);
      pipeAccessDataList[i] = PipeAccessDataWithEntityId({
        entityId: approvedEntityId,
        pipeAccessData: PipeAccess.get(entityId, approvedEntityId)
      });
    }

    return
      ExperienceEntityData({
        worldEntityData: worldEntityData,
        programAttacher: ProgramAttachment.get(entityId),
        programAdmin: ProgramAdmin.get(entityId),
        smartItemMetadata: SmartItemMetadata.get(entityId),
        gateApprovalsData: GateApprovals.get(entityId),
        exchanges: exchangeInfoData,
        pipeAccessDataList: pipeAccessDataList
      });
  }

  function getMultipleEntityData(EntityId[] memory entityIds) public view returns (ExperienceEntityData[] memory) {
    ExperienceEntityData[] memory experienceEntityData = new ExperienceEntityData[](entityIds.length);
    for (uint256 i = 0; i < entityIds.length; i++) {
      experienceEntityData[i] = getEntityData(entityIds[i]);
    }
    return experienceEntityData;
  }
}
