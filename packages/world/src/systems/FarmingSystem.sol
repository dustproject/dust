// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { addEnergyToLocalPool, transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { getObjectTypeAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { InventoryUtils, ToolData } from "../utils/InventoryUtils.sol";

import { Math } from "../utils/Math.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { TILL_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract FarmingSystem is System {
  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    uint128 callerEnergy = caller.activate().energy;
    caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = getOrCreateEntityAt(coord);
    require(objectType.isTillable(), "Not tillable");

    // If player died, return early
    callerEnergy = FarmingLib._processEnergyReduction(caller, callerEnergy);
    if (callerEnergy == 0) {
      return;
    }

    ToolData memory toolData = InventoryUtils.getToolData(caller, toolSlot);
    require(toolData.toolType.isHoe(), "Must equip a hoe");
    toolData.use(type(uint128).max, 1);

    EntityObjectType._set(farmland, ObjectTypes.Farmland);
  }
}

library FarmingLib {
  function _processEnergyReduction(EntityId caller, uint128 callerEnergy) public returns (uint128) {
    (callerEnergy,) = transferEnergyToPool(caller, Math.min(callerEnergy, TILL_ENERGY_COST));
    return callerEnergy;
  }
}
