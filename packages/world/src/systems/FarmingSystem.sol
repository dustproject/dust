// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { ObjectTypes } from "../types/ObjectType.sol";
import { Vec3 } from "../types/Vec3.sol";

contract FarmingSystem is System {
  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    caller.activate();
    caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isTillable(), "Not tillable");

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    require(toolData.toolType.isHoe(), "Must equip a hoe");

    if (toolData.use(type(uint128).max) == 0) {
      return; // Player died
    }

    EntityObjectType._set(farmland, ObjectTypes.Farmland);
  }
}
