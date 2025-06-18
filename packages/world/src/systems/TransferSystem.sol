// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";

import { InventoryUtils, SlotAmount, SlotData, SlotTransfer } from "../utils/InventoryUtils.sol";
import { TransferNotification, notify } from "../utils/NotifUtils.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { Vec3 } from "../types/Vec3.sol";

contract TransferSystem is System {
  function transfer(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotTransfer[] calldata transfers,
    bytes calldata extraData
  ) external {
    caller.activate();

    bool selfTransfer = (from == to);
    bool callerIsFrom = (caller == from);
    bool callerIsTo = (caller == to);

    EntityId target;

    if (selfTransfer) {
      // If it is a transfer within the same inventory,
      // only call the hook if it is not the caller's inventory
      target = (callerIsFrom ? EntityId.wrap(0) : from);
    } else {
      // If transferring between different inventories,
      // caller must be involved and the hook should be called for other party
      require(callerIsFrom || callerIsTo, "Caller is not involved in transfer");
      target = callerIsFrom ? to : from;
      caller.requireConnected(target);
    }

    SlotData[] memory deposits;
    SlotData[] memory withdrawals;

    (SlotData[] memory fromSlotData, SlotData[] memory toSlotData) = InventoryUtils.transfer(from, to, transfers);

    // Get deposits and withdrawals FROM THE TARGET's PERSPECTIVE
    // If target == to, we are depositing fromSlotData and withdrawing toSlotData
    (deposits, withdrawals) = target == to ? (fromSlotData, toSlotData) : (toSlotData, fromSlotData);

    _validateTargetAndNotify(caller, target, deposits, withdrawals, extraData);
  }

  function transferAmounts(
    EntityId caller,
    EntityId from,
    EntityId to,
    SlotAmount[] calldata amounts,
    bytes calldata extraData
  ) external {
    caller.activate();

    // SlotAmount transfers don't support self-transfers
    require(from != to, "Cannot transfer amounts to self");

    bool callerIsFrom = (caller == from);
    bool callerIsTo = (caller == to);

    // Caller must be involved in the transfer
    require(callerIsFrom || callerIsTo, "Caller is not involved in transfer");

    // Determine which entity needs hook validation
    EntityId target = callerIsFrom ? to : from;

    caller.requireConnected(target);

    // Execute the transfer and get the slot data
    SlotData[] memory fromSlotData = InventoryUtils.transfer(from, to, amounts);

    // Get deposits and withdrawals FROM THE TARGET's PERSPECTIVE
    // If target == to, we are depositing fromSlotData
    // If target == from, we are withdrawing fromSlotData
    SlotData[] memory deposits;
    SlotData[] memory withdrawals;

    (deposits, withdrawals) = target == to ? (fromSlotData, new SlotData[](0)) : (new SlotData[](0), fromSlotData);

    _validateTargetAndNotify(caller, target, deposits, withdrawals, extraData);
  }

  function _validateTargetAndNotify(
    EntityId caller,
    EntityId target,
    SlotData[] memory deposits,
    SlotData[] memory withdrawals,
    bytes calldata extraData
  ) internal {
    if (target._exists()) {
      ObjectType targetType = target._getObjectType();
      require(targetType != ObjectTypes.Player, "Cannot access another player's inventory");
      require(!targetType.isPassThrough(), "Cannot transfer directly to pass-through object");

      Hooks.TransferContext memory ctx = Hooks.TransferContext({
        caller: caller,
        target: target,
        deposits: deposits,
        withdrawals: withdrawals,
        extraData: extraData
      });

      bytes memory onTransfer = abi.encodeCall(Hooks.ITransfer.onTransfer, (ctx));

      target._getProgram().callOrRevert(onTransfer);
    }

    notify(caller, TransferNotification({ transferEntityId: target, deposits: deposits, withdrawals: withdrawals }));
  }
}
