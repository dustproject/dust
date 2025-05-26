// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";

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

import { BUILD_ENERGY_COST } from "../Constants.sol";
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
    ObjectType buildType = InventorySlot._getObjectType(caller, slot);
    require(buildType.isBlock(), "Cannot build non-block object");

    // If player died, return early
    bool playerDied = BuildLib._handleEnergyReduction(caller, callerEnergy);
    if (playerDied) {
      return EntityId.wrap(0);
    }

    (EntityId base, Vec3[] memory coords) = BuildLib._addBlocks(coord, buildType, orientation);

    BuildLib._handleBuildType(base, buildType, coord);

    InventoryUtils.removeObjectFromSlot(caller, slot, 1);

    // Note: we call this after the build state has been updated, to prevent re-entrancy attacks
    BuildLib._requireBuildsAllowed(caller, base, buildType, coords, extraData);

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

    Vec3 coord = caller.getPosition();

    Vec3[] memory moveCoords = new Vec3[](1);
    moveCoords[0] = coord + vec3(0, 1, 0);
    MoveLib.moveWithoutGravity(coord, moveCoords);

    notify(caller, MoveNotification({ moveCoords: moveCoords }));

    return buildWithOrientation(caller, coord, slot, orientation, extraData);
  }

  function jumpBuild(EntityId caller, uint16 slot, bytes calldata extraData) public returns (EntityId) {
    return jumpBuildWithOrientation(caller, slot, Orientation.wrap(0), extraData);
  }
}

library BuildLib {
  function _handleEnergyReduction(EntityId caller, uint128 callerEnergy) public returns (bool) {
    (callerEnergy,) = transferEnergyToPool(caller, Math.min(callerEnergy, BUILD_ENERGY_COST));
    return callerEnergy == 0;
  }

  function _handleBuildType(EntityId base, ObjectType buildType, Vec3 coord) public {
    if (buildType.isGrowable()) {
      _handleGrowable(base, buildType, coord);
    } else if (buildType.hasExtraDrops()) {
      DisabledExtraDrops._set(base, true);
    }
  }

  function _addBlock(ObjectType buildType, Vec3 coord) internal returns (EntityId) {
    (EntityId terrain, ObjectType terrainObjectType) = EntityUtils.getOrCreateBlockAt(coord);
    require(terrainObjectType == ObjectTypes.Air, "Cannot build on a non-air block");
    require(InventoryUtils.isEmpty(terrain), "Cannot build where there are dropped objects");
    if (!buildType.isPassThrough()) {
      require(!EntityUtils.getMovableEntityAt(coord)._exists(), "Cannot build on a movable entity");
    }

    EntityObjectType._set(terrain, buildType);

    return terrain;
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
      Vec3 relativeCoord = coords[i];
      EntityId relative = _addBlock(buildType, relativeCoord);
      BaseEntity._set(relative, base);
    }
    return (base, coords);
  }

  function _handleGrowable(EntityId base, ObjectType buildType, Vec3 baseCoord) public {
    ObjectType belowType = EntityUtils.getObjectTypeAt(baseCoord - vec3(0, 1, 0));
    require(buildType.isPlantableOn(belowType), "Cannot plant on this block");

    removeEnergyFromLocalPool(baseCoord, buildType.getGrowableEnergy());

    SeedGrowth._setFullyGrownAt(base, uint128(block.timestamp) + buildType.getTimeToGrow());
  }

  function _requireBuildsAllowed(
    EntityId caller,
    EntityId base,
    ObjectType buildType,
    Vec3[] memory coords,
    bytes calldata extraData
  ) public {
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
