// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityIdLib } from "@dust/world/src/EntityId.sol";

import { AllowedCaller } from "./codegen/tables/AllowedCaller.sol";
import { Owner } from "./codegen/tables/Owner.sol";
import { SmartItem } from "./codegen/tables/SmartItem.sol";

contract WhitelistSystem is System {
  function setAllowed(EntityId target, EntityId caller, bool allowed) external {
    bytes32 smartItemId = SmartItem.get(target);
    _requireOwner(smartItemId);
    AllowedCaller.set(smartItemId, caller, allowed);
  }

  function setOwner(EntityId target, EntityId newOwner) external {
    bytes32 smartItemId = SmartItem.get(target);
    _requireOwner(smartItemId);
    Owner.set(smartItemId, newOwner);
  }

  function _requireOwner(bytes32 smartItemId) internal view {
    require(Owner.get(smartItemId) == EntityIdLib.encodePlayer(_msgSender()), "Only the owner can call this function");
  }
}
