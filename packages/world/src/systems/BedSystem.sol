// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BedPlayer } from "../codegen/tables/BedPlayer.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { MAX_RESPAWN_HALF_WIDTH, PLAYER_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";
import { checkWorldStatus } from "../Utils.sol";

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

import { EntityId } from "../EntityId.sol";
import { ISleepHook, IWakeupHook } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";

contract BedSystem is System {
  function sleep(EntityId caller, EntityId bed, bytes calldata extraData) public {
    caller.activate();

    (Vec3 callerCoord,) = caller.requireConnected(bed);

    require(bed._getObjectType() == ObjectTypes.Bed, "Not a bed");

    bed = bed.baseEntityId();

    require(!BedPlayer._getPlayerEntityId(bed)._exists(), "Bed full");

    Vec3 bedCoord = bed._getPosition();

    BedLib.addPlayerToBed(caller, bed, bedCoord);

    PlayerUtils.removePlayerFromGrid(caller, callerCoord);

    bytes memory onSleep = abi.encodeCall(ISleepHook.onSleep, (caller, bed, extraData));
    bed._getProgram().callOrRevert(onSleep);

    notify(caller, SleepNotification({ bed: bed, bedCoord: bedCoord }));
  }

  // TODO: for now this only supports players, as players are the only entities that can sleep
  function wakeup(EntityId caller, Vec3 spawnCoord, bytes calldata extraData) public {
    checkWorldStatus();

    caller._validateCaller();

    (EntityId bed, Vec3 bedCoord) = BedLib.getPlayerBed(caller);
    require(bedCoord.inSurroundingCube(spawnCoord, MAX_RESPAWN_HALF_WIDTH), "Bed is too far away");

    EnergyData memory playerData = BedLib.removePlayerFromBed(caller, bed, bedCoord);
    if (playerData.energy == 0) {
      // Player died while sleeping

      (EntityId drop, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(spawnCoord);
      require(objectType.isPassThrough(), "Cannot drop items on a non-passable block");

      InventoryUtils.transferAll(caller, drop);

      return;
    }

    require(!MoveLib._gravityApplies(spawnCoord), "Cannot spawn player here as gravity applies");

    PlayerUtils.addPlayerToGrid(caller, spawnCoord);

    bytes memory onWakeup = abi.encodeCall(IWakeupHook.onWakeup, (caller, bed, extraData));
    bed._getProgram().callOrRevert(onWakeup);

    notify(caller, WakeupNotification({ bed: bed, bedCoord: bedCoord }));
  }

  function removeDeadPlayerFromBed(EntityId player, Vec3 dropCoord) public {
    checkWorldStatus();

    (EntityId bed, Vec3 bedCoord) = BedLib.getPlayerBed(player);

    require(bedCoord.inSurroundingCube(dropCoord, MAX_RESPAWN_HALF_WIDTH), "Drop location is too far from bed");

    (EntityId drop, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(dropCoord);
    require(objectType.isPassThrough(), "Cannot drop items on a non-passable block");

    EnergyData memory playerData = BedLib.removePlayerFromBed(player, bed, bedCoord);
    require(playerData.energy == 0, "Player is not dead");

    InventoryUtils.transferAll(player, drop);
  }
}

// To avoid reaching bytecode size limit
library BedLib {
  function addPlayerToBed(EntityId caller, EntityId bed, Vec3 bedCoord) public {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    require(forceField._exists(), "Bed is not inside a forcefield");

    uint128 depletedTime = increaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);
    PlayerBed._setBedEntityId(caller, bed);
    BedPlayer._set(bed, caller, depletedTime);
  }

  function removePlayerFromBed(EntityId caller, EntityId bed, Vec3 bedCoord) public returns (EnergyData memory) {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    uint128 depletedTime = decreaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);

    EnergyData memory playerData = updateSleepingPlayerEnergy(caller, bed, depletedTime, bedCoord);

    PlayerUtils.removePlayerFromBed(caller, bed);
    return playerData;
  }

  function getPlayerBed(EntityId player) public view returns (EntityId, Vec3) {
    EntityId bed = PlayerBed._getBedEntityId(player);
    require(bed._exists(), "Player is not in a bed");

    Vec3 bedCoord = bed._getPosition();
    return (bed, bedCoord);
  }
}
