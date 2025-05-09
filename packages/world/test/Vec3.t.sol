// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool, ReverseTerrainPosition } from "../src/utils/Vec3Storage.sol";

import { EntityId } from "../src/EntityId.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

contract Vec3Test is DustTest {
  function testVec3Encoding() public pure {
    Vec3 vec = vec3(1, 2, 3);
    assertEq(vec.x(), 1);
    assertEq(vec.y(), 2);
    assertEq(vec.z(), 3);

    vec = vec3(-1, -2, -3);
    assertEq(vec.x(), -1);
    assertEq(vec.y(), -2);
    assertEq(vec.z(), -3);
  }

  function testVec3ToEntity() public {
    EntityId entityId = randomEntityId();

    Vec3 vec = vec3(1, 2, 3);
    EntityPosition.set(entityId, vec);
    Vec3 stored = EntityPosition.get(entityId);
    assertEq(vec, stored, "Vec3s do not match");

    vec = vec3(-1, -2, -3);
    EntityPosition.set(entityId, vec);
    stored = EntityPosition.get(entityId);
    assertEq(vec, stored, "Vec3s do not match");
  }

  function testUint128ToVec3() public {
    Vec3 vec = vec3(1, 2, 3);
    uint128 value = 123;
    LocalEnergyPool.set(vec, value);
    uint128 storedValue = LocalEnergyPool.get(vec);
    assertEq(value, storedValue, "Values do not match");
  }
}
