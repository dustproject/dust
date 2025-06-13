// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";
import { SafeCastLib } from "solady/utils/SafeCastLib.sol";

import { DisabledExtraDrops } from "../codegen/tables/DisabledExtraDrops.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { EntityFluidLevel } from "../codegen/tables/EntityFluidLevel.sol";
import { EntityOrientation } from "../codegen/tables/EntityOrientation.sol";
import { Machine } from "../codegen/tables/Machine.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { Math } from "../utils/Math.sol";
import { RandomLib } from "../utils/RandomLib.sol";
import { TreeLib } from "../utils/TreeLib.sol";
import { ResourcePosition } from "../utils/Vec3Storage.sol";

import {
  addEnergyToLocalPool,
  decreaseFragmentDrainRate,
  transferEnergyToPool,
  updateMachineEnergy,
  updateSleepingPlayerEnergy
} from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { DeathNotification, MineNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import {
  DEFAULT_MINE_ENERGY_COST,
  HIT_ACTION_MODIFIER,
  MAX_PICKUP_RADIUS,
  MINE_ACTION_MODIFIER,
  ORE_TOOL_BASE_MULTIPLIER,
  PLAYER_ENERGY_DRAIN_RATE,
  SAFE_PROGRAM_GAS,
  SPECIALIZATION_MULTIPLIER,
  TOOL_MINE_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../Constants.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectAmount, ObjectType } from "../types/ObjectType.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

import { NatureLib } from "../utils/NatureLib.sol";

import { ObjectTypes } from "../types/ObjectType.sol";
import { OreLib } from "../utils/OreLib.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3, vec3 } from "../types/Vec3.sol";

contract MineSystem is System {
  using SafeCastLib for *;
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
    } while (massLeft > 0 && Energy._getEnergy(caller) > 0 && ToolUtils.getToolData(caller, toolSlot).massLeft > 0);
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
    MineLib._requireReachable(coord);

    (EntityId mined, ObjectType minedType) = EntityUtils.getOrCreateBlockAt(coord);
    require(minedType.isBlock(), "Object is not mineable");

    mined = mined.baseEntityId();
    Vec3 baseCoord = mined._getPosition();

    minedType = _prepareBlock(mined, minedType, coord);

    (uint128 massLeft, bool canMine) =
      MineLib._applyMassReduction(caller, callerEnergy, toolSlot, minedType, Mass._getMass(mined));

    if (!canMine) {
      // Player died, return early
      return mined;
    }

    if (massLeft == 0) {
      // The block was fully mined
      Mass._deleteRecord(mined);

      // Handle landbound and growable blocks on top of the mined block
      _handleAbove(caller, baseCoord);

      // Remove the block and all relative blocks
      _removeBlock(mined, minedType, baseCoord);
      _removeRelativeBlocks(mined, minedType, baseCoord);

      // Handle drops
      _handleDrop(caller, mined, minedType, baseCoord);

      // It is fine to destroy the entity before requiring mines allowed,
      // as machines can't be destroyed if they have energy
      _cleanupEntity(caller, mined, minedType, baseCoord);

      notify(caller, MineNotification({ mineEntityId: mined, mineCoord: coord, mineObjectType: minedType }));
    } else {
      Mass._setMass(mined, massLeft);
    }

    MineLib._requireMinesAllowed(caller, minedType, coord, extraData);

    return mined;
  }

  function _prepareBlock(EntityId mined, ObjectType minedType, Vec3 coord) internal returns (ObjectType) {
    if (minedType.isMachine()) {
      (EnergyData memory machineData,) = updateMachineEnergy(mined);
      require(machineData.energy == 0, "Cannot mine a machine that has energy");
      return minedType;
    }

    if (minedType == ObjectTypes.UnrevealedOre) {
      return RandomResourceLib._collapseRandomOre(mined, coord);
    }

    if (minedType.isGrowable() && SeedGrowth._getFullyGrownAt(mined) <= block.timestamp) {
      // If the seed is fully grown, grow it
      return NatureLib.growSeed(coord, mined, minedType);
    }

    return minedType;
  }

  function _removeBlock(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    // If object being mined is seed, no need to check above entities
    if (objectType.isGrowable()) {
      _removeGrowable(entityId, objectType, coord);
      return;
    }

    ObjectType replacementType = EntityFluidLevel._get(entityId) > 0 ? ObjectTypes.Water : ObjectTypes.Air;
    EntityObjectType._set(entityId, replacementType);

    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    EntityId above = EntityUtils.getMovableEntityAt(aboveCoord);
    // Note: currently it is not possible for the above player to not be the base entity,
    // but if we add other types of movable entities we should check that it is a base entity
    if (above._exists()) {
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

  function _handleAbove(EntityId caller, Vec3 coord) internal {
    // Remove growables on top of this block
    Vec3 aboveCoord = coord + vec3(0, 1, 0);

    (EntityId above, ObjectType aboveType) = EntityUtils.getBlockAt(aboveCoord);
    bool isGrowable = aboveType.isGrowable();
    bool isLandbound = aboveType.isLandbound();

    if (!isGrowable && !isLandbound) {
      return;
    }

    if (!above._exists()) {
      EntityUtils.getOrCreateBlockAt(aboveCoord);
    }

    if (isGrowable && SeedGrowth._getFullyGrownAt(above) <= block.timestamp) {
      // If the seed is fully grown, grow it and don't remove it yet
      aboveType = NatureLib.growSeed(aboveCoord, above, aboveType);
    }

    if (isLandbound) {
      _removeBlock(above, aboveType, aboveCoord);
      _handleDrop(caller, above, aboveType, aboveCoord);
    }
  }

  function _removeGrowable(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    EntityObjectType._set(entityId, ObjectTypes.Air);
    addEnergyToLocalPool(coord, objectType.getGrowableEnergy());
  }

  function _cleanupEntity(EntityId caller, EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    if (minedType == ObjectTypes.Bed) {
      MineLib._mineBed(mined, baseCoord);
    } else if (minedType.isMachine()) {
      Energy._deleteRecord(mined);
      Machine._deleteRecord(mined);
    }

    // Detach program if it exists
    ProgramId program = mined._getProgram();
    if (program.exists()) {
      bytes memory onDetachProgram = abi.encodeCall(
        Hooks.IDetachProgram.onDetachProgram,
        (Hooks.DetachProgramContext({ caller: caller, target: mined, extraData: "" }))
      );
      program.call({ gas: SAFE_PROGRAM_GAS, hook: onDetachProgram });

      EntityProgram._deleteRecord(mined);
    }
  }

  function _handleDrop(EntityId caller, EntityId mined, ObjectType minedType, Vec3 minedCoord) internal {
    // Get drops with all metadata for resource tracking
    ObjectAmount[] memory result = RandomResourceLib._getMineDrops(mined, minedType, minedCoord);

    for (uint256 i = 0; i < result.length; i++) {
      (ObjectType dropType, uint128 amount) = (result[i].objectType, result[i].amount);

      if (amount == 0) continue;

      try InventoryUtils.addObject(caller, dropType, amount) {
        // added to inventory successfully
      } catch {
        // If that fails, drop the object on the ground
        InventoryUtils.addObject(mined, dropType, amount);
      }

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

    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);

    uint128 energyReduction = _getCallerEnergyReduction(toolData.toolType, callerEnergy, massLeft);

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
    if (!sleepingPlayerId._exists()) {
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

  function _requireReachable(Vec3 coord) public view {
    Vec3[6] memory neighbors = coord.neighbors6();
    for (uint256 i = 0; i < neighbors.length; i++) {
      Vec3 neighbor = neighbors[i];
      ObjectType objectType = EntityUtils.getObjectTypeAt(neighbor);

      // If the neighbor is passthrough, we consider the coordinate reachable
      if (objectType.isPassThrough()) return;
    }

    revert("Coordinate is not reachable");
  }

  function _requireMinesAllowed(EntityId caller, ObjectType objectType, Vec3 coord, bytes calldata extraData) public {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);
    if (!forceField._exists()) {
      return;
    }

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    if (machineData.energy == 0) {
      return;
    }

    // We know fragment is active because its forcefield exists, so we can use its program
    ProgramId program = fragment._getProgram();
    if (!program.exists()) {
      program = forceField._getProgram();
      if (!program.exists()) {
        return;
      }
    }

    bytes memory onMine = abi.encodeCall(
      Hooks.IMine.onMine,
      (
        Hooks.MineContext({
          caller: caller,
          target: forceField,
          objectType: objectType,
          coord: coord,
          extraData: extraData
        })
      )
    );

    program.callOrRevert(onMine);
  }

  function _getToolMultiplier(ObjectType toolType, ObjectType minedType) public pure returns (uint128) {
    // Bare hands case - just return action modifier
    if (toolType.isNull()) {
      return MINE_ACTION_MODIFIER;
    }

    // Apply base tool multiplier
    bool isWoodenTool = toolType == ObjectTypes.WoodenAxe || toolType == ObjectTypes.WoodenPick;
    uint128 multiplier = isWoodenTool ? WOODEN_TOOL_BASE_MULTIPLIER : ORE_TOOL_BASE_MULTIPLIER;

    // Apply specialization bonus if tool matches the task
    if ((toolType.isAxe() && minedType.hasAxeMultiplier()) || (toolType.isPick() && minedType.hasPickMultiplier())) {
      multiplier = multiplier * SPECIALIZATION_MULTIPLIER;
    }

    return multiplier * MINE_ACTION_MODIFIER;
  }
}

library RandomResourceLib {
  struct RandomDrop {
    ObjectType objectType;
    uint256[] distribution;
  }

  function _getMineDrops(EntityId mined, ObjectType objectType, Vec3 coord) public view returns (ObjectAmount[] memory) {
    RandomDrop[] memory randomDrops = _getRandomDrops(mined, objectType);

    ObjectAmount[] memory result = new ObjectAmount[](randomDrops.length + 1);

    if (randomDrops.length > 0) {
      uint256 randomSeed = NatureLib.getRandomSeed(coord);
      for (uint256 i = 0; i < randomDrops.length; i++) {
        RandomDrop memory drop = randomDrops[i];
        (uint256 cap, uint256 remaining) = NatureLib.getCapAndRemaining(drop.objectType);
        uint256[] memory weights = RandomLib.adjustWeights(drop.distribution, cap, remaining);
        uint256 amount = RandomLib.selectByWeight(weights, randomSeed);
        result[i] = ObjectAmount(drop.objectType, uint16(amount));
      }
    }

    // If farmland, convert to dirt
    if (objectType == ObjectTypes.Farmland || objectType == ObjectTypes.WetFarmland) {
      objectType = ObjectTypes.Dirt;
    }

    // Add base type as a drop for all objects
    result[result.length - 1] = ObjectAmount(objectType, 1);

    return result;
  }

  function _getRandomDrops(EntityId mined, ObjectType objectType) private view returns (RandomDrop[] memory drops) {
    if (!objectType.hasExtraDrops() || DisabledExtraDrops._get(mined)) {
      return drops;
    }

    if (objectType == ObjectTypes.FescueGrass || objectType == ObjectTypes.SwitchGrass) {
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = 43; // 0 seeds: 43%
      distribution[1] = 57; // 1 seed:  57%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Wheat) {
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 40; // 0 seeds: 40%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 20; // 2 seeds: 20%
      distribution[3] = 10; // 3 seeds: 10%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Melon) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20; // 0 seeds: 20%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 27; // 2 seeds: 27%
      distribution[3] = 23; // 3 seeds: 23%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.MelonSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Pumpkin) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20; // 0 seeds: 20%
      distribution[1] = 30; // 1 seed:  30%
      distribution[2] = 27; // 2 seeds: 27%
      distribution[3] = 23; // 3 seeds: 23%

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(ObjectTypes.PumpkinSeed, distribution);
      return drops;
    }

    if (objectType.isLeaf()) {
      uint256 chance = TreeLib.getLeafDropChance(objectType);
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = 100 - chance; // No sapling
      distribution[1] = chance; // 1 sapling

      drops = new RandomDrop[](1);
      drops[0] = RandomDrop(objectType.getSapling(), distribution);
      return drops;
    }
  }

  function _getRandomOre(Vec3 coord) public view returns (ObjectType) {
    return OreLib.getRandomOre(coord);
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
