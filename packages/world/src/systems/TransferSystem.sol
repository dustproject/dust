// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { InventoryUtils, SlotTransfer, SlotTransfer } from "../utils/InventoryUtils.sol";
import { TransferNotification, notify } from "../utils/NotifUtils.sol";

import { SMART_CHEST_ENERGY_COST } from "../Constants.sol";
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

    if (caller != from) {
      caller.requireConnected(from);
    }
    from.requireConnected(to);

    transferEnergyToPool(caller, SMART_CHEST_ENERGY_COST);

    (EntityId[] memory entities, ObjectAmount[] memory objectAmounts) =
      InventoryUtils.getObjectsAndEntities(from, slotTransfers);

    InventoryUtils.transfer(from, to, slotTransfers);

    // Note: we call this after the transfer state has been updated, to prevent re-entrancy attacks
    TransferLib._onTransfer(caller, from, to, entities, objectAmounts, extraData);
  }
}

library TransferLib {
  function _onTransfer(
    EntityId caller,
    EntityId from,
    EntityId to,
    EntityId[] memory entities,
    ObjectAmount[] memory objectAmounts,
    bytes calldata extraData
  ) public {
    EntityId target = _getTarget(caller, from, to);

    require(ObjectType._get(target) != ObjectTypes.Player, "Cannot transfer to player");

    bytes memory onTransfer =
      abi.encodeCall(ITransferHook.onTransfer, (caller, target, from, to, objectAmounts, entities, extraData));

    target.getProgram().callOrRevert(onTransfer);

    notify(caller, TransferNotification({ transferEntityId: target, tools: entities, objectAmounts: objectAmounts }));
  }

  function _getTarget(EntityId caller, EntityId from, EntityId to) internal pure returns (EntityId) {
    if (caller == from) {
      return to;
    } else if (caller == to) {
      return from;
    } else {
      revert("Caller is not involved in transfer");
    }
  }
}
