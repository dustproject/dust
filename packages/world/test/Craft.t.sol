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

import { Mass } from "../src/codegen/tables/Mass.sol";
import { MovablePosition } from "../src/codegen/tables/MovablePosition.sol";
import { ObjectType } from "../src/codegen/tables/ObjectType.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { Player } from "../src/codegen/tables/Player.sol";

import { PlayerStatus } from "../src/codegen/tables/PlayerStatus.sol";
import { Position } from "../src/codegen/tables/Position.sol";
import { ReversePosition } from "../src/codegen/tables/ReversePosition.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import { CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "../src/Constants.sol";
import { ObjectTypeId } from "../src/ObjectTypeId.sol";
import { ObjectTypeLib } from "../src/ObjectTypeLib.sol";
import { ObjectTypes } from "../src/ObjectTypes.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { SlotAmount } from "../src/utils/InventoryUtils.sol";

import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract CraftTest is DustTest {
  using ObjectTypeLib for ObjectTypeId;

  function hashRecipe(
    ObjectTypeId stationObjectTypeId,
    ObjectTypeId[] memory inputTypes,
    uint16[] memory inputAmounts,
    ObjectTypeId[] memory outputTypes,
    uint16[] memory outputAmounts
  ) internal pure returns (bytes32) {
    return keccak256(abi.encode(stationObjectTypeId, inputTypes, inputAmounts, outputTypes, outputAmounts));
  }

  function testCraftSingleInputSingleOutput() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

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

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftMultipleInputsSingleOutput() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.Sand;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 6;
    inputAmounts[1] = 2;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    SlotAmount[] memory inputs = new SlotAmount[](2);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });
    inputs[1] = SlotAmount({ slot: 1, amount: inputAmounts[1] });

    vm.prank(alice);
    startGasReport("handcraft multiple inputs");
    world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);
    endGasReport();

    for (uint256 i = 0; i < inputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, inputTypes[i], 0);
    }
    for (uint256 i = 0; i < outputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
    }

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftWithStation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.IronBar;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 30;
    inputAmounts[1] = 5;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    SlotAmount[] memory inputs = new SlotAmount[](2);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });
    inputs[1] = SlotAmount({ slot: 1, amount: inputAmounts[1] });

    vm.prank(alice);
    startGasReport("craft with station");
    world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);
    endGasReport();

    for (uint256 i = 0; i < inputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, inputTypes[i], 0);
    }
    for (uint256 i = 0; i < outputTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
    }

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftAnyInput() public {
    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 8;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.Chest;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;

    bytes32 recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectTypeId inputObjectTypeId1 = ObjectTypes.OakPlanks;
    ObjectTypeId inputObjectTypeId2 = ObjectTypes.BirchPlanks;
    ObjectTypeId inputObjectTypeId3 = ObjectTypes.JunglePlanks;

    // Doing it here to avoid stack too deep
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId1, 2);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId2, 3);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId3, 3);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId1, 2);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId2, 3);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId3, 3);

    {
      Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
      EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

      EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

      SlotAmount[] memory inputs = new SlotAmount[](3);
      inputs[0] = SlotAmount({ slot: 0, amount: 2 });
      inputs[1] = SlotAmount({ slot: 1, amount: 3 });
      inputs[2] = SlotAmount({ slot: 2, amount: 3 });

      vm.prank(alice);
      startGasReport("craft with any input");
      world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);
      endGasReport();

      EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
      assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
    }

    assertInventoryHasObject(aliceEntityId, inputObjectTypeId1, 0);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId2, 0);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId3, 0);
    {
      for (uint256 i = 0; i < outputTypes.length; i++) {
        assertInventoryHasObject(aliceEntityId, outputTypes[i], outputAmounts[i]);
      }
    }
  }

  function testCraftTool() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.WoodenPick;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectTypeId inputObjectTypeId = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId, 5);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 5);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    startGasReport("craft tool");
    world.craft(aliceEntityId, recipeId, inputs);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 0);
    assertInventoryHasObject(aliceEntityId, outputTypes[0], 1);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(toolEntityId.exists(), "tool entity id should exist");
    ObjectTypeId toolObjectTypeId = ObjectType.get(toolEntityId);
    assertEq(toolObjectTypeId, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasTool(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectTypeMetadata.getMass(outputTypes[0]), "mass should be equal to tool mass");

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftWoodenPick() public {
    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.WoodenPick;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId inputObjectTypeId = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId, 10);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 10);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 5);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 of the crafted tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(toolEntityId.exists(), "tool entity id should exist");
    ObjectTypeId toolObjectTypeId = ObjectType.get(toolEntityId);
    assertEq(toolObjectTypeId, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasTool(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectTypeMetadata.getMass(outputTypes[0]), "mass should be equal to tool mass");

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftWoodenAxe() public {
    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 5;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.WoodenAxe;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId inputObjectTypeId = ObjectTypes.OakPlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId, 10);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 10);

    EnergyDataSnapshot memory beforeEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    world.craft(aliceEntityId, recipeId, inputs);

    assertInventoryHasObject(aliceEntityId, inputObjectTypeId, 5);
    uint16[] memory toolSlots = InventoryTypeSlots.get(aliceEntityId, outputTypes[0]);
    assertEq(toolSlots.length, 1, "should have 1 of the crafted tool");
    EntityId toolEntityId = InventorySlot.getEntityId(aliceEntityId, toolSlots[0]);
    assertTrue(toolEntityId.exists(), "tool entity id should exist");
    ObjectTypeId toolObjectTypeId = ObjectType.get(toolEntityId);
    assertEq(toolObjectTypeId, outputTypes[0], "tool object type should be equal to expected output object type");
    assertInventoryHasTool(aliceEntityId, toolEntityId, 1);
    assertEq(Mass.get(toolEntityId), ObjectTypeMetadata.getMass(outputTypes[0]), "mass should be equal to tool mass");

    EnergyDataSnapshot memory afterEnergyDataSnapshot = getEnergyDataSnapshot(aliceEntityId, playerCoord);
    assertEnergyFlowedFromPlayerToLocalPool(beforeEnergyDataSnapshot, afterEnergyDataSnapshot);
  }

  function testCraftMultipleOutputs() public {
    vm.skip(true, "TODO");
  }

  function testCraftWithCoal() public {
    vm.skip(true, "TODO");
  }

  function testCraftFailsIfNotEnoughInputs() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Input amount must be greater than zero");
    world.craft(aliceEntityId, recipeId, inputs);

    inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.AnyPlank;
    inputAmounts = new uint16[](1);
    inputAmounts[0] = 8;
    outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.Chest;
    outputAmounts = new uint16[](1);
    outputAmounts[0] = 1;
    recipeId = hashRecipe(ObjectTypes.Workbench, inputTypes, inputAmounts, outputTypes, outputAmounts);

    ObjectTypeId inputObjectTypeId1 = ObjectTypes.OakPlanks;
    ObjectTypeId inputObjectTypeId2 = ObjectTypes.BirchPlanks;
    ObjectTypeId inputObjectTypeId3 = ObjectTypes.JunglePlanks;
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId1, 1);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId2, 1);
    TestInventoryUtils.addObject(aliceEntityId, inputObjectTypeId3, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId1, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId2, 1);
    assertInventoryHasObject(aliceEntityId, inputObjectTypeId3, 1);
    Vec3 stationCoord = playerCoord + vec3(1, 0, 0);
    EntityId stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    inputs = new SlotAmount[](3);
    inputs[0] = SlotAmount({ slot: 0, amount: 1 });
    inputs[1] = SlotAmount({ slot: 1, amount: 1 });
    inputs[2] = SlotAmount({ slot: 2, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Not enough inputs for recipe");
    world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);
  }

  function testCraftFailsIfInvalidRecipe() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](2);
    inputTypes[0] = ObjectTypes.Stone;
    inputTypes[1] = ObjectTypes.IronBar;
    uint16[] memory inputAmounts = new uint16[](2);
    inputAmounts[0] = 30;
    inputAmounts[1] = 5;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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
    world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);

    stationCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);
    stationEntityId = setObjectAtCoord(stationCoord, ObjectTypes.Workbench);

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.craftWithStation(aliceEntityId, recipeId, stationEntityId, inputs);
  }

  function testCraftFailsIfFullInventory() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    TestInventoryUtils.addObject(
      aliceEntityId,
      ObjectTypes.OakLog,
      ObjectTypeMetadata.getMaxInventorySlots(ObjectTypes.Player) * ObjectTypeMetadata.getStackable(ObjectTypes.OakLog)
    );
    assertEq(
      Inventory.length(aliceEntityId),
      ObjectTypeMetadata.getMaxInventorySlots(ObjectTypes.Player),
      "Wrong number of occupied inventory slots"
    );

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("All slots used");
    world.craft(aliceEntityId, recipeId, inputs);
  }

  function testCraftFailsIfNotEnoughEnergy() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
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

    ObjectTypeId[] memory inputTypes = new ObjectTypeId[](1);
    inputTypes[0] = ObjectTypes.OakLog;
    uint16[] memory inputAmounts = new uint16[](1);
    inputAmounts[0] = 1;
    ObjectTypeId[] memory outputTypes = new ObjectTypeId[](1);
    outputTypes[0] = ObjectTypes.OakPlanks;
    uint16[] memory outputAmounts = new uint16[](1);
    outputAmounts[0] = 4;
    bytes32 recipeId = hashRecipe(ObjectTypes.Null, inputTypes, inputAmounts, outputTypes, outputAmounts);

    for (uint256 i = 0; i < inputTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
      assertInventoryHasObject(aliceEntityId, inputTypes[i], inputAmounts[i]);
    }

    PlayerStatus.setBedEntityId(aliceEntityId, randomEntityId());

    SlotAmount[] memory inputs = new SlotAmount[](1);
    inputs[0] = SlotAmount({ slot: 0, amount: inputAmounts[0] });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.craft(aliceEntityId, recipeId, inputs);
  }
}
