// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { CanOnlyFuelMachines, MustProvideAtLeastOneSlot, SlotIsNotFuel } from "../Errors.sol";
import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotAmount } from "../utils/InventoryUtils.sol";
import { FuelMachineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { MACHINE_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3 } from "../types/Vec3.sol";

contract MachineSystem is System {
  function fuelMachine(EntityId caller, EntityId machine, SlotAmount[] memory slots, bytes calldata extraData) external {
    caller.activate();
    if (slots.length == 0) revert MustProvideAtLeastOneSlot();
    caller.requireConnected(machine);

    machine = machine.baseEntityId();

    ObjectType objectType = machine._getObjectType();
    if (!objectType.isMachine()) revert CanOnlyFuelMachines(objectType);

    uint16 fuelAmount = 0;
    for (uint256 i = 0; i < slots.length; i++) {
      ObjectType slotType = InventorySlot._getObjectType(caller, slots[i].slot);
      if (slotType != ObjectTypes.Battery) revert SlotIsNotFuel(slotType);
      // we convert the mass to energy
      fuelAmount += slots[i].amount;
      InventoryUtils.removeObjectFromSlot(caller, slots[i].slot, slots[i].amount);
    }

    EnergyData memory machineData = updateMachineEnergy(machine);

    uint128 newEnergyLevel = machineData.energy + uint128(fuelAmount) * ObjectPhysics._getEnergy(ObjectTypes.Battery);

    Energy._setEnergy(machine, newEnergyLevel);

    ProgramId program = machine._getProgram();
    program.callOrRevert(
      abi.encodeCall(
        Hooks.IFuel.onFuel,
        (Hooks.FuelContext({ caller: caller, target: machine, fuelAmount: fuelAmount, extraData: extraData }))
      )
    );

    notify(caller, FuelMachineNotification({ machine: machine, fuelAmount: fuelAmount }));
  }
}
