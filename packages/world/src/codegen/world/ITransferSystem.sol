// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../types/EntityId.sol";
import { SlotTransfer, SlotAmount } from "../../utils/InventoryUtils.sol";

/**
 * @title ITransferSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface ITransferSystem {
  function transfer(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotTransfer[] calldata transfers,
    bytes calldata extraData
  ) external;

  function transferAmounts(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotAmount[] calldata amounts,
    bytes calldata extraData
  ) external;
}
