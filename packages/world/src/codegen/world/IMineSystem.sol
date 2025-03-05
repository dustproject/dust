// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Vec3 } from "../../Vec3.sol";
import { EntityId } from "../../EntityId.sol";

/**
 * @title IMineSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IMineSystem {
  function mineWithExtraData(Vec3 coord, bytes memory extraData) external payable returns (EntityId);

  function mineUntilDestroyedWithExtraData(Vec3 coord, bytes memory extraData) external payable;

  function mine(Vec3 coord) external payable;

  function mineUntilDestroyed(Vec3 coord) external payable;
}
