// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Vec3 } from "../../Vec3.sol";
import { EntityId } from "../../EntityId.sol";

/**
 * @title ISpawnSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface ISpawnSystem {
  function getAllRandomSpawnCoords(
    address sender
  ) external view returns (Vec3[] memory spawnCoords, uint256[] memory blockNumbers);

  function getRandomSpawnCoord(uint256 blockNumber, address sender) external view returns (Vec3 spawnCoord);

  function isValidSpawn(Vec3 spawnCoord) external view returns (bool);

  function getValidSpawnY(Vec3 spawnCoordCandidate) external view returns (Vec3 spawnCoord);

  function randomSpawn(uint256 blockNumber, int32 y) external returns (EntityId);

  function spawn(EntityId spawnTile, Vec3 spawnCoord, bytes memory extraData) external returns (EntityId);
}
