// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "../EntityId.sol";

import { buildSystem } from "../codegen/systems/BuildSystemLib.sol";
import { programSystem } from "../codegen/systems/ProgramSystemLib.sol";

import { Orientation } from "../Orientation.sol";
import { ProgramId } from "../ProgramId.sol";
import { Vec3 } from "../Vec3.sol";

import { System } from "@latticexyz/world/src/System.sol";

contract BatchSystem is System {
  function buildAndAttachProgram(
    EntityId caller,
    Vec3 coord,
    uint16 slot,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) public returns (EntityId) {
    EntityId buildEntity = buildSystem.callAsRoot().build(caller, coord, slot, buildExtraData);
    if (buildEntity._exists()) {
      programSystem.callAsRoot().attachProgram(caller, buildEntity, program, attachExtraData);
    }
    return buildEntity;
  }

  function buildAndAttachProgramWithOrientation(
    EntityId caller,
    Vec3 coord,
    uint16 slot,
    Orientation orientation,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) public returns (EntityId) {
    EntityId buildEntity =
      buildSystem.callAsRoot().buildWithOrientation(caller, coord, slot, orientation, buildExtraData);
    if (buildEntity._exists()) {
      programSystem.callAsRoot().attachProgram(caller, buildEntity, program, attachExtraData);
    }
    return buildEntity;
  }

  function jumpBuildAndAttachProgram(
    EntityId caller,
    uint16 slot,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) public returns (EntityId) {
    EntityId buildEntity = buildSystem.callAsRoot().jumpBuild(caller, slot, buildExtraData);
    if (buildEntity._exists()) {
      programSystem.callAsRoot().attachProgram(caller, buildEntity, program, attachExtraData);
    }
    return buildEntity;
  }

  function jumpBuildWithOrientationAndAttachProgram(
    EntityId caller,
    uint16 slot,
    Orientation orientation,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) public returns (EntityId) {
    EntityId buildEntity = buildSystem.callAsRoot().jumpBuildWithOrientation(caller, slot, orientation, buildExtraData);
    if (buildEntity._exists()) {
      programSystem.callAsRoot().attachProgram(caller, buildEntity, program, attachExtraData);
    }
    return buildEntity;
  }
}
