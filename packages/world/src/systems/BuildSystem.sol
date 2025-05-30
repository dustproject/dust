// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { EntityFluidLevel } from "../codegen/tables/EntityFluidLevel.sol";

import { DisabledExtraDrops } from "../codegen/tables/DisabledExtraDrops.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";

import { EntityOrientation } from "../codegen/tables/EntityOrientation.sol";
import { ObjectPhysics } from "../codegen/tables/ObjectPhysics.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { removeEnergyFromLocalPool, transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { Math } from "../utils/Math.sol";
import { BuildNotification, MoveNotification, notify } from "../utils/NotifUtils.sol";

import { MoveLib } from "./libraries/MoveLib.sol";
import { TerrainLib } from "./libraries/TerrainLib.sol";

import { BUILD_ENERGY_COST, MAX_FLUID_LEVEL } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType, ObjectTypes } from "../ObjectType.sol";

import { ProgramId } from "../ProgramId.sol";
import { IBuildHook } from "../ProgramInterfaces.sol";
import { Orientation, Vec3, vec3 } from "../Vec3.sol";

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
    ObjectType slotType = InventorySlot._getObjectType(caller, slot);
    ObjectType buildType = _getBuildType(slotType);

    // If player died, return early
    bool playerDied = BuildLib._handleEnergyReduction(caller, callerEnergy);
    if (playerDied) {
      return EntityId.wrap(0);
    }

    (EntityId base, Vec3[] memory coords) = BuildLib._addBlocks(coord, buildType, orientation);

    _updateInventory(caller, slot, slotType);

    // Note: we call this after the build state has been updated, to prevent re-entrancy attacks
    _requireBuildsAllowed(caller, base, buildType, coords, extraData);

    notify(caller, BuildNotification({ buildEntityId: base, buildCoord: coords[0], buildObjectType: buildType }));

    return base;
  }

  function jumpBuildWithOrientation(EntityId caller, uint16 slot, Orientation orientation, bytes calldata extraData)
    public
    returns (EntityId)
  {
    caller.activate();

    ObjectType buildObjectType = InventorySlot._getObjectType(caller, slot);
    require(!buildObjectType.isPassThrough(), "Cannot jump build on a pass-through block");

    Vec3 coord = caller._getPosition();

    Vec3[] memory moveCoords = new Vec3[](1);
    moveCoords[0] = coord + vec3(0, 1, 0);
    MoveLib.moveWithoutGravity(coord, moveCoords);

    notify(caller, MoveNotification({ moveCoords: moveCoords }));

    return buildWithOrientation(caller, coord, slot, orientation, extraData);
  }

  function jumpBuild(EntityId caller, uint16 slot, bytes calldata extraData) public returns (EntityId) {
    return jumpBuildWithOrientation(caller, slot, Orientation.wrap(0), extraData);
  }

  function _getBuildType(ObjectType slotType) internal pure returns (ObjectType) {
    if (slotType == ObjectTypes.WaterBucket) {
      return ObjectTypes.Water;
    }

    require(slotType.isBlock(), "Cannot build non-block object");

    return slotType;
  }

  function _updateInventory(EntityId caller, uint16 slot, ObjectType slotType) internal {
    InventoryUtils.removeObjectFromSlot(caller, slot, 1);

    // If the build type is water, we need to add an empty bucket back to the inventory
    if (slotType == ObjectTypes.WaterBucket) {
      InventoryUtils.addObjectToSlot(caller, ObjectTypes.Bucket, 1, slot);
    }
  }

  function _requireBuildsAllowed(
    EntityId caller,
    EntityId base,
    ObjectType buildType,
    Vec3[] memory coords,
    bytes calldata extraData
  ) internal {
    for (uint256 i = 0; i < coords.length; i++) {
      Vec3 coord = coords[i];
      (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);

      // If placing a forcefield, there should be no active forcefield at coord
      if (buildType == ObjectTypes.ForceField) {
        require(!forceField._exists(), "Force field overlaps with another force field");
        ForceFieldUtils.setupForceField(base, coord);
      }

      if (forceField._exists()) {
        (EnergyData memory machineData,) = updateMachineEnergy(forceField);
        if (machineData.energy > 0) {
          // We know fragment is active because its forcefield exists, so we can use its program
          ProgramId program = fragment._getProgram();
          if (!program.exists()) {
            program = forceField._getProgram();
          }

          bytes memory onBuild = abi.encodeCall(IBuildHook.onBuild, (caller, forceField, buildType, coord, extraData));

          program.callOrRevert(onBuild);
        }
      }
    }
  }
}

library BuildLib {
  function _handleEnergyReduction(EntityId caller, uint128 callerEnergy) public returns (bool) {
    (callerEnergy,) = transferEnergyToPool(caller, Math.min(callerEnergy, BUILD_ENERGY_COST));
    return callerEnergy == 0;
  }

  function _addBlocks(Vec3 baseCoord, ObjectType buildType, Orientation orientation)
    public
    returns (EntityId, Vec3[] memory)
  {
    Vec3[] memory coords = buildType.getRelativeCoords(baseCoord, orientation);

    EntityId base = _addBlock(buildType, baseCoord);
    EntityOrientation._set(base, orientation);

    uint128 mass = ObjectPhysics._getMass(buildType);
    Mass._setMass(base, mass);

    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      EntityId relative = _addBlock(buildType, coords[i]);
      BaseEntity._set(relative, base);
    }

    _handleSpecialBlockTypes(base, buildType, baseCoord);
    return (base, coords);
  }

  function _addBlock(ObjectType buildType, Vec3 coord) internal returns (EntityId) {
    (EntityId terrain, ObjectType terrainType) = EntityUtils.getOrCreateBlockAt(coord);

    if (buildType == ObjectTypes.Water) {
      _validateWaterBuild(terrainType, coord);
    } else {
      _validateBlockBuild(terrainType, buildType, coord, terrain);
    }

    _applyTerrainModifications(terrain, terrainType, buildType);

    return terrain;
  }

  function _validateWaterBuild(ObjectType terrainType, Vec3 coord) internal view {
    if (terrainType == ObjectTypes.Water) {
      // Allow building water on water only if fluid level < MAX
      uint8 currentFluidLevel = EntityUtils.getFluidLevelAt(coord);
      require(currentFluidLevel < MAX_FLUID_LEVEL, "Water is already at max level");
    } else {
      require(
        terrainType == ObjectTypes.Air || terrainType.isWaterloggable(),
        "Can only build water on air or waterloggable blocks"
      );
    }
  }

  function _validateBlockBuild(ObjectType terrainType, ObjectType buildType, Vec3 coord, EntityId terrain)
    internal
    view
  {
    require(terrainType == ObjectTypes.Water || terrainType == ObjectTypes.Air, "Can only build on air or water");

    if (!buildType.isPassThrough()) {
      require(InventoryUtils.isEmpty(terrain), "Cannot build where there are dropped objects");
      require(!EntityUtils.getMovableEntityAt(coord)._exists(), "Cannot build on a movable entity");
    }
  }

  function _applyTerrainModifications(EntityId terrain, ObjectType terrainType, ObjectType buildType) internal {
    if (buildType == ObjectTypes.Water) {
      EntityFluidLevel._set(terrain, MAX_FLUID_LEVEL);
      // Only set water block type if the terrain is air
      if (terrainType == ObjectTypes.Air) {
        EntityObjectType._set(terrain, ObjectTypes.Water);
      }
      return;
    }

    // Handle water removal when placing non-waterloggable blocks
    if (terrainType == ObjectTypes.Water && !buildType.isWaterloggable()) {
      EntityFluidLevel._deleteRecord(terrain);
    }

    // Set the new block type
    EntityObjectType._set(terrain, buildType);
  }

  function _handleSpecialBlockTypes(EntityId base, ObjectType buildType, Vec3 coord) public {
    if (buildType.isGrowable()) {
      ObjectType belowType = EntityUtils.getObjectTypeAt(coord - vec3(0, 1, 0));
      require(buildType.isPlantableOn(belowType), "Cannot plant on this block");

      removeEnergyFromLocalPool(coord, buildType.getGrowableEnergy());

      SeedGrowth._setFullyGrownAt(base, uint128(block.timestamp) + buildType.getTimeToGrow());
    } else if (buildType.hasExtraDrops()) {
      DisabledExtraDrops._set(base, true);
    }
  }
}
