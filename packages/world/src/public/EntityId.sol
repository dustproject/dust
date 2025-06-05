// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId as RootEntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { Vec3 } from "../Vec3.sol";

type EntityId is bytes32;

/// @title Public EntityId Interface
/// @notice Safe public interface for EntityId operations that user programs can use
/// @dev This only exposes read-only operations that are safe for user programs
library PublicEntityId {
  /// @notice Check if two EntityIds are equal
  function equals(EntityId self, EntityId other) internal pure returns (bool) {
    return self == other;
  }

  /// @notice Check if an entity exists in the world
  function exists(EntityId self) internal view returns (bool) {
    return self.exists();
  }

  /// @notice Get the object type of an entity
  function getObjectType(EntityId self) internal view returns (ObjectType) {
    return self.getObjectType();
  }

  /// @notice Get the position of an entity
  function getPosition(EntityId self) internal view returns (Vec3) {
    return self.getPosition();
  }

  /// @notice Get the player address from a player entity
  function getPlayerAddress(EntityId self) internal pure returns (address) {
    return self.getPlayerAddress();
  }
}
