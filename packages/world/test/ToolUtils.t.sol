// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

import { DustTest } from "./DustTest.sol";

import {
  ACTION_MODIFIER_DENOMINATOR,
  ORE_TOOL_BASE_MULTIPLIER,
  SPECIALIZATION_MULTIPLIER,
  TOOL_ACTION_ENERGY_COST,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../src/Constants.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { vec3 } from "../src/types/Vec3.sol";

import { Math } from "../src/utils/Math.sol";

import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { TestInventoryUtils, TestToolUtils, ToolData } from "./utils/TestUtils.sol";

contract ToolUtilsTest is DustTest {
  // Storage variables to avoid stack issues
  uint128 private _tempMultiplier;
  uint128 private _tempUseMassMax;

  function testToolUse() public {
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Add a tool
    TestInventoryUtils.addEntity(alice, ObjectTypes.IronPick);
    EntityId toolId = InventorySlot.getEntityId(alice, 0);

    // Get tool data
    ToolData memory toolData = TestToolUtils.getToolData(alice, 0);
    assertEq(toolData.toolType, ObjectTypes.IronPick);
    assertEq(toolData.tool, toolId);

    // Use the tool partially
    uint128 initialMass = Mass.getMass(toolId);
    // Use the tool with a limit larger than energy cost so tool mass is reduced
    TestToolUtils.use(toolData, TOOL_ACTION_ENERGY_COST + 1, ACTION_MODIFIER_DENOMINATOR, false, FixedPointMathLib.WAD);

    // Tool should still exist with reduced mass
    assertLt(Mass.getMass(toolId), initialMass, "Tool mass should be reduced");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1, "Tool should still be in inventory");

    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz tests

  // Helper to calculate multiplier inline
  function _getMultiplier(ObjectType toolType, uint128 actionModifier, bool specialized) private pure returns (uint128) {
    uint128 baseMultiplier = toolType.isWoodenTool() ? WOODEN_TOOL_BASE_MULTIPLIER : ORE_TOOL_BASE_MULTIPLIER;
    uint128 specializationMultiplier = specialized ? SPECIALIZATION_MULTIPLIER : 1;
    return baseMultiplier * specializationMultiplier * actionModifier;
  }

  // Fuzz test to verify tool mass reduction never exceeds max using actual inventory tools
  function testFuzzToolMassReduction(uint8 toolTypeIndex, uint128 actionModifier, uint128 useMassMax, bool specialized)
    public
  {
    // Setup player
    (, EntityId alice) = createTestPlayer(vec3(0, 0, 0));

    // Tool types to test
    ObjectType[6] memory toolTypes = [
      ObjectTypes.WoodenPick,
      ObjectTypes.WoodenAxe,
      ObjectTypes.IronPick,
      ObjectTypes.CopperAxe,
      ObjectTypes.CopperWhacker,
      ObjectTypes.IronWhacker
    ];

    // Bound inputs and add tool
    ObjectType toolType = toolTypes[bound(toolTypeIndex, 0, 5)];
    // Bound actionModifier to reasonable game values (up to 1000x modifier)
    actionModifier = uint128(bound(actionModifier, 1, 1000 * ACTION_MODIFIER_DENOMINATOR));
    // Bound useMassMax to prevent overflow when multiplied by ACTION_MODIFIER_DENOMINATOR (1e18)
    useMassMax = uint128(bound(useMassMax, 1, type(uint128).max));

    EntityId toolEntity = TestInventoryUtils.addEntity(alice, toolType);

    // Store values to avoid stack issues
    _tempMultiplier = _getMultiplier(toolType, actionModifier, specialized);
    _tempUseMassMax = useMassMax;

    // Get tool data and use tool
    ToolData memory toolData = TestToolUtils.getToolData(alice, TestInventoryUtils.findEntity(alice, toolEntity));
    uint128 initialToolMass = toolData.massLeft;
    uint128 actionMassReduction =
      TestToolUtils.use(toolData, useMassMax, actionModifier, specialized, FixedPointMathLib.WAD);

    // Check tool state after use
    uint128 actualToolMassReduction = initialToolMass - Mass.getMass(toolEntity);

    // Verify the invariant: tool mass reduction should never exceed max
    assertLe(
      actualToolMassReduction,
      Math.min(ObjectPhysics.getMass(toolType) / 10, initialToolMass),
      "INVARIANT VIOLATED: actualToolMassReduction exceeds maxToolMassReduction"
    );

    if (!TestInventoryUtils.hasEntity(alice, toolEntity)) {
      // Tool was fully consumed
      assertEq(actualToolMassReduction, initialToolMass, "All tool mass should be consumed");
    }
    // Verify the relationship between actionMassReduction and toolMassReduction
    else if (actionMassReduction > 0) {
      // Calculate energy cost that was deducted from useMassMax
      uint128 energyCost = Math.min(_tempUseMassMax, TOOL_ACTION_ENERGY_COST);
      uint128 effectiveMassLeft = _tempUseMassMax > energyCost ? _tempUseMassMax - energyCost : 0;

      // If no mass left after energy cost, tool shouldn't be used
      if (effectiveMassLeft == 0) {
        assertEq(actualToolMassReduction, 0, "Tool should not be used when mass is fully consumed by energy cost");
      } else {
        // Calculate max tool mass reduction
        uint128 maxToolMassReduction = Math.min(ObjectPhysics.getMass(toolType) / 10, initialToolMass);

        // Calculate expected values matching the contract's logic exactly
        uint256 maxReductionScaled = uint256(maxToolMassReduction) * _tempMultiplier;
        uint256 massLeftScaled = uint256(effectiveMassLeft) * ACTION_MODIFIER_DENOMINATOR;

        if (maxReductionScaled <= massLeftScaled) {
          // Tool capacity is limiting - expect exact max tool mass reduction
          assertEq(
            actualToolMassReduction,
            maxToolMassReduction,
            "Tool mass reduction should be exact max when tool capacity limits"
          );
        } else {
          // effectiveMassLeft is limiting - calculate expected with divUp
          uint128 expectedToolMassReduction = uint128(Math.divUp(massLeftScaled, _tempMultiplier));
          assertEq(actualToolMassReduction, expectedToolMassReduction, "Tool mass reduction should match expected");
        }
      }
    }

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
  }
}
