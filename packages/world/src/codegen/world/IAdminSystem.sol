// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { ObjectTypeId } from "../../ObjectTypeId.sol";
import { Vec3 } from "../../Vec3.sol";

/**
 * @title IAdminSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IAdminSystem {
  function adminAddToInventory(EntityId owner, ObjectTypeId objectTypeId, uint16 numObjectsToAdd) external;

  function adminAddToolToInventory(EntityId owner, ObjectTypeId toolObjectTypeId) external returns (EntityId);

  function adminRemoveFromInventory(EntityId owner, ObjectTypeId objectTypeId, uint16 numObjectsToRemove) external;

  function adminRemoveToolFromInventory(EntityId owner, EntityId tool) external;

  function adminTeleportPlayer(address player, Vec3 finalCoord) external;
}
