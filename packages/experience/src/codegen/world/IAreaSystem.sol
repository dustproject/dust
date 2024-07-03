// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Area } from "./../../utils/AreaUtils.sol";

/**
 * @title IAreaSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IAreaSystem {
  function experience__setArea(bytes32 areaId, string memory name, Area memory area) external;

  function experience__deleteArea(bytes32 areaId) external;
}
