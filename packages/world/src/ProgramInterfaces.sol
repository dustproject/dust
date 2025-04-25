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
interface IProgramValidator {
  function validateProgram(
    EntityId caller,
    EntityId target,
    EntityId programmed,
    ProgramId program,
    bytes memory extraData
  ) external view;
}

interface IAttachProgramHook {
  function onAttachProgram(EntityId caller, EntityId target, bytes memory extraData) external;
}

interface IDetachProgramHook {
  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external;
}

interface ITransferHook {
  function onTransfer(
    EntityId caller,
    EntityId target,
    SlotData[] memory deposits,
    SlotData[] memory withdrawals,
    bytes memory extraData
  ) external;
}

interface IHitHook {
  function onHit(EntityId caller, EntityId target, uint128 damage, bytes memory extraData) external;
}

interface IFuelHook {
  function onFuel(EntityId caller, EntityId target, uint16 fuelAmount, bytes memory extraData) external;
}

interface IAddFragmentHook {
  function onAddFragment(EntityId caller, EntityId target, EntityId added, bytes memory extraData) external;
}

interface IRemoveFragmentHook {
  function onRemoveFragment(EntityId caller, EntityId target, EntityId removed, bytes memory extraData) external;
}

interface IBuildHook {
  function onBuild(EntityId caller, EntityId target, ObjectType objectType, Vec3 coord, bytes memory extraData)
    external;
}

interface IMineHook {
  function onMine(EntityId caller, EntityId target, ObjectType objectType, Vec3 coord, bytes memory extraData) external;
}

interface ISpawnHook {
  function onSpawn(EntityId caller, EntityId target, uint128 spawnEnergy, bytes memory extraData) external;
}

interface ISleepHook {
  function onSleep(EntityId caller, EntityId target, bytes memory extraData) external;
}

interface IWakeupHook {
  function onWakeup(EntityId caller, EntityId target, bytes memory extraData) external;
}

interface IOpenHook {
  function onOpen(EntityId caller, EntityId target, bytes memory extraData) external;
}

interface ICloseHook {
  function onClose(EntityId caller, EntityId target, bytes memory extraData) external;
}
