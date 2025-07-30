// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { DustScript } from "@dust/world/script/DustScript.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";

import { getAccessControl } from "../src/getAccessControl.sol";
import { getForceField } from "../src/getForceField.sol";
import { getGroupId } from "../src/getGroupId.sol";
import { hasAccess } from "../src/hasAccess.sol";
import { isForceFieldActive } from "../src/isForceFieldActive.sol";

contract GetAccessGroup is DustScript {
  function run(address worldAddress, EntityId target) public {
    StoreSwitch.setStoreAddress(worldAddress);

    (uint256 groupId, bool locked) = getAccessControl(target);

    EntityId forceField = getForceField(target);
    bool isActive = isForceFieldActive(forceField);

    console.log("Group ID:", groupId);
    console.log("Locked:", locked);
    console.log("Force Field:");
    console.logBytes32(forceField.unwrap());
    console.log("Is Active:", isActive);

    (uint256 ffGroupId, bool ffLocked) = getAccessControl(forceField);
    console.log("Force Field Group ID:", ffGroupId);
    console.log("Force Field Locked:", ffLocked);
  }

  function run(address worldAddress, EntityId target, EntityId caller) external {
    run(worldAddress, target);
    console.log("hasAccess:", hasAccess(caller, target));
  }
}
