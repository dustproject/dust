// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { getObjectTypeIdAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { TILL_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract FarmingSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function till(EntityId caller, Vec3 coord, uint16 toolSlot) external {
    caller.activate();
    (Vec3 callerCoord,) = caller.requireConnected(coord);

    (EntityId farmland, ObjectTypeId objectTypeId) = getOrCreateEntityAt(coord);
    require(objectTypeId == ObjectTypes.Dirt || objectTypeId == ObjectTypes.Grass, "Not dirt or grass");
    (, ObjectTypeId toolType) = InventoryUtils.useTool(caller, callerCoord, toolSlot, type(uint128).max);
    require(toolType.isHoe(), "Must equip a hoe");

    transferEnergyToPool(caller, TILL_ENERGY_COST);

    ObjectType._set(farmland, ObjectTypes.Farmland);
  }
}
