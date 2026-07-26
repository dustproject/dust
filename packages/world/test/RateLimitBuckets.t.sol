// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest } from "./DustTest.sol";

import { RATE_LIMIT_TIME_INTERVAL } from "../src/Constants.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";
import { EntityPosition } from "../src/utils/Vec3Storage.sol";

/**
 * Actions repeated across a rate-limit bucket boundary.
 *
 * Every other gas test in the suite runs inside a single `block.timestamp`, so
 * they all pay the cost of writing the *first* record of a rate-limit bucket and
 * never the cost of the second. `RateLimitUnits` buckets on
 * `timestamp - (timestamp % RATE_LIMIT_TIME_INTERVAL)`, and the interval is 2
 * seconds — one Base block — so continuous play is almost entirely the case the
 * suite does not cover.
 *
 * Each test below reports the same action twice: once in a fresh bucket, once in
 * the next one. The pairs are not redundant; the second row is what a player
 * actually pays, move after move, for as long as they keep playing.
 */
contract RateLimitBucketsTest is DustTest {
  function testMoveAcrossBucketBoundary() public {
    (address alice,,) = setupFlatChunkWithPlayer();
    EntityId aliceEntityId = EntityTypeLib.encodePlayer(alice);
    Vec3 start = EntityPosition.get(aliceEntityId);

    // A straight walkable run, one cell per bucket.
    Vec3[] memory hops = new Vec3[](2);
    for (uint256 i = 0; i < hops.length; i++) {
      hops[i] = start + vec3(0, 0, int32(uint32(i)) + 1);
      setObjectAtCoord(hops[i], ObjectTypes.Air);
      setObjectAtCoord(hops[i] + vec3(0, 1, 0), ObjectTypes.Air);
      setObjectAtCoord(hops[i] - vec3(0, 1, 0), ObjectTypes.Grass);
    }

    Vec3[] memory path = new Vec3[](1);

    path[0] = hops[0];
    vm.prank(alice);
    startGasReport("move 1 block, first rate limit bucket");
    world.move(aliceEntityId, path);
    endGasReport();

    vm.warp(block.timestamp + RATE_LIMIT_TIME_INTERVAL);

    path[0] = hops[1];
    vm.prank(alice);
    startGasReport("move 1 block, later bucket (steady state)");
    world.move(aliceEntityId, path);
    endGasReport();

    assertEq(EntityPosition.get(aliceEntityId), hops[1], "Player did not walk both hops");
  }

  function testMineAcrossBucketBoundary() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Two blocks either side of the player, both mineable in a single hit.
    Vec3[] memory mineCoords = new Vec3[](2);
    mineCoords[0] = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    mineCoords[1] = vec3(playerCoord.x() - 1, FLAT_CHUNK_GRASS_LEVEL, playerCoord.z());
    for (uint256 i = 0; i < mineCoords.length; i++) {
      ObjectType mineObjectType = TerrainLib.getBlockType(mineCoords[i]);
      ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    }

    vm.prank(alice);
    startGasReport("mine terrain with hand, first rate limit bucket");
    world.mine(aliceEntityId, mineCoords[0], "");
    endGasReport();

    vm.warp(block.timestamp + RATE_LIMIT_TIME_INTERVAL);

    vm.prank(alice);
    startGasReport("mine terrain with hand, later bucket (steady state)");
    world.mine(aliceEntityId, mineCoords[1], "");
    endGasReport();
  }
}
