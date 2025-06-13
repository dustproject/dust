// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { LibBit } from "solady/utils/LibBit.sol";

import { DustTest, console } from "./DustTest.sol";

import { ACTION_MODIFIER_DENOMINATOR } from "../src/Constants.sol";
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
    TestToolUtils.use(toolData, 100, ACTION_MODIFIER_DENOMINATOR);

    // Tool should still exist with reduced mass
    assertTrue(Mass.getMass(toolId) < initialMass, "Tool mass should be reduced");
    assertEq(TestInventoryUtils.getOccupiedSlotCount(alice), 1, "Tool should still be in inventory");

    _verifyInventoryBitmapIntegrity(alice);
  }

  // Fuzz tests

  // Fuzz test to verify tool mass reduction never exceeds max using actual inventory tools
  function testFuzzToolMassReduction(uint8 toolTypeIndex, uint128 multiplier, uint128 useMassMax) public {
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

    // Bound inputs
    toolTypeIndex = uint8(bound(toolTypeIndex, 0, 5));
    multiplier = uint128(bound(multiplier, 1, 100e18)); // 0.000001x to 100x
    useMassMax = uint128(bound(useMassMax, 1, type(uint64).max));

    // Add tool to inventory
    ObjectType toolType = toolTypes[toolTypeIndex];
    EntityId toolEntity = TestInventoryUtils.addEntity(alice, toolType);
    uint16 slot = TestInventoryUtils.findEntity(alice, toolEntity);

    // Get tool data
    ToolData memory toolData = TestToolUtils.getToolData(alice, slot);
    uint128 initialToolMass = toolData.massLeft;
    uint128 maxToolMassReduction = Math.min(ObjectPhysics.getMass(toolType) / 10, initialToolMass);

    // Use the tool with the given multiplier
    uint128 actionMassReduction = TestToolUtils.use(toolData, useMassMax, multiplier);

    // Get the actual tool mass reduction
    uint128 finalToolMass = Mass.getMass(toolEntity);
    uint128 actualToolMassReduction = initialToolMass > finalToolMass ? initialToolMass - finalToolMass : 0;

    // Verify the invariant: tool mass reduction should never exceed max
    assertLe(
      actualToolMassReduction,
      maxToolMassReduction,
      "INVARIANT VIOLATED: actualToolMassReduction exceeds maxToolMassReduction"
    );

    // Verify the relationship between actionMassReduction and toolMassReduction
    if (actionMassReduction > 0 && multiplier > 0) {
      // The tool mass reduction should match what we expect from the formula
      uint128 expectedToolMassReduction = actionMassReduction * ACTION_MODIFIER_DENOMINATOR / multiplier;

      // Account for the case where the tool was fully consumed
      if (actualToolMassReduction < expectedToolMassReduction) {
        // Tool must have been fully consumed
        assertEq(finalToolMass, 0, "Tool should be fully consumed");
        assertEq(actualToolMassReduction, initialToolMass, "All tool mass should be consumed");
      } else {
        // Normal case - tool mass reduction matches expected
        assertEq(actualToolMassReduction, expectedToolMassReduction, "Tool mass reduction mismatch");
      }
    }

    // Verify inventory integrity
    _verifyInventoryBitmapIntegrity(alice);
  }
}
