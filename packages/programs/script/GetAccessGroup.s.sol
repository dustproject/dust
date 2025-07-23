// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { DustScript } from "@dust/world/script/DustScript.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { getForceField } from "../src/getForceField.sol";
import { getGroupId } from "../src/getGroupId.sol";
import { isAllowed } from "../src/isAllowed.sol";

contract GetAccessGroup is DustScript {
  function run(address worldAddress, EntityId target) public {
    StoreSwitch.setStoreAddress(worldAddress);

    (uint256 groupId, bool dd) = getGroupId(target);

    (EntityId forceField, bool isProtected) = getForceField(target);
    console.log("Group ID:", groupId);
    console.log("Default Deny:", dd);
    console.log("Force Field:");
    console.logBytes32(forceField.unwrap());
    console.log("Is Protected:", isProtected);
    (uint256 ffGroupId, bool ffDd) = getGroupId(forceField);
    console.log("Force Field Group ID:", ffGroupId);
    console.log("Force Field Default Deny:", ffDd);
  }

  function run(address worldAddress, EntityId target, EntityId caller) external {
    run(worldAddress, target);
    console.log("isAllowed:", isAllowed(target, caller));
  }
}
