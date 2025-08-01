// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";
import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotAmount } from "../utils/InventoryUtils.sol";
import { FuelMachineNotification, notify } from "../utils/NotifUtils.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import { ProgramId } from "../types/ProgramId.sol";

contract MachineSystem is System {
  function energizeMachine(EntityId caller, EntityId machine, SlotAmount[] calldata slots, bytes calldata extraData)
    public
  {
    caller.activate();
    require(slots.length > 0, "Must provide at least one slot");
    caller.requireConnected(machine);

    machine = machine._baseEntityId();

    ObjectType objectType = machine._getObjectType();
    require(objectType.isMachine(), "Can only fuel machines");

    uint16 fuelAmount = 0;
    for (uint256 i = 0; i < slots.length; i++) {
      ObjectType slotType = InventorySlot._getObjectType(caller, slots[i].slot);
      require(slotType == ObjectTypes.Battery, "Slot is not fuel");
      // we convert the mass to energy
      fuelAmount += slots[i].amount;
      InventoryUtils.removeObjectFromSlot(caller, slots[i].slot, slots[i].amount);
    }

    EnergyData memory machineData = updateMachineEnergy(machine);

    uint128 energyProvided = uint128(fuelAmount) * ObjectPhysics._getEnergy(ObjectTypes.Battery);
    uint128 newEnergyLevel = machineData.energy + energyProvided;

    Energy._setEnergy(machine, newEnergyLevel);

    ProgramId program = machine._getProgram();
    program.hook({ caller: caller, target: machine, revertOnFailure: true, extraData: extraData }).onEnergize(
      energyProvided
    );

    notify(caller, FuelMachineNotification({ machine: machine, fuelAmount: fuelAmount }));
  }

  /// @notice deprecated
  function fuelMachine(EntityId caller, EntityId machine, SlotAmount[] calldata slots, bytes calldata extraData)
    external
  {
    energizeMachine(caller, machine, slots, extraData);
  }
}
