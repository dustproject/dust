// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EntityId } from "../../EntityId.sol";
import { ObjectTypeId } from "../../ObjectTypeId.sol";
import { Vec3 } from "../../Vec3.sol";
import { Direction } from "../common.sol";

/**
 * @title IBuildSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IBuildSystem {
  function build(
    EntityId caller,
    ObjectTypeId buildObjectTypeId,
    Vec3 baseCoord,
    bytes calldata extraData
  ) external returns (EntityId);

  function buildWithDirection(
    EntityId caller,
    ObjectTypeId buildObjectTypeId,
    Vec3 baseCoord,
    Direction direction,
    bytes calldata extraData
  ) external returns (EntityId);

  function jumpBuildWithDirection(
    EntityId caller,
    ObjectTypeId buildObjectTypeId,
    Direction direction,
    bytes calldata extraData
  ) external;

  function jumpBuild(EntityId caller, ObjectTypeId buildObjectTypeId, bytes calldata extraData) external;
}
