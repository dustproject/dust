// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { MustEquipHoe, NotTillable } from "../Errors.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { addEnergyToLocalPool, transferEnergyToPool } from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import { Math } from "../utils/Math.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { TILL_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { ObjectTypes } from "../types/ObjectType.sol";
import { Vec3, vec3 } from "../types/Vec3.sol";

contract FarmingSystem is System {
  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    uint128 callerEnergy = caller.activate().energy;
    caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    if (!objectType.isTillable()) revert NotTillable(objectType);

    // If player died, return early
    (callerEnergy,) = transferEnergyToPool(caller, Math.min(callerEnergy, TILL_ENERGY_COST));
    if (callerEnergy == 0) {
      return;
    }

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    if (!toolData.toolType.isHoe()) revert MustEquipHoe(toolData.toolType);
    toolData.use(type(uint128).max);

    EntityObjectType._set(farmland, ObjectTypes.Farmland);
  }
}
