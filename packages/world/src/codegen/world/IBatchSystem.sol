// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../types/EntityId.sol";
import { Vec3 } from "../../types/Vec3.sol";
import { ProgramId } from "../../types/ProgramId.sol";
import { Orientation } from "../../types/Orientation.sol";

/**
 * @title IBatchSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IBatchSystem {
  function buildAndAttachProgram(
    EntityId caller,
    Vec3 coord,
    uint16 slot,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) external returns (EntityId);

  function buildAndAttachProgramWithOrientation(
    EntityId caller,
    Vec3 coord,
    uint16 slot,
    Orientation orientation,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) external returns (EntityId);

  function jumpBuildAndAttachProgram(
    EntityId caller,
    uint16 slot,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) external returns (EntityId);

  function jumpBuildWithOrientationAndAttachProgram(
    EntityId caller,
    uint16 slot,
    Orientation orientation,
    ProgramId program,
    bytes calldata buildExtraData,
    bytes calldata attachExtraData
  ) external returns (EntityId);
}
