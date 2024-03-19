// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@everlonxyz/utils/src/Types.sol";

/**
 * @title IPlayerSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IPlayerSystem {
  function spawnPlayer(VoxelCoord memory spawnCoord) external returns (bytes32);

  function changePlayerOwner(address newOwner) external;
}
