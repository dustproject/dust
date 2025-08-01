// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

import { DisabledExtraDrops } from "../codegen/tables/DisabledExtraDrops.sol";
import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";

import { EntityOrientation } from "../codegen/tables/EntityOrientation.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { removeEnergyFromLocalPool, transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { Math } from "../utils/Math.sol";
import { BuildNotification, MoveNotification, notify } from "../utils/NotifUtils.sol";

import { MoveLib } from "./libraries/MoveLib.sol";

import { BUILD_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../types/ObjectType.sol";

import { ProgramId } from "../types/ProgramId.sol";
import { Orientation, Vec3, vec3 } from "../types/Vec3.sol";

struct BuildContext {
  EntityId caller;
  ObjectType slotType;
  ObjectType buildType;
  Vec3 coord;
  uint128 callerEnergy;
  uint16 slot;
  Orientation orientation;
}

contract BuildSystem is System {
  function build(EntityId caller, Vec3 coord, uint16 slot, bytes calldata extraData) public returns (EntityId) {
    return buildWithOrientation(caller, coord, slot, Orientation.wrap(0), extraData);
  }

  function buildWithOrientation(
    EntityId caller,
    Vec3 coord,
    uint16 slot,
    Orientation orientation,
    bytes calldata extraData
  ) public returns (EntityId) {
    uint128 callerEnergy = caller.activate().energy;
    caller.requireConnected(coord);

    BuildContext memory ctx = _buildContext(caller, coord, slot, orientation, callerEnergy);

    return _build(ctx, extraData);
  }

  function jumpBuild(EntityId caller, uint16 slot, bytes calldata extraData) public returns (EntityId) {
    return jumpBuildWithOrientation(caller, slot, Orientation.wrap(0), extraData);
  }

  function jumpBuildWithOrientation(EntityId caller, uint16 slot, Orientation orientation, bytes calldata extraData)
    public
    returns (EntityId)
  {
    uint128 callerEnergy = caller.activate().energy;
    Vec3 coord = caller._getPosition();

    BuildContext memory ctx = _buildContext(caller, coord, slot, orientation, callerEnergy);

    require(!ctx.buildType.isPassThrough(), "Cannot jump build on a pass-through block");

    // Jump movement
    MoveLib.jump(coord);

    Vec3[] memory moveCoords = new Vec3[](1);
    moveCoords[0] = coord + vec3(0, 1, 0);
    notify(caller, MoveNotification({ moveCoords: moveCoords }));

    return _build(ctx, extraData);
  }

  function _build(BuildContext memory ctx, bytes calldata extraData) internal returns (EntityId) {
    (EntityId base, Vec3[] memory coords) = BuildLib._executeBuild(ctx);

    if (coords.length == 0) {
      return base;
    }

    _handleSpecialBlockTypes(ctx, base);

    _requireBuildsAllowed(ctx, base, coords, extraData);

    notify(
      ctx.caller, BuildNotification({ buildEntityId: base, buildCoord: coords[0], buildObjectType: ctx.buildType })
    );

    return base;
  }

  function _buildContext(EntityId caller, Vec3 coord, uint16 slot, Orientation orientation, uint128 callerEnergy)
    internal
    view
    returns (BuildContext memory)
  {
    ObjectType slotType = InventorySlot._getObjectType(caller, slot);
    ObjectType buildType = _getBuildType(slotType);

    return BuildContext({
      caller: caller,
      coord: coord,
      slot: slot,
      orientation: orientation,
      callerEnergy: callerEnergy,
      slotType: slotType,
      buildType: buildType
    });
  }

  function _getBuildType(ObjectType slotType) internal pure returns (ObjectType) {
    require(slotType.isBlock(), "Cannot build non-block object");
    return slotType;
  }

  /**
   * @dev Handles special initialization for specific block types (growables, extra drops)
   */
  function _handleSpecialBlockTypes(BuildContext memory ctx, EntityId base) internal {
    if (ctx.buildType.isGrowable()) {
      ObjectType belowType = EntityUtils.getObjectTypeAt(ctx.coord - vec3(0, 1, 0));
      require(ctx.buildType.isPlantableOn(belowType), "Cannot plant on this block");

      removeEnergyFromLocalPool(ctx.coord, ctx.buildType.getGrowableEnergy());

      SeedGrowth._setFullyGrownAt(base, uint128(block.timestamp) + ctx.buildType.getTimeToGrow());
    } else if (ctx.buildType.hasExtraDrops()) {
      DisabledExtraDrops._set(base, true);
    }
  }

  /**
   * @dev Validates builds against force fields and calls build hooks for programs
   */
  function _requireBuildsAllowed(BuildContext memory ctx, EntityId base, Vec3[] memory coords, bytes calldata extraData)
    internal
  {
    for (uint256 i = 0; i < coords.length; i++) {
      Vec3 coord = coords[i];

      (ProgramId program, EntityId target) = _getHookTarget(coord);

      if (ctx.buildType == ObjectTypes.ForceField) {
        require(!target._exists(), "Force field overlaps with another force field");
        ForceFieldUtils.setupForceField(base, coord);
        // Return early as it is not possible for a new forcefield to have a program
        return;
      }

      if (!program.exists()) {
        continue;
      }

      program.hook({ caller: ctx.caller, target: target, revertOnFailure: true, extraData: extraData }).onBuild({
        entity: base,
        coord: coord,
        slotType: ctx.slotType,
        objectType: ctx.buildType,
        orientation: ctx.orientation
      });
    }
  }

  function _getHookTarget(Vec3 coord) internal returns (ProgramId, EntityId) {
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);
    if (!forceField._exists()) {
      return (ProgramId.wrap(0), forceField);
    }

    EnergyData memory machineData = updateMachineEnergy(forceField);
    if (machineData.energy == 0) {
      return (ProgramId.wrap(0), forceField);
    }

    // We know fragment is active because its forcefield exists, so we can use its program
    ProgramId program = fragment._getProgram();
    if (program.exists()) {
      return (program, fragment);
    }

    return (forceField._getProgram(), forceField);
  }
}

library BuildLib {
  function _executeBuild(BuildContext memory ctx) public returns (EntityId, Vec3[] memory) {
    (ctx.callerEnergy,) = transferEnergyToPool(ctx.caller, Math.min(ctx.callerEnergy, BUILD_ENERGY_COST));
    if (ctx.callerEnergy == 0) {
      return (EntityId.wrap(0), new Vec3[](0));
    }

    _updateInventory(ctx);

    return _addBlocks(ctx);
  }

  /**
   * @dev Updates inventory after a successful build (removes item, handles water bucket)
   */
  function _updateInventory(BuildContext memory ctx) internal {
    InventoryUtils.removeObjectFromSlot(ctx.caller, ctx.slot, 1);
    if (ctx.slotType == ObjectTypes.WaterBucket) {
      InventoryUtils.addObjectToSlot(ctx.caller, ObjectTypes.Bucket, 1, ctx.slot);
    }
  }

  function _addBlocks(BuildContext memory ctx) internal returns (EntityId, Vec3[] memory) {
    Vec3[] memory coords = ctx.buildType.getRelativeCoords(ctx.coord, ctx.orientation);

    EntityId base = _addBlock(ctx.buildType, ctx.coord);
    EntityOrientation._set(base, ctx.orientation);

    EntityUtils.setEntityObjectType(base, ctx.buildType);

    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      EntityId relative = _addBlock(ctx.buildType, coords[i]);
      BaseEntity._set(relative, base);
      // We don't use setEntityObjectType as we don't set the mass for relative blocks
      EntityObjectType._set(relative, ctx.buildType);
    }

    return (base, coords);
  }

  function _addBlock(ObjectType buildType, Vec3 coord) internal returns (EntityId) {
    (EntityId terrain, ObjectType terrainType) = EntityUtils.getOrCreateBlockAt(coord);

    _validateBlockBuild(terrainType, buildType, coord, terrain);

    _applyTerrainModifications(terrain, buildType);

    return terrain;
  }

  /**
   * @dev Validates that a non-water block can be placed at the given location
   *
   * Block placement validation checks:
   * 1. Terrain compatibility: Block can only be placed on Air or Water
   *    - Air: Standard empty space placement
   *    - Water: Allows underwater building (ONLY waterloggable blocks)
   *
   * 2. For non-passthrough blocks (solid blocks like stone, wood):
   *    - No dropped items: Cannot build where items are lying on the ground
   *    - No entities: Cannot build where a movable entity (player, mob) exists
   *    Passthrough blocks (like torches, fescue grass) skip these checks
   */
  function _validateBlockBuild(ObjectType terrainType, ObjectType buildType, Vec3 coord, EntityId terrain)
    internal
    view
  {
    if (terrainType == ObjectTypes.Water) {
      require(buildType.isWaterloggable(), "Cannot build on water with non-waterloggable block");
    } else {
      require(terrainType == ObjectTypes.Air, "Can only build on air or water");
    }

    if (!buildType.isPassThrough()) {
      require(InventoryUtils.isEmpty(terrain), "Cannot build where there are dropped objects");
      require(!EntityUtils.getMovableEntityAt(coord)._exists(), "Cannot build on a movable entity");
    }
  }

  /**
   * @dev Applies terrain modifications when placing a block (sets object type, handles water interactions)
   * - Waterloggable blocks can coexist with water
   * - Non-waterloggable blocks DO NOT remove water level when placed, so they will revert back to water when mined
   */
  function _applyTerrainModifications(EntityId terrain, ObjectType buildType) internal {
    // NOTE: until we solve water conservation, we do not remove fluid level, instead we only allow waterloggable blocks
    // if (terrainType == ObjectTypes.Water && !buildType.isWaterloggable()) {
    //   EntityFluidLevel._deleteRecord(terrain);
    // }
  }
}
