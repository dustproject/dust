// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../src/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";

import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";
import { LocalEnergyPool } from "../src/codegen/tables/LocalEnergyPool.sol";
import { ResourceCount } from "../src/codegen/tables/ResourceCount.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import { CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { SlotAmount } from "../src/utils/InventoryUtils.sol";

import { TestEntityUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract CraftTest is DustTest {
  function hashRecipe(
    ObjectType stationObjectType,
    ObjectType[] memory inputTypes,
    uint16[] memory inputAmounts,
    ObjectType[] memory outputTypes,
    uint16[] memory outputAmounts
  ) internal pure returns (bytes32) {
    return keccak256(abi.encode(stationObjectType, inputTypes, inputAmounts, outputTypes, outputAmounts));
  }

  function testCraftSingleInputSingleOutput() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    startGasReport("handcraft single input");
    world.craft(aliceEntityId, recipeId, inputs);
    endGasReport();

    for (uint256 i = 0; i < inputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, inputTypes[i], 0);
    }
    for (uint256 i = 0; i < outputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
    }

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftMultipleInputsSingleOutput() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.Sand;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 6;
    inputAmounts[1] = 2;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.Powerstone;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
    EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](2);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });
    inputs[1] = SlotAmount({ slot: 1, amount: inputAmounts[1] });

    vm.prank(alice);
    startGasReport("handcraft multiple inputs");
    world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);
    endGasReport();

    for (uint256 i = 0; i < inputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, inputTypes[i], 0);
    }
    for (uint256 i = 0; i < outputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
    }

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftWithStation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.IronBar;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 30;
    inputAmounts[1] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.ForceField;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
    EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](2);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });
    inputs[1] = SlotAmount({ slot: 1, amount: inputAmounts[1] });

    vm.prank(alice);
    startGasReport("craft with station");
    world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);
    endGasReport();

    for (uint256 i = 0; i < inputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, inputTypes[i], 0);
    }
    for (uint256 i = 0; i < outputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
    }

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftAnyInput() public {
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 8;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.Chest;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;

    bytes32 recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectType inputObjectType1 = ObjectTypes.OakPlanks;
    ObjectType inputObjectType2 = ObjectTypes.BirchPlanks;
    ObjectType inputObjectType3 = ObjectTypes.JunglePlanks;

    // Doing it here to avoid stack too deep
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    TestInventoryUtils.addObject(aliceEntityId, inputObjectType1, 2);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType2, 3);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType3, 3);
    assertInventoryHasObject(aliceEntityId, inputObjectType1, 2);
    assertInventoryHasObject(aliceEntityId, inputObjectType2, 3);
    assertInventoryHasObject(aliceEntityId, inputObjectType3, 3);

    {
      Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
      EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

      EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

      SlotAmount[] memory inputs = new SlotAmount[](3);
      inputs[0] = SlotAmount({ slot: 0, amount: 2 });
      inputs[1] = SlotAmount({ slot: 1, amount: 3 });
      inputs[2] = SlotAmount({ slot: 2, amount: 3 });

      vm.prank(alice);
      startGasReport("craft with any input");
      world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);
      endGasReport();

      assertEnergyFlowedFromPlayerToLocalPool(snapshot);
    }

    assertInventoryHasObject(aliceEntityId, inputObjectType1, 0);
    assertInventoryHasObject(aliceEntityId, inputObjectType2, 0);
    assertInventoryHasObject(aliceEntityId, inputObjectType3, 0);
    {
      for (uint256 i = 0; i < outputTypes.length; i++) {
        assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
      }
    }
  }

  function testCraftTool() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.WoodenPick;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectType inputObjectType = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType, 5);
    assertInventoryHasObject(aliceEntityId, inputObjectType, 5);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    startGasReport("craft tool");
    world.craft(aliceEntityId, recipeId, inputs);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, inputObjectType, 0);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], 1);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(TestEntityUtils.exists(toolEntityId), "tool entity id should exist");
    ObjectType toolObjectType = EntityObjectType.get(toolEntityId);
    assertEq(toolObjectType, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectPhysics.getMass(outputTypes[0]), "mass should be equal to tool mass");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftWoodenPick() public {
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.WoodenPick;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType inputObjectType = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType, 10);
    assertInventoryHasObject(aliceEntityId, inputObjectType, 10);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    assertInventoryHasObject(aliceEntityId, inputObjectType, 5);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 of the crafted tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(TestEntityUtils.exists(toolEntityId), "tool entity id should exist");
    ObjectType toolObjectType = EntityObjectType.get(toolEntityId);
    assertEq(toolObjectType, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectPhysics.getMass(outputTypes[0]), "mass should be equal to tool mass");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftWoodenAxe() public {
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.WoodenAxe;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType inputObjectType = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType, 10);
    assertInventoryHasObject(aliceEntityId, inputObjectType, 10);

    EnergyDataSnapshot memory snapshot = getEnergyDataSnapshot(aliceEntityId);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    assertInventoryHasObject(aliceEntityId, inputObjectType, 5);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 of the crafted tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(TestEntityUtils.exists(toolEntityId), "tool entity id should exist");
    ObjectType toolObjectType = EntityObjectType.get(toolEntityId);
    assertEq(toolObjectType, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectPhysics.getMass(outputTypes[0]), "mass should be equal to tool mass");

    assertEnergyFlowedFromPlayerToLocalPool(snapshot);
  }

  function testCraftMultipleOutputs() public {
    vm.skip(true, "TODO");
  }

  function testCraftFailsIfNotEnoughInputs() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Input amount must be greater than 0");
    world.craft(aliceEntityId, recipeId, inputs);

    inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    inputAmounts = new uint16[](1);
    inputAmounts[0] = 8;
    outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.Chest;
    outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectType inputObjectType1 = ObjectTypes.OakPlanks;
    ObjectType inputObjectType2 = ObjectTypes.BirchPlanks;
    ObjectType inputObjectType3 = ObjectTypes.JunglePlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType1, 1);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType2, 1);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectType3, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectType1, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectType2, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectType3, 1);
    Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
    EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    inputs = new SlotAmount[](3);
    inputs[0] = SlotAmount({ slot: 0, amount: 1 });
    inputs[1] = SlotAmount({ slot: 1, amount: 1 });
    inputs[2] = SlotAmount({ slot: 2, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Not enough inputs for recipe");
    world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);
  }

  function testCraftFailsIfInvalidRecipe() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.Diamond;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Recipe not found");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftFailsIfInvalidStation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.IronBar;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 30;
    inputAmounts[1] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.ForceField;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
    EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Furnace);

    SlotAmount[] memory inputs = new SlotAmount[](2);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });
    inputs[1] = SlotAmount({ slot: 1, amount: inputAmounts[1] });

    vm.prank(alice);
    vm.expectRevert("This recipe requires a station");
    world.craft(aliceEntityId, recipeId, inputs);

    vm.prank(alice);
    vm.expectRevert("Invalid station");
    world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);

    stationCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);
    stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.craftWithStation(aliceEntityId, stationEntityId, recipeId, inputs);
  }

  function testCraftFailsIfFullInventory() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    TestInventoryUtils.addObject(
      aliceEntityId, ObjectTypes.OakLog, ObjectTypes.Player.getMaxInventorySlots() * ObjectTypes.OakLog.getStackable()
    );
    assertEq(
      Inventory.lengthOccupiedSlots(aliceEntityId),
      ObjectTypes.Player.getMaxInventorySlots(),
      "Wrong number of occupied inventory slots"
    );

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Inventory is full");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftFailsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    Energy.setEnergy(aliceEntityId, 1);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Not enough energy");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftFailsIfNoPlayer() public {
    (, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.expectRevert("Caller not allowed");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    PlayerBed.setBedEntityId(aliceEntityId, randomEntityId());

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftInsufficientEnergyHandling() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Setup a recipe
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    // Add the recipe ingredients to inventory
    TestInventoryUtils.addObject(aliceEntityId, inputTypes[0], inputAmounts[0]);

    // Drain almost all player energy
    Energy.setEnergy(aliceEntityId, 1);

    // Try to craft with no energy
    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Not enough energy");
    world.craft(aliceEntityId, recipeId, inputs);

    // Verify inventory is unchanged
    assertInventoryHasObject(aliceEntityId, inputTypes[0], inputAmounts[0]);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], 0);
  }

  function testCraftPartialInputConsumption() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Setup a recipe that requires multiple of the same input
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.Stone;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 9;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.Furnace;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    // Add more than needed to inventory
    uint16 extraAmount = 5;
    TestInventoryUtils.addObject(aliceEntityId, inputTypes[0], inputAmounts[0] + extraAmount);
    assertInventoryHasObject(aliceEntityId, inputTypes[0], inputAmounts[0] + extraAmount);

    // Craft with multiple inputs from same slot
    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    // Verify correct resources were consumed
    assertInventoryHasObject(aliceEntityId, inputTypes[0], extraAmount);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], outputAmounts[0]);
  }

  function testCraftInputTypeMatching() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.WoodenAxe;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    // Add different log types
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakPlanks, 5);
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.BirchPlanks, 5);

    // Craft with oak log
    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: 5 });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    // Verify oak log was consumed
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakPlanks, 0);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.BirchPlanks, 5);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], outputAmounts[0]);

    // Add more oak logs for next test
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.OakPlanks, 5);

    // Try to craft with birch log
    inputs[0] = SlotAmount({ slot: 1, amount: 5 });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    // Verify birch log was consumed
    assertInventoryHasObject(aliceEntityId, ObjectTypes.OakPlanks, 5);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.BirchPlanks, 0);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], outputAmounts[0] * 2);
  }

  function testCraftInventoryFullReplacesInputs() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Setup a recipe
    ObjectType[] memory inputTypes = new ObjectType[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectType[] memory outputTypes = new ObjectType[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    // Add the recipe ingredient
    TestInventoryUtils.addObject(aliceEntityId, inputTypes[0], inputAmounts[0]);

    // Fill all inventory slots except the input slot with different items
    for (uint8 slot = 1; slot < ObjectTypes.Player.getMaxInventorySlots(); slot++) {
      TestInventoryUtils.addObjectToSlot(aliceEntityId, ObjectTypes.Grass, 1, slot);
    }

    // Craft should still work because output type can stack with like items
    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    // Verify the output was created in the same slot as the input
    assertInventoryHasObject(aliceEntityId, outputTypes[0], outputAmounts[0]);
    assertInventoryHasObject(aliceEntityId, inputTypes[0], 0);
  }
}
