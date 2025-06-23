// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { NoOptionsAvailable } from "../Errors.sol";

library RandomLib {
  // Simple weighted selection from an array of weights
  function selectByWeight(uint256[] memory weights, uint256 randomSeed) internal pure returns (uint256) {
    uint256 totalWeight = 0;
    for (uint256 i = 0; i < weights.length; i++) {
      totalWeight += weights[i];
    }

    if (totalWeight == 0) revert NoOptionsAvailable();

    // Select option based on weights
    uint256 randomValue = randomSeed % totalWeight;
    uint256 cumulativeWeight = 0;

    uint256 j = 0;
    for (; j < weights.length - 1; j++) {
      cumulativeWeight += weights[j];
      if (randomValue < cumulativeWeight) break;
    }

    return j;
  }

  // Adjusts pre-calculated weights based on resource availability
  function adjustWeights(uint256[] memory distribution, uint256 cap, uint256 remaining)
    internal
    pure
    returns (uint256[] memory weights)
  {
    uint8 maxAmount = uint8(distribution.length - 1);

    weights = new uint256[](distribution.length);

    weights[0] = distribution[0]; // Weight for 0 drops stays the same

    // For each non-zero option, apply compound probability adjustment
    for (uint8 i = 1; i <= maxAmount; i++) {
      if (remaining < i) {
        weights[i] = 0;
        continue;
      }

      // Calculate compound probability for getting i resources
      uint256 p = distribution[i];

      // Apply availability adjustment for each resource needed
      for (uint8 j = 0; j < i; j++) {
        p = p * (remaining - j) / (cap - j);
      }

      weights[i] = p;
    }
  }
}
