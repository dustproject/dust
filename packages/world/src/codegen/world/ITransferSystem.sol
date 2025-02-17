// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { ObjectTypeId } from "../../ObjectTypeIds.sol";

/**
 * @title ITransferSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface ITransferSystem {
  function transferWithExtraData(
    EntityId srcEntityId,
    EntityId dstEntityId,
    ObjectTypeId transferObjectTypeId,
    uint16 numToTransfer,
    bytes memory extraData
  ) external payable;

  function transferToolWithExtraData(
    EntityId srcEntityId,
    EntityId dstEntityId,
    EntityId toolEntityId,
    bytes memory extraData
  ) external payable;

  function transferToolsWithExtraData(
    EntityId srcEntityId,
    EntityId dstEntityId,
    EntityId[] memory toolEntityIds,
    bytes memory extraData
  ) external payable;

  function transfer(
    EntityId srcEntityId,
    EntityId dstEntityId,
    ObjectTypeId transferObjectTypeId,
    uint16 numToTransfer
  ) external payable;

  function transferTool(EntityId srcEntityId, EntityId dstEntityId, EntityId toolEntityId) external payable;

  function transferTools(EntityId srcEntityId, EntityId dstEntityId, EntityId[] memory toolEntityIds) external payable;
}
