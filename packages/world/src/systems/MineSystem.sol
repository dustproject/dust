// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { EntityOrientation } from "../codegen/tables/EntityOrientation.sol";
import { Machine } from "../codegen/tables/Machine.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { Math } from "../utils/Math.sol";
import { ResourcePosition } from "../utils/Vec3Storage.sol";

import {
  addEnergyToLocalPool,
  decreaseFragmentDrainRate,
  transferEnergyToPool,
  updateMachineEnergy,
  updatePlayerEnergy,
  updateSleepingPlayerEnergy
} from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils, ToolData } from "../utils/InventoryUtils.sol";
import { DeathNotification, MineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import {
  DEFAULT_MINE_ENERGY_COST,
  DEFAULT_ORE_TOOL_MULTIPLIER,
  DEFAULT_WOODEN_TOOL_MULTIPLIER,
  PLAYER_ENERGY_DRAIN_RATE,
  SAFE_PROGRAM_GAS,
  SPECIALIZED_ORE_TOOL_MULTIPLIER,
  SPECIALIZED_WOODEN_TOOL_MULTIPLIER,
  TOOL_MINE_ENERGY_COST
} from "../Constants.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectAmount, ObjectType } from "../ObjectType.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

import { NatureLib } from "../NatureLib.sol";
import { ObjectTypes } from "../ObjectType.sol";

import { ProgramId } from "../ProgramId.sol";
import { IDetachProgramHook, IMineHook } from "../ProgramInterfaces.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract MineSystem is System {
  using Math for *;

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
    } while (
      massLeft > 0 && Energy._getEnergy(caller) > 0 && InventoryUtils.getToolData(caller, toolSlot).massLeft > 0
    );
  }

  function mineUntilDestroyed(EntityId caller, Vec3 coord, bytes calldata extraData) public {
    uint128 massLeft = 0;
    do {
      // TODO: factor out the mass reduction logic so it's cheaper to call
      EntityId entityId = _mine(caller, coord, type(uint16).max, extraData);
      massLeft = Mass._getMass(entityId);
    } while (massLeft > 0 && Energy._getEnergy(caller) > 0);
  }

  function _mine(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) internal returns (EntityId) {
    uint128 callerEnergy = caller.activate().energy;
    caller.requireConnected(coord);

    (EntityId mined, ObjectType minedType) = EntityUtils.getOrCreateBlockAt(coord);
    require(minedType.isBlock(), "Object is not mineable");

    mined = mined.baseEntityId();
    Vec3 baseCoord = mined.getPosition();

    if (minedType.isMachine()) {
      (EnergyData memory machineData,) = updateMachineEnergy(mined);
      require(machineData.energy == 0, "Cannot mine a machine that has energy");
    } else if (minedType == ObjectTypes.UnrevealedOre) {
      minedType = RandomResourceLib._collapseRandomOre(mined, coord);
    }

    (uint128 massLeft, bool canMine) =
      MineLib._applyMassReduction(caller, callerEnergy, toolSlot, minedType, Mass._getMass(mined));

    if (!canMine) {
      // Player died, return early
      return mined;
    }

    if (massLeft == 0) {
      // The block was fully mined
      Mass._deleteRecord(mined);

      _handleGrowable(caller, baseCoord);
      _removeBlock(mined, minedType, baseCoord);
      _removeRelativeBlocks(mined, minedType, baseCoord);
      _handleDrop(caller, mined, minedType, baseCoord);
      _destroyEntity(caller, mined, minedType, baseCoord);

      notify(caller, MineNotification({ mineEntityId: mined, mineCoord: coord, mineObjectType: minedType }));
    } else {
      Mass._setMass(mined, massLeft);
    }

    MineLib._requireMinesAllowed(caller, minedType, coord, extraData);

    return mined;
  }

  function _handleGrowable(EntityId caller, Vec3 coord) internal {
    // Remove growables on top of this block
    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    // If above is growable, the entity must exist as there are not growables in the base terrain
    (EntityId above, ObjectType aboveType) = EntityUtils.getBlockAt(aboveCoord);
    if (aboveType.isGrowable()) {
      if (!above.exists()) {
        EntityUtils.getOrCreateBlockAt(aboveCoord);
      }
      _removeGrowable(above, aboveType, aboveCoord);
      _handleDrop(caller, above, aboveType, aboveCoord);
    }
  }

  function _removeGrowable(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    EntityObjectType._set(entityId, ObjectTypes.Air);
    require(SeedGrowth._getFullyGrownAt(entityId) > block.timestamp, "Cannot mine fully grown seed");
    addEnergyToLocalPool(coord, objectType.getGrowableEnergy());
  }

  function _removeBlock(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    // If object being mined is seed, no need to check above entities
    if (objectType.isGrowable()) {
      _removeGrowable(entityId, objectType, coord);
      return;
    }

    EntityObjectType._set(entityId, ObjectTypes.Air);

    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    EntityId above = EntityUtils.getMovableEntityAt(aboveCoord);
    // Note: currently it is not possible for the above player to not be the base entity,
    // but if we add other types of movable entities we should check that it is a base entity
    if (above.exists()) {
      MoveLib.runGravity(aboveCoord);
    }
  }

  function _removeRelativeBlocks(EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    // First coord will be the base coord, the rest is relative schema coords
    Vec3[] memory coords = minedType.getRelativeCoords(baseCoord, EntityOrientation._get(mined));

    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      (EntityId relative, ObjectType relativeType) = EntityUtils.getBlockAt(relativeCoord);
      BaseEntity._deleteRecord(relative);

      _removeBlock(relative, relativeType, relativeCoord);
    }
  }

  function _destroyEntity(EntityId caller, EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    if (minedType == ObjectTypes.Bed) {
      MineLib._mineBed(mined, baseCoord);
    } else if (minedType.isMachine()) {
      Energy._deleteRecord(mined);
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
      (ObjectType dropType, uint128 amount) = (result[i].objectType, result[i].amount);

      if (amount == 0) {
        continue;
      }

      InventoryUtils.addObject(caller, dropType, amount);

      // Track mined resource count for seeds
      // TODO: could make it more general like .isCappedResource() or something
      if (dropType.isGrowable()) {
        ResourceCount._set(dropType, ResourceCount._get(dropType) + amount);
      }
    }
  }
}

library MineLib {
  function _applyMassReduction(
    EntityId caller,
    uint128 callerEnergy,
    uint16 toolSlot,
    ObjectType minedType,
    uint128 massLeft
  ) public returns (uint128, bool) {
    if (massLeft == 0) {
      return (0, true);
    }

    ToolData memory toolData = InventoryUtils.getToolData(caller, toolSlot);

    uint128 energyReduction = MineLib._getCallerEnergyReduction(toolData.toolType, callerEnergy, massLeft);

    if (energyReduction > 0) {
      // If player died, return early
      (callerEnergy,) = transferEnergyToPool(caller, energyReduction);
      if (callerEnergy == 0) {
        return (massLeft, false);
      }

      massLeft -= energyReduction;
    }

    uint128 toolMultiplier = _getToolMultiplier(toolData.toolType, minedType);

    uint128 massReduction = toolData.use(massLeft, toolMultiplier);

    massLeft -= massReduction;

    return (massLeft, true);
  }

  function _getCallerEnergyReduction(ObjectType toolType, uint128 currentEnergy, uint128 massLeft)
    internal
    pure
    returns (uint128)
  {
    // if tool mass reduction is not enough, consume energy from player up to mine energy cost
    uint128 maxEnergyCost = toolType.isNull() ? DEFAULT_MINE_ENERGY_COST : TOOL_MINE_ENERGY_COST;
    maxEnergyCost = Math.min(currentEnergy, maxEnergyCost);
    return Math.min(massLeft, maxEnergyCost);
  }

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

    // Bed entity should now be Air
    InventoryUtils.transferAll(sleepingPlayerId, bed);

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

  function _getToolMultiplier(ObjectType toolType, ObjectType minedType) public pure returns (uint128) {
    if (toolType.isNull()) {
      return 1;
    }

    bool isWoodenTool = toolType == ObjectTypes.WoodenAxe || toolType == ObjectTypes.WoodenPick;

    if ((toolType.isAxe() && minedType.hasAxeMultiplier()) || (toolType.isPick() && minedType.hasPickMultiplier())) {
      return isWoodenTool ? SPECIALIZED_WOODEN_TOOL_MULTIPLIER : SPECIALIZED_ORE_TOOL_MULTIPLIER;
    }

    return isWoodenTool ? DEFAULT_WOODEN_TOOL_MULTIPLIER : DEFAULT_ORE_TOOL_MULTIPLIER;
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
    Mass._setMass(entityId, ObjectPhysics._getMass(ore));

    return ore;
  }

  function _trackPosition(Vec3 coord, ObjectType objectType) public {
    // Track resource position for mining/respawning
    uint256 count = ResourceCount._get(objectType);
    ResourcePosition._set(objectType, count, coord);
    ResourceCount._set(objectType, count + 1);
  }
}
