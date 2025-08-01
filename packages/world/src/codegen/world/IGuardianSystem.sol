// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

/**
 * @title IGuardianSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IGuardianSystem {
  function pause() external;

  function unpause() external;

  function addGuardian(address guardian) external;

  function removeGuardian(address guardian) external;
}
