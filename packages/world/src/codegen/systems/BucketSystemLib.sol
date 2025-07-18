// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { BucketSystem } from "../../systems/BucketSystem.sol";
import { EntityId } from "../../types/EntityId.sol";
import { Vec3 } from "../../types/Vec3.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type BucketSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "", name: "BucketSystem" }))
BucketSystemType constant bucketSystem = BucketSystemType.wrap(
  0x737900000000000000000000000000004275636b657453797374656d00000000
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
 * @title BucketSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library BucketSystemLib {
  error BucketSystemLib_CallingFromRootSystem();

  function fillBucket(BucketSystemType self, EntityId caller, Vec3 waterCoord, uint16 bucketSlot) internal {
    return CallWrapper(self.toResourceId(), address(0)).fillBucket(caller, waterCoord, bucketSlot);
  }

  function wetFarmland(BucketSystemType self, EntityId caller, Vec3 coord, uint16 bucketSlot) internal {
    return CallWrapper(self.toResourceId(), address(0)).wetFarmland(caller, coord, bucketSlot);
  }

  function fillBucket(CallWrapper memory self, EntityId caller, Vec3 waterCoord, uint16 bucketSlot) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert BucketSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _fillBucket_EntityId_Vec3_uint16.fillBucket,
      (caller, waterCoord, bucketSlot)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function wetFarmland(CallWrapper memory self, EntityId caller, Vec3 coord, uint16 bucketSlot) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert BucketSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _wetFarmland_EntityId_Vec3_uint16.wetFarmland,
      (caller, coord, bucketSlot)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function fillBucket(RootCallWrapper memory self, EntityId caller, Vec3 waterCoord, uint16 bucketSlot) internal {
    bytes memory systemCall = abi.encodeCall(
      _fillBucket_EntityId_Vec3_uint16.fillBucket,
      (caller, waterCoord, bucketSlot)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function wetFarmland(RootCallWrapper memory self, EntityId caller, Vec3 coord, uint16 bucketSlot) internal {
    bytes memory systemCall = abi.encodeCall(
      _wetFarmland_EntityId_Vec3_uint16.wetFarmland,
      (caller, coord, bucketSlot)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function callFrom(BucketSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(BucketSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(BucketSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(BucketSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(BucketSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (BucketSystemType) {
    return BucketSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(BucketSystemType self) internal view returns (address) {
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

interface _fillBucket_EntityId_Vec3_uint16 {
  function fillBucket(EntityId caller, Vec3 waterCoord, uint16 bucketSlot) external;
}

interface _wetFarmland_EntityId_Vec3_uint16 {
  function wetFarmland(EntityId caller, Vec3 coord, uint16 bucketSlot) external;
}

using BucketSystemLib for BucketSystemType global;
using BucketSystemLib for CallWrapper global;
using BucketSystemLib for RootCallWrapper global;
