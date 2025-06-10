// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { SlotAmount } from "../src/utils/InventoryUtils.sol";
import { LocalEnergyPool } from "../src/utils/Vec3Storage.sol";

import { MAX_PLAYER_ENERGY } from "../src/Constants.sol";
import { EntityId } from "../src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "../src/types/ObjectType.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

contract FoodTest is DustTest {
  function testEatFood() public {
    // Setup player with initial energy at 50% of max
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();
    uint128 initialEnergy = MAX_PLAYER_ENERGY / 2;
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: initialEnergy, drainRate: 1 })
    );

    // Add some wheat_slop to player inventory
    ObjectType foodType = ObjectTypes.WheatSlop;
    uint16 foodAmount = 3;
    TestInventoryUtils.addObject(aliceEntityId, foodType, foodAmount);

    // Get energy value of food
    uint128 foodEnergyValue = ObjectPhysics.getEnergy(foodType);

    // Eat food
    uint16 amountToEat = 2;
    vm.prank(alice);
    world.eat(aliceEntityId, SlotAmount({ slot: 0, amount: amountToEat }));

    // Check if energy was added correctly
    uint128 expectedEnergy = initialEnergy + (foodEnergyValue * amountToEat);
    assertEq(Energy.getEnergy(aliceEntityId), expectedEnergy, "Player energy not updated correctly");
  }

  function testEatInvalidFood() public {
    // Setup player
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Add non-food item to inventory
    ObjectType nonFoodType = ObjectTypes.Dirt;
    uint16 amount = 3;
    TestInventoryUtils.addObject(aliceEntityId, nonFoodType, amount);

    // Try to eat non-food item
    vm.prank(alice);
    vm.expectRevert("Object is not food");
    world.eat(aliceEntityId, SlotAmount({ slot: 0, amount: 1 }));
  }

  function testEatFoodOverMaxEnergy() public {
    // Setup player with high initial energy
    (address alice, EntityId aliceEntityId, Vec3 aliceCoord) = setupFlatChunkWithPlayer();
    uint128 initialEnergy = MAX_PLAYER_ENERGY - 10; // Just below max
    Energy.set(
      aliceEntityId, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: initialEnergy, drainRate: 1 })
    );

    // Add food to player inventory
    ObjectType foodType = ObjectTypes.WheatSlop;
    uint16 foodAmount = 3;
    TestInventoryUtils.addObject(aliceEntityId, foodType, foodAmount);

    // Get energy value of food (which will be > 10)
    uint128 foodEnergyValue = ObjectPhysics.getEnergy(foodType);

    // Record initial local energy pool value
    Vec3 shardCoord = aliceCoord.toLocalEnergyPoolShardCoord();
    uint128 initialLocalEnergy = LocalEnergyPool.get(shardCoord);

    // Eat food
    vm.prank(alice);
    world.eat(aliceEntityId, SlotAmount({ slot: 0, amount: 1 }));

    // Check if energy was capped at max
    assertEq(Energy.getEnergy(aliceEntityId), MAX_PLAYER_ENERGY, "Player energy not capped at max");

    // Check if excess energy was added to the local pool
    uint128 expectedExcess = foodEnergyValue - (MAX_PLAYER_ENERGY - initialEnergy);
    uint128 actualLocalEnergy = LocalEnergyPool.get(shardCoord);
    assertEq(actualLocalEnergy, initialLocalEnergy + expectedExcess, "Excess energy not added to local pool");
  }

  function testEatMoreThanInventory() public {
    // Setup player
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Add food to player inventory
    ObjectType foodType = ObjectTypes.WheatSlop;
    uint16 foodAmount = 3;
    TestInventoryUtils.addObject(aliceEntityId, foodType, foodAmount);

    // Try to eat more than available
    vm.prank(alice);
    vm.expectRevert("Not enough objects in slot");
    world.eat(aliceEntityId, SlotAmount({ slot: 0, amount: foodAmount + 1 }));
  }

  function testEatReducesInventory() public {
    // Setup player
    (address alice, EntityId aliceEntityId,) = setupFlatChunkWithPlayer();

    // Add food to player inventory
    ObjectType foodType = ObjectTypes.WheatSlop;
    uint16 initialFoodAmount = 5;
    TestInventoryUtils.addObject(aliceEntityId, foodType, initialFoodAmount);

    // Eat some food
    uint16 amountToEat = 3;
    vm.prank(alice);
    world.eat(aliceEntityId, SlotAmount({ slot: 0, amount: amountToEat }));

    // Check inventory was reduced correctly
    assertInventoryHasObject(aliceEntityId, foodType, initialFoodAmount - amountToEat);
  }
}
