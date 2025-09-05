// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  SKILL_CRAFT_MASS_ENERGY_TO_MAX,
  SKILL_ENERGY_MAX_DISCOUNT_WAD,
  SKILL_MINING_MASS_TO_MAX,
  SKILL_MOVE_ENERGY_TO_MAX
} from "../src/Constants.sol";
import { ActivityType } from "../src/codegen/common.sol";
import { Death } from "../src/codegen/tables/Death.sol";
import { PlayerProgress, PlayerProgressData } from "../src/codegen/tables/PlayerProgress.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { DustTest } from "./DustTest.sol";
import { TestPlayerSkillUtils } from "./utils/TestUtils.sol";

contract PlayerSkillUtilsTest is DustTest {
  function _setProgress(EntityId player, ActivityType activity, uint128 progress) internal {
    PlayerProgress.set(
      player,
      activity,
      PlayerProgressData({ accumulated: 0, current: progress, lastUpdatedAt: uint128(block.timestamp), exponent: 0 })
    );
    Death.setDeaths(player, 0);
  }

  function testMoveMultiplierZeroAndCap() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, 0);
    uint256 m0 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(m0, 1e18, "zero progress should yield 1.0x multiplier");

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX);
    uint256 mCap = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(mCap, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "cap progress should yield max discount");

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX + 1);
    uint256 mOver = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(mOver, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "over-cap should saturate at max discount");
  }

  function testMonotonicity() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX / 4);
    uint256 m1 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX / 2);
    uint256 m2 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    assertLe(m2, m1, "multiplier must be monotone non-increasing with progress");
  }

  function testMinePickMultiplierAtCap() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    _setProgress(aliceEntityId, ActivityType.MinePickMass, SKILL_MINING_MASS_TO_MAX);
    uint256 m = TestPlayerSkillUtils.getMineEnergyMultiplierWad(aliceEntityId, ObjectTypes.WoodenPick);
    assertEq(m, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "mining at cap should yield max discount");
  }

  function testCraftStationSpecific() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();
    _setProgress(aliceEntityId, ActivityType.CraftWorkbenchMass, SKILL_CRAFT_MASS_ENERGY_TO_MAX);
    uint256 mWorkbench = TestPlayerSkillUtils.getCraftEnergyMultiplierWad(aliceEntityId, ObjectTypes.Workbench);
    assertEq(mWorkbench, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "workbench progress at cap => max discount");
  }

  // Fuzz tests

  function testMoveMultiplierFuzz(uint128 progress) public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, progress);
    uint256 m = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    assertLe(m, 1e18, "multiplier must not exceed 1.0");
    assertGe(m, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "multiplier must not be below max-discount bound");

    if (progress == 0) assertEq(m, 1e18, "zero progress must yield no discount");
    if (progress >= SKILL_MOVE_ENERGY_TO_MAX) assertEq(m, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD);
  }

  function testMoveMultiplierMonotonicFuzz(uint128 a, uint128 b) public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    uint128 lo = a <= b ? a : b;
    uint128 hi = a <= b ? b : a;

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, lo);
    uint256 mLo = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, hi);
    uint256 mHi = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    assertLe(mHi, mLo, "multiplier must be monotone non-increasing with progress");
  }

  function testCraftMultiplierFuzz(uint128 progress, uint8 stationIdx) public {
    ObjectType[6] memory stations = [
      ObjectTypes.Workbench,
      ObjectTypes.Powerstone,
      ObjectTypes.Furnace,
      ObjectTypes.Stonecutter,
      ObjectTypes.Anvil,
      ObjectTypes.Null
    ];

    stationIdx = uint8(bound(stationIdx, 0, stations.length - 1));
    ObjectType station = stations[stationIdx];

    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    ActivityType activity;
    if (station == ObjectTypes.Workbench) activity = ActivityType.CraftWorkbenchMass;
    else if (station == ObjectTypes.Powerstone) activity = ActivityType.CraftPowerstoneMass;
    else if (station == ObjectTypes.Furnace) activity = ActivityType.CraftFurnaceMass;
    else if (station == ObjectTypes.Stonecutter) activity = ActivityType.CraftStonecutterMass;
    else if (station == ObjectTypes.Anvil) activity = ActivityType.CraftAnvilMass;
    else activity = ActivityType.CraftHandMass;

    _setProgress(aliceEntityId, activity, progress);

    uint256 m = TestPlayerSkillUtils.getCraftEnergyMultiplierWad(aliceEntityId, station);
    assertLe(m, 1e18, "multiplier must not exceed 1.0");
    assertGe(m, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD, "multiplier below lower bound");

    if (progress == 0) assertEq(m, 1e18, "zero progress must yield no discount");
    if (progress >= SKILL_CRAFT_MASS_ENERGY_TO_MAX) assertEq(m, 1e18 - SKILL_ENERGY_MAX_DISCOUNT_WAD);
  }

  function testMineMultiplierNoToolIsOne() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();
    _setProgress(aliceEntityId, ActivityType.MinePickMass, SKILL_MINING_MASS_TO_MAX);
    uint256 m = TestPlayerSkillUtils.getMineEnergyMultiplierWad(aliceEntityId, ObjectTypes.Null);
    assertEq(m, 1e18, "no applicable mining progress => no discount");
  }
}
