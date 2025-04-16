// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotData, SlotTransfer } from "../utils/InventoryUtils.sol";
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
    SlotTransfer[] memory transfers,
    bytes calldata extraData
  ) public {
    caller.activate();

    EntityId target;

    // Transferring within the same inventory
    if (from == to) {
      if (caller != from) {
        caller.requireConnected(from);
        target = from;
      }
    } else {
      // Can't withdraw from a player, unless it is the player itself
      if (caller == to) {
        caller.requireConnected(from);
        require(ObjectType._get(from) != ObjectTypes.Player, "Cannot transfer from player");
        target = from;
      }
      // Can't deposit to a player, unless it is the player itself
      else if (caller == from) {
        caller.requireConnected(to);
        require(ObjectType._get(to) != ObjectTypes.Player, "Cannot transfer to player");
        target = to;
      } else {
        // TODO: remove this restriction
        revert("Caller is not involved in transfer");
      }
    }

    (SlotData[] memory deposits, SlotData[] memory withdrawals) = InventoryUtils.transfer(from, to, transfers);

    if (target.exists()) {
      bytes memory onTransfer =
        abi.encodeCall(ITransferHook.onTransfer, (caller, target, deposits, withdrawals, extraData));

      target.getProgram().callOrRevert(onTransfer);
    }

    notify(caller, TransferNotification({ transferEntityId: target, deposits: deposits, withdrawals: withdrawals }));
  }
}
