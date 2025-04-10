// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Vec3 } from "../../Vec3.sol";
import { EntityId } from "../../EntityId.sol";

/**
 * @title IForceFieldSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IForceFieldSystem {
  function validateSpanningTree(
    Vec3[26] memory boundaryFragments,
    uint256 len,
    uint256[] calldata parents
  ) external pure returns (bool);

  function computeBoundaryFragments(
    EntityId forceField,
    Vec3 fragmentCoord
  ) external view returns (Vec3[26] memory, uint256);

  function addFragment(
    EntityId caller,
    EntityId forceField,
    Vec3 refFragmentCoord,
    Vec3 fragmentCoord,
    bytes calldata extraData
  ) external;

  function removeFragment(
    EntityId caller,
    EntityId forceField,
    Vec3 fragmentCoord,
    uint256[] calldata parents,
    bytes calldata extraData
  ) external;
}
