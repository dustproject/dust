// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Machine } from "../codegen/tables/Machine.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Orientation } from "../codegen/tables/Orientation.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { Position } from "../utils/Vec3Storage.sol";
import { ResourcePosition } from "../utils/Vec3Storage.sol";

import {
  addEnergyToLocalPool,
  decreaseFragmentDrainRate,
  decreasePlayerEnergy,
  transferEnergyToPool,
  updateMachineEnergy,
  updatePlayerEnergy,
  updateSleepingPlayerEnergy
} from "../utils/EnergyUtils.sol";

import {
  createEntityAt,
  getEntityAt,
  getMovableEntityAt,
  getObjectTypeAt,
  getOrCreateEntityAt
} from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils, ToolData } from "../utils/InventoryUtils.sol";
import { DeathNotification, MineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { MINE_ENERGY_COST, PLAYER_ENERGY_DRAIN_RATE, SAFE_PROGRAM_GAS } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectAmount, ObjectType } from "../ObjectType.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

import { NatureLib } from "../NatureLib.sol";
import { ObjectTypes } from "../ObjectType.sol";

import { ProgramId } from "../ProgramId.sol";
import { IDetachProgramHook, IMineHook } from "../ProgramInterfaces.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract MineSystem is System {
  function getRandomOreType(Vec3 coord) external view returns (ObjectType) {
    return RandomResourceLib._getRandomOre(coord);
  }

  function mine(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) external returns (EntityId) {
    return _mine(caller, coord, toolSlot, extraData);
  }

  function mine(EntityId caller, Vec3 coord, bytes calldata extraData) external returns (EntityId) {
    return _mine(caller, coord, type(uint16).max, extraData);
  }

  function mineUntilDestroyed(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) public {
    uint128 massLeft = 0;
    do {
      // TODO: factor out the mass reduction logic so it's cheaper to call
      EntityId entityId = _mine(caller, coord, toolSlot, extraData);
      massLeft = Mass._getMass(entityId);
    } while (massLeft > 0);
  }

  function mineUntilDestroyed(EntityId caller, Vec3 coord, bytes calldata extraData) public {
    uint128 massLeft = 0;
    do {
      // TODO: factor out the mass reduction logic so it's cheaper to call
      EntityId entityId = _mine(caller, coord, type(uint16).max, extraData);
      massLeft = Mass._getMass(entityId);
    } while (massLeft > 0);
  }

  function _mine(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) internal returns (EntityId) {
    caller.activate();
    (Vec3 callerCoord,) = caller.requireConnected(coord);

    (EntityId mined, ObjectType minedType) = getOrCreateEntityAt(coord);
    require(minedType.isMineable(), "Object is not mineable");

    mined = mined.baseEntityId();
    Vec3 baseCoord = Position._get(mined);

    if (minedType.isMachine()) {
      (EnergyData memory machineData,) = updateMachineEnergy(mined);
      require(machineData.energy == 0, "Cannot mine a machine that has energy");
    } else if (minedType == ObjectTypes.UnrevealedOre) {
      minedType = RandomResourceLib._collapseRandomOre(mined, coord);
    }

    (uint128 finalMass, bool canMine) = _processMassReduction(caller, callerCoord, toolSlot, mined);
    if (!canMine) {
      return mined;
    }

    if (finalMass != 0) {
      Mass._setMass(mined, finalMass);
      MineLib._requireMinesAllowed(caller, minedType, coord, extraData);
      return mined;
    }

    // The block was fully mined
    Mass._deleteRecord(mined);

    _handleGrowable(caller, baseCoord);

    _removeBlock(mined, minedType, baseCoord);
    _removeRelativeBlocks(mined, minedType, baseCoord);
    _handleDrop(caller, mined, minedType, baseCoord);

    _destroyEntity(caller, mined, minedType, baseCoord);

    MineLib._requireMinesAllowed(caller, minedType, coord, extraData);

    notify(caller, MineNotification({ mineEntityId: mined, mineCoord: coord, mineObjectType: minedType }));

    return mined;
  }

  function _handleGrowable(EntityId caller, Vec3 coord) internal {
    // Remove growables on top of this block
    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    // If above is growable, the entity must exist as there are not growables in the base terrain
    (EntityId above, ObjectType aboveType) = getEntityAt(aboveCoord);
    if (aboveType.isGrowable()) {
      if (!above.exists()) {
        above = createEntityAt(aboveCoord, aboveType);
      }
      _removeGrowable(above, aboveType, aboveCoord);
      _handleDrop(caller, above, aboveType, aboveCoord);
    }
  }

  function _removeGrowable(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    EntityObjectType._set(entityId, ObjectTypes.Air);
    require(SeedGrowth._getFullyGrownAt(entityId) > block.timestamp, "Cannot mine fully grown seed");
    addEnergyToLocalPool(coord, ObjectTypeMetadata._getEnergy(objectType));
  }

  function _removeBlock(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    // If object being mined is seed, no need to check above entities
    if (objectType.isGrowable()) {
      _removeGrowable(entityId, objectType, coord);
      return;
    }

    EntityObjectType._set(entityId, ObjectTypes.Air);

    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    EntityId above = getMovableEntityAt(aboveCoord);
    // Note: currently it is not possible for the above player to not be the base entity,
    // but if we add other types of movable entities we should check that it is a base entity
    if (above.exists()) {
      MoveLib.runGravity(above, aboveCoord);
    }
  }

  function _removeRelativeBlocks(EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    // First coord will be the base coord, the rest is relative schema coords
    Vec3[] memory coords = minedType.getRelativeCoords(baseCoord, Orientation._get(mined));

    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      (EntityId relative, ObjectType relativeType) = getEntityAt(relativeCoord);
      BaseEntity._deleteRecord(relative);

      _removeBlock(relative, relativeType, relativeCoord);
    }
  }

  function _destroyEntity(EntityId caller, EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    if (minedType == ObjectTypes.Bed) {
      MineLib._mineBed(mined, baseCoord);
    } else if (minedType == ObjectTypes.ForceField) {
      Machine._deleteRecord(mined);
    }

    // Detach program if it exists
    ProgramId program = mined.getProgram();
    if (program.exists()) {
      bytes memory onDetachProgram = abi.encodeCall(IDetachProgramHook.onDetachProgram, (caller, mined, ""));
      program.call({ gas: SAFE_PROGRAM_GAS, hook: onDetachProgram });

      EntityProgram._deleteRecord(mined);
    }
  }

  function _handleDrop(EntityId caller, EntityId mined, ObjectType minedType, Vec3 coord) internal {
    // Get drops with all metadata for resource tracking
    ObjectAmount[] memory result = RandomResourceLib._getMineDrops(mined, minedType, coord);

    for (uint256 i = 0; i < result.length; i++) {
      (ObjectType dropType, uint16 amount) = (result[i].objectType, uint16(result[i].amount));
      InventoryUtils.addObject(caller, dropType, amount);

      // Track mined resource count for seeds
      // TODO: could make it more general like .isCappedResource() or something
      if (dropType.isGrowable()) {
        ResourceCount._set(dropType, ResourceCount._get(dropType) + amount);
      }
    }
  }

  // TODO: this is ugly, but doing this to avoid stack too deep errors. We should refactor later.
  function _processMassReduction(EntityId caller, Vec3 callerCoord, uint16 toolSlot, EntityId mined)
    internal
    returns (uint128, bool)
  {
    ToolData memory toolData = InventoryUtils.getToolData(caller, toolSlot);
    (uint128 finalMass, uint128 toolMassReduction, uint128 energyReduction) = _getMassReduction(toolData, mined);

    if (energyReduction > 0) {
      // If player died, return early
      (uint128 callerEnergy,) = transferEnergyToPool(caller, energyReduction);
      if (callerEnergy == 0) {
        return (finalMass, false);
      }
    }

    // Apply tool usage after decreasing player energy so we make sure the player is alive
    toolData.applyMassReduction(callerCoord, toolMassReduction);
    return (finalMass, true);
  }

  function _getMassReduction(ToolData memory toolData, EntityId mined)
    internal
    view
    returns (uint128, uint128, uint128)
  {
    uint128 massLeft = Mass._getMass(mined);
    if (massLeft == 0) {
      return (0, 0, 0);
    }

    uint128 toolMassReduction = toolData.getMassReduction(massLeft);

    // if tool mass reduction is not enough, consume energy from player up to mine energy cost
    uint128 energyReduction = 0;
    if (toolMassReduction < massLeft) {
      uint128 remaining = massLeft - toolMassReduction;
      energyReduction = MINE_ENERGY_COST <= remaining ? MINE_ENERGY_COST : remaining;
      massLeft -= energyReduction;
    }

    uint128 finalMass = massLeft - toolMassReduction;

    return (finalMass, toolMassReduction, energyReduction);
  }
}

library MineLib {
  function _mineBed(EntityId bed, Vec3 bedCoord) public {
    // If there is a player sleeping in the mined bed, kill them
    EntityId sleepingPlayerId = BedPlayer._getPlayerEntityId(bed);
    if (!sleepingPlayerId.exists()) {
      return;
    }

    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    uint128 depletedTime = decreaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);
    EnergyData memory playerData = updateSleepingPlayerEnergy(sleepingPlayerId, bed, depletedTime, bedCoord);
    PlayerUtils.removePlayerFromBed(sleepingPlayerId, bed);

    // Kill the player
    // The player is not on the grid so no need to call killPlayer
    Energy._setEnergy(sleepingPlayerId, 0);
    addEnergyToLocalPool(bedCoord, playerData.energy);
    notify(sleepingPlayerId, DeathNotification({ deathCoord: bedCoord }));
  }

  function _requireMinesAllowed(EntityId caller, ObjectType objectType, Vec3 coord, bytes calldata extraData) public {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);
    if (!forceField.exists()) {
      return;
    }

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    if (machineData.energy == 0) {
      return;
    }

    // We know fragment is active because its forcefield exists, so we can use its program
    ProgramId program = fragment.getProgram();
    if (!program.exists()) {
      program = forceField.getProgram();
      if (!program.exists()) {
        return;
      }
    }

    bytes memory onMine = abi.encodeCall(IMineHook.onMine, (caller, forceField, objectType, coord, extraData));

    program.callOrRevert(onMine);
  }
}

library RandomResourceLib {
  function _getMineDrops(EntityId mined, ObjectType objectType, Vec3 coord) public view returns (ObjectAmount[] memory) {
    return NatureLib.getMineDrops(mined, objectType, coord);
  }

  function _getRandomOre(Vec3 coord) public view returns (ObjectType) {
    return NatureLib.getRandomOre(coord);
  }

  function _collapseRandomOre(EntityId entityId, Vec3 coord) public returns (ObjectType) {
    ObjectType ore = _getRandomOre(coord);

    // We use UnrevealedOre as we want to track for all ores
    _trackPosition(coord, ObjectTypes.UnrevealedOre);

    // Set mined resource count for the specific ore
    ResourceCount._set(ore, ResourceCount._get(ore) + 1);
    EntityObjectType._set(entityId, ore);
    Mass._setMass(entityId, ObjectTypeMetadata._getMass(ore));

    return ore;
  }

  function _trackPosition(Vec3 coord, ObjectType objectType) public {
    // Track resource position for mining/respawning
    uint256 count = ResourceCount._get(objectType);
    ResourcePosition._set(objectType, count, coord);
    ResourceCount._set(objectType, count + 1);
  }
}
