// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

/**
 * @title IChipSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IChipSystem {
  function attachChip(EntityId entityId, ResourceId chipSystemId, bytes calldata extraData) external payable;

  function detachChip(EntityId entityId, bytes calldata extraData) external payable;
}
