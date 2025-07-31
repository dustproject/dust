// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { ActivityType } from "../src/codegen/common.sol";
import { PlayerActivity } from "../src/codegen/tables/PlayerActivity.sol";
import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";

import { PlayerActivityUtils } from "../src/utils/PlayerActivityUtils.sol";

import { DustTest } from "./DustTest.sol";

import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";
import { EntityPosition, ReverseMovablePosition } from "../src/utils/Vec3Storage.sol";

import {
  LAVA_MOVE_ENERGY_COST,
  MAX_FLUID_LEVEL,
  MAX_PLAYER_GLIDES,
  MAX_PLAYER_JUMPS,
  MOVE_ENERGY_COST,
  PLAYER_ENERGY_DRAIN_RATE,
  PLAYER_FALL_ENERGY_COST,
  PLAYER_LAVA_ENERGY_DRAIN_RATE,
  PLAYER_SAFE_FALL_DISTANCE,
  PLAYER_SWIM_ENERGY_DRAIN_RATE
} from "../src/Constants.sol";
import { ObjectType } from "../src/types/ObjectType.sol";

import { ObjectTypes } from "../src/types/ObjectType.sol";

import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { NonPassableBlock } from "../src/systems/libraries/MoveLib.sol";
import { TestEntityUtils, TestInventoryUtils, TestPlayerActivityUtils } from "./utils/TestUtils.sol";

import { Direction } from "../src/codegen/common.sol";

contract MoveTest is DustTest {
  function _testMoveMultipleBlocks(address player, uint8 numBlocksToMove, bool overTerrain) internal {
    EntityId playerEntityId = EntityTypeLib.encodePlayer(player);
    Vec3 startingCoord = EntityPosition.get(playerEntityId);
    Vec3[] memory newCoords = new Vec3[](numBlocksToMove);
    for (uint32 i = 0; i < numBlocksToMove; i++) {
      newCoords[i] = startingCoord + vec3(0, 0, int32(i) + 1);

      Vec3 belowCoord = newCoords[i] - vec3(0, 1, 0);
      Vec3 aboveCoord = newCoords[i] + vec3(0, 1, 0);
      if (overTerrain) {
        setTerrainAtCoord(newCoords[i], ObjectTypes.Air);
        setTerrainAtCoord(aboveCoord, ObjectTypes.Air);
        setTerrainAtCoord(belowCoord, ObjectTypes.Grass);
      } else {
        setObjectAtCoord(newCoords[i], ObjectTypes.Air);
        setObjectAtCoord(aboveCoord, ObjectTypes.Air);
        setObjectAtCoord(belowCoord, ObjectTypes.Grass);
      }
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(playerEntityId);

    vm.prank(player);
    startGasReport(
      string.concat("move ", Strings.toString(numBlocksToMove), " blocks ", overTerrain ? "terrain" : "non-terrain")
    );
    world.move(playerEntityId, newCoords);
    endGasReport();

    Vec3 finalCoord = EntityPosition.get(playerEntityId);
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(finalCoord, newCoords[numBlocksToMove - 1], "Player did not move to the correct coord");
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), playerEntityId, "Above coord is not the player"
    );
    assertEq(EntityId.unwrap(ReverseMovablePosition.get(startingCoord)), bytes32(0), "Player position was not deleted");
    assertEq(
      EntityId.unwrap(ReverseMovablePosition.get(startingCoord)), bytes32(0), "Above starting coord is not the player"
    );

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);

    // Check player activity tracking - all moves should be walk steps
    uint256 walkSteps = TestPlayerActivityUtils.getActivityValue(playerEntityId, ActivityType.MoveWalkSteps);
    assertEq(walkSteps, numBlocksToMove, "Walk steps activity not tracked correctly");

    // Should have no swim steps
    uint256 swimSteps = TestPlayerActivityUtils.getActivityValue(playerEntityId, ActivityType.MoveSwimSteps);
    assertEq(swimSteps, 0, "Swim steps should be zero");
  }

  function testMoveOneBlockTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 1, true);
  }

  function testMoveOneBlockNonTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 1, false);
  }

  function testMoveFiveBlocksTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 5, true);
  }

  function testMoveFiveBlocksNonTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 5, false);
  }

  function testMoveTenBlocksTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 10, true);
  }

  function testMoveTenBlocksNonTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 10, false);
  }

  function testMoveMaxBlocksTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 24, true);
  }

  function testMoveMaxBlocksNonTerrain() public {
    (address alice,,) = setupAirChunkWithPlayer();
    _testMoveMultipleBlocks(alice, 24, false);
  }

  function testMoveOverLava() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);

    for (uint8 i = 0; i < newCoords.length; i++) {
      setObjectAtCoord(newCoords[i] - vec3(0, 1, 0), ObjectTypes.Lava);
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);
    vm.prank(alice);
    startGasReport("move over lava");
    world.move(aliceEntityId, newCoords);
    endGasReport();
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, newCoords[newCoords.length - 1], "Player did not move to new coords");

    uint128 energyLost = assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(LAVA_MOVE_ENERGY_COST * newCoords.length, energyLost, "Player energy lost is not equal to lava move cost");

    assertEq(Energy.getDrainRate(aliceEntityId), PLAYER_LAVA_ENERGY_DRAIN_RATE, "Player drain rate is not correct");

    newCoords = new Vec3[](1);
    newCoords[0] = finalCoord + vec3(0, 0, 1);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Drain rate should go back to normal
    assertEq(Energy.getDrainRate(aliceEntityId), PLAYER_ENERGY_DRAIN_RATE, "Player drain rate was not restored");
  }

  function testDrainRateUpdateSwimming() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](1);
    newCoords[0] = playerCoord + vec3(0, 0, 1);

    setObjectAtCoord(newCoords[0] + vec3(0, 1, 0), ObjectTypes.Water);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Expect the player to be in water and have a different drain rate
    assertEq(Energy.getDrainRate(aliceEntityId), PLAYER_SWIM_ENERGY_DRAIN_RATE, "Player drain rate is not correct");

    newCoords[0] = newCoords[0] + vec3(0, 0, 1);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Drain rate should go back to normal
    assertEq(Energy.getDrainRate(aliceEntityId), PLAYER_ENERGY_DRAIN_RATE, "Player drain rate was not restored");
  }

  function testMoveJump() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint256 numJumps = 1;
    Vec3[] memory newCoords = new Vec3[](numJumps);
    for (uint32 i = 0; i < numJumps; i++) {
      newCoords[i] = playerCoord + vec3(0, int32(i) + 1, 0);
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    startGasReport("move single jump");
    world.move(aliceEntityId, newCoords);
    endGasReport();

    // Expect the player to fall down back to the original coord
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, playerCoord, "Player did not fall back to the original coord");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveGlide() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint256 numGlides = 2;
    Vec3[] memory newCoords = new Vec3[](numGlides + 1);
    for (uint32 i = 0; i < newCoords.length; i++) {
      newCoords[i] = playerCoord + vec3(0, 1, int32(int256(uint256(i))));
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }
    Vec3 expectedFinalCoord = playerCoord + vec3(0, 0, int32(int256(numGlides)));
    setObjectAtCoord(expectedFinalCoord - vec3(0, 1, 0), ObjectTypes.Grass);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Expect the player to fall down back after the last block
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, expectedFinalCoord, "Player did not move to new coords");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveDiagonalDownIsNotFall() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // 4 diagonal moves down
    Vec3[] memory newCoords = new Vec3[](4);
    newCoords[0] = playerCoord + vec3(1, -1, 0);
    newCoords[1] = newCoords[0] + vec3(1, -1, 0);
    newCoords[2] = newCoords[1] + vec3(1, -1, 0);
    newCoords[3] = newCoords[2] + vec3(1, -1, 0);

    // Set grass below the new path
    for (uint8 i = 0; i < newCoords.length; i++) {
      setObjectAtCoord(newCoords[i] - vec3(0, 1, 0), ObjectTypes.Grass);
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Expect the player to be above the grass
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, newCoords[3], "Player did not move to the grass coord");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    uint128 playerEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(playerEnergyLost, MOVE_ENERGY_COST * newCoords.length, "Player energy lost is not equal to path length");
  }

  function testMoveFallWithoutDamage() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint32 numFalls = PLAYER_SAFE_FALL_DISTANCE - 1;
    Vec3[] memory newCoords = new Vec3[](1);
    newCoords[0] = playerCoord + vec3(1, 0, 0);

    Vec3 grassCoord = newCoords[0] - vec3(0, 1, 0).mul(int32(numFalls));
    // Set grass below the new path
    setObjectAtCoord(grassCoord, ObjectTypes.Grass);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Expect the player to be above the grass
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, grassCoord + vec3(0, 1, 0), "Player did not move to the grass coord");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    uint128 playerEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    // Fall damage is greater than the move energy cost
    assertGt(PLAYER_FALL_ENERGY_COST, MOVE_ENERGY_COST, "Fall energy cost is not greater than the move energy cost");
    assertEq(playerEnergyLost, MOVE_ENERGY_COST * 2, "Player energy lost is move + landing energy cost");
  }

  function testMoveFallDamage() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](PLAYER_SAFE_FALL_DISTANCE + 2);
    newCoords[0] = playerCoord + vec3(1, 0, 0); // move to the hole
    newCoords[1] = playerCoord + vec3(1, -1, 0);
    newCoords[2] = playerCoord + vec3(1, -2, 0);
    newCoords[3] = playerCoord + vec3(1, -3, 0);
    newCoords[4] = playerCoord + vec3(1, -4, 0);

    Vec3 grassCoord = playerCoord + vec3(1, -5, 0);
    setObjectAtCoord(grassCoord, ObjectTypes.Grass);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Expect the player to be above the grass
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, grassCoord + vec3(0, 1, 0), "Player did not move to the grass coord");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );

    uint128 playerEnergyLost = assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    assertEq(playerEnergyLost, MOVE_ENERGY_COST * 2 + PLAYER_FALL_ENERGY_COST, "Player energy lost is incorrect");
  }

  function testMoveThroughWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](3);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 1, 1);
    newCoords[2] = playerCoord + vec3(0, 0, 2);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, newCoords[newCoords.length - 1], "Player did not move to new coords");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveEndAtStart() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](4);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);
    newCoords[2] = playerCoord + vec3(0, 0, 1);
    newCoords[3] = playerCoord;
    for (uint8 i = 0; i < newCoords.length; i++) {
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, playerCoord, "Player did not move to new coords");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveOverlapStartingCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](6);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);
    newCoords[2] = playerCoord + vec3(0, 0, 1);
    newCoords[3] = playerCoord;
    newCoords[4] = playerCoord + vec3(0, 0, -1);
    newCoords[5] = playerCoord + vec3(0, 0, -2);
    for (uint8 i = 0; i < newCoords.length; i++) {
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }
    Vec3 expectedFinalCoord = newCoords[newCoords.length - 1];
    setObjectAtCoord(expectedFinalCoord - vec3(0, 1, 0), ObjectTypes.Grass);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, expectedFinalCoord, "Player did not move to new coords");
    Vec3 aboveFinalCoord = finalCoord + vec3(0, 1, 0);
    assertEq(
      BaseEntity.get(ReverseMovablePosition.get(aboveFinalCoord)), aliceEntityId, "Above coord is not the player"
    );
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveFailsIfInvalidJump() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint256 numJumps = MAX_PLAYER_JUMPS + 1;
    Vec3[] memory newCoords = new Vec3[](numJumps);
    for (uint8 i = 0; i < numJumps; i++) {
      newCoords[i] = playerCoord + vec3(0, int32(int256(uint256(i))) + 1, 0);
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }

    vm.prank(alice);
    vm.expectRevert("Cannot jump more than 3 blocks");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFailsIfInvalidGlide() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint256 numGlides = MAX_PLAYER_GLIDES + 1;
    Vec3[] memory newCoords = new Vec3[](numGlides + 1);
    for (uint8 i = 0; i < newCoords.length; i++) {
      newCoords[i] = playerCoord + vec3(0, 1, int32(int256(uint256(i))));
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }

    vm.prank(alice);
    vm.expectRevert("Cannot glide more than 10 blocks");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFailsIfNonPassable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);
    for (uint8 i = 0; i < newCoords.length; i++) {
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
    }

    setObjectAtCoord(newCoords[1], ObjectTypes.Dirt);

    vm.prank(alice);
    vm.expectPartialRevert(NonPassableBlock.selector);
    world.move(aliceEntityId, newCoords);

    setObjectAtCoord(newCoords[0] + vec3(0, 1, 0), ObjectTypes.Dirt);

    vm.prank(alice);
    vm.expectPartialRevert(NonPassableBlock.selector);
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFailsIfPlayer() public {
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupAirChunkWithPlayer();

    (,, Vec3 bobCoord) = spawnPlayerOnAirChunk(aliceCoord + vec3(0, 0, 2));

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = aliceCoord + vec3(0, 0, 1);
    newCoords[1] = bobCoord;
    setObjectAtCoord(newCoords[0], ObjectTypes.Air);
    setObjectAtCoord(newCoords[0] + vec3(0, 1, 0), ObjectTypes.Air);

    vm.prank(alice);
    vm.expectRevert("Cannot move through a player");
    world.move(aliceEntityId, newCoords);

    newCoords[1] = bobCoord + vec3(0, 1, 0);

    vm.prank(alice);
    vm.expectRevert("Cannot move through a player");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 3);

    vm.prank(alice);
    vm.expectRevert("New coord is too far from old coord");
    world.move(aliceEntityId, newCoords);

    uint256 pathLength = uint256(int256(playerCoord.x())) + 1;
    newCoords = new Vec3[](pathLength);
    for (uint32 i = 0; i < pathLength; i++) {
      newCoords[i] = (playerCoord - vec3(1, 0, 0).mul(int32(i) + 1));
    }

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Set player energy to exactly enough for one move
    uint128 exactEnergy = MOVE_ENERGY_COST;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: exactEnergy, drainRate: 0 })
    );

    Vec3[] memory newCoords = new Vec3[](1);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    setObjectAtCoord(newCoords[0], ObjectTypes.Air);
    setObjectAtCoord(newCoords[0] + vec3(0, 1, 0), ObjectTypes.Air);
    setObjectAtCoord(newCoords[0] - vec3(0, 1, 0), ObjectTypes.Dirt);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Check energy is zero
    assertEq(Energy.getEnergy(aliceEntityId), 0, "Player energy is not 0");

    // Call activate to trigger player removal from grid
    vm.prank(alice);
    world.activate(aliceEntityId);

    // Verify the player entity is still registered to the address, but removed from the grid
    assertEq(EntityPosition.get(aliceEntityId), vec3(0, 0, 0), "Player position was not deleted");
    assertEq(ReverseMovablePosition.get(playerCoord), EntityId.wrap(0), "Player reverse position was not deleted");
    assertEq(
      ReverseMovablePosition.get(playerCoord + vec3(0, 1, 0)),
      EntityId.wrap(0),
      "Player reverse position at head was not deleted"
    );
  }

  function testDeathFromLongFall() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add items to player's inventory to test transfer
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Stone, 10);
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.IronOre, 5);

    // Setup a fall path with a specific death point
    uint32 fallHeight = 10; // Well above the PLAYER_SAFE_FALL_DISTANCE
    Vec3[] memory newCoords = new Vec3[](fallHeight);

    // Create a high column of air blocks
    for (uint32 i = 0; i < fallHeight; i++) {
      Vec3 airCoord = playerCoord + vec3(0, -int32(i + 1), 1);
      setObjectAtCoord(airCoord, ObjectTypes.Air);
      newCoords[i] = airCoord;
    }

    // Set the last coordinate
    Vec3 landingCoord = newCoords[newCoords.length - 1] - vec3(0, 1, 0);
    setObjectAtCoord(landingCoord, ObjectTypes.Grass);

    // Calculate energy costs for the fall
    // Falls after threshold cost PLAYER_FALL_ENERGY_COST each
    uint32 deathIndex = 5; // We want the player to die at the 5th step (index 4)

    // Calculate energy needed to die exactly at deathIndex
    uint128 energyForFallsBeforeDeath = PLAYER_FALL_ENERGY_COST * (deathIndex - PLAYER_SAFE_FALL_DISTANCE);

    Energy.set(
      aliceEntityId,
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: energyForFallsBeforeDeath, drainRate: 0 })
    );

    // Verify inventory before move
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Stone, 10);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronOre, 5);

    // Get entity at the expected death location
    (EntityId entityAtDeathLocation,) = TestEntityUtils.getBlockAt(landingCoord + vec3(0, 1, 0));

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Verify player died (energy went to zero)
    assertEq(Energy.getEnergy(aliceEntityId), 0, "Player energy should be 0 after fatal fall");

    // Verify player position was cleared
    assertEq(EntityPosition.get(aliceEntityId), vec3(0, 0, 0), "Player position should be cleared after death");

    // Verify inventory was transferred to the entity at death location
    assertInventoryHasObject(entityAtDeathLocation, ObjectTypes.Stone, 10);
    assertInventoryHasObject(entityAtDeathLocation, ObjectTypes.IronOre, 5);

    assertInventoryHasObject(aliceEntityId, ObjectTypes.Stone, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronOre, 0);
  }

  function testMoveHorizontalPathFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add items to player's inventory to test transfer
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.IronOre, 8);
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Diamond, 3);

    // Create a horizontal path where player will run out of energy at a specific point
    uint32 pathLength = 5;
    uint32 deathIndex = 3;

    // Calculate energy needed to die exactly at deathIndex
    // Energy for moves before death point + 1 energy unit to die at exact position
    uint128 energy = MOVE_ENERGY_COST * deathIndex + 1;

    Energy.set(aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: energy, drainRate: 0 }));

    // Create a horizontal path
    Vec3[] memory newCoords = new Vec3[](pathLength);
    for (uint32 i = 0; i < pathLength; i++) {
      newCoords[i] = playerCoord + vec3(0, 0, int32(i) + 1);
      setObjectAtCoord(newCoords[i], ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] + vec3(0, 1, 0), ObjectTypes.Air);
      setObjectAtCoord(newCoords[i] - vec3(0, 1, 0), ObjectTypes.Dirt);
    }

    // Identify the exact death location
    Vec3 expectedDeathCoord = newCoords[deathIndex];

    // Get or create entity at the expected death location
    (EntityId entityAtDeathLocation,) = TestEntityUtils.getBlockAt(expectedDeathCoord);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Verify player died (energy went to zero)
    assertEq(Energy.getEnergy(aliceEntityId), 0, "Player energy should be 0 after energy depletion");

    // Verify player position was cleared
    assertEq(EntityPosition.get(aliceEntityId), vec3(0, 0, 0), "Player position should be cleared after death");

    // Verify inventory was transferred to the entity at death location
    assertInventoryHasObject(entityAtDeathLocation, ObjectTypes.IronOre, 8);
    assertInventoryHasObject(entityAtDeathLocation, ObjectTypes.Diamond, 3);

    assertInventoryHasObject(aliceEntityId, ObjectTypes.IronOre, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Diamond, 0);
  }

  function testMoveFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);

    vm.expectRevert("Caller not allowed");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3[] memory newCoords = new Vec3[](2);
    newCoords[0] = playerCoord + vec3(0, 0, 1);
    newCoords[1] = playerCoord + vec3(0, 0, 2);

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.move(aliceEntityId, newCoords);
  }

  function testMoveWithLowEnergyFatal() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set player energy to just under one move
    Energy.set(
      aliceEntityId,
      EnergyData({
        lastUpdatedTime: uint128(block.timestamp),
        energy: MOVE_ENERGY_COST - 1,
        drainRate: PLAYER_ENERGY_DRAIN_RATE
      })
    );

    // Try to move multiple steps
    Vec3[] memory newCoords = new Vec3[](3);
    for (uint32 i = 0; i < 3; i++) {
      newCoords[i] = playerCoord + vec3(0, 0, int32(i) + 1);
    }

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Should not move but still deplete its energy
    assertPlayerIsDead(aliceEntityId, playerCoord);
  }

  function testMoveThroughDifferentBlockTypes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create a path with different block types
    Vec3[] memory path = new Vec3[](3);
    path[0] = playerCoord + vec3(1, 0, 0);
    path[1] = playerCoord + vec3(2, 0, 0);
    path[2] = playerCoord + vec3(3, 0, 0);

    // Set block types
    setTerrainAtCoord(path[0], ObjectTypes.Water);
    setTerrainAtCoord(path[1], ObjectTypes.Air);
    setTerrainAtCoord(path[2], ObjectTypes.FescueGrass);

    vm.prank(alice);
    world.move(aliceEntityId, path);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, path[path.length - 1], "Player did not move to new coords");
  }

  function testMultiplePlayersCollision() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create second player
    Vec3 bobCoord = vec3(playerCoord.x() + 1, FLAT_CHUNK_GRASS_LEVEL + 1, playerCoord.z());

    createTestPlayer(bobCoord);

    // Try to move through Bob
    Vec3[] memory newCoords = new Vec3[](1);
    newCoords[0] = bobCoord;

    vm.prank(alice);
    vm.expectRevert("Cannot move through a player");
    world.move(aliceEntityId, newCoords);
  }

  // Water/Fluid interaction tests
  function testGravityDoesNotApplyInWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Verify player is in water
    uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(playerCoord);
    assertEq(fluidLevel, MAX_FLUID_LEVEL, "Player should be in water");

    // Move vertically underwater - no gravity should apply
    Vec3[] memory newCoords = new Vec3[](3);
    newCoords[0] = playerCoord + vec3(0, 1, 0);
    newCoords[1] = playerCoord + vec3(0, 2, 0);
    newCoords[2] = playerCoord + vec3(0, 3, 0);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, newCoords[2], "Player should reach final position");
  }

  function testMoveThroughDifferentFluidLevels() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create path with water and non-water blocks
    Vec3[] memory path = new Vec3[](4);
    path[0] = playerCoord + vec3(1, 0, 0); // Air
    path[1] = playerCoord + vec3(2, 0, 0); // Water
    path[2] = playerCoord + vec3(3, 0, 0); // Water
    path[3] = playerCoord + vec3(4, 0, 0); // Air

    // Set up terrain
    setObjectAtCoord(path[0], ObjectTypes.Air);
    setObjectAtCoord(path[1], ObjectTypes.Water);
    setObjectAtCoord(path[2], ObjectTypes.Water);
    setObjectAtCoord(path[3], ObjectTypes.Air);

    vm.prank(alice);
    world.move(aliceEntityId, path);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, path[3], "Player should reach final position");
  }

  function testFluidLevelWithSpawnsWithFluidBlocks() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test movement through blocks that spawn with fluid
    ObjectType[4] memory fluidBlocks = [ObjectTypes.Water, ObjectTypes.Coral, ObjectTypes.SeaAnemone, ObjectTypes.Algae];

    for (uint256 i = 0; i < fluidBlocks.length; i++) {
      Vec3 testCoord = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
      setObjectAtCoord(testCoord, fluidBlocks[i]);

      // Verify fluid level
      uint8 fluidLevel = TestEntityUtils.getFluidLevelAt(testCoord);
      assertEq(fluidLevel, MAX_FLUID_LEVEL, "Block should have max fluid level");
    }

    // Move through all these blocks
    Vec3[] memory newCoords = new Vec3[](fluidBlocks.length);
    for (uint256 i = 0; i < fluidBlocks.length; i++) {
      newCoords[i] = playerCoord + vec3(int32(int256(i + 1)), 0, 0);
    }

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    // Should successfully move through all fluid blocks
    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, newCoords[newCoords.length - 1], "Player should move through fluid blocks");
  }

  function testJumpingInWater() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Try to jump up in water (should work without gravity)
    Vec3[] memory jumpPath = new Vec3[](3);
    jumpPath[0] = playerCoord + vec3(0, 1, 0);
    jumpPath[1] = playerCoord + vec3(0, 2, 0);
    jumpPath[2] = playerCoord + vec3(0, 3, 0);

    vm.prank(alice);
    world.move(aliceEntityId, jumpPath);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, jumpPath[2], "Player should be able to jump/swim up in water");
  }

  function testWalkMoveUnits() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Player can walk up to 30 blocks per Ethereum block
    // Try to move 30 blocks, the next move should revert in the same block
    Vec3[] memory newCoords = new Vec3[](30);

    Vec3 belowCoord;

    for (uint32 i = 0; i < newCoords.length; i++) {
      newCoords[i] = playerCoord + vec3(0, 0, int32(i) + 1);
      belowCoord = newCoords[i] - vec3(0, 1, 0);
      setTerrainAtCoord(belowCoord, ObjectTypes.Grass);
    }

    // This should work
    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    newCoords = new Vec3[](1);
    newCoords[0] = playerCoord + vec3(0, 0, 31);

    belowCoord = newCoords[0] - vec3(0, 1, 0);
    setTerrainAtCoord(belowCoord, ObjectTypes.Grass);

    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, playerCoord + vec3(0, 0, 30), "Player should have moved 30 blocks");

    // Move to next block and verify can move again
    vm.roll(block.number + 1);

    Vec3[] memory nextMove = new Vec3[](1);
    nextMove[0] = finalCoord + vec3(0, 0, 1);

    vm.prank(alice);
    world.move(aliceEntityId, nextMove);

    assertEq(
      EntityPosition.get(aliceEntityId), finalCoord + vec3(0, 0, 1), "Player should be able to move in new block"
    );
  }

  function testWaterMoveUnits() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupWaterChunkWithPlayer();

    // Player can swim up to ~27 blocks per Ethereum block in water
    // Try to move 27 blocks, the next one should revert in the same block
    Vec3[] memory newCoords = new Vec3[](27);

    Vec3 belowCoord;

    for (uint32 i = 0; i < newCoords.length; i++) {
      newCoords[i] = playerCoord + vec3(0, 0, int32(i) + 1);
      belowCoord = newCoords[i] - vec3(0, 1, 0);
      setTerrainAtCoord(newCoords[i], ObjectTypes.Water);
      setTerrainAtCoord(belowCoord, ObjectTypes.Water);
    }

    // This should work
    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    newCoords = new Vec3[](1);
    newCoords[0] = playerCoord + vec3(0, 0, 28);

    belowCoord = newCoords[0] - vec3(0, 1, 0);
    setTerrainAtCoord(newCoords[0], ObjectTypes.Water);
    setTerrainAtCoord(belowCoord, ObjectTypes.Water);

    vm.prank(alice);
    vm.expectRevert("Rate limit exceeded");
    world.move(aliceEntityId, newCoords);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    // Should have moved 27 blocks
    assertEq(finalCoord, playerCoord + vec3(0, 0, 27), "Player should have moved exactly 27 blocks in water");

    // Move to next block and verify can move again
    vm.roll(block.number + 1);

    vm.prank(alice);
    world.move(aliceEntityId, newCoords);

    assertEq(
      EntityPosition.get(aliceEntityId), finalCoord + vec3(0, 0, 1), "Player should be able to move in new block"
    );
  }

  function testMoveDirectionsPackedSimple() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test simple movement: just horizontal moves (flat chunk already has good terrain)
    Direction[] memory directions = new Direction[](3);
    directions[0] = Direction.PositiveX;
    directions[1] = Direction.PositiveZ;
    directions[2] = Direction.NegativeX;

    // Pack directions and count into uint256
    uint256 packed = 0;
    // Pack count (3) into top 6 bits
    packed |= uint256(3) << 250;
    // Pack directions into bottom bits
    packed |= uint256(uint8(directions[0])) << (0 * 5);
    packed |= uint256(uint8(directions[1])) << (1 * 5);
    packed |= uint256(uint8(directions[2])) << (2 * 5);

    // Set up terrain for the path
    Vec3[] memory expectedPath = new Vec3[](3);
    expectedPath[0] = playerCoord + vec3(1, 0, 0);
    expectedPath[1] = expectedPath[0] + vec3(0, 0, 1);
    expectedPath[2] = expectedPath[1] + vec3(-1, 0, 0);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    vm.prank(alice);
    world.moveDirectionsPacked(aliceEntityId, packed);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, expectedPath[2], "Player did not move to expected position");
    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testMoveDirectionsPackedComplex() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test complex diagonal movements
    Direction[] memory directions = new Direction[](5);
    directions[0] = Direction.PositiveXPositiveZ;
    directions[1] = Direction.NegativeXPositiveZ;
    directions[2] = Direction.PositiveY;
    directions[3] = Direction.NegativeZ;
    directions[4] = Direction.PositiveXNegativeY;

    // Pack directions and count
    uint256 packed = 0;
    // Pack count (5) into top 6 bits
    packed |= uint256(5) << 250;
    // Pack directions into bottom bits
    for (uint256 i = 0; i < directions.length; i++) {
      packed |= uint256(uint8(directions[i])) << (i * 5);
    }

    // Calculate expected path
    Vec3[] memory expectedPath = new Vec3[](5);
    expectedPath[0] = playerCoord + vec3(1, 0, 1);
    expectedPath[1] = expectedPath[0] + vec3(-1, 0, 1);
    expectedPath[2] = expectedPath[1] + vec3(0, 1, 0);
    expectedPath[3] = expectedPath[2] + vec3(0, 0, -1);
    expectedPath[4] = expectedPath[3] + vec3(1, -1, 0);

    // No need to set up terrain - flat chunk already has proper ground

    vm.prank(alice);
    world.moveDirectionsPacked(aliceEntityId, packed);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    assertEq(finalCoord, expectedPath[4], "Player did not move to expected position");
  }

  function testMoveDirectionsPackedEquivalence() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Bob needs to be in the same chunk for simplicity
    Vec3 bobCoord = playerCoord + vec3(5, 0, 0);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create a path with various directions
    Direction[] memory directions = new Direction[](8);
    directions[0] = Direction.PositiveX;
    directions[1] = Direction.PositiveZ;
    directions[2] = Direction.NegativeX;
    directions[3] = Direction.PositiveY;
    directions[4] = Direction.PositiveXPositiveZ;
    directions[5] = Direction.NegativeY;
    directions[6] = Direction.NegativeZ;
    directions[7] = Direction.PositiveX;

    // Pack directions and count for Bob
    uint256 packed = 0;
    // Pack count (8) into top 6 bits
    packed |= uint256(8) << 250;
    // Pack directions into bottom bits
    for (uint256 i = 0; i < directions.length; i++) {
      packed |= uint256(uint8(directions[i])) << (i * 5);
    }

    // No need to set up terrain - flat chunk already has proper ground

    // Move Alice with regular moveDirections
    vm.prank(alice);
    world.moveDirections(aliceEntityId, directions);

    // Move Bob with packed version
    vm.prank(bob);
    world.moveDirectionsPacked(bobEntityId, packed);

    // Check that both ended up at equivalent positions
    Vec3 aliceFinal = EntityPosition.get(aliceEntityId);
    Vec3 bobFinal = EntityPosition.get(bobEntityId);

    assertEq(aliceFinal - playerCoord, bobFinal - bobCoord, "X displacement should be equal");
  }

  function testMoveDirectionsPackedMaxCapacity() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Test maximum capacity: 30 directions in one uint256 (within move limit)
    uint8 maxDirections = 30;

    // Create alternating pattern of movements
    uint256 packed = 0;
    // Pack count (30) into top 6 bits
    packed |= uint256(maxDirections) << 250;
    // Pack directions into bottom bits
    for (uint256 i = 0; i < maxDirections; i++) {
      Direction dir = (i % 2 == 0) ? Direction.PositiveX : Direction.NegativeX;
      packed |= uint256(uint8(dir)) << (i * 5);
    }

    // No need to set up terrain - flat chunk already has proper ground

    vm.prank(alice);
    world.moveDirectionsPacked(aliceEntityId, packed);

    Vec3 finalCoord = EntityPosition.get(aliceEntityId);
    // After 30 moves alternating +1/-1 on X, should be at playerCoord.x
    assertEq(finalCoord.x(), playerCoord.x(), "Final X position incorrect");
    assertEq(finalCoord.z(), playerCoord.z(), "Z position should not change");
  }

  function testMoveDirectionsPackedGasComparison() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 bobCoord = playerCoord + vec3(20, 0, 0);
    setTerrainAtCoord(bobCoord, ObjectTypes.Air);
    setTerrainAtCoord(bobCoord + vec3(0, 1, 0), ObjectTypes.Air);
    setTerrainAtCoord(bobCoord - vec3(0, 1, 0), ObjectTypes.Dirt);
    (address bob, EntityId bobEntityId) = createTestPlayer(bobCoord);

    // Create 10 forward movements
    Direction[] memory directions = new Direction[](10);
    uint256 packed = 0;
    // Pack count (10) into top 6 bits
    packed |= uint256(10) << 250;

    for (uint256 i = 0; i < 10; i++) {
      directions[i] = Direction.PositiveZ;
      // Pack directions into bottom bits
      packed |= uint256(uint8(Direction.PositiveZ)) << (i * 5);

      // Set up terrain for both players
      setTerrainAtCoord(playerCoord + vec3(0, 0, int32(int256(i + 1))), ObjectTypes.Air);
      setTerrainAtCoord(playerCoord + vec3(0, 1, int32(int256(i + 1))), ObjectTypes.Air);
      setTerrainAtCoord(playerCoord + vec3(0, -1, int32(int256(i + 1))), ObjectTypes.Grass);

      setTerrainAtCoord(bobCoord + vec3(0, 0, int32(int256(i + 1))), ObjectTypes.Air);
      setTerrainAtCoord(bobCoord + vec3(0, 1, int32(int256(i + 1))), ObjectTypes.Air);
      setTerrainAtCoord(bobCoord + vec3(0, -1, int32(int256(i + 1))), ObjectTypes.Grass);
    }

    // Measure gas for regular moveDirections
    vm.prank(alice);
    startGasReport("moveDirections 10 moves");
    world.moveDirections(aliceEntityId, directions);
    endGasReport();

    // Measure gas for packed version
    vm.prank(bob);
    startGasReport("moveDirectionsPacked 10 moves");
    world.moveDirectionsPacked(bobEntityId, packed);
    endGasReport();
  }
}
