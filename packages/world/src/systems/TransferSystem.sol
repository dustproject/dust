// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { InventoryUtils, SlotData, SlotTransfer } from "../utils/InventoryUtils.sol";
import { TransferNotification, notify } from "../utils/NotifUtils.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";

import { ITransferHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

contract TransferSystem is System {
  function transfer(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotTransfer[] memory transfers,
    bytes calldata extraData
  ) public {
    caller.activate();

    bool selfTransfer = (from == to);
    bool callerIsFrom = (caller == from);
    bool callerIsTo = (caller == to);

    EntityId target;

    if (selfTransfer) {
      target = (callerIsFrom ? EntityId.wrap(0) : from);
    } else {
      require(callerIsFrom || callerIsTo, "caller not involved");
      target = (callerIsFrom ? to : from);
    }

    if (from == to) {
      // Transferring within the same inventory
      if (caller != from) {
        target = from;
      }
    } else {
      if (caller == to) {
        target = from;
      } else if (caller == from) {
        target = to;
      } else {
        // TODO: remove this restriction
        revert("Caller is not involved in transfer");
      }
    }

    if (target.exists()) {
      caller.requireConnected(target);
      require(EntityObjectType._get(target) != ObjectTypes.Player, "Cannot access another player's inventory");
    }

    (SlotData[] memory fromSlotData, SlotData[] memory toSlotData) = InventoryUtils.transfer(from, to, transfers);

    // Get deposits and withdrawals FROM THE TARGET's PERSPECTIVE
    // If target == to, we are depositing fromSlotData and withdrawing toSlotData
    (SlotData[] memory deposits, SlotData[] memory withdrawals) =
      target == to ? (fromSlotData, toSlotData) : (toSlotData, fromSlotData);

    if (target.exists()) {
      bytes memory onTransfer =
        abi.encodeCall(ITransferHook.onTransfer, (caller, target, deposits, withdrawals, extraData));

      target.getProgram().callOrRevert(onTransfer);
    }

    notify(caller, TransferNotification({ transferEntityId: target, deposits: deposits, withdrawals: withdrawals }));
  }
}
