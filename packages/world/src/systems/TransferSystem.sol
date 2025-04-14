// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotTransfer, SlotTransfer } from "../utils/InventoryUtils.sol";
import { TransferNotification, notify } from "../utils/NotifUtils.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectAmount } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";

import { ITransferHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

contract TransferSystem is System {
  function transfer(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotTransfer[] memory slotTransfers,
    bytes calldata extraData
  ) public {
    caller.activate();

    // TODO: this is incorrect, we might need 2 targets (eg. transferring from chest to chest), but we need to figure out how to prevent reentrancies
    EntityId target;

    // Can't withdraw from a player, unless it is the player itself
    if (caller != from) {
      caller.requireConnected(from);
      require(ObjectType._get(from) != ObjectTypes.Player, "Cannot transfer from player");
      target = from;
    }

    // Can't deposit to a player, unless it is the player itself
    if (caller != to) {
      caller.requireConnected(to);
      require(ObjectType._get(to) != ObjectTypes.Player, "Cannot transfer to player");
      target = to;
    }

    (EntityId[] memory entities, ObjectAmount[] memory objectAmounts) =
      InventoryUtils.getObjectsAndEntities(from, slotTransfers);

    if (target.exists()) {
      InventoryUtils.transfer(from, to, slotTransfers);

      bytes memory onTransfer =
        abi.encodeCall(ITransferHook.onTransfer, (caller, target, from, to, objectAmounts, entities, extraData));

      target.getProgram().callOrRevert(onTransfer);
    }

    notify(caller, TransferNotification({ transferEntityId: target, tools: entities, objectAmounts: objectAmounts }));
  }
}
