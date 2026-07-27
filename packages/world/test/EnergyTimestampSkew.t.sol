// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest } from "./DustTest.sol";

import { Energy } from "../src/codegen/tables/Energy.sol";
import { EntityId } from "../src/types/EntityId.sol";

/**
 * Energy math when stored state is ahead of `block.timestamp`.
 *
 * `getLatestEnergyData` used to open with a bare
 *
 *   uint128 timeSinceLastUpdate = uint128(block.timestamp) - energyData.lastUpdatedTime;
 *
 * which assumes `lastUpdatedTime <= block.timestamp`. That holds for a landed
 * transaction, but not for `eth_call`/`eth_estimateGas` at `pending` on a chain
 * that builds sub-blocks: the pending *state* can already hold a write stamped
 * with a newer block's timestamp while the simulated header still carries the
 * older one. The subtraction then underflowed and the call failed with panic
 * 0x11 rather than a clean revert.
 *
 * On Base Sepolia this showed up as bursts of estimates failing with
 * "panic: arithmetic underflow or overflow (0x11)" that succeeded on retry a
 * block later -- invisible in play, but a panic means an unguarded subtraction
 * rather than an intended revert.
 */
contract EnergyTimestampSkewTest is DustTest {
  function testEnergyDoesNotUnderflowWhenStateIsAheadOfBlockTimestamp() public {
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    uint128 energyBefore = Energy.getEnergy(aliceEntityId);

    // Stored state one block ahead of the header we execute against -- exactly
    // what a `pending` estimate sees mid sub-block.
    Energy.setLastUpdatedTime(aliceEntityId, uint128(block.timestamp + 2));

    vm.prank(alice);
    world.activate(aliceEntityId);

    assertEq(Energy.getEnergy(aliceEntityId), energyBefore, "Energy should not drain when state is ahead");
  }

  function testNoUnderflowWhenStateMatchesBlockTimestamp() public {
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    Energy.setLastUpdatedTime(aliceEntityId, uint128(block.timestamp));

    vm.prank(alice);
    world.activate(aliceEntityId);
  }
}
