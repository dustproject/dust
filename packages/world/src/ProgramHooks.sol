// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextProviderLib } from "@latticexyz/world/src/WorldContext.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { SAFE_PROGRAM_GAS } from "./Constants.sol";
import { EntityId } from "./types/EntityId.sol";
import { ObjectAmount, ObjectType } from "./types/ObjectType.sol";
import { Orientation } from "./types/Orientation.sol";
import { ProgramId } from "./types/ProgramId.sol";
import { Vec3 } from "./types/Vec3.sol";
import { SlotData } from "./utils/InventoryUtils.sol";

/**
 * Naming convention for all hooks/getters:
 * - caller is the entity that called the system and triggered the call to the program
 * - target is the entity for which the function is being called
 */

// Base context struct for all hooks
struct HookContext {
  EntityId caller;
  EntityId target;
  bool revertOnFailure;
  bytes extraData;
}

// Interfaces

interface IProgramValidator {
  struct ProgramData {
    EntityId programmed;
    ProgramId program;
  }

  function validateProgram(HookContext calldata ctx, ProgramData calldata data) external view;
}

interface IAttachProgram {
  function onAttachProgram(HookContext calldata ctx) external;
}

interface IDetachProgram {
  function onDetachProgram(HookContext calldata ctx) external;
}

interface ITransfer {
  struct TransferData {
    SlotData[] deposits;
    SlotData[] withdrawals;
  }

  function onTransfer(HookContext calldata ctx, TransferData calldata transfer) external;
}

interface IHit {
  struct HitData {
    EntityId target;
    EntityId tool;
    uint128 damage;
  }

  function onHit(HookContext calldata ctx, HitData calldata hit) external;
}

interface IEnergize {
  struct EnergizeData {
    uint128 amount;
  }

  function onEnergize(HookContext calldata ctx, EnergizeData calldata energize) external;
}

interface IAddFragment {
  struct AddFragmentData {
    EntityId added;
  }

  function onAddFragment(HookContext calldata ctx, AddFragmentData calldata fragment) external;
}

interface IRemoveFragment {
  struct RemoveFragmentData {
    EntityId removed;
  }

  function onRemoveFragment(HookContext calldata ctx, RemoveFragmentData calldata fragment) external;
}

interface IBuild {
  struct BuildData {
    EntityId entity;
    Vec3 coord;
    ObjectType slotType;
    ObjectType objectType;
    Orientation orientation;
  }

  function onBuild(HookContext calldata ctx, BuildData calldata build) external;
}

interface IMine {
  struct MineData {
    EntityId entity;
    EntityId tool;
    Vec3 coord;
    ObjectType objectType;
  }

  function onMine(HookContext calldata ctx, MineData calldata mine) external;
}

interface ISpawn {
  struct SpawnData {
    uint128 energy;
    Vec3 coord;
  }

  function onSpawn(HookContext calldata ctx, SpawnData calldata spawn) external;
}

interface ISleep {
  function onSleep(HookContext calldata ctx) external;
}

interface IWakeup {
  function onWakeup(HookContext calldata ctx) external;
}

interface IOpen {
  function onOpen(HookContext calldata ctx) external;
}

interface IClose {
  function onClose(HookContext calldata ctx) external;
}

struct Hook {
  ProgramId program;
  HookContext ctx;
}

library HooksLib {
  function hook(ProgramId self, EntityId caller, EntityId target, bool revertOnFailure, bytes memory extraData)
    internal
    pure
    returns (Hook memory)
  {
    return Hook(self, HookContext(caller, target, revertOnFailure, extraData));
  }

  function validateProgram(Hook memory self, EntityId programmed, ProgramId program) internal view {
    IProgramValidator.ProgramData memory data =
      IProgramValidator.ProgramData({ programmed: programmed, program: program });

    _staticcall(self, abi.encodeCall(IProgramValidator.validateProgram, (self.ctx, data)));
  }

  function onAttachProgram(Hook memory self) internal {
    _call(self, abi.encodeCall(IAttachProgram.onAttachProgram, (self.ctx)));
  }

  function onDetachProgram(Hook memory self) internal {
    _call(self, abi.encodeCall(IDetachProgram.onDetachProgram, (self.ctx)));
  }

  function onTransfer(Hook memory self, SlotData[] memory deposits, SlotData[] memory withdrawals) internal {
    ITransfer.TransferData memory transfer = ITransfer.TransferData({ deposits: deposits, withdrawals: withdrawals });

    _call(self, abi.encodeCall(ITransfer.onTransfer, (self.ctx, transfer)));
  }

  function onHit(Hook memory self, EntityId target, EntityId tool, uint128 damage) internal {
    IHit.HitData memory hit = IHit.HitData({ target: target, tool: tool, damage: damage });

    _call(self, abi.encodeCall(IHit.onHit, (self.ctx, hit)));
  }

  function onEnergize(Hook memory self, uint128 amount) internal {
    IEnergize.EnergizeData memory energize = IEnergize.EnergizeData({ amount: amount });

    _call(self, abi.encodeCall(IEnergize.onEnergize, (self.ctx, energize)));
  }

  function onAddFragment(Hook memory self, EntityId added) internal {
    IAddFragment.AddFragmentData memory fragment = IAddFragment.AddFragmentData({ added: added });

    _call(self, abi.encodeCall(IAddFragment.onAddFragment, (self.ctx, fragment)));
  }

  function onRemoveFragment(Hook memory self, EntityId removed) internal {
    IRemoveFragment.RemoveFragmentData memory fragment = IRemoveFragment.RemoveFragmentData({ removed: removed });

    _call(self, abi.encodeCall(IRemoveFragment.onRemoveFragment, (self.ctx, fragment)));
  }

  function onMine(Hook memory self, EntityId entity, EntityId tool, ObjectType objectType, Vec3 coord) internal {
    IMine.MineData memory mine = IMine.MineData({ entity: entity, tool: tool, objectType: objectType, coord: coord });

    _call(self, abi.encodeCall(IMine.onMine, (self.ctx, mine)));
  }

  function onBuild(
    Hook memory self,
    EntityId entity,
    Vec3 coord,
    ObjectType slotType,
    ObjectType objectType,
    Orientation orientation
  ) internal {
    IBuild.BuildData memory build = IBuild.BuildData({
      entity: entity,
      coord: coord,
      slotType: slotType,
      objectType: objectType,
      orientation: orientation
    });

    _call(self, abi.encodeCall(IBuild.onBuild, (self.ctx, build)));
  }

  function onSpawn(Hook memory self, uint128 energy, Vec3 coord) internal {
    ISpawn.SpawnData memory spawn = ISpawn.SpawnData({ energy: energy, coord: coord });

    _call(self, abi.encodeCall(ISpawn.onSpawn, (self.ctx, spawn)));
  }

  function onSleep(Hook memory self) internal {
    _call(self, abi.encodeCall(ISleep.onSleep, (self.ctx)));
  }

  function onWakeup(Hook memory self) internal {
    _call(self, abi.encodeCall(IWakeup.onWakeup, (self.ctx)));
  }

  function onOpen(Hook memory self) internal {
    _call(self, abi.encodeCall(IOpen.onOpen, (self.ctx)));
  }

  function onClose(Hook memory self) internal {
    _call(self, abi.encodeCall(IClose.onClose, (self.ctx)));
  }

  /**
   * @dev Private helper that executes hooks with proper gas handling based on revertOnFailure
   * @param self The Hook containing program and context
   * @param hookData The calldata to use for the program call
   */
  function _call(Hook memory self, bytes memory hookData) private {
    address programAddress = self.program.getAddress();
    if (programAddress == address(0)) {
      return;
    }

    bytes memory data = _hookWorldContext(hookData);
    bool revertOnFailure = self.ctx.revertOnFailure;
    uint256 gas = revertOnFailure ? gasleft() : SAFE_PROGRAM_GAS;
    (bool success, bytes memory returnData) = programAddress.call{ gas: gas }(data);

    if (revertOnFailure && !success) revertWithBytes(returnData);
  }

  /**
   * @dev Private helper that executes view/pure hooks with proper gas handling based on revertOnFailure
   * @param self The Hook containing program and context
   * @param hookData The calldata to use for the program staticcall
   */
  function _staticcall(Hook memory self, bytes memory hookData) private view {
    address programAddress = self.program.getAddress();
    if (programAddress == address(0)) {
      return;
    }

    bytes memory data = _hookWorldContext(hookData);
    bool revertOnFailure = self.ctx.revertOnFailure;
    uint256 gas = revertOnFailure ? gasleft() : SAFE_PROGRAM_GAS;
    (bool success, bytes memory returnData) = programAddress.staticcall{ gas: gas }(data);

    if (revertOnFailure && !success) revertWithBytes(returnData);
  }

  function _hookWorldContext(bytes memory hookData) private pure returns (bytes memory) {
    return WorldContextProviderLib.appendContext({ callData: hookData, msgSender: address(0), msgValue: 0 });
  }
}

using HooksLib for Hook global;
