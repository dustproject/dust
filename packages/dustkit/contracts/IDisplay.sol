// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "@dust/world/src/types/EntityId.sol";

/**
 * Follows a similar convention to protocol programs:
 * - caller is the entity interacting with the program
 * - target is the entity for which the function is being called
 */
interface IDisplay {
  function contentURI(EntityId caller, EntityId target, bytes memory extraData) external view returns (string memory);
}
