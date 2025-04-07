// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { EntityData, PlayerEntityData } from "../../systems/helper/ReadUtils.sol";
import { Vec3 } from "../../Vec3.sol";

/**
 * @title IReadSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IReadSystem {
  function getEntityData(EntityId entityId) external view returns (EntityData memory);

  function getEntityDataAtCoord(Vec3 coord) external view returns (EntityData memory);

  function getMultipleEntityData(EntityId[] memory entityIds) external view returns (EntityData[] memory);

  function getMultipleEntityDataAtCoord(Vec3[] memory coord) external view returns (EntityData[] memory);

  function getPlayerEntityData(address player) external view returns (PlayerEntityData memory);

  function getPlayersEntityData(address[] memory players) external view returns (PlayerEntityData[] memory);
}
