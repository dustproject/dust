// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { VoxelCoord } from "../../VoxelCoord.sol";

/**
 * @title IBedSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IBedSystem {
  function sleepWithExtraData(EntityId bedEntityId, bytes memory extraData) external;

  function wakeupWithExtraData(VoxelCoord memory spawnCoord, bytes memory extraData) external;

  function sleep(EntityId bedEntityId) external;

  function wakeup(VoxelCoord memory spawnCoord) external;
}
