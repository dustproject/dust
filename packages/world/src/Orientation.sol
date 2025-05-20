// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

type Orientation is uint8;

function eq(Orientation self, Orientation other) pure returns (bool) {
  return Orientation.unwrap(self) == Orientation.unwrap(other);
}

using { eq as == } for Orientation global;
