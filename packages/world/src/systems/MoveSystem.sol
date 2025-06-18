// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Direction } from "../codegen/common.sol";
import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityId } from "../types/EntityId.sol";
import { Vec3 } from "../types/Vec3.sol";

import { MoveNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";
import { MoveLib } from "./libraries/MoveLib.sol";

contract MoveSystem is System {
  function move(EntityId caller, Vec3[] calldata newCoords) public {
    caller.activate();

    MoveLib.move(caller._getPosition(), newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }

  function moveDirections(EntityId caller, Direction[] calldata directions) public {
    caller.activate();

    Vec3 coord = caller._getPosition();

    Vec3[] memory newCoords = new Vec3[](directions.length);
    for (uint256 i = 0; i < directions.length; i++) {
      newCoords[i] = (i == 0 ? coord : newCoords[i - 1]).transform(directions[i]);
    }

    MoveLib.move(coord, newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }

  // 5 bits per direction, packed into a single uint256 (max 51 directions)
  function moveDirectionsPacked(EntityId caller, uint256 packedDirections, uint8 count) public {
    caller.activate();

    Vec3 coord = caller._getPosition();

    Vec3[] memory newCoords = new Vec3[](count);
    for (uint256 i = 0; i < count; i++) {
      Direction direction = Direction((packedDirections >> (i * 5)) & 0x1F);
      newCoords[i] = (i == 0 ? coord : newCoords[i - 1]).transform(direction);
    }

    MoveLib.move(coord, newCoords);

    notify(caller, MoveNotification({ moveCoords: newCoords }));
  }
}
