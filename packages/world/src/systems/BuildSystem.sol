// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action, Direction } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { Inventory } from "../codegen/tables/Inventory.sol";
import { InventorySlot } from "../codegen/tables/InventorySlot.sol";
import { Mass } from "../codegen/tables/Mass.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { ObjectTypeMetadata } from "../codegen/tables/ObjectTypeMetadata.sol";
import { Orientation } from "../codegen/tables/Orientation.sol";

import { SeedGrowth } from "../codegen/tables/SeedGrowth.sol";

import { MovablePosition, ReverseMovablePosition } from "../utils/Vec3Storage.sol";

import { getUniqueEntity } from "../Utils.sol";

import { removeEnergyFromLocalPool, transferEnergyToPool, updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { getMovableEntityAt, getObjectTypeIdAt, getOrCreateEntityAt } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { InventoryUtils } from "../utils/InventoryUtils.sol";
import { BuildNotification, MoveNotification, notify } from "../utils/NotifUtils.sol";

import { MoveLib } from "./libraries/MoveLib.sol";
import { TerrainLib } from "./libraries/TerrainLib.sol";

import { BUILD_ENERGY_COST } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { ObjectTypes } from "../ObjectTypes.sol";

import { ProgramId } from "../ProgramId.sol";
import { IBuildHook } from "../ProgramInterfaces.sol";
import { Vec3, vec3 } from "../Vec3.sol";

using ObjectTypeLib for ObjectTypeId;

contract BuildSystem is System {
  function build(EntityId caller, Vec3 coord, uint16 slot, bytes calldata extraData) public returns (EntityId) {
    return buildWithDirection(caller, coord, slot, Direction.PositiveZ, extraData);
  }

  function buildWithDirection(EntityId caller, Vec3 coord, uint16 slot, Direction direction, bytes calldata extraData)
    public
    returns (EntityId)
  {
    caller.activate();
    caller.requireConnected(coord);
    ObjectTypeId buildObjectType = InventorySlot._getObjectType(caller, slot);
    require(buildObjectType.isBlock(), "Cannot build non-block object");

    (EntityId base, Vec3[] memory coords) = BuildLib._addBlocks(coord, buildObjectType, direction);

    if (buildObjectType.isSeed()) {
      BuildLib._handleSeed(base, buildObjectType, coord);
    }

    InventoryUtils.removeObjectFromSlot(caller, slot, 1);

    transferEnergyToPool(caller, BUILD_ENERGY_COST);

    // Note: we call this after the build state has been updated, to prevent re-entrancy attacks
    BuildLib._requireBuildsAllowed(caller, base, buildObjectType, coords, extraData);

    notify(
      caller, BuildNotification({ buildEntityId: base, buildCoord: coords[0], buildObjectTypeId: buildObjectType })
    );

    return base;
  }

  function jumpBuildWithDirection(EntityId caller, uint16 slot, Direction direction, bytes calldata extraData) public {
    caller.activate();

    ObjectTypeId buildObjectType = InventorySlot._getObjectType(caller, slot);
    require(!ObjectTypeMetadata._getCanPassThrough(buildObjectType), "Cannot jump build on a pass-through block");

    Vec3 coord = MovablePosition._get(caller);

    Vec3[] memory moveCoords = new Vec3[](1);
    moveCoords[0] = coord + vec3(0, 1, 0);
    MoveLib.moveWithoutGravity(caller, coord, moveCoords);

    notify(caller, MoveNotification({ moveCoords: moveCoords }));

    buildWithDirection(caller, coord, slot, direction, extraData);
  }

  function jumpBuild(EntityId caller, uint16 slot, bytes calldata extraData) public {
    jumpBuildWithDirection(caller, slot, Direction.PositiveZ, extraData);
  }
}

library BuildLib {
  function _addBlock(ObjectTypeId buildObjectType, Vec3 coord) internal returns (EntityId) {
    (EntityId terrain, ObjectTypeId terrainObjectTypeId) = getOrCreateEntityAt(coord);
    require(terrainObjectTypeId == ObjectTypes.Air, "Cannot build on a non-air block");
    require(Inventory._length(terrain) == 0, "Cannot build where there are dropped objects");
    if (!ObjectTypeMetadata._getCanPassThrough(buildObjectType)) {
      require(!getMovableEntityAt(coord).exists(), "Cannot build on a movable entity");
    }

    ObjectType._set(terrain, buildObjectType);

    return terrain;
  }

  function _addBlocks(Vec3 baseCoord, ObjectTypeId buildObjectType, Direction direction)
    public
    returns (EntityId, Vec3[] memory)
  {
    Vec3[] memory coords = buildObjectType.getRelativeCoords(baseCoord, direction);
    EntityId base = _addBlock(buildObjectType, baseCoord);
    Orientation._set(base, direction);
    uint128 mass = ObjectTypeMetadata._getMass(buildObjectType);
    Mass._setMass(base, mass);
    // Only iterate through relative schema coords
    for (uint256 i = 1; i < coords.length; i++) {
      Vec3 relativeCoord = coords[i];
      EntityId relative = _addBlock(buildObjectType, relativeCoord);
      BaseEntity._set(relative, base);
    }
    return (base, coords);
  }

  function _handleSeed(EntityId base, ObjectTypeId buildObjectTypeId, Vec3 baseCoord) public {
    ObjectTypeId belowTypeId = getObjectTypeIdAt(baseCoord - vec3(0, 1, 0));
    if (buildObjectTypeId.isCropSeed()) {
      require(belowTypeId == ObjectTypes.WetFarmland, "Crop seeds need wet farmland");
    } else if (buildObjectTypeId.isTreeSeed()) {
      require(belowTypeId == ObjectTypes.Dirt || belowTypeId == ObjectTypes.Grass, "Tree seeds need dirt or grass");
    }

    removeEnergyFromLocalPool(baseCoord, ObjectTypeMetadata._getEnergy(buildObjectTypeId));

    SeedGrowth._setFullyGrownAt(base, uint128(block.timestamp) + buildObjectTypeId.timeToGrow());
  }

  function _requireBuildsAllowed(
    EntityId caller,
    EntityId base,
    ObjectTypeId objectTypeId,
    Vec3[] memory coords,
    bytes calldata extraData
  ) public {
    for (uint256 i = 0; i < coords.length; i++) {
      Vec3 coord = coords[i];
      (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);

      // If placing a forcefield, there should be no active forcefield at coord
      if (objectTypeId == ObjectTypes.ForceField) {
        require(!forceField.exists(), "Force field overlaps with another force field");
        ForceFieldUtils.setupForceField(base, coord);
      }

      if (forceField.exists()) {
        (EnergyData memory machineData,) = updateMachineEnergy(forceField);
        if (machineData.energy > 0) {
          // We know fragment is active because its forcefield exists, so we can use its program
          ProgramId program = fragment.getProgram();
          if (!program.exists()) {
            program = forceField.getProgram();
          }

          bytes memory onBuild =
            abi.encodeCall(IBuildHook.onBuild, (caller, forceField, objectTypeId, coord, extraData));

          program.callOrRevert(onBuild);
        }
      }
    }
  }
}
