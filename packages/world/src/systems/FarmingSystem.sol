// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { addEnergyToLocalPool, transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { getObjectTypeAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { TILL_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract FarmingSystem is System {
  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    caller.activate();
    (Vec3 callerCoord,) = caller.requireConnected(coord);

    (EntityId farmland, ObjectType objectType) = getOrCreateEntityAt(coord);
    require(objectType.isTillable(), "Not tillable");

    // If player died, return early
    uint128 callerEnergy = FarmingLib._processEnergyReduction(caller);
    if (callerEnergy == 0) {
      return;
    }

    ObjectType toolType = InventoryUtils.useTool(caller, callerCoord, toolSlot, type(uint128).max);
    require(toolType.isHoe(), "Must equip a hoe");

    EntityObjectType._set(farmland, ObjectTypes.Farmland);
  }
}

library FarmingLib {
  function _processEnergyReduction(EntityId caller) public returns (uint128) {
    (uint128 callerEnergy,) = transferEnergyToPool(caller, TILL_ENERGY_COST);
    return callerEnergy;
  }
}
