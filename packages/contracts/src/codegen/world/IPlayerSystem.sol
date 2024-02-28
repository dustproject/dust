// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@everlonxyz/utils/src/Types.sol";

/**
 * @title IPlayerSystem
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IPlayerSystem {
  function spawnPlayer(VoxelCoord memory spawnCoord) external returns (bytes32);

  function activatePlayer(bytes32 playerEntityId) external;

  function hitPlayer(bytes32 hitEntityId) external;
}
