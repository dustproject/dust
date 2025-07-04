// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibString } from "solady/utils/LibString.sol";
import { SafeCastLib } from "solady/utils/SafeCastLib.sol";

import { CHUNK_SIZE, FRAGMENT_SIZE, REGION_SIZE } from "../Constants.sol";

import { Direction } from "../codegen/common.sol";
import { Orientation } from "./Orientation.sol";

import { Math } from "../utils/Math.sol";

// Vec3 stores 3 packed int32 values (x, y, z)
type Vec3 is uint96;

function vec3(int32 _x, int32 _y, int32 _z) pure returns (Vec3 v) {
  // Pack 3 int32 values into a single uint96
  assembly {
    v := or(or(shl(64, and(_x, 0xffffffff)), shl(32, and(_y, 0xffffffff))), and(_z, 0xffffffff))
  }
}

function eq(Vec3 a, Vec3 b) pure returns (bool) {
  return a.unwrap() == b.unwrap();
}

function neq(Vec3 a, Vec3 b) pure returns (bool) {
  return a.unwrap() != b.unwrap();
}

function lt(Vec3 a, Vec3 b) pure returns (bool) {
  (int32 minX, int32 minY, int32 minZ) = a.xyz();
  (int32 maxX, int32 maxY, int32 maxZ) = b.xyz();
  return minX < maxX && minY < maxY && minZ < maxZ;
}

function leq(Vec3 a, Vec3 b) pure returns (bool) {
  (int32 minX, int32 minY, int32 minZ) = a.xyz();
  (int32 maxX, int32 maxY, int32 maxZ) = b.xyz();
  return minX <= maxX && minY <= maxY && minZ <= maxZ;
}

function add(Vec3 a, Vec3 b) pure returns (Vec3) {
  (int32 ax, int32 ay, int32 az) = a.xyz();
  (int32 bx, int32 by, int32 bz) = b.xyz();
  return vec3(ax + bx, ay + by, az + bz);
}

function sub(Vec3 a, Vec3 b) pure returns (Vec3) {
  (int32 ax, int32 ay, int32 az) = a.xyz();
  (int32 bx, int32 by, int32 bz) = b.xyz();
  return vec3(ax - bx, ay - by, az - bz);
}

function getDirectionVector(Direction direction) pure returns (Vec3) {
  if (direction == Direction.PositiveX) return vec3(1, 0, 0);
  if (direction == Direction.NegativeX) return vec3(-1, 0, 0);
  if (direction == Direction.PositiveY) return vec3(0, 1, 0);
  if (direction == Direction.NegativeY) return vec3(0, -1, 0);
  if (direction == Direction.PositiveZ) return vec3(0, 0, 1);
  if (direction == Direction.NegativeZ) return vec3(0, 0, -1);

  if (direction == Direction.PositiveXPositiveY) return vec3(1, 1, 0);
  if (direction == Direction.PositiveXNegativeY) return vec3(1, -1, 0);
  if (direction == Direction.NegativeXPositiveY) return vec3(-1, 1, 0);
  if (direction == Direction.NegativeXNegativeY) return vec3(-1, -1, 0);

  if (direction == Direction.PositiveXPositiveZ) return vec3(1, 0, 1);
  if (direction == Direction.PositiveXNegativeZ) return vec3(1, 0, -1);
  if (direction == Direction.NegativeXPositiveZ) return vec3(-1, 0, 1);
  if (direction == Direction.NegativeXNegativeZ) return vec3(-1, 0, -1);

  if (direction == Direction.PositiveYPositiveZ) return vec3(0, 1, 1);
  if (direction == Direction.PositiveYNegativeZ) return vec3(0, 1, -1);
  if (direction == Direction.NegativeYPositiveZ) return vec3(0, -1, 1);
  if (direction == Direction.NegativeYNegativeZ) return vec3(0, -1, -1);

  if (direction == Direction.PositiveXPositiveYPositiveZ) return vec3(1, 1, 1);
  if (direction == Direction.PositiveXPositiveYNegativeZ) return vec3(1, 1, -1);
  if (direction == Direction.PositiveXNegativeYPositiveZ) return vec3(1, -1, 1);
  if (direction == Direction.PositiveXNegativeYNegativeZ) return vec3(1, -1, -1);
  if (direction == Direction.NegativeXPositiveYPositiveZ) return vec3(-1, 1, 1);
  if (direction == Direction.NegativeXPositiveYNegativeZ) return vec3(-1, 1, -1);
  if (direction == Direction.NegativeXNegativeYPositiveZ) return vec3(-1, -1, 1);
  if (direction == Direction.NegativeXNegativeYNegativeZ) return vec3(-1, -1, -1);

  revert("Invalid direction");
}

library Vec3Lib {
  using LibString for *;
  using SafeCastLib for *;
  using Math for *;

  function unwrap(Vec3 self) internal pure returns (uint96) {
    return Vec3.unwrap(self);
  }

  function x(Vec3 self) internal pure returns (int32 r) {
    assembly {
      r := signextend(3, shr(64, self))
    }
  }

  function y(Vec3 self) internal pure returns (int32 r) {
    assembly {
      r := signextend(3, shr(32, self))
    }
  }

  function z(Vec3 self) internal pure returns (int32 r) {
    assembly {
      r := signextend(3, self)
    }
  }

  function xyz(Vec3 self) internal pure returns (int32 x_, int32 y_, int32 z_) {
    assembly {
      // sign-extend the top 96−32 = 64 bits, then shift down
      x_ := signextend(3, shr(64, self))
      y_ := signextend(3, shr(32, self))
      z_ := signextend(3, self)
    }
  }

  function toArray(Vec3 self) internal pure returns (int32[3] memory) {
    int32[3] memory arr;
    (arr[0], arr[1], arr[2]) = self.xyz();
    return arr;
  }

  function mul(Vec3 a, int32 scalar) internal pure returns (Vec3) {
    return vec3(x(a) * scalar, y(a) * scalar, z(a) * scalar);
  }

  function mul(Vec3 a, uint256 scalar) internal pure returns (Vec3) {
    return a.mul(scalar.toInt32());
  }

  function div(Vec3 a, int32 scalar) internal pure returns (Vec3) {
    require(scalar != 0, "Division by zero");
    (int32 ax, int32 ay, int32 az) = a.xyz();
    return vec3(ax / scalar, ay / scalar, az / scalar);
  }

  function div(Vec3 a, uint256 scalar) internal pure returns (Vec3) {
    require(scalar != 0, "Division by zero");
    return a.div(scalar.toInt32());
  }

  function mod(Vec3 a, int32 scalar) internal pure returns (Vec3) {
    (int32 ax, int32 ay, int32 az) = a.xyz();
    return vec3(_mod(ax, scalar), _mod(ay, scalar), _mod(az, scalar));
  }

  function floorDiv(Vec3 a, int32 divisor) internal pure returns (Vec3) {
    require(divisor != 0, "Division by zero");

    (int32 ax, int32 ay, int32 az) = a.xyz();
    return vec3(_floorDiv(ax, divisor), _floorDiv(ay, divisor), _floorDiv(az, divisor));
  }

  function neg(Vec3 a) internal pure returns (Vec3) {
    (int32 ax, int32 ay, int32 az) = a.xyz();
    return vec3(-ax, -ay, -az);
  }

  function manhattanDistance(Vec3 a, Vec3 b) internal pure returns (uint256) {
    (int32 ax, int32 ay, int32 az) = a.xyz();
    (int32 bx, int32 by, int32 bz) = b.xyz();
    return ax.dist(bx) + ay.dist(by) + az.dist(bz);
  }

  function chebyshevDistance(Vec3 a, Vec3 b) internal pure returns (uint256) {
    (int32 ax, int32 ay, int32 az) = a.xyz();
    (int32 bx, int32 by, int32 bz) = b.xyz();

    return Math.max(ax.dist(bx), ay.dist(by), az.dist(bz));
  }

  function absDelta(Vec3 a, Vec3 b) internal pure returns (uint64, uint64, uint64) {
    (int32 ax, int32 ay, int32 az) = a.xyz();
    (int32 bx, int32 by, int32 bz) = b.xyz();

    return (uint64(ax.dist(bx)), uint64(ay.dist(by)), uint64(az.dist(bz)));
  }

  function clamp(Vec3 self, Vec3 min, Vec3 max) internal pure returns (Vec3) {
    if (self < min) return min;
    if (max < self) return max;
    return self;
  }

  function getNeighbor(Vec3 self, Direction direction) internal pure returns (Vec3) {
    return self + getDirectionVector(direction);
  }

  function neighbors6(Vec3 a) internal pure returns (Vec3[6] memory) {
    Vec3[6] memory result;

    // Positive and negative directions along each axis
    for (uint8 i = 0; i < 6; i++) {
      result[i] = a.getNeighbor(Direction(i));
    }

    return result;
  }

  function neighbors26(Vec3 a) internal pure returns (Vec3[26] memory) {
    Vec3[26] memory result;

    // Generate all neighbors in a 3x3x3 cube, excluding the center
    for (uint8 i = 0; i < 26; i++) {
      result[i] = a.getNeighbor(Direction(i));
    }

    return result;
  }

  function applyOrientation(Vec3 v, Orientation orientation) internal pure returns (Vec3) {
    (uint8 a, uint8 b, uint8 c) = orientation.getPermutation();
    (bool rx, bool ry, bool rz) = orientation.getReflection();

    int32[3] memory arr = v.toArray();

    (int32 nx, int32 ny, int32 nz) = (arr[a], arr[b], arr[c]);

    if (rx) nx = -nx;
    if (ry) ny = -ny;
    if (rz) nz = -nz;

    return vec3(nx, ny, nz);
  }

  function inSurroundingCube(Vec3 self, Vec3 other, uint256 radius) internal pure returns (bool) {
    return chebyshevDistance(self, other) <= radius;
  }

  function inSphere(Vec3 self, Vec3 other, uint256 radius) internal pure returns (bool) {
    Vec3 d = other - self;
    // TODO: should probably use direct subtraction of components to avoid overflow issues
    return uint256(int256(d.x()) ** 2 + int256(d.y()) ** 2 + int256(d.z()) ** 2) <= radius * radius;
  }

  // Function to get the new Vec3 based on the direction
  function transform(Vec3 self, Direction direction) internal pure returns (Vec3) {
    return self + getDirectionVector(direction);
  }

  function inVonNeumannNeighborhood(Vec3 center, Vec3 checkCoord) internal pure returns (bool) {
    return center.manhattanDistance(checkCoord) == 1;
  }

  function toChunkCoord(Vec3 self) internal pure returns (Vec3) {
    return self.floorDiv(CHUNK_SIZE);
  }

  function toFragmentCoord(Vec3 self) internal pure returns (Vec3) {
    return self.floorDiv(FRAGMENT_SIZE);
  }

  function fromFragmentCoord(Vec3 self) internal pure returns (Vec3) {
    return self.mul(FRAGMENT_SIZE);
  }

  // Note: Local Energy Pool shards are 2D for now, but the table supports 3D
  // Thats why the Y is ignored, and 0 in the util functions
  function toLocalEnergyPoolShardCoord(Vec3 coord) internal pure returns (Vec3) {
    return vec3(_floorDiv(coord.x(), REGION_SIZE), int32(0), _floorDiv(coord.z(), REGION_SIZE));
  }

  function toString(Vec3 a) internal pure returns (string memory) {
    return string(abi.encodePacked("(", x(a).toString(), ",", y(a).toString(), ",", z(a).toString(), ")"));
  }

  // ======== Helper Functions ========

  // Floor division (integer division that rounds down)
  function _floorDiv(int32 a, int32 b) private pure returns (int32) {
    require(b != 0, "Division by zero");

    // Handle special case for negative numbers
    if ((a < 0) != (b < 0) && a % b != 0) {
      return a / b - 1;
    }

    return a / b;
  }

  // The `%` operator in Solidity is not a modulo operator, it's a remainder operator, which behaves differently for negative numbers.
  function _mod(int32 a, int32 b) private pure returns (int32) {
    return ((a % b) + b) % b;
  }
}

using Vec3Lib for Vec3 global;
using { eq as ==, neq as !=, add as +, sub as -, leq as <=, lt as < } for Vec3 global;
