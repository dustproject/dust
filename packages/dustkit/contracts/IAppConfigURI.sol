// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "@dust/world/src/types/EntityId.sol";

interface IAppConfigURI {
  function appConfigURI(EntityId viaEntity) external returns (string memory uri);
}
