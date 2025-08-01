// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Direction } from "../codegen/common.sol";

import { EntityId } from "../types/EntityId.sol";
import { Vec3 } from "../types/Vec3.sol";

import { MoveNotification, notify } from "../utils/NotifUtils.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

contract MoveSystem is System {
  function move(EntityId caller, Vec3[] memory newCoords) public {
    caller.activate();

    MoveLib.move(caller._getPosition(), newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }

  function moveDirections(EntityId caller, Direction[] memory directions) public {
    caller.activate();

    Vec3 coord = caller._getPosition();

    Vec3[] memory newCoords = new Vec3[](directions.length);
    for (uint256 i = 0; i < directions.length; i++) {
      newCoords[i] = (i == 0 ? coord : newCoords[i - 1]).transform(directions[i]);
    }

    MoveLib.move(coord, newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }

  // 6 bits for count, 5 bits per direction, packed into a single uint256 (max 50 directions)
  function moveDirectionsPacked(EntityId caller, uint256 packed) public {
    caller.activate();

    // Extract count (top 6 bits)
    uint8 count = uint8(packed >> 250);
    require(count <= 50, "Too many directions packed");

    // Extract packedDirections (bottom 250 bits)
    uint256 packedDirections = packed & ((1 << 250) - 1);

    Vec3 coord = caller._getPosition();
    Vec3[] memory newCoords = new Vec3[](count);

    Vec3 prev = coord;
    for (uint256 i = 0; i < count; ++i) {
      Direction direction = Direction((packedDirections >> (i * 5)) & 0x1F);
      prev = prev.transform(direction);
      newCoords[i] = prev;
    }

    MoveLib.move(coord, newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }
}
