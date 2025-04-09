// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { InventorySlot, InventorySlotData } from "../codegen/tables/InventorySlot.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";

import { CRAFT_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";

import { Vec3 } from "../Vec3.sol";
import { transferEnergyToPool } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotAmount } from "../utils/InventoryUtils.sol";
import { CraftNotification, notify } from "../utils/NotifUtils.sol";

contract CraftFuelSystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function craftFuel(EntityId caller, EntityId powerstone, SlotAmount[] memory inputs) public {
    caller.activate();
    require(inputs.length > 0, "Must provide at least one input");
    require(
      powerstone.exists() && ObjectType._get(powerstone) == ObjectTypes.Powerstone,
      "You need a powerstone to craft fuel"
    );
    caller.requireConnected(powerstone);

    uint128 totalEnergy = 0;
    for (uint256 i = 0; i < inputs.length; i++) {
      ObjectTypeId inputType = InventorySlot._getObjectType(caller, inputs[i].slot);
      require(inputType.isLog() || inputType.isLeaf(), "Can only use logs or leaves to make fuel");
      // we convert the mass to energy
      totalEnergy +=
        inputs[i].amount * (ObjectTypeMetadata._getEnergy(inputType) + ObjectTypeMetadata._getMass(inputType));
      InventoryUtils.removeObject(caller, inputType, inputs[i].amount);
    }
    uint128 fuelAmount = totalEnergy / ObjectTypeMetadata._getEnergy(ObjectTypes.Fuel);
    require(fuelAmount > 0 && fuelAmount <= uint128(type(uint16).max), "Invalid fuel amount");
    InventoryUtils.addObject(caller, ObjectTypes.Fuel, uint16(fuelAmount));

    transferEnergyToPool(caller, CRAFT_ENERGY_COST);

    // TODO: should we use a diff notification for fuel?
    notify(caller, CraftNotification({ recipeId: bytes32(0), station: powerstone }));
  }
}
