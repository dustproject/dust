// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { BedPlayer } from "../codegen/tables/BedPlayer.sol";
import { SafeCastLib } from "solady/utils/SafeCastLib.sol";

import { DisabledExtraDrops } from "../codegen/tables/DisabledExtraDrops.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { Death, DeathData } from "../codegen/tables/Death.sol";
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
  updateMachineEnergy,
  updateSleepingPlayerEnergy
} from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";

import { DeathNotification, MineNotification, WakeupNotification, notify } from "../utils/NotifUtils.sol";

import { PlayerProgressUtils } from "../utils/PlayerProgressUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { RateLimitUtils } from "../utils/RateLimitUtils.sol";
import { ToolData, ToolUtils } from "../utils/ToolUtils.sol";

import {
  MACHINE_ENERGY_DRAIN_RATE,
  MINE_ACTION_MODIFIER,
  PLAYER_ENERGY_DRAIN_RATE,
  PRECISION_MULTIPLIER
} from "../Constants.sol";

import { EntityId } from "../types/EntityId.sol";
import { ObjectAmount, ObjectType } from "../types/ObjectType.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

import { NatureLib } from "../utils/NatureLib.sol";

import { ObjectTypes } from "../types/ObjectType.sol";
import { OreLib } from "../utils/OreLib.sol";

import { ProgramId } from "../types/ProgramId.sol";
import { Vec3, vec3 } from "../types/Vec3.sol";

struct MineContext {
  EntityId caller;
  EntityId mined;
  Vec3 coord;
  uint128 callerEnergy;
  bytes extraData;
  ToolData toolData;
  ObjectType objectType;
}

contract MineSystem is System {
  using SafeCastLib for *;
  using Math for *;

  function getRandomOreType(Vec3 coord) external view returns (ObjectType) {
    return MineRandomLib._getRandomOre(coord);
  }

  function mine(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) external returns (EntityId) {
    // Check rate limit for work actions
    RateLimitUtils.mine(caller);
    return _mine(caller, coord, toolSlot, extraData);
  }

  function mine(EntityId caller, Vec3 coord, bytes calldata extraData) external returns (EntityId) {
    // Check rate limit for work actions
    RateLimitUtils.mine(caller);
    return _mine(caller, coord, type(uint16).max, extraData);
  }

  function mineUntilDestroyed(EntityId caller, Vec3 coord, uint16 toolSlot, bytes calldata extraData) public {
    // Check rate limit for work actions
    RateLimitUtils.mine(caller);
    uint128 massLeft = 0;
    do {
      // TODO: factor out the mass reduction logic so it's cheaper to call
      EntityId entityId = _mine(caller, coord, toolSlot, extraData);
      massLeft = Mass._getMass(entityId);
    } while (massLeft > 0 && Energy._getEnergy(caller) > 0 && ToolUtils.getToolData(caller, toolSlot).massLeft > 0);
  }

  function mineUntilDestroyed(EntityId caller, Vec3 coord, bytes calldata extraData) public {
    // Check rate limit for work actions
    RateLimitUtils.mine(caller);
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

    MineContext memory ctx = _mineContext({
      caller: caller,
      coord: coord,
      extraData: extraData,
      toolSlot: toolSlot,
      callerEnergy: callerEnergy
    });

    (uint128 massLeft, bool canMine) = MinePhysicsLib._applyMassReduction(ctx);

    if (!canMine) {
      // Player died, return early
      return ctx.mined;
    }

    if (massLeft == 0) {
      // The block was fully mined
      _destroyObject(ctx);

      notify(
        caller, MineNotification({ mineEntityId: ctx.mined, mineCoord: ctx.coord, mineObjectType: ctx.objectType })
      );
    } else {
      Mass._setMass(ctx.mined, massLeft);
    }

    MineLib._requireMinesAllowed(ctx);

    return ctx.mined;
  }

  function _mineContext(EntityId caller, Vec3 coord, bytes calldata extraData, uint16 toolSlot, uint128 callerEnergy)
    internal
    returns (MineContext memory ctx)
  {
    (EntityId mined, ObjectType minedType) = _prepareBlock(coord);
    ToolData memory toolData = ToolUtils.getToolData(caller, toolSlot);
    return MineContext({
      caller: caller,
      coord: coord,
      extraData: extraData,
      toolData: toolData,
      callerEnergy: callerEnergy,
      mined: mined,
      objectType: minedType
    });
  }

  function _prepareBlock(Vec3 coord) internal returns (EntityId, ObjectType) {
    (EntityId mined, ObjectType objectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(objectType.isBlock(), "Object is not mineable");

    mined = mined._baseEntityId();

    if (Mass._get(mined) == 0) {
      // If the mass is 0, we assume the block was not correctly setup (e.g. missing mass)
      // NOTE: This currently targets the issue where grown seeds/saplings were not given mass
      // TODO: We could potentially stop assigning mass on build and just do it here
      Mass._setMass(mined, ObjectPhysics._getMass(objectType));
    }

    if (objectType.isMachine()) {
      EnergyData memory machineData = updateMachineEnergy(mined);
      require(machineData.energy == 0, "Cannot mine a machine that has energy");

      // Prevent mining forcefields that have sleeping players
      if (objectType == ObjectTypes.ForceField) {
        _requireNoSleepingPlayers(mined);
      }

      return (mined, objectType);
    }

    if (objectType == ObjectTypes.UnrevealedOre) {
      return (mined, MineRandomLib._collapseRandomOre(mined, coord));
    }

    if (objectType.isGrowable() && SeedGrowth._getFullyGrownAt(mined) <= block.timestamp) {
      // If the seed is fully grown, grow it
      return (mined, NatureLib.growSeed(coord, mined, objectType));
    }

    return (mined, objectType);
  }

  function _destroyObject(MineContext memory ctx) internal {
    Mass._deleteRecord(ctx.mined);

    Vec3 baseCoord = ctx.mined._getPosition();

    // Get all coords: index 0 is base, rest are relatives
    Vec3[] memory coords = ctx.objectType.getRelativeCoords(baseCoord, EntityOrientation._get(ctx.mined));

    for (uint256 i = 0; i < coords.length; i++) {
      Vec3 coord = coords[i];
      _handleAbove(ctx.caller, coord);

      (EntityId entity, ObjectType objectType) = EntityUtils.getBlockAt(coord);

      // Delete BaseEntity only for relatives (i > 0)
      if (i > 0) {
        BaseEntity._deleteRecord(entity);
      }

      _removeBlock(entity, objectType, coord);
    }

    // Handle drops from the mined object itself
    MineDropLib._handleDrop(ctx.caller, ctx.mined, ctx.objectType, baseCoord);

    // It is fine to destroy the entity before requiring mines allowed,
    // as machines can't be destroyed if they have energy
    _cleanupEntity(ctx.caller, ctx.mined, ctx.objectType, baseCoord);
  }

  function _removeBlock(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    // If object being mined is seed, no need to check above entities
    if (objectType.isGrowable()) {
      _removeGrowable(entityId, objectType, coord);
      return;
    }

    ObjectType replacementType = EntityFluidLevel._get(entityId) > 0 ? ObjectTypes.Water : ObjectTypes.Air;
    EntityUtils.setEntityObjectType(entityId, replacementType);

    Vec3 aboveCoord = coord + vec3(0, 1, 0);
    EntityId above = EntityUtils.getMovableEntityAt(aboveCoord);
    // Note: currently it is not possible for the above player to not be the base entity,
    // but if we add other types of movable entities we should check that it is a base entity
    if (above._exists()) {
      MoveLib.runGravity(aboveCoord);
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
      isLandbound = aboveType.isLandbound();
    }

    if (isLandbound) {
      _removeBlock(above, aboveType, aboveCoord);
      MineDropLib._handleDrop(caller, above, aboveType, aboveCoord);
    }
  }

  function _removeGrowable(EntityId entityId, ObjectType objectType, Vec3 coord) internal {
    EntityUtils.setEntityObjectType(entityId, ObjectTypes.Air);
    addEnergyToLocalPool(coord, objectType.getGrowableEnergy());
  }

  function _cleanupEntity(EntityId caller, EntityId mined, ObjectType minedType, Vec3 baseCoord) internal {
    if (minedType == ObjectTypes.Bed) {
      MineBedLib._mineBed(mined, baseCoord);
    } else if (minedType.isMachine()) {
      Energy._deleteRecord(mined);
      Machine._deleteRecord(mined);
    }

    // Detach program if it exists
    ProgramId program = mined._getProgram();
    if (program.exists()) {
      program.hook({ caller: caller, target: mined, revertOnFailure: false, extraData: "" }).onDetachProgram();

      EntityProgram._deleteRecord(mined);
    }
  }

  function _requireNoSleepingPlayers(EntityId forceField) internal view {
    uint128 drainRate = Energy._getDrainRate(forceField);

    /* Check if drain rate is perfectly divisible by machine rate
    * This works because:
    * - Each fragment contributes exactly MACHINE_ENERGY_DRAIN_RATE to the total
    * - Each sleeping player adds PLAYER_ENERGY_DRAIN_RATE which has remainder 4,526,893,230
    * - Therefore: drainRate % MACHINE_ENERGY_DRAIN_RATE == 0 only when no players are sleeping
    *
    * Edge case proof: When would N players give remainder 0?
    * We need: (N * PLAYER_ENERGY_DRAIN_RATE) % MACHINE_ENERGY_DRAIN_RATE == 0
    * This means: N * PLAYER_ENERGY_DRAIN_RATE = K * MACHINE_ENERGY_DRAIN_RATE (for some integer K)
    *
    * Given: PLAYER_ENERGY_DRAIN_RATE = 1,351,851,852,000
    *        MACHINE_ENERGY_DRAIN_RATE = 9,488,203,935
    *        GCD(1351851852000, 9488203935) = 15
    *
    * Therefore: N * (1351851852000/15) = K * (9488203935/15)
    *            N * 90,123,456,800 = K * 632,546,929
    *
    * Since 90,123,456,800 and 632,546,929 are coprime (GCD = 1),
    * N must be a multiple of 632,546,929 for the equation to hold.
    * This means at least 632,546,929 players must be sleeping in the same forcefield!
        */

    // TODO: This modulo check is a hack but not ideal long-term. We should consider:
    // - Storing fragment count for the forcefield entity
    // - Or tracking sleeping player count directly
    // - Or using a more robust detection method that doesn't rely on mathematical properties
    require(drainRate % MACHINE_ENERGY_DRAIN_RATE == 0, "Cannot mine forcefield with sleeping players");
  }
}

library MineLib {
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

  function _requireMinesAllowed(MineContext calldata ctx) public {
    (ProgramId program, EntityId target, EnergyData memory energyData) = ForceFieldUtils.getHookTarget(ctx.coord);

    if (!program.exists()) {
      return;
    }

    program.hook({ caller: ctx.caller, target: target, revertOnFailure: energyData.energy > 0, extraData: ctx.extraData })
      .onMine({ entity: ctx.mined, tool: ctx.toolData.tool, objectType: ctx.objectType, coord: ctx.coord });
  }
}

library MinePhysicsLib {
  function _applyMassReduction(MineContext calldata ctx) public returns (uint128, bool) {
    uint128 massLeft = Mass._get(ctx.mined);
    if (massLeft == 0) {
      return (0, true);
    }

    bool specialized = (ctx.toolData.toolType.isAxe() && ctx.objectType.hasAxeMultiplier())
      || (ctx.toolData.toolType.isPick() && ctx.objectType.hasPickMultiplier());

    // Compute progress-based energy multiplier and apply (Option A semantics)
    uint256 energyMultiplierWad =
      PlayerProgressUtils.getMiningEnergyMultiplierWad(ctx.caller, ctx.toolData.toolType, ctx.objectType);
    uint128 totalMassReduction = ctx.toolData.use(massLeft, MINE_ACTION_MODIFIER, specialized, energyMultiplierWad);

    // If caller died (totalMassReduction == 0), return early
    if (totalMassReduction == 0) {
      return (massLeft, false);
    }

    massLeft -= totalMassReduction;

    // Track the mass reduction for player activity
    PlayerProgressUtils.trackMine(ctx.caller, totalMassReduction, ctx.toolData.toolType, ctx.objectType);

    return (massLeft, true);
  }
}

library MineBedLib {
  function _mineBed(EntityId bed, Vec3 bedCoord) public {
    // If there is a player sleeping in the mined bed, spawn them
    EntityId sleepingPlayer = BedPlayer._getPlayerEntityId(bed);
    if (!sleepingPlayer._exists()) {
      return;
    }

    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(bedCoord);
    decreaseFragmentDrainRate(forceField, fragment, PLAYER_ENERGY_DRAIN_RATE);
    EnergyData memory playerData = updateSleepingPlayerEnergy(sleepingPlayer, bed, forceField, bedCoord);

    PlayerUtils.removePlayerFromBed(sleepingPlayer, bed);

    // Player died
    if (playerData.energy == 0) {
      // Bed entity should now be Air
      bool allTransferred = InventoryUtils.transferAll(sleepingPlayer, bed);
      require(allTransferred, "Failed to transfer all items to drop location");

      Death._set(
        sleepingPlayer, DeathData({ lastDiedAt: uint128(block.timestamp), deaths: Death.getDeaths(sleepingPlayer) + 1 })
      );
      notify(sleepingPlayer, DeathNotification({ deathCoord: bedCoord }));
      return;
    }

    // If player is not dead, spawn them at the bed position
    PlayerUtils.addPlayerToGrid(sleepingPlayer, bedCoord);

    // Run gravity on the bed coordinate to ensure the player is placed correctly
    MoveLib.runGravity(bedCoord);

    bed._getProgram().hook({ caller: sleepingPlayer, target: bed, revertOnFailure: false, extraData: "" }).onWakeup();

    notify(sleepingPlayer, WakeupNotification({ bed: bed, bedCoord: bedCoord }));
  }
}

library MineDropLib {
  function _handleDrop(EntityId caller, EntityId mined, ObjectType minedType, Vec3 minedCoord) public {
    // Get extra drops (seeds, saplings, etc)
    ObjectAmount[] memory extraDrops = MineRandomLib._getExtraDrops(mined, minedType, minedCoord);

    // Handle extra drops with resource tracking
    for (uint256 i = 0; i < extraDrops.length; i++) {
      (ObjectType dropType, uint128 amount) = (extraDrops[i].objectType, extraDrops[i].amount);

      if (amount == 0) continue;

      _addToInventoryOrDrop(caller, mined, dropType, amount);

      // Track mined resource count for seeds from extra drops
      // TODO: could make it more general like .isCappedResource() or something
      if (dropType.isGrowable()) {
        ResourceCount._set(dropType, ResourceCount._get(dropType) + amount);
      }
    }

    // Handle the mined object itself (no resource tracking)
    // If farmland, convert to dirt
    if (minedType == ObjectTypes.Farmland || minedType == ObjectTypes.WetFarmland) {
      minedType = ObjectTypes.Dirt;
    }

    // If cotton bush, convert to cotton fiber
    // if (minedType == ObjectTypes.CottonBush) {
    //   minedType = ObjectTypes.Cotton;
    // }

    _addToInventoryOrDrop(caller, mined, minedType, 1);
  }

  function _addToInventoryOrDrop(EntityId caller, EntityId fallbackEntity, ObjectType objectType, uint128 amount)
    private
  {
    try InventoryUtils.addObject(caller, objectType, amount) {
      // added to inventory successfully
    } catch {
      // If that fails, drop the object on the ground
      InventoryUtils.addObject(fallbackEntity, objectType, amount);
    }
  }
}

library MineRandomLib {
  struct DropDistribution {
    ObjectType objectType;
    uint256[] distribution;
  }

  function _getExtraDrops(EntityId mined, ObjectType objectType, Vec3 coord)
    public
    view
    returns (ObjectAmount[] memory)
  {
    DropDistribution[] memory dropDistributions = _getDropDistributions(mined, objectType);

    ObjectAmount[] memory result = new ObjectAmount[](dropDistributions.length);

    if (dropDistributions.length > 0) {
      uint256 randomSeed = NatureLib.getRandomSeed(coord);
      for (uint256 i = 0; i < dropDistributions.length; i++) {
        DropDistribution memory drop = dropDistributions[i];
        (uint256 cap, uint256 remaining) = NatureLib.getCapAndRemaining(drop.objectType);
        uint256[] memory weights = RandomLib.adjustWeights(drop.distribution, cap, remaining);
        uint256 amount = RandomLib.selectByWeight(weights, randomSeed);
        result[i] = ObjectAmount(drop.objectType, uint16(amount));
      }
    }

    return result;
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
    EntityUtils.setEntityObjectType(entityId, ore);

    return ore;
  }

  function _trackPosition(Vec3 coord, ObjectType objectType) private {
    // Track resource position for mining/respawning
    uint256 count = ResourceCount._get(objectType);
    ResourcePosition._set(objectType, count, coord);
    ResourceCount._set(objectType, count + 1);
  }

  function _getDropDistributions(EntityId mined, ObjectType objectType)
    private
    view
    returns (DropDistribution[] memory drops)
  {
    if (!objectType.hasExtraDrops() || DisabledExtraDrops._get(mined)) {
      return drops;
    }

    if (objectType == ObjectTypes.FescueGrass || objectType == ObjectTypes.SwitchGrass) {
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = 43 * PRECISION_MULTIPLIER; // 0 seeds: 43%
      distribution[1] = 57 * PRECISION_MULTIPLIER; // 1 seed:  57%

      drops = new DropDistribution[](1);
      drops[0] = DropDistribution(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Wheat) {
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 40 * PRECISION_MULTIPLIER; // 0 seeds: 40%
      distribution[1] = 30 * PRECISION_MULTIPLIER; // 1 seed:  30%
      distribution[2] = 20 * PRECISION_MULTIPLIER; // 2 seeds: 20%
      distribution[3] = 10 * PRECISION_MULTIPLIER; // 3 seeds: 10%

      drops = new DropDistribution[](1);
      drops[0] = DropDistribution(ObjectTypes.WheatSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Melon) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20 * PRECISION_MULTIPLIER; // 0 seeds: 20%
      distribution[1] = 30 * PRECISION_MULTIPLIER; // 1 seed:  30%
      distribution[2] = 27 * PRECISION_MULTIPLIER; // 2 seeds: 27%
      distribution[3] = 23 * PRECISION_MULTIPLIER; // 3 seeds: 23%

      drops = new DropDistribution[](1);
      drops[0] = DropDistribution(ObjectTypes.MelonSeed, distribution);
      return drops;
    }

    if (objectType == ObjectTypes.Pumpkin) {
      // Expected return 1.53
      uint256[] memory distribution = new uint256[](4);
      distribution[0] = 20 * PRECISION_MULTIPLIER; // 0 seeds: 20%
      distribution[1] = 30 * PRECISION_MULTIPLIER; // 1 seed:  30%
      distribution[2] = 27 * PRECISION_MULTIPLIER; // 2 seeds: 27%
      distribution[3] = 23 * PRECISION_MULTIPLIER; // 3 seeds: 23%

      drops = new DropDistribution[](1);
      drops[0] = DropDistribution(ObjectTypes.PumpkinSeed, distribution);
      return drops;
    }

    // if (objectType == ObjectTypes.CottonBush) {
    //   // Similar to wheat distribution
    //   uint256[] memory distribution = new uint256[](4);
    //   distribution[0] = 40 * PRECISION_MULTIPLIER; // 0 seeds: 40%
    //   distribution[1] = 30 * PRECISION_MULTIPLIER; // 1 seed:  30%
    //   distribution[2] = 20 * PRECISION_MULTIPLIER; // 2 seeds: 20%
    //   distribution[3] = 10 * PRECISION_MULTIPLIER; // 3 seeds: 10%
    //
    //   drops = new DropDistribution[](1);
    //   drops[0] = DropDistribution(ObjectTypes.CottonSeed, distribution);
    //   return drops;
    // }

    if (objectType.isLeaf()) {
      uint256 chance = TreeLib.getLeafDropChance(objectType);
      uint256[] memory distribution = new uint256[](2);
      distribution[0] = PRECISION_MULTIPLIER - chance; // No sapling
      distribution[1] = chance; // 1 sapling

      drops = new DropDistribution[](1);
      drops[0] = DropDistribution(objectType.getSapling(), distribution);
      return drops;
    }
  }
}
