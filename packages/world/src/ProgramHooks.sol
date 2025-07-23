// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "./types/EntityId.sol";
import { ObjectType } from "./types/ObjectType.sol";
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
  bool canRevert;
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
    ObjectType objectType;
    Vec3 coord;
    Orientation orientation;
  }

  function onBuild(HookContext calldata ctx, BuildData calldata build) external;
}

interface IMine {
  struct MineData {
    EntityId entity;
    ObjectType objectType;
    Vec3 coord;
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
