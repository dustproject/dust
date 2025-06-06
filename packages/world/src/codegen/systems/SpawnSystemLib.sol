// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { SpawnSystem } from "../../systems/SpawnSystem.sol";
import { Vec3 } from "../../Vec3.sol";
import { EntityId } from "../../EntityId.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type SpawnSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "", name: "SpawnSystem" }))
SpawnSystemType constant spawnSystem = SpawnSystemType.wrap(
  0x73790000000000000000000000000000537061776e53797374656d0000000000
);

struct CallWrapper {
  ResourceId systemId;
  address from;
}

struct RootCallWrapper {
  ResourceId systemId;
  address from;
}

/**
 * @title SpawnSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library SpawnSystemLib {
  error SpawnSystemLib_CallingFromRootSystem();

  function getAllRandomSpawnCoords(
    SpawnSystemType self,
    address sender
  ) internal view returns (Vec3[] memory spawnCoords, uint256[] memory blockNumbers) {
    return CallWrapper(self.toResourceId(), address(0)).getAllRandomSpawnCoords(sender);
  }

  function getRandomSpawnCoord(
    SpawnSystemType self,
    uint256 blockNumber,
    address sender
  ) internal view returns (Vec3 spawnCoord) {
    return CallWrapper(self.toResourceId(), address(0)).getRandomSpawnCoord(blockNumber, sender);
  }

  function isValidSpawn(SpawnSystemType self, Vec3 spawnCoord) internal view returns (bool) {
    return CallWrapper(self.toResourceId(), address(0)).isValidSpawn(spawnCoord);
  }

  function getValidSpawnY(SpawnSystemType self, Vec3 spawnCoordCandidate) internal view returns (Vec3 spawnCoord) {
    return CallWrapper(self.toResourceId(), address(0)).getValidSpawnY(spawnCoordCandidate);
  }

  function randomSpawn(SpawnSystemType self, uint256 blockNumber, int32 y) internal returns (EntityId) {
    return CallWrapper(self.toResourceId(), address(0)).randomSpawn(blockNumber, y);
  }

  function spawn(
    SpawnSystemType self,
    EntityId spawnTile,
    Vec3 spawnCoord,
    uint128 spawnEnergy,
    bytes memory extraData
  ) internal returns (EntityId) {
    return CallWrapper(self.toResourceId(), address(0)).spawn(spawnTile, spawnCoord, spawnEnergy, extraData);
  }

  function getAllRandomSpawnCoords(
    CallWrapper memory self,
    address sender
  ) internal view returns (Vec3[] memory spawnCoords, uint256[] memory blockNumbers) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_getAllRandomSpawnCoords_address.getAllRandomSpawnCoords, (sender));
    bytes memory worldCall = self.from == address(0)
      ? abi.encodeCall(IWorldCall.call, (self.systemId, systemCall))
      : abi.encodeCall(IWorldCall.callFrom, (self.from, self.systemId, systemCall));
    (bool success, bytes memory returnData) = address(_world()).staticcall(worldCall);
    if (!success) revertWithBytes(returnData);

    bytes memory result = abi.decode(returnData, (bytes));
    return abi.decode(result, (Vec3[], uint256[]));
  }

  function getRandomSpawnCoord(
    CallWrapper memory self,
    uint256 blockNumber,
    address sender
  ) internal view returns (Vec3 spawnCoord) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _getRandomSpawnCoord_uint256_address.getRandomSpawnCoord,
      (blockNumber, sender)
    );
    bytes memory worldCall = self.from == address(0)
      ? abi.encodeCall(IWorldCall.call, (self.systemId, systemCall))
      : abi.encodeCall(IWorldCall.callFrom, (self.from, self.systemId, systemCall));
    (bool success, bytes memory returnData) = address(_world()).staticcall(worldCall);
    if (!success) revertWithBytes(returnData);

    bytes memory result = abi.decode(returnData, (bytes));
    return abi.decode(result, (Vec3));
  }

  function isValidSpawn(CallWrapper memory self, Vec3 spawnCoord) internal view returns (bool) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_isValidSpawn_Vec3.isValidSpawn, (spawnCoord));
    bytes memory worldCall = self.from == address(0)
      ? abi.encodeCall(IWorldCall.call, (self.systemId, systemCall))
      : abi.encodeCall(IWorldCall.callFrom, (self.from, self.systemId, systemCall));
    (bool success, bytes memory returnData) = address(_world()).staticcall(worldCall);
    if (!success) revertWithBytes(returnData);

    bytes memory result = abi.decode(returnData, (bytes));
    return abi.decode(result, (bool));
  }

  function getValidSpawnY(CallWrapper memory self, Vec3 spawnCoordCandidate) internal view returns (Vec3 spawnCoord) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_getValidSpawnY_Vec3.getValidSpawnY, (spawnCoordCandidate));
    bytes memory worldCall = self.from == address(0)
      ? abi.encodeCall(IWorldCall.call, (self.systemId, systemCall))
      : abi.encodeCall(IWorldCall.callFrom, (self.from, self.systemId, systemCall));
    (bool success, bytes memory returnData) = address(_world()).staticcall(worldCall);
    if (!success) revertWithBytes(returnData);

    bytes memory result = abi.decode(returnData, (bytes));
    return abi.decode(result, (Vec3));
  }

  function randomSpawn(CallWrapper memory self, uint256 blockNumber, int32 y) internal returns (EntityId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_randomSpawn_uint256_int32.randomSpawn, (blockNumber, y));

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (EntityId));
  }

  function spawn(
    CallWrapper memory self,
    EntityId spawnTile,
    Vec3 spawnCoord,
    uint128 spawnEnergy,
    bytes memory extraData
  ) internal returns (EntityId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert SpawnSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _spawn_EntityId_Vec3_uint128_bytes.spawn,
      (spawnTile, spawnCoord, spawnEnergy, extraData)
    );

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (EntityId));
  }

  function randomSpawn(RootCallWrapper memory self, uint256 blockNumber, int32 y) internal returns (EntityId) {
    bytes memory systemCall = abi.encodeCall(_randomSpawn_uint256_int32.randomSpawn, (blockNumber, y));

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (EntityId));
  }

  function spawn(
    RootCallWrapper memory self,
    EntityId spawnTile,
    Vec3 spawnCoord,
    uint128 spawnEnergy,
    bytes memory extraData
  ) internal returns (EntityId) {
    bytes memory systemCall = abi.encodeCall(
      _spawn_EntityId_Vec3_uint128_bytes.spawn,
      (spawnTile, spawnCoord, spawnEnergy, extraData)
    );

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (EntityId));
  }

  function callFrom(SpawnSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(SpawnSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(SpawnSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(SpawnSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(SpawnSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (SpawnSystemType) {
    return SpawnSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(SpawnSystemType self) internal view returns (address) {
    return Systems.getSystem(self.toResourceId());
  }

  function _world() private view returns (IWorldCall) {
    return IWorldCall(StoreSwitch.getStoreAddress());
  }
}

/**
 * System Function Interfaces
 *
 * We generate an interface for each system function, which is then used for encoding system calls.
 * This is necessary to handle function overloading correctly (which abi.encodeCall cannot).
 *
 * Each interface is uniquely named based on the function name and parameters to prevent collisions.
 */

interface _getAllRandomSpawnCoords_address {
  function getAllRandomSpawnCoords(address sender) external;
}

interface _getRandomSpawnCoord_uint256_address {
  function getRandomSpawnCoord(uint256 blockNumber, address sender) external;
}

interface _isValidSpawn_Vec3 {
  function isValidSpawn(Vec3 spawnCoord) external;
}

interface _getValidSpawnY_Vec3 {
  function getValidSpawnY(Vec3 spawnCoordCandidate) external;
}

interface _randomSpawn_uint256_int32 {
  function randomSpawn(uint256 blockNumber, int32 y) external;
}

interface _spawn_EntityId_Vec3_uint128_bytes {
  function spawn(EntityId spawnTile, Vec3 spawnCoord, uint128 spawnEnergy, bytes memory extraData) external;
}

using SpawnSystemLib for SpawnSystemType global;
using SpawnSystemLib for CallWrapper global;
using SpawnSystemLib for RootCallWrapper global;
