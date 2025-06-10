// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Direction } from "../codegen/common.sol";
import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityId } from "../types/EntityId.sol";
import { Vec3 } from "../types/Vec3.sol";

import { MoveLib } from "../utils/MoveLib.sol";
import { MoveNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

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
}
