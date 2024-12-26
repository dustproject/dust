// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ResourceType } from "./../common.sol";

/**
 * @title IAssetsSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IAssetsSystem {
  function experience__setAsset(address asset, ResourceType assetType) external;

  function experience__deleteAsset(address asset) external;
}
