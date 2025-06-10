// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { EntityPosition, LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";

import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, Vec3Lib, vec3 } from "../src/types/Vec3.sol";

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

  function testVec3ToArray() public pure {
    Vec3 v = vec3(11, 22, 33);
    assertEq(v, vec3(11, 22, 33));
  }

  function testApplyOrientationIdentity() public pure {
    // Identity orientation: perm = [0,1,2], refl = [0,0,0], should be orientation 0
    Orientation o = Orientation.wrap(0);
    Vec3 v = vec3(1, 2, 3);
    Vec3 r = v.applyOrientation(o);
    assertEq(r, vec3(1, 2, 3));
  }

  function testApplyOrientationFlipX() public pure {
    // perm = [0,1,2], refl = [1,0,0] => orientation 1
    Orientation o = Orientation.wrap(1);
    Vec3 v = vec3(2, 3, 4);
    Vec3 r = v.applyOrientation(o);
    assertEq(r, vec3(-2, 3, 4));
  }

  function testApplyOrientationSwapYZ() public pure {
    // TODO: check
    // perm = [0,2,1], refl = [0,0,0] => orientation 2*8+0 = 16
    Orientation o = Orientation.wrap(16);
    Vec3 v = vec3(2, 3, 4);
    Vec3 r = v.applyOrientation(o);
    // perm [1,0,2] would give (y,x,z)
    assertEq(r, vec3(3, 2, 4));
  }

  function testGetRelativeCoordsPlayer() public pure {
    // Only orientation 0 is supported for Player (identity)
    Vec3 base = vec3(10, 20, 30);
    Vec3[] memory coords = ObjectTypes.Player.getRelativeCoords(base);
    assertEq(coords.length, 2, "Should have 2 coords (base + 1 offset)");

    assertEq(coords[0], vec3(10, 20, 30));
    assertEq(coords[1], vec3(10, 21, 30));
  }

  function testGetRelativeCoordsBedNegativeX() public pure {
    // Test for supported orientation == 1
    Vec3 base = vec3(5, 5, 5);
    Orientation o = Orientation.wrap(1);
    Vec3[] memory coords = ObjectTypes.Bed.getRelativeCoords(base, o);
    assertEq(coords.length, 2, "Should have 2 coords (base + 1 offset)");

    assertEq(coords[0], vec3(5, 5, 5));
    assertEq(coords[1], vec3(4, 5, 5));
  }

  function testGetRelativeCoordsBedNegativeZ() public pure {
    // Test for supported orientation == 44
    Vec3 base = vec3(7, 0, 0);
    Orientation o = Orientation.wrap(44);
    Vec3[] memory coords = ObjectTypes.Bed.getRelativeCoords(base, o);
    assertEq(coords.length, 2, "Should have 2 coords (base + 1 offset)");

    assertEq(coords[0], vec3(7, 0, 0));
    assertEq(coords[1], vec3(7, 0, -1));
  }

  /// forge-config: default.allow_internal_expect_revert = true
  function testOrientationUnsupportedSingleBlock() public {
    // Only supported orientation is 0 for now
    for (uint8 i = 1; i < 48; i++) {
      Orientation o = Orientation.wrap(i);
      vm.expectRevert("Orientation not supported");
      ObjectTypes.Dirt.getRelativeCoords(vec3(0, 0, 0), o);
    }
  }

  /// forge-config: default.allow_internal_expect_revert = true
  function testOrientationUnsupportedMultiBlockRevert() public {
    Orientation o = Orientation.wrap(20);
    vm.expectRevert("Orientation not supported");
    ObjectTypes.Bed.getRelativeCoords(vec3(0, 0, 0), o);
  }
}
