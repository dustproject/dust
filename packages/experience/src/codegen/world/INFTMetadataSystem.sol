// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { ERC721MetadataData } from "./../tables/ERC721Metadata.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

/**
 * @title INFTMetadataSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface INFTMetadataSystem {
  function experience__setNFTMetadata(ERC721MetadataData memory metadata) external;

  function experience__setMUDNFTMetadata(ResourceId namespaceId, ERC721MetadataData memory metadata) external;

  function experience__deleteNFTMetadata() external;
}
