// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@biomesaw/utils/src/Types.sol";

/**
 * @title IMineSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IMineSystem {
  function mine(VoxelCoord memory coord, bytes memory extraData) external payable;
}
