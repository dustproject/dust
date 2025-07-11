// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../types/EntityId.sol";
import { Vec3 } from "../../types/Vec3.sol";
import { Direction } from "../common.sol";

/**
 * @title IMoveSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IMoveSystem {
  function move(EntityId caller, Vec3[] memory newCoords) external;

  function moveDirections(EntityId caller, Direction[] memory directions) external;

  function moveDirectionsPacked(EntityId caller, uint256 packed) external;
}
