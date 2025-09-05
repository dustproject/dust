// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  SKILL_ENERGY_MAX_DISCOUNT_WAD, SKILL_MINING_MASS_TO_MAX, SKILL_MOVE_ENERGY_TO_MAX, WAD
} from "../src/Constants.sol";
import { ActivityType } from "../src/codegen/common.sol";

import { Death } from "../src/codegen/tables/Death.sol";
import { PlayerProgress, PlayerProgressData } from "../src/codegen/tables/PlayerProgress.sol";

import { EntityId } from "../src/types/EntityId.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

import { DustTest } from "./DustTest.sol";
import { TestPlayerSkillUtils } from "./utils/TestUtils.sol";

contract PlayerSkillUtilsTest is DustTest {
  function _setProgress(EntityId player, ActivityType activity, uint128 progress) internal {
    // Set current exactly to progress; keep accumulated at 0 so floor doesn't dominate.
    // Align deaths to zero and lastUpdatedAt to now to avoid decay.
    PlayerProgress.set(
      player,
      activity,
      PlayerProgressData({ accumulated: 0, current: progress, lastUpdatedAt: uint128(block.timestamp), exponent: 0 })
    );
    Death.setDeaths(player, 0);
  }

  function testMoveMultiplierZeroAndCap() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Zero progress → no discount (1.0x)
    _setProgress(aliceEntityId, ActivityType.MoveEnergy, 0);
    uint256 m0 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(m0, WAD, "zero progress should yield 1.0x multiplier");

    // At or above cap → max discount
    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX);
    uint256 mCap = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(mCap, WAD - SKILL_ENERGY_MAX_DISCOUNT_WAD, "cap progress should yield max discount");

    // Above cap still saturates at max discount
    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX + 1);
    uint256 mOver = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);
    assertEq(mOver, WAD - SKILL_ENERGY_MAX_DISCOUNT_WAD, "over-cap should saturate at max discount");
  }

  function testMonotonicity() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX / 4);
    uint256 m1 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    _setProgress(aliceEntityId, ActivityType.MoveEnergy, SKILL_MOVE_ENERGY_TO_MAX / 2);
    uint256 m2 = TestPlayerSkillUtils.getMoveEnergyMultiplierWad(aliceEntityId);

    // More progress => multiplier should be <= (never larger)
    assertLe(m2, m1, "multiplier must be monotone non-increasing with progress");
  }

  function testTillHasNoDiscount() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();
    uint256 m = TestPlayerSkillUtils.getTillEnergyMultiplierWad(aliceEntityId);
    assertEq(m, WAD, "tilling should not have a discount");
  }

  function testMinePickMultiplierAtCap() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // For mining with pick, activity is MinePickMass
    _setProgress(aliceEntityId, ActivityType.MinePickMass, SKILL_MINING_MASS_TO_MAX);

    uint256 m = TestPlayerSkillUtils.getMineEnergyMultiplierWad(aliceEntityId, ObjectTypes.WoodenPick);

    assertEq(m, WAD - SKILL_ENERGY_MAX_DISCOUNT_WAD, "mining at cap should yield max discount");
  }

  function testCraftStationSpecific() public {
    (, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();
    // Use BuildMass progress to ensure independence; station type is read only to select activity category.
    _setProgress(aliceEntityId, ActivityType.CraftWorkbenchMass, SKILL_MOVE_ENERGY_TO_MAX);
    uint256 mWorkbench = TestPlayerSkillUtils.getCraftEnergyMultiplierWad(aliceEntityId, ObjectTypes.Workbench);
    assertEq(mWorkbench, WAD - SKILL_ENERGY_MAX_DISCOUNT_WAD, "workbench progress at cap, max discount");
  }
}
