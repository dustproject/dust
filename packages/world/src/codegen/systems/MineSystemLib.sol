// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { MineSystem } from "../../systems/MineSystem.sol";
import { Vec3 } from "../../Vec3.sol";
import { ObjectTypeId } from "../../ObjectTypeId.sol";
import { EntityId } from "../../EntityId.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type MineSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "", name: "MineSystem" }))
MineSystemType constant mineSystem = MineSystemType.wrap(
  0x737900000000000000000000000000004d696e6553797374656d000000000000
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
 * @title MineSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library MineSystemLib {
  error MineSystemLib_CallingFromRootSystem();

  function getRandomOreType(MineSystemType self, Vec3 coord) internal view returns (ObjectTypeId) {
    return CallWrapper(self.toResourceId(), address(0)).getRandomOreType(coord);
  }

  function mine(
    MineSystemType self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal returns (EntityId) {
    return CallWrapper(self.toResourceId(), address(0)).mine(caller, coord, toolSlot, extraData);
  }

  function mine(MineSystemType self, EntityId caller, Vec3 coord, bytes memory extraData) internal returns (EntityId) {
    return CallWrapper(self.toResourceId(), address(0)).mine(caller, coord, extraData);
  }

  function mineUntilDestroyed(
    MineSystemType self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal {
    return CallWrapper(self.toResourceId(), address(0)).mineUntilDestroyed(caller, coord, toolSlot, extraData);
  }

  function mineUntilDestroyed(MineSystemType self, EntityId caller, Vec3 coord, bytes memory extraData) internal {
    return CallWrapper(self.toResourceId(), address(0)).mineUntilDestroyed(caller, coord, extraData);
  }

  function _processEnergyReduction(
    MineSystemType self,
    EntityId caller,
    Vec3 callerCoord,
    EntityId mined,
    uint16 toolSlot
  ) internal returns (uint128, uint128) {
    return CallWrapper(self.toResourceId(), address(0))._processEnergyReduction(caller, callerCoord, mined, toolSlot);
  }

  function getRandomOreType(CallWrapper memory self, Vec3 coord) internal view returns (ObjectTypeId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_getRandomOreType_Vec3.getRandomOreType, (coord));
    bytes memory worldCall = self.from == address(0)
      ? abi.encodeCall(IWorldCall.call, (self.systemId, systemCall))
      : abi.encodeCall(IWorldCall.callFrom, (self.from, self.systemId, systemCall));
    (bool success, bytes memory returnData) = address(_world()).staticcall(worldCall);
    if (!success) revertWithBytes(returnData);

    bytes memory result = abi.decode(returnData, (bytes));
    return abi.decode(result, (ObjectTypeId));
  }

  function mine(
    CallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal returns (EntityId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _mine_EntityId_Vec3_uint16_bytes.mine,
      (caller, coord, toolSlot, extraData)
    );

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (EntityId));
  }

  function mine(
    CallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    bytes memory extraData
  ) internal returns (EntityId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_mine_EntityId_Vec3_bytes.mine, (caller, coord, extraData));

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (EntityId));
  }

  function mineUntilDestroyed(
    CallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _mineUntilDestroyed_EntityId_Vec3_uint16_bytes.mineUntilDestroyed,
      (caller, coord, toolSlot, extraData)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function mineUntilDestroyed(CallWrapper memory self, EntityId caller, Vec3 coord, bytes memory extraData) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _mineUntilDestroyed_EntityId_Vec3_bytes.mineUntilDestroyed,
      (caller, coord, extraData)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function _processEnergyReduction(
    CallWrapper memory self,
    EntityId caller,
    Vec3 callerCoord,
    EntityId mined,
    uint16 toolSlot
  ) internal returns (uint128, uint128) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert MineSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      __processEnergyReduction_EntityId_Vec3_EntityId_uint16._processEnergyReduction,
      (caller, callerCoord, mined, toolSlot)
    );

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (uint128, uint128));
  }

  function mine(
    RootCallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal returns (EntityId) {
    bytes memory systemCall = abi.encodeCall(
      _mine_EntityId_Vec3_uint16_bytes.mine,
      (caller, coord, toolSlot, extraData)
    );

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (EntityId));
  }

  function mine(
    RootCallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    bytes memory extraData
  ) internal returns (EntityId) {
    bytes memory systemCall = abi.encodeCall(_mine_EntityId_Vec3_bytes.mine, (caller, coord, extraData));

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (EntityId));
  }

  function mineUntilDestroyed(
    RootCallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    uint16 toolSlot,
    bytes memory extraData
  ) internal {
    bytes memory systemCall = abi.encodeCall(
      _mineUntilDestroyed_EntityId_Vec3_uint16_bytes.mineUntilDestroyed,
      (caller, coord, toolSlot, extraData)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function mineUntilDestroyed(
    RootCallWrapper memory self,
    EntityId caller,
    Vec3 coord,
    bytes memory extraData
  ) internal {
    bytes memory systemCall = abi.encodeCall(
      _mineUntilDestroyed_EntityId_Vec3_bytes.mineUntilDestroyed,
      (caller, coord, extraData)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function _processEnergyReduction(
    RootCallWrapper memory self,
    EntityId caller,
    Vec3 callerCoord,
    EntityId mined,
    uint16 toolSlot
  ) internal returns (uint128, uint128) {
    bytes memory systemCall = abi.encodeCall(
      __processEnergyReduction_EntityId_Vec3_EntityId_uint16._processEnergyReduction,
      (caller, callerCoord, mined, toolSlot)
    );

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (uint128, uint128));
  }

  function callFrom(MineSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(MineSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(MineSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(MineSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(MineSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (MineSystemType) {
    return MineSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(MineSystemType self) internal view returns (address) {
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

interface _getRandomOreType_Vec3 {
  function getRandomOreType(Vec3 coord) external;
}

interface _mine_EntityId_Vec3_uint16_bytes {
  function mine(EntityId caller, Vec3 coord, uint16 toolSlot, bytes memory extraData) external;
}

interface _mine_EntityId_Vec3_bytes {
  function mine(EntityId caller, Vec3 coord, bytes memory extraData) external;
}

interface _mineUntilDestroyed_EntityId_Vec3_uint16_bytes {
  function mineUntilDestroyed(EntityId caller, Vec3 coord, uint16 toolSlot, bytes memory extraData) external;
}

interface _mineUntilDestroyed_EntityId_Vec3_bytes {
  function mineUntilDestroyed(EntityId caller, Vec3 coord, bytes memory extraData) external;
}

interface __processEnergyReduction_EntityId_Vec3_EntityId_uint16 {
  function _processEnergyReduction(EntityId caller, Vec3 callerCoord, EntityId mined, uint16 toolSlot) external;
}

using MineSystemLib for MineSystemType global;
using MineSystemLib for CallWrapper global;
using MineSystemLib for RootCallWrapper global;
