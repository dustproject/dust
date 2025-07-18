// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { NatureSystem } from "../../systems/NatureSystem.sol";
import { EntityId } from "../../types/EntityId.sol";
import { Vec3 } from "../../types/Vec3.sol";
import { ObjectType } from "../../types/ObjectType.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type NatureSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "", name: "NatureSystem" }))
NatureSystemType constant natureSystem = NatureSystemType.wrap(
  0x737900000000000000000000000000004e617475726553797374656d00000000
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
 * @title NatureSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library NatureSystemLib {
  error NatureSystemLib_CallingFromRootSystem();

  function chunkCommit(NatureSystemType self, EntityId caller, Vec3 chunkCoord) internal {
    return CallWrapper(self.toResourceId(), address(0)).chunkCommit(caller, chunkCoord);
  }

  function respawnResource(NatureSystemType self, uint256 blockNumber, ObjectType resourceType) internal {
    return CallWrapper(self.toResourceId(), address(0)).respawnResource(blockNumber, resourceType);
  }

  function growSeed(NatureSystemType self, EntityId caller, Vec3 coord) internal {
    return CallWrapper(self.toResourceId(), address(0)).growSeed(caller, coord);
  }

  function chunkCommit(CallWrapper memory self, EntityId caller, Vec3 chunkCoord) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert NatureSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_chunkCommit_EntityId_Vec3.chunkCommit, (caller, chunkCoord));
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function respawnResource(CallWrapper memory self, uint256 blockNumber, ObjectType resourceType) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert NatureSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _respawnResource_uint256_ObjectType.respawnResource,
      (blockNumber, resourceType)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function growSeed(CallWrapper memory self, EntityId caller, Vec3 coord) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert NatureSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_growSeed_EntityId_Vec3.growSeed, (caller, coord));
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function chunkCommit(RootCallWrapper memory self, EntityId caller, Vec3 chunkCoord) internal {
    bytes memory systemCall = abi.encodeCall(_chunkCommit_EntityId_Vec3.chunkCommit, (caller, chunkCoord));
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function respawnResource(RootCallWrapper memory self, uint256 blockNumber, ObjectType resourceType) internal {
    bytes memory systemCall = abi.encodeCall(
      _respawnResource_uint256_ObjectType.respawnResource,
      (blockNumber, resourceType)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function growSeed(RootCallWrapper memory self, EntityId caller, Vec3 coord) internal {
    bytes memory systemCall = abi.encodeCall(_growSeed_EntityId_Vec3.growSeed, (caller, coord));
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function callFrom(NatureSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(NatureSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(NatureSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(NatureSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(NatureSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (NatureSystemType) {
    return NatureSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(NatureSystemType self) internal view returns (address) {
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

interface _chunkCommit_EntityId_Vec3 {
  function chunkCommit(EntityId caller, Vec3 chunkCoord) external;
}

interface _respawnResource_uint256_ObjectType {
  function respawnResource(uint256 blockNumber, ObjectType resourceType) external;
}

interface _growSeed_EntityId_Vec3 {
  function growSeed(EntityId caller, Vec3 coord) external;
}

using NatureSystemLib for NatureSystemType global;
using NatureSystemLib for CallWrapper global;
using NatureSystemLib for RootCallWrapper global;
