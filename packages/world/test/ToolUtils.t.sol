// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibBit } from "solady/utils/LibBit.sol";

import { DustTest, console } from "./DustTest.sol";

import {
  ACTION_MODIFIER_DENOMINATOR,
  ORE_TOOL_BASE_MULTIPLIER,
  SPECIALIZATION_MULTIPLIER,
  WOODEN_TOOL_BASE_MULTIPLIER
} from "../src/Constants.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { InventoryBitmap } from "../src/codegen/tables/InventoryBitmap.sol";
import { Math } from "../src/utils/Math.sol";

import { InventorySlot, InventorySlotData } from "../src/codegen/tables/InventorySlot.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { TestEntityUtils, TestInventoryUtils, TestToolUtils, ToolData } from "./utils/TestUtils.sol";

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
    TestToolUtils.use(toolData, 100);

    // Tool should still exist with reduced mass
    assertTrue(Mass.getMass(toolId) < initialMass, "Tool mass should be reduced");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1, "Tool should still be in inventory");

    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz tests

  // Helper to calculate multiplier inline
  function _getMultiplier(ObjectType toolType, uint128 actionModifier, bool specialized) private pure returns (uint128) {
    return (toolType.isWoodenTool() ? WOODEN_TOOL_BASE_MULTIPLIER : ORE_TOOL_BASE_MULTIPLIER)
      * (specialized ? SPECIALIZATION_MULTIPLIER : 1) * actionModifier;
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
    actionModifier = uint128(bound(actionModifier, 1, 100 * ACTION_MODIFIER_DENOMINATOR));
    useMassMax = uint128(bound(useMassMax, 1, type(uint64).max));

    EntityId toolEntity = TestInventoryUtils.addEntity(alice, toolType);

    // Store values to avoid stack issues
    _tempMultiplier = _getMultiplier(toolType, actionModifier, specialized);
    _tempUseMassMax = useMassMax;

    // Get tool data and use tool
    ToolData memory toolData = TestToolUtils.getToolData(alice, TestInventoryUtils.findEntity(alice, toolEntity));
    uint128 initialToolMass = toolData.massLeft;
    uint128 actionMassReduction = TestToolUtils.use(toolData, useMassMax, actionModifier, specialized);

    // Check tool state after use
    bool toolStillInInventory = TestInventoryUtils.findEntity(alice, toolEntity) != type(uint16).max;
    uint128 actualToolMassReduction = initialToolMass - (toolStillInInventory ? Mass.getMass(toolEntity) : 0);

    // Verify the invariant: tool mass reduction should never exceed max
    assertLe(
      actualToolMassReduction,
      Math.min(ObjectPhysics.getMass(toolType) / 10, initialToolMass),
      "INVARIANT VIOLATED: actualToolMassReduction exceeds maxToolMassReduction"
    );

    // Verify the relationship between actionMassReduction and toolMassReduction
    if (actionMassReduction > 0) {
      if (!toolStillInInventory) {
        // Tool was fully consumed
        assertEq(actualToolMassReduction, initialToolMass, "All tool mass should be consumed");
      } else {
        // Calculate max tool mass reduction
        uint128 maxToolMassReduction = Math.min(ObjectPhysics.getMass(toolType) / 10, initialToolMass);

        // Check if tool capacity or useMassMax is limiting
        if (maxToolMassReduction * _tempMultiplier / ACTION_MODIFIER_DENOMINATOR <= _tempUseMassMax) {
          // Tool capacity is limiting - expect exact max tool mass reduction
          assertEq(actualToolMassReduction, maxToolMassReduction, "Tool mass reduction should match expected exactly");
        } else {
          // useMassMax is limiting - calculate expected with rounding
          // Break down calculation to avoid stack issues
          uint128 numerator = _tempUseMassMax * ACTION_MODIFIER_DENOMINATOR + _tempMultiplier - 1;
          uint128 expected = Math.min(numerator / _tempMultiplier, maxToolMassReduction);
          assertEq(actualToolMassReduction, expected, "Tool mass reduction should match expected exactly");
        }
      }
    }

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
  }
}
