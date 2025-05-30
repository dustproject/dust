// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

/**
 * @title IModeratorSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IModeratorSystem {
  function pause() external;

  function unpause() external;

  function addModerator(address moderator) external;

  function removeModerator(address moderator) external;
}
