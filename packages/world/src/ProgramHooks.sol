// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "./EntityId.sol";
import { ObjectType } from "./ObjectType.sol";
import { ProgramId } from "./ProgramId.sol";
import { Vec3 } from "./Vec3.sol";
import { SlotData } from "./utils/InventoryUtils.sol";

/**
 * Naming convention for all hooks/getters:
 * - caller is the entity that called the system and triggered the call to the program
 * - target is the entity for which the function is being called
 */

// Context structs for each hook type

struct ValidateProgramContext {
  EntityId caller;
  EntityId target;
  EntityId programmed;
  ProgramId program;
  bytes extraData;
}

struct AttachProgramContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

struct DetachProgramContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

struct TransferContext {
  EntityId caller;
  EntityId target;
  SlotData[] deposits;
  SlotData[] withdrawals;
  bytes extraData;
}

struct HitContext {
  EntityId caller;
  EntityId target;
  uint128 damage;
  bytes extraData;
}

struct FuelContext {
  EntityId caller;
  EntityId target;
  uint16 fuelAmount;
  bytes extraData;
}

struct AddFragmentContext {
  EntityId caller;
  EntityId target;
  EntityId added;
  bytes extraData;
}

struct RemoveFragmentContext {
  EntityId caller;
  EntityId target;
  EntityId removed;
  bytes extraData;
}

struct BuildContext {
  EntityId caller;
  EntityId target;
  ObjectType objectType;
  Vec3 coord;
  bytes extraData;
}

struct MineContext {
  EntityId caller;
  EntityId target;
  ObjectType objectType;
  Vec3 coord;
  bytes extraData;
}

struct SpawnContext {
  EntityId caller;
  EntityId target;
  uint128 spawnEnergy;
  bytes extraData;
}

struct SleepContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

struct WakeupContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

struct OpenContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

struct CloseContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

// Interfaces

interface IProgramValidator {
  function validateProgram(ValidateProgramContext calldata ctx) external view;
}

interface IAttachProgram {
  function onAttachProgram(AttachProgramContext calldata ctx) external;
}

interface IDetachProgram {
  function onDetachProgram(DetachProgramContext calldata ctx) external;
}

interface ITransfer {
  function onTransfer(TransferContext calldata ctx) external;
}

interface IHit {
  function onHit(HitContext calldata ctx) external;
}

interface IFuel {
  function onFuel(FuelContext calldata ctx) external;
}

interface IAddFragment {
  function onAddFragment(AddFragmentContext calldata ctx) external;
}

interface IRemoveFragment {
  function onRemoveFragment(RemoveFragmentContext calldata ctx) external;
}

interface IBuild {
  function onBuild(BuildContext calldata ctx) external;
}

interface IMine {
  function onMine(MineContext calldata ctx) external;
}

interface ISpawn {
  function onSpawn(SpawnContext calldata ctx) external;
}

interface ISleep {
  function onSleep(SleepContext calldata ctx) external;
}

interface IWakeup {
  function onWakeup(WakeupContext calldata ctx) external;
}

interface IOpen {
  function onOpen(OpenContext calldata ctx) external;
}

interface IClose {
  function onClose(CloseContext calldata ctx) external;
}
