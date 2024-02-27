// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@everlonxyz/utils/src/Types.sol";

/**
 * @title IBuildSystem
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IBuildSystem {
  function build(bytes32 inventoryEntityId, VoxelCoord memory coord) external;
}
