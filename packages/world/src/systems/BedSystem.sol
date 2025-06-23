// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import {
  BedFull,
  BedNotInsideForceField,
  BedTooFarAway,
  CannotDropOnNonPassableBlock,
  CannotSpawnHereGravityApplies,
  DropLocationTooFarFromBed,
  NotABed,
  PlayerIsNotDead,
  PlayerNotInBed
} from "../Errors.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { Machine } from "../codegen/tables/Machine.sol";

import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { MAX_RESPAWN_HALF_WIDTH, PLAYER_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";
import { checkWorldStatus } from "../utils/WorldUtils.sol";

import {
  decreaseFragmentDrainRate,
  increaseFragmentDrainRate,
  updateMachineEnergy,
  updateSleepingPlayerEnergy
} from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { SleepNotification, WakeupNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { MoveLib } from "./libraries/MoveLib.sol";

import "../ProgramHooks.sol" as Hooks;
import { EntityId } from "../types/EntityId.sol";
import { Vec3 } from "../types/Vec3.sol";

contract BedSystem is System {
  function sleep(EntityId caller, EntityId bed, bytes calldata extraData) public {
    caller.activate();

    (Vec3 callerCoord,) = caller.requireConnected(bed);

    if (bed._getObjectType() != ObjectTypes.Bed) revert NotABed(bed._getObjectType());

    bed = bed.baseEntityId();

    if (BedPlayer._getPlayerEntityId(bed)._exists()) revert BedFull(bed);

    Vec3 bedCoord = bed._getPosition();

    BedLib.addPlayerToBed(caller, bed, bedCoord);

    PlayerUtils.removePlayerFromGrid(caller, callerCoord);

    bytes memory onSleep =
      abi.encodeCall(Hooks.ISleep.onSleep, (Hooks.SleepContext({ caller: caller, target: bed, extraData: extraData })));
    bed._getProgram().callOrRevert(onSleep);

    notify(caller, SleepNotification({ bed: bed, bedCoord: bedCoord }));
  }

  // TODO: for now this only supports players, as players are the only entities that can sleep
  function wakeup(EntityId caller, Vec3 spawnCoord, bytes calldata extraData) public {
    checkWorldStatus();

    caller._validateCaller();

    (EntityId bed, Vec3 bedCoord) = BedLib.getPlayerBed(caller);
    if (!bedCoord.inSurroundingCube(spawnCoord, MAX_RESPAWN_HALF_WIDTH)) revert BedTooFarAway(bedCoord, spawnCoord);

    EnergyData memory playerData = BedLib.removePlayerFromBed(caller, bed, bedCoord);
    if (playerData.energy == 0) {
      // Player died while sleeping

      (EntityId drop, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(spawnCoord);
      if (!objectType.isPassThrough()) revert CannotDropOnNonPassableBlock(objectType);

      InventoryUtils.transferAll(caller, drop);

      return;
    }

    if (MoveLib._gravityApplies(spawnCoord)) revert CannotSpawnHereGravityApplies(spawnCoord);

    PlayerUtils.addPlayerToGrid(caller, spawnCoord);

    bytes memory onWakeup = abi.encodeCall(
      Hooks.IWakeup.onWakeup, (Hooks.WakeupContext({ caller: caller, target: bed, extraData: extraData }))
    );
    bed._getProgram().callOrRevert(onWakeup);

    notify(caller, WakeupNotification({ bed: bed, bedCoord: bedCoord }));
  }

  function removeDeadPlayerFromBed(EntityId player, Vec3 dropCoord) public {
    checkWorldStatus();

    (EntityId bed, Vec3 bedCoord) = BedLib.getPlayerBed(player);

    if (!bedCoord.inSurroundingCube(dropCoord, MAX_RESPAWN_HALF_WIDTH)) {
      revert DropLocationTooFarFromBed(dropCoord, bedCoord);
    }

    (EntityId drop, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(dropCoord);
    if (!objectType.isPassThrough()) revert CannotDropOnNonPassableBlock(objectType);

    EnergyData memory playerData = BedLib.removePlayerFromBed(player, bed, bedCoord);
    if (playerData.energy != 0) revert PlayerIsNotDead(player);

    InventoryUtils.transferAll(player, drop);
  }
}

// To avoid reaching bytecode size limit
library BedLib {
  function addPlayerToBed(EntityId caller, EntityId bed, Vec3 bedCoord) public {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    if (!forceField._exists()) revert BedNotInsideForceField(bed);

    increaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);

    // Get the current depleted time from the machine
    uint128 depletedTime = forceField._exists() ? Machine._getDepletedTime(forceField) : 0;

    PlayerBed._setBedEntityId(caller, bed);
    BedPlayer._set(bed, caller, depletedTime);
  }

  function removePlayerFromBed(EntityId caller, EntityId bed, Vec3 bedCoord) public returns (EnergyData memory) {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    decreaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);

    EnergyData memory playerData = updateSleepingPlayerEnergy(caller, bed, forceField, bedCoord);

    PlayerUtils.removePlayerFromBed(caller, bed);
    return playerData;
  }

  function getPlayerBed(EntityId player) public view returns (EntityId, Vec3) {
    EntityId bed = PlayerBed._getBedEntityId(player);
    if (!bed._exists()) revert PlayerNotInBed(player);

    Vec3 bedCoord = bed._getPosition();
    return (bed, bedCoord);
  }
}
