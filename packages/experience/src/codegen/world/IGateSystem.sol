// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "@biomesaw/world/src/EntityId.sol";
import { GateApprovalsData } from "../tables/GateApprovals.sol";

/**
 * @title IGateSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IGateSystem {
  function experience__setGateApprovals(EntityId entityId, GateApprovalsData memory approvals) external;

  function experience__deleteGateApprovals(EntityId entityId) external;

  function experience__setGateApprovedPlayers(EntityId entityId, address[] memory players) external;

  function experience__pushGateApprovedPlayer(EntityId entityId, address player) external;

  function experience__popGateApprovedPlayer(EntityId entityId) external;

  function experience__updateGateApprovedPlayer(EntityId entityId, uint256 index, address player) external;

  function experience__setGateApprovedNFT(EntityId entityId, address[] memory nfts) external;

  function experience__pushGateApprovedNFT(EntityId entityId, address nft) external;

  function experience__popGateApprovedNFT(EntityId entityId) external;

  function experience__updateGateApprovedNFT(EntityId entityId, uint256 index, address nft) external;
}
