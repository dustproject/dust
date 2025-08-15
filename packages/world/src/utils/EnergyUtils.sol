// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BedPlayer } from "../codegen/tables/BedPlayer.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { PlayerBed } from "../codegen/tables/PlayerBed.sol";

import { Fragment } from "../codegen/tables/Fragment.sol";
import { Machine, MachineData } from "../codegen/tables/Machine.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { LocalEnergyPool } from "../utils/Vec3Storage.sol";

import { PLAYER_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import { Vec3 } from "../types/Vec3.sol";

function getLatestEnergyData(EntityId entityId) view returns (EnergyData memory, uint128, uint128) {
  EnergyData memory energyData = Energy._get(entityId);
  uint128 timeSinceLastUpdate = uint128(block.timestamp) - energyData.lastUpdatedTime;

  if (timeSinceLastUpdate == 0) {
    return (energyData, 0, 0);
  }

  energyData.lastUpdatedTime = uint128(block.timestamp);

  if (energyData.energy == 0) {
    return (energyData, 0, timeSinceLastUpdate);
  }

  uint128 energyDrained = timeSinceLastUpdate * energyData.drainRate;
  uint128 depletedTime = 0;

  // Update accumulated depleted time if it ran out of energy on this update
  if (energyDrained >= energyData.energy) {
    // Calculate when it ran out by determining how much time it took to drain the energy
    uint128 timeToDeplete = energyData.energy / energyData.drainRate;
    // Add the remaining time after depletion to the accumulated depleted time
    depletedTime = timeSinceLastUpdate - timeToDeplete;
    energyDrained = energyData.energy;
    energyData.energy = 0;
  } else {
    energyData.energy -= energyDrained;
  }

  return (energyData, energyDrained, depletedTime);
}

function updateMachineEnergy(EntityId machine) returns (EnergyData memory) {
  if (!machine._exists()) {
    return EnergyData(0, 0, 0);
  }

  (EnergyData memory energyData, uint128 energyDrained, uint128 depletedTime) = getLatestEnergyData(machine);

  if (energyDrained > 0) {
    addEnergyToLocalPool(machine._getPosition(), energyDrained);
  }

  uint128 currentDepletedTime = Machine._getDepletedTime(machine);
  if (depletedTime > 0) {
    currentDepletedTime += depletedTime;
    Machine._setDepletedTime(machine, currentDepletedTime);
  }

  Energy._set(machine, energyData);
  return energyData;
}

/// @dev Used within systems before performing an action
function updatePlayerEnergy(EntityId player) returns (EnergyData memory) {
  require(!PlayerBed._getBedEntityId(player).exists(), "Player is sleeping");

  (EnergyData memory energyData, uint128 energyDrained,) = getLatestEnergyData(player);
  Vec3 coord = player._getPosition();

  if (energyDrained > 0) {
    addEnergyToLocalPool(coord, energyDrained);
  }

  if (energyData.energy == 0) {
    PlayerUtils.killPlayer(player, coord);
  }

  Energy._set(player, energyData);
  return energyData;
}

function updateEnergy(EntityId entity) returns (EnergyData memory) {
  ObjectType objectType = entity._getObjectType();
  if (objectType == ObjectTypes.Player) {
    return updatePlayerEnergy(entity);
  } else if (objectType.isMachine()) {
    return updateMachineEnergy(entity);
  }

  revert("Can only update energy for players or machines");
}

function decreaseMachineEnergy(EntityId machine, uint128 amount) returns (uint128) {
  require(amount > 0, "Cannot decrease 0 energy");
  uint128 current = Energy._getEnergy(machine);
  require(current >= amount, "Not enough energy");
  uint128 newEnergy = current - amount;
  Energy._setEnergy(machine, newEnergy);

  return newEnergy;
}

function decreasePlayerEnergy(EntityId player, Vec3 playerCoord, uint128 amount) returns (uint128) {
  require(amount > 0, "Cannot decrease 0 energy");
  uint128 current = Energy._getEnergy(player);
  require(current >= amount, "Not enough energy");

  uint128 newEnergy = current - amount;
  Energy._setEnergy(player, newEnergy);

  if (newEnergy == 0) {
    PlayerUtils.killPlayer(player, playerCoord);
  }

  return newEnergy;
}

function increaseFragmentDrainRate(EntityId forceField, EntityId fragment, uint128 amount) {
  if (forceField._exists()) {
    EnergyData memory machineData = updateMachineEnergy(forceField);
    Energy._setDrainRate(forceField, machineData.drainRate + amount);
  }
  Fragment._setExtraDrainRate(fragment, Fragment._getExtraDrainRate(fragment) + amount);
}

function decreaseFragmentDrainRate(EntityId forceField, EntityId fragment, uint128 amount) {
  if (forceField._exists()) {
    EnergyData memory machineData = updateMachineEnergy(forceField);
    Energy._setDrainRate(forceField, machineData.drainRate - amount);
  }
  Fragment._setExtraDrainRate(fragment, Fragment._getExtraDrainRate(fragment) - amount);
}

function addEnergyToLocalPool(Vec3 coord, uint128 numToAdd) returns (uint128) {
  Vec3 shardCoord = coord.toLocalEnergyPoolShardCoord();
  uint128 newLocalEnergy = LocalEnergyPool._get(shardCoord) + numToAdd;
  LocalEnergyPool._set(shardCoord, newLocalEnergy);
  return newLocalEnergy;
}

function transferEnergyToPool(EntityId entityId, uint128 amount) returns (uint128) {
  Vec3 coord = entityId._getPosition();
  ObjectType objectType = entityId._getObjectType();

  uint128 newEntityEnergy;
  if (objectType == ObjectTypes.Player) {
    newEntityEnergy = decreasePlayerEnergy(entityId, coord, amount);
  } else {
    if (!objectType.isMachine()) {
      (entityId,) = ForceFieldUtils.getForceField(coord);
    }
    newEntityEnergy = decreaseMachineEnergy(entityId, amount);
  }

  addEnergyToLocalPool(coord, amount);

  return newEntityEnergy;
}

function removeEnergyFromLocalPool(Vec3 coord, uint128 numToRemove) returns (uint128) {
  Vec3 shardCoord = coord.toLocalEnergyPoolShardCoord();
  uint128 localEnergy = LocalEnergyPool._get(shardCoord);
  require(localEnergy >= numToRemove, "Not enough energy in local pool");

  uint128 newLocalEnergy = localEnergy - numToRemove;
  LocalEnergyPool._set(shardCoord, newLocalEnergy);
  return newLocalEnergy;
}

// NOTE: assumes updateSleepingPlayerEnergy is always called after the forcefield is updated
function updateSleepingPlayerEnergy(EntityId player, EntityId bed, EntityId forceField, Vec3 bedCoord)
  returns (EnergyData memory)
{
  uint128 timeWithoutEnergy = 0;
  uint128 currentDepletedTime = 0;

  EnergyData memory playerEnergyData = Energy._get(player);
  MachineData memory machineData = Machine._get(forceField);

  // If forcefield was destroyed, entityId should be 0
  if (forceField._exists()) {
    currentDepletedTime = machineData.depletedTime;
    uint128 lastDepletedTime = BedPlayer._getLastDepletedTime(bed);
    require(
      lastDepletedTime <= currentDepletedTime,
      "Invalid last depleted time for bed, should be less than or equal to current depleted time"
    );
    timeWithoutEnergy = currentDepletedTime - lastDepletedTime;
  } else {
    // Conservatively assume that the player has been sleeping without energy since the last time they were updated
    currentDepletedTime = 0;
    timeWithoutEnergy = uint128(block.timestamp) - playerEnergyData.lastUpdatedTime;
  }

  if (timeWithoutEnergy > 0) {
    uint128 totalEnergyDepleted = timeWithoutEnergy * PLAYER_ENERGY_DRAIN_RATE;
    // No need to call updatePlayerEnergy as drain rate is 0 if sleeping
    uint128 transferredToPool =
      playerEnergyData.energy < totalEnergyDepleted ? playerEnergyData.energy : totalEnergyDepleted;

    playerEnergyData.energy -= transferredToPool;
    addEnergyToLocalPool(bedCoord, transferredToPool);
  }

  // Set last updated so next time updatePlayerEnergy is called it will drain from here
  playerEnergyData.lastUpdatedTime = uint128(block.timestamp);
  Energy._set(player, playerEnergyData);
  BedPlayer._setLastDepletedTime(bed, currentDepletedTime);

  return playerEnergyData;
}

function burnToolEnergy(ObjectType toolType, Vec3 coord) {
  uint16 numPlanks = toolType.getPlankAmount();
  addEnergyToLocalPool(coord, numPlanks * ObjectPhysics._getMass(ObjectTypes.AnyPlank));
}
