// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord, EntityData, InventoryObject } from "../../Types.sol";
import { EntityId } from "../../EntityId.sol";

/**
 * @title IReadSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IReadSystem {
  function getObjectTypeIdAtCoord(VoxelCoord memory coord) external view returns (uint16);

  function getEntityIdAtCoord(VoxelCoord memory coord) external view returns (EntityId);

  function getEntityData(EntityId entityId) external view returns (EntityData memory);

  function getEntityDataAtCoord(VoxelCoord memory coord) external view returns (EntityData memory);

  function getMultipleEntityDataAtCoord(VoxelCoord[] memory coord) external view returns (EntityData[] memory);

  function getLastActivityTime(address player) external view returns (uint256);

  function getInventory(address player) external view returns (InventoryObject[] memory);

  function getInventory(EntityId entityId) external view returns (InventoryObject[] memory);

  function getCoordForEntityId(EntityId entityId) external view returns (VoxelCoord memory);

  function getPlayerCoord(address player) external view returns (VoxelCoord memory);
}
