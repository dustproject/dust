// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC165 } from "@latticexyz/world/src/IERC165.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { TestEnergyUtils, TestForceFieldUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "../src/codegen/tables/EntityProgram.sol";

import { Fragment } from "../src/codegen/tables/Fragment.sol";
import { Machine } from "../src/codegen/tables/Machine.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";
import { DustTest, console } from "./DustTest.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import {
  FragmentPosition,
  MovablePosition,
  Position,
  ReverseFragmentPosition,
  ReversePosition
} from "../src/utils/Vec3Storage.sol";

import { FRAGMENT_SIZE, MACHINE_ENERGY_DRAIN_RATE } from "../src/Constants.sol";
import { EntityId } from "../src/EntityId.sol";
import { ObjectType } from "../src/ObjectType.sol";
import { ObjectTypes } from "../src/ObjectType.sol";
import { ProgramId } from "../src/ProgramId.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";

contract TestForceFieldProgram is System {
  // Just for testing, real programs should use tables
  bool revertOnValidateProgram;
  bool revertOnBuild;
  bool revertOnMine;
  bool revertOnRemoveFragment;

  function validateProgram(EntityId, EntityId, EntityId, ProgramId, bytes memory) external view {
    require(!revertOnValidateProgram, "Not allowed by forcefield");
    // Function is now empty since we use vm.expectCall to verify it was called with correct parameters
  }

  function onBuild(EntityId, EntityId, ObjectType, Vec3, bytes memory) external view {
    require(!revertOnBuild, "Not allowed by forcefield");
  }

  function onMine(EntityId, EntityId, ObjectType, Vec3, bytes memory) external view {
    require(!revertOnMine, "Not allowed by forcefield");
  }

  function onRemoveFragment(EntityId, EntityId, EntityId, bytes memory) external {
    require(!revertOnRemoveFragment, "Not allowed by forcefield");
  }

  function setRevertOnBuild(bool _revertOnBuild) external {
    revertOnBuild = _revertOnBuild;
  }

  function setRevertOnMine(bool _revertOnMine) external {
    revertOnMine = _revertOnMine;
  }

  function setRevertOnValidateProgram(bool _revert) external {
    revertOnValidateProgram = _revert;
  }

  function setRevertOnRemoveFragment(bool _revert) external {
    revertOnRemoveFragment = _revert;
  }

  fallback() external { }
}

contract TestFragmentProgram is System {
  // Just for testing, real programs should use tables
  bool revertOnValidateProgram;
  bool revertOnBuild;
  bool revertOnMine;

  function validateProgram(EntityId, EntityId, EntityId, ProgramId, bytes memory) external view {
    require(!revertOnValidateProgram, "Not allowed by forcefield fragment");
    // Function is now empty since we use vm.expectCall to verify it was called with correct parameters
  }

  function onBuild(EntityId, EntityId, ObjectType, Vec3, bytes memory) external view {
    require(!revertOnBuild, "Not allowed by forcefield fragment");
  }

  function onMine(EntityId, EntityId, ObjectType, Vec3, bytes memory) external view {
    require(!revertOnMine, "Not allowed by forcefield fragment");
  }

  function setRevertOnBuild(bool _revertOnBuild) external {
    revertOnBuild = _revertOnBuild;
  }

  function setRevertOnMine(bool _revertOnMine) external {
    revertOnMine = _revertOnMine;
  }

  function setRevertOnValidateProgram(bool _revert) external {
    revertOnValidateProgram = _revert;
  }

  fallback() external { }
}

contract TestChestProgram is System {
  fallback() external { }
}

contract ForceFieldTest is DustTest {
  function attachTestProgram(EntityId entityId, System programSystem) internal returns (ProgramId) {
    bytes14 namespace = bytes14(keccak256(abi.encode(programSystem)));
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, programSystem, false);

    Vec3 coord;
    // Handle force field fragments differently than regular entities
    if (EntityObjectType.get(entityId) == ObjectTypes.Fragment) {
      // For fragments, we need to use FragmentPosition instead of Position
      coord = FragmentPosition.get(entityId).fromFragmentCoord();
    } else {
      coord = Position.get(entityId) - vec3(1, 0, 0);
    }

    ProgramId program = ProgramId.wrap(programSystemId.unwrap());
    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(coord);
    vm.prank(bob);
    world.attachProgram(bobEntityId, entityId, program, "");
    return program;
  }

  function testMineWithForceFieldWithNoEnergy() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 0, drainRate: 1 })
    );

    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);
    program.setRevertOnMine(true);

    // Mine a block within the force field's area
    Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Prank as the player to mine the block
    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    // Verify that the block was successfully mined (should be replaced with Air)
    EntityId mineEntityId = ReversePosition.get(mineCoord);
    assertTrue(EntityObjectType.get(mineEntityId) == ObjectTypes.Air, "Block was not mined");
  }

  function testMineFailsIfNotAllowedByForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);
    program.setRevertOnMine(true);

    // Mine a block within the force field's area
    Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Prank as the player to mine the block
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testMineFailsIfNotAllowedByFragment() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    (, EntityId fragmentEntityId) = TestForceFieldUtils.getForceField(forceFieldCoord);

    TestFragmentProgram program = new TestFragmentProgram();
    attachTestProgram(fragmentEntityId, program);
    program.setRevertOnMine(true);

    // Mine a block within the force field's area
    Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Prank as the player to mine the block
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield fragment");
    world.mine(aliceEntityId, mineCoord, "");
  }

  function testBuildWithForceFieldWithNoEnergy() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 0, drainRate: 1 })
    );

    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);
    program.setRevertOnBuild(true);

    // Define build coordinates within force field
    Vec3 buildCoord = forceFieldCoord + vec3(1, 0, 1);

    // Set terrain at build coord to air
    setTerrainAtCoord(buildCoord, ObjectTypes.Air);

    // Add block to player's inventory
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    // Build the block
    vm.prank(alice);
    world.build(aliceEntityId, buildCoord, inventorySlot, "");

    // Verify that the block was successfully built
    EntityId buildEntityId = ReversePosition.get(buildCoord);
    assertTrue(EntityObjectType.get(buildEntityId) == buildObjectType, "Block was not built correctly");
  }

  function testBuildFailsIfNotAllowedByForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with NO energy (depleted)
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);
    program.setRevertOnBuild(true);

    // Define build coordinates within force field
    Vec3 buildCoord = forceFieldCoord + vec3(1, 0, 1);

    // Set terrain at build coord to air
    setTerrainAtCoord(buildCoord, ObjectTypes.Air);

    // Add block to player's inventory
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    // Try to build the block, should fail
    uint16 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testBuildFailsIfNotAllowedByFragment() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    (, EntityId fragmentEntityId) = TestForceFieldUtils.getForceField(forceFieldCoord);

    TestFragmentProgram program = new TestFragmentProgram();
    attachTestProgram(fragmentEntityId, program);
    program.setRevertOnBuild(true);

    // Define build coordinates within force field
    Vec3 buildCoord = forceFieldCoord + vec3(1, 0, 1);

    // Set terrain at build coord to air
    setTerrainAtCoord(buildCoord, ObjectTypes.Air);

    // Add block to player's inventory
    ObjectType buildObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
    assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

    uint16 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

    // Try to build the block, should fail
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield fragment");
    world.build(aliceEntityId, buildCoord, inventorySlot, "");
  }

  function testSetupForceField() public {
    // Set up a flat chunk with a player
    (,, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(forceFieldCoord);

    // Verify that the force field is active
    assertTrue(TestForceFieldUtils.isForceFieldActive(forceFieldEntityId), "Force field not active");

    // Verify that the fragment at the force field coordinate exists
    Vec3 fragmentCoord = forceFieldCoord.toFragmentCoord();
    assertTrue(TestForceFieldUtils.isFragment(forceFieldEntityId, fragmentCoord), "Force field fragment not found");

    // Verify that we can get the force field from the coordinate
    (EntityId retrievedForceFieldId,) = TestForceFieldUtils.getForceField(forceFieldCoord);
    assertEq(
      EntityId.unwrap(retrievedForceFieldId), EntityId.unwrap(forceFieldEntityId), "Retrieved incorrect force field"
    );
  }

  function testFragmentProgramIsNotUsedIfNoEnergy() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with NO energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    setupForceField(forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 0, drainRate: 1 }));

    // Get the fragment entity ID
    (, EntityId fragmentEntityId) = TestForceFieldUtils.getForceField(forceFieldCoord);

    // Attach a program to the fragment
    TestFragmentProgram program = new TestFragmentProgram();
    attachTestProgram(fragmentEntityId, program);
    program.setRevertOnMine(true);

    // Mine a block within the force field's area
    Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Prank as the player to mine the block, should not revert since forcefield has no energy
    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    // Verify that the block was successfully mined (should be replaced with Air)
    EntityId mineEntityId = ReversePosition.get(mineCoord);
    assertTrue(EntityObjectType.get(mineEntityId) == ObjectTypes.Air, "Block was not mined");
  }

  function testFragmentProgramIsNotUsedIfNotActive() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Get the fragment entity ID
    (, EntityId fragmentEntityId) = TestForceFieldUtils.getForceField(forceFieldCoord);

    // Attach a program to the fragment
    TestFragmentProgram program = new TestFragmentProgram();
    attachTestProgram(fragmentEntityId, program);
    program.setRevertOnMine(true);

    // Destroy the forcefield
    TestForceFieldUtils.destroyForceField(forceFieldEntityId);

    // Mine a block within the force field's area
    Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

    ObjectType mineObjectType = ObjectTypes.Grass;
    ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
    setObjectAtCoord(mineCoord, mineObjectType);

    // Prank as the player to mine the block, should not revert since forcefield is destroyed
    vm.prank(alice);
    world.mine(aliceEntityId, mineCoord, "");

    // Verify that the block was successfully mined (should be replaced with Air)
    EntityId mineEntityId = ReversePosition.get(mineCoord);
    assertTrue(EntityObjectType.get(mineEntityId) == ObjectTypes.Air, "Block was not mined");
  }

  function testAddFragment() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    EnergyData memory initialEnergyData =
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 });

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(forceFieldCoord, initialEnergyData);

    // Define expansion area
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 0, 0);

    // Expand the force field
    vm.prank(alice);
    startGasReport("Add single fragment");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");
    endGasReport();

    // Verify that the energy drain rate has increased
    EnergyData memory afterEnergyData = Energy.get(forceFieldEntityId);
    assertEq(
      afterEnergyData.drainRate,
      initialEnergyData.drainRate + MACHINE_ENERGY_DRAIN_RATE,
      "Energy drain rate did not increase correctly"
    );

    // Verify that each new fragment exists
    assertTrue(
      TestForceFieldUtils.isFragment(forceFieldEntityId, newFragmentCoord),
      "Force field fragment not found at coordinate"
    );
  }

  function testRemoveFragment() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 0, 0);

    // Add a fragment
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");

    // Get energy data after addition
    EnergyData memory afterAddEnergyData = Energy.get(forceFieldEntityId);

    // Compute boundary fragments
    Vec3[] memory boundary = world.computeBoundaryFragments(forceFieldEntityId, newFragmentCoord);

    uint8[] memory boundaryIdx = new uint8[](boundary.length);
    boundaryIdx[0] = 0;

    // Create a valid parent array for the boundary
    uint8[] memory parents = new uint8[](boundary.length);
    parents[0] = 0; // Root

    // Remove the fragment
    vm.prank(alice);
    startGasReport("Remove forcefield fragment");
    world.removeFragment(aliceEntityId, forceFieldEntityId, newFragmentCoord, boundaryIdx, parents, "");
    endGasReport();

    // Get energy data after removal
    EnergyData memory afterRemoveEnergyData = Energy.get(forceFieldEntityId);

    // Verify energy drain rate decreased
    assertEq(
      afterRemoveEnergyData.drainRate,
      afterAddEnergyData.drainRate - MACHINE_ENERGY_DRAIN_RATE,
      "Energy drain rate did not decrease correctly"
    );

    // Verify fragment no longer exists
    assertFalse(
      TestForceFieldUtils.isFragment(forceFieldEntityId, newFragmentCoord),
      "Force field fragment still exists after removal"
    );

    // Verify original fragment still exists
    assertTrue(
      TestForceFieldUtils.isFragment(forceFieldEntityId, refFragmentCoord), "Original force field fragment was removed"
    );
  }

  function testAddFragmentFailsIfRefFragmentNotAdjacent() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Reference fragment coordinate
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();

    // This coordinate is not adjacent to the reference fragment
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 1, 0);

    // Add should fail because new fragment is not adjacent to reference fragment (not in Von Neumann neighborhood)
    vm.prank(alice);
    vm.expectRevert("Reference fragment is not adjacent to new fragment");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");
  }

  // Test that diagonal coordinates are not considered adjacent (Von Neumann neighborhood enforces orthogonal adjacency)
  function testAddFragmentFailsIfRefFragmentNotInVonNeumannNeighborhood() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Reference fragment coordinate
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();

    // This coordinate is diagonally adjacent to the reference fragment (1,1,0 offset)
    Vec3 diagonalFragmentCoord = refFragmentCoord + vec3(1, 1, 0);

    // Add should fail because diagonal adjacency is not allowed (Von Neumann neighborhood requires manhattan distance = 1)
    vm.prank(alice);
    vm.expectRevert("Reference fragment is not adjacent to new fragment");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, diagonalFragmentCoord, "");
  }

  function testAddFragmentFailsIfRefFragmentNotInForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Invalid reference fragment coordinate (not part of the force field)
    Vec3 invalidRefFragmentCoord = forceFieldCoord.toFragmentCoord() + vec3(10, 0, 0);

    // Expansion area - directly adjacent to the invalid reference fragment
    Vec3 newFragmentCoord = invalidRefFragmentCoord + vec3(1, 0, 0);

    // Expand should fail because reference fragment is not part of the force field
    vm.prank(alice);
    vm.expectRevert("Fragment is too far");
    world.addFragment(aliceEntityId, forceFieldEntityId, invalidRefFragmentCoord, newFragmentCoord, "");
  }

  function testRemoveFragmentFailsIfInvalidSpanningTree() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Add a fragment to the force field
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 0, 0);

    vm.prank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");

    // Compute boundary fragments
    Vec3[] memory boundaryFragments = world.computeBoundaryFragments(forceFieldEntityId, newFragmentCoord);

    // Create boundaryIdx as [0, 1, ..., len-1]
    uint8[] memory boundaryIdx = new uint8[](boundaryFragments.length);
    for (uint256 i = 0; i < boundaryIdx.length; i++) {
      boundaryIdx[i] = uint8(i);
    }

    // Create an invalid parents array
    uint8[] memory invalidParents = new uint8[](boundaryIdx.length);
    invalidParents[0] = 1; // Invalid: for len=1, parents[0] must be 0

    // Remove should fail because the parent array doesn't represent a valid spanning tree
    vm.prank(alice);
    vm.expectRevert("Invalid spanning tree");
    world.removeFragment(aliceEntityId, forceFieldEntityId, newFragmentCoord, boundaryIdx, invalidParents, "");
  }

  function testComputeBoundaryFragments() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Expand the force field
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 fragment1 = refFragmentCoord + vec3(1, 0, 0);
    Vec3 fragment2 = refFragmentCoord + vec3(0, 1, 0);
    Vec3 fragment3 = refFragmentCoord + vec3(1, 1, 0);

    vm.startPrank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, fragment1, "");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, fragment2, "");
    world.addFragment(aliceEntityId, forceFieldEntityId, fragment1, fragment3, "");
    vm.stopPrank();

    // Compute the boundary fragments for fragment3
    Vec3[] memory boundaryFragments = world.computeBoundaryFragments(forceFieldEntityId, fragment3);

    // We expect 2 boundary fragments (fragment1 and fragment2)
    assertEq(boundaryFragments.length, 3, "Expected 3 boundary fragments");

    // Verify that each boundary fragment is part of the force field
    for (uint256 i = 0; i < boundaryFragments.length; i++) {
      assertTrue(
        TestForceFieldUtils.isFragment(forceFieldEntityId, boundaryFragments[i]),
        "Boundary fragment is not part of the force field"
      );
    }

    // Check that fragment1 and fragment2 are in the boundary
    bool foundRefFragment = false;
    bool foundFragment1 = false;
    bool foundFragment2 = false;
    for (uint256 i = 0; i < boundaryFragments.length; i++) {
      if (boundaryFragments[i] == refFragmentCoord) foundRefFragment = true;
      if (boundaryFragments[i] == fragment1) foundFragment1 = true;
      if (boundaryFragments[i] == fragment2) foundFragment2 = true;
    }
    assertTrue(foundRefFragment, "Fragment1 should be in the boundary");
    assertTrue(foundFragment1, "Fragment1 should be in the boundary");
    assertTrue(foundFragment2, "Fragment2 should be in the boundary");
  }

  function testAddIntoExistingForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create first force field
    Vec3 forceField1Coord = playerCoord + vec3(2, 0, 0);
    EntityId forceField1EntityId = setupForceField(
      forceField1Coord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Create second force field
    Vec3 forceField2Coord = forceField1Coord + vec3(FRAGMENT_SIZE, 0, 0);
    setupForceField(
      forceField2Coord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Try to expand first force field into second force field's area (should fail)
    Vec3 refFragmentCoord = forceField1Coord.toFragmentCoord();
    Vec3 newFragmentCoord = forceField2Coord.toFragmentCoord();
    vm.prank(alice);
    vm.expectRevert("Fragment already belongs to a forcefield");
    world.addFragment(aliceEntityId, forceField1EntityId, refFragmentCoord, newFragmentCoord, "");
  }

  function testForceFieldEnergyDrainsOverTime() public {
    // Set up a flat chunk with a player
    (,, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create a force field with energy
    uint128 initialTimestamp = uint128(vm.getBlockTimestamp());
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId =
      setupForceField(forceFieldCoord, EnergyData({ lastUpdatedTime: initialTimestamp, energy: 100, drainRate: 1 }));
    assertEq(
      Machine.getDepletedTime(forceFieldEntityId),
      uint128(vm.getBlockTimestamp()),
      "Accumulated depleted time is not initialized correctly"
    );

    // Fast forward time
    uint256 timeToAdvance = 50; // seconds
    vm.warp(vm.getBlockTimestamp() + timeToAdvance);

    TestEnergyUtils.updateMachineEnergy(forceFieldEntityId);

    // Check energy level (should be reduced)
    EnergyData memory currentEnergy = Energy.get(forceFieldEntityId);
    assertEq(currentEnergy.energy, 50, "Energy should be reduced after time passes");
    assertEq(Machine.getDepletedTime(forceFieldEntityId), initialTimestamp, "Accumulated depleted time changed");

    // Fast forward enough time to deplete all energy
    vm.warp(vm.getBlockTimestamp() + 60);

    TestEnergyUtils.updateMachineEnergy(forceFieldEntityId);

    // Check energy level (should be 0)
    currentEnergy = Energy.get(forceFieldEntityId);
    assertEq(currentEnergy.energy, 0, "Energy should be completely depleted");
    assertEq(
      Machine.getDepletedTime(forceFieldEntityId), initialTimestamp + 10, "Accumulated depleted time should be tracked"
    );
  }

  function testOnBuildAndOnMineHooksForForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Create and attach a test program
    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);

    // Test onBuild hook
    {
      // Set the program to allow building
      program.setRevertOnBuild(false);

      // Define build coordinates within force field
      Vec3 buildCoord = forceFieldCoord + vec3(1, 0, 1);

      // Set terrain at build coord to air
      setTerrainAtCoord(buildCoord, ObjectTypes.Air);

      // Add block to player's inventory
      ObjectType buildObjectType = ObjectTypes.Grass;
      TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
      assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

      uint16 inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

      // Build should succeed
      vm.prank(alice);
      world.build(aliceEntityId, buildCoord, inventorySlot, "");

      // Verify build succeeded
      EntityId buildEntityId = ReversePosition.get(buildCoord);
      assertTrue(EntityObjectType.get(buildEntityId) == buildObjectType, "Block was not built correctly");

      // Now set the program to disallow building
      program.setRevertOnBuild(true);

      // Define new build coordinates
      Vec3 buildCoord2 = forceFieldCoord + vec3(-1, 0, 1);

      // Set terrain at build coord to air
      setTerrainAtCoord(buildCoord2, ObjectTypes.Air);

      // Add block to player's inventory
      TestInventoryUtils.addObject(aliceEntityId, buildObjectType, 1);
      assertInventoryHasObject(aliceEntityId, buildObjectType, 1);

      inventorySlot = findInventorySlotWithObjectType(aliceEntityId, buildObjectType);

      // Build should fail
      vm.prank(alice);
      vm.expectRevert("Not allowed by forcefield");
      world.build(aliceEntityId, buildCoord2, inventorySlot, "");
    }

    // Test onMine hook
    {
      // Set the program to allow mining
      program.setRevertOnMine(false);

      // Mine a block within the force field's area
      Vec3 mineCoord = forceFieldCoord + vec3(1, 0, 0);

      ObjectType mineObjectType = ObjectTypes.Grass;
      ObjectPhysics.setMass(mineObjectType, playerHandMassReduction - 1);
      setObjectAtCoord(mineCoord, mineObjectType);

      // Mining should succeed
      vm.prank(alice);
      world.mine(aliceEntityId, mineCoord, "");

      // Verify mining succeeded
      EntityId mineEntityId = ReversePosition.get(mineCoord);
      assertTrue(EntityObjectType.get(mineEntityId) == ObjectTypes.Air, "Block was not mined");

      // Now set the program to disallow mining
      program.setRevertOnMine(true);

      // Define new mine coordinates
      Vec3 mineCoord2 = forceFieldCoord + vec3(-1, 0, 0);

      setObjectAtCoord(mineCoord2, mineObjectType);

      // Mining should fail
      vm.prank(alice);
      vm.expectRevert("Not allowed by forcefield");
      world.mine(aliceEntityId, mineCoord2, "");
    }
  }

  function testOverlappingForceFieldBoundaries() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create first force field
    Vec3 forceField1Coord = playerCoord - vec3(10, 0, 0);
    EntityId forceField1EntityId = setupForceField(
      forceField1Coord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Create second force field
    Vec3 forceField2Coord = playerCoord + vec3(10, 0, 0);
    EntityId forceField2EntityId = setupForceField(
      forceField2Coord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Add fragment to first force field
    Vec3 refFragmentCoord1 = forceField1Coord.toFragmentCoord();
    Vec3 newFragment1 = refFragmentCoord1 + vec3(1, 0, 0);
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceField1EntityId, refFragmentCoord1, newFragment1, "");

    // Add fragment to second force field
    Vec3 refFragmentCoord2 = forceField2Coord.toFragmentCoord();
    Vec3 newFragment2 = refFragmentCoord2 - vec3(1, 0, 0);
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceField2EntityId, refFragmentCoord2, newFragment2, "");

    // Try to add fragment to first force field in area occupied by second force field
    // This should fail
    vm.prank(alice);
    vm.expectRevert("Fragment already belongs to a forcefield");
    world.addFragment(aliceEntityId, forceField1EntityId, newFragment1, newFragment2, "");

    // Try to add fragment to second force field in area occupied by first force field
    // This should fail
    vm.prank(alice);
    vm.expectRevert("Fragment already belongs to a forcefield");
    world.addFragment(aliceEntityId, forceField2EntityId, newFragment2, newFragment1, "");
  }

  function testFragmentGasUsage() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Create a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 10000, drainRate: 1 })
    );

    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 0, 0);

    // Test adding a fragment
    vm.startPrank(alice);

    startGasReport("Add forcefield fragment");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");
    endGasReport();

    // Compute boundary fragments for removal
    Vec3[] memory boundary = world.computeBoundaryFragments(forceFieldEntityId, newFragmentCoord);
    assertEq(boundary.length, 1, "Expected 1 boundary fragment");

    uint8[] memory boundaryIdx = new uint8[](boundary.length);
    boundaryIdx[0] = 0; // Root
    uint8[] memory parents = new uint8[](boundary.length);
    parents[0] = 0; // Root

    startGasReport("Remove forcefield fragment");
    world.removeFragment(aliceEntityId, forceFieldEntityId, newFragmentCoord, boundaryIdx, parents, "");
    endGasReport();

    vm.stopPrank();
  }

  function testAttachProgramToObjectInForceField() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Create forcefield program and attach it
    TestForceFieldProgram forceFieldProgram = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, forceFieldProgram);

    // Set up a chest inside the forcefield
    Vec3 chestCoord = forceFieldCoord + vec3(1, 0, 0);
    setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Create a chest program
    TestChestProgram chestProgram = new TestChestProgram();

    // Register the chest program
    bytes14 namespace = "chestProgramNS";
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "chestProgram");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, chestProgram, false);

    // Expect the forcefield program's onProgramAttached to be called with the correct parameters
    bytes memory expectedCallData = abi.encodeCall(
      TestForceFieldProgram.validateProgram,
      (aliceEntityId, forceFieldEntityId, chestEntityId, ProgramId.wrap(programSystemId.unwrap()), bytes(""))
    );
    vm.expectCall(address(forceFieldProgram), expectedCallData);

    // Attach program with test player
    vm.prank(alice);
    world.attachProgram(aliceEntityId, chestEntityId, ProgramId.wrap(programSystemId.unwrap()), "");
  }

  function testAttachProgramToObjectInForceFieldFailsWhenDisallowed() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    // Create forcefield program, attach it, and configure it to disallow program attachments
    TestForceFieldProgram forceFieldProgram = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, forceFieldProgram);
    forceFieldProgram.setRevertOnValidateProgram(true);

    // Set up a chest inside the forcefield
    Vec3 chestCoord = forceFieldCoord + vec3(1, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Create the chest program
    TestChestProgram chestProgram = new TestChestProgram();
    bytes14 namespace = bytes14(vm.randomBytes(14));
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, chestProgram, false);

    // Attach program with test player
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield");
    // Attempt to attach program with test player, should fail
    world.attachProgram(aliceEntityId, chestEntityId, ProgramId.wrap(programSystemId.unwrap()), "");
  }

  function testAttachProgramToObjectWithNoForceFieldEnergy() public {
    // Set up a flat chunk with a player
    (,, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Set up a force field with NO energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 0, drainRate: 1 })
    );

    // Create forcefield program and attach it
    TestForceFieldProgram forceFieldProgram = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, forceFieldProgram);
    forceFieldProgram.setRevertOnValidateProgram(true); // Should not matter since forcefield has no energy

    // Set up a chest inside the forcefield
    Vec3 chestCoord = forceFieldCoord + vec3(1, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Register the chest program
    TestChestProgram chestProgram = new TestChestProgram();

    // We explicitly do NOT use vm.expectCall here since we're testing that
    // the hook is NOT called when there's no energy

    // Attach the program
    ProgramId program = attachTestProgram(chestEntityId, chestProgram);
    assertEq(EntityProgram.get(chestEntityId), program, "Program not atached to chest");
  }

  function testValidateSpanningTree() public view {
    // Test case 1: Empty array (trivial case)
    {
      Vec3[] memory boundary = new Vec3[](0);
      uint8[] memory boundaryIdx = new uint8[](0);
      uint8[] memory parents = new uint8[](0);
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Empty array should not be valid");
    }

    // Test case 2: Single node (trivial case)
    {
      Vec3[] memory boundary = new Vec3[](1);
      boundary[0] = vec3(0, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](1);
      boundaryIdx[0] = 0;
      uint8[] memory parents = new uint8[](1);
      parents[0] = 0; // Self-referential
      assertTrue(world.validateSpanningTree(boundary, boundaryIdx, parents), "Single node should be valid");
    }

    // Test case 3: Simple line of 3 nodes
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0; // Root
      parents[1] = 0; // Parent is boundary[0]
      parents[2] = 1; // Parent is boundary[1]
      assertTrue(world.validateSpanningTree(boundary, boundaryIdx, parents), "Line of 3 nodes should be valid");
    }

    // Test case 4: Star pattern (all nodes connected to root)
    {
      Vec3[] memory boundary = new Vec3[](5);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(0, 1, 0);
      boundary[3] = vec3(-1, 0, 0);
      boundary[4] = vec3(0, -1, 0);
      uint8[] memory boundaryIdx = new uint8[](5);
      for (uint8 i = 0; i < 5; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](5);
      parents[0] = 0; // Root
      parents[1] = 0;
      parents[2] = 0;
      parents[3] = 0;
      parents[4] = 0;
      assertTrue(world.validateSpanningTree(boundary, boundaryIdx, parents), "Star pattern should be valid");
    }

    // Test case 5: Invalid - parents array length mismatch
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](2);
      parents[0] = 0;
      parents[1] = 0;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Invalid parents length");
    }

    // Test case 6: Invalid - non-adjacent nodes
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(3, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Non-adjacent fragments");
    }

    // Test case 7: Invalid - disconnected graph
    {
      Vec3[] memory boundary = new Vec3[](4);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(5, 0, 0);
      boundary[3] = vec3(6, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](4);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      boundaryIdx[3] = 3;
      uint8[] memory parents = new uint8[](4);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 2;
      parents[3] = 2;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Disconnected graph should be invalid");
    }

    // Test case 8: Invalid - cycle in the graph
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(1, 1, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 2;
      parents[1] = 0;
      parents[2] = 1;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Root must be self-referential");
    }

    // Test case 9: Valid - complex tree with branches
    {
      Vec3[] memory boundary = new Vec3[](7);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(0, 1, 0);
      boundary[3] = vec3(2, 0, 0);
      boundary[4] = vec3(1, 1, 0);
      boundary[5] = vec3(0, 2, 0);
      boundary[6] = vec3(3, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](7);
      for (uint8 i = 0; i < 7; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](7);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 0;
      parents[3] = 1;
      parents[4] = 2;
      parents[5] = 2;
      parents[6] = 3;
      assertTrue(world.validateSpanningTree(boundary, boundaryIdx, parents), "Complex tree should be valid");
    }

    // Test case 10: Invalid - diagonal neighbors
    {
      Vec3[] memory boundary = new Vec3[](2);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 1, 0);
      uint8[] memory boundaryIdx = new uint8[](2);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      uint8[] memory parents = new uint8[](2);
      parents[0] = 0;
      parents[1] = 0;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Non-adjacent fragments");
    }

    // Test case 11: Invalid - parent index out of bounds
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 10;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Parent index out of bounds");
    }

    // Test case 12: Invalid - cycle in the middle of the array
    {
      Vec3[] memory boundary = new Vec3[](5);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(3, 0, 0);
      boundary[4] = vec3(4, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](5);
      for (uint8 i = 0; i < 5; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](5);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 3;
      parents[3] = 2;
      parents[4] = 3;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Cycle in the middle of the array");
    }

    // Test case 13: Invalid - multiple nodes pointing to non-existent parent
    {
      Vec3[] memory boundary = new Vec3[](5);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(3, 0, 0);
      boundary[4] = vec3(4, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](5);
      for (uint8 i = 0; i < 5; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](5);
      parents[0] = 0;
      parents[1] = 10;
      parents[2] = 10;
      parents[3] = 10;
      parents[4] = 0;
      assertFalse(
        world.validateSpanningTree(boundary, boundaryIdx, parents), "Multiple nodes pointing to non-existent parent"
      );
    }

    // Test case 14: Invalid - node is its own parent (except root)
    {
      Vec3[] memory boundary = new Vec3[](4);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(3, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](4);
      for (uint8 i = 0; i < 4; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](4);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 2;
      parents[3] = 2;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Node cannot be its own parent");
    }

    // Test case 15: Invalid - complex cycle in a larger graph
    {
      Vec3[] memory boundary = new Vec3[](8);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(3, 0, 0);
      boundary[4] = vec3(4, 0, 0);
      boundary[5] = vec3(3, 1, 0);
      boundary[6] = vec3(2, 1, 0);
      boundary[7] = vec3(1, 1, 0);
      uint8[] memory boundaryIdx = new uint8[](8);
      for (uint8 i = 0; i < 8; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](8);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      parents[3] = 2;
      parents[4] = 3;
      parents[5] = 6;
      parents[6] = 7;
      parents[7] = 5;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Complex cycle in larger graph");
    }

    // Test case 16: Invalid - root not at index 0
    {
      Vec3[] memory boundary = new Vec3[](4);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(3, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](4);
      for (uint8 i = 0; i < 4; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](4);
      parents[0] = 1;
      parents[1] = 1;
      parents[2] = 1;
      parents[3] = 2;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Root must be at index 0");
    }

    // Test case 17: Invalid - parent references later index
    {
      Vec3[] memory boundary = new Vec3[](4);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(1, 1, 0);
      boundary[3] = vec3(0, 1, 0);
      uint8[] memory boundaryIdx = new uint8[](4);
      for (uint8 i = 0; i < 4; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](4);
      parents[0] = 0;
      parents[1] = 3;
      parents[2] = 1;
      parents[3] = 0;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Forward reference creates invalid tree");
    }

    // Test case 18: Valid - zigzag pattern
    {
      Vec3[] memory boundary = new Vec3[](5);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(1, 1, 0);
      boundary[3] = vec3(0, 1, 0);
      boundary[4] = vec3(0, 2, 0);
      uint8[] memory boundaryIdx = new uint8[](5);
      for (uint8 i = 0; i < 5; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](5);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      parents[3] = 2;
      parents[4] = 3;
      assertTrue(world.validateSpanningTree(boundary, boundaryIdx, parents), "Zigzag pattern should be valid");
    }

    // Test case 19: Invalid - multiple roots
    {
      Vec3[] memory boundary = new Vec3[](6);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(10, 0, 0);
      boundary[4] = vec3(11, 0, 0);
      boundary[5] = vec3(12, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](6);
      for (uint8 i = 0; i < 6; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](6);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      parents[3] = 3;
      parents[4] = 3;
      parents[5] = 4;
      assertFalse(world.validateSpanningTree(boundary, boundaryIdx, parents), "Multiple roots should be invalid");
    }

    // Test case 20: Invalid - complex disconnected components
    {
      Vec3[] memory boundary = new Vec3[](10);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      boundary[3] = vec3(10, 0, 0);
      boundary[4] = vec3(11, 0, 0);
      boundary[5] = vec3(20, 0, 0);
      boundary[6] = vec3(21, 0, 0);
      boundary[7] = vec3(22, 0, 0);
      boundary[8] = vec3(23, 0, 0);
      boundary[9] = vec3(24, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](10);
      for (uint8 i = 0; i < 10; i++) {
        boundaryIdx[i] = i;
      }
      uint8[] memory parents = new uint8[](10);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      parents[3] = 3;
      parents[4] = 3;
      parents[5] = 5;
      parents[6] = 5;
      parents[7] = 6;
      parents[8] = 7;
      parents[9] = 8;
      assertFalse(
        world.validateSpanningTree(boundary, boundaryIdx, parents), "Complex disconnected components should be invalid"
      );
    }

    // Additional Test case 21: Valid - permuted order with valid parents
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 2; // Order: [2,1,0]
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 0;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0; // Root is boundary[2]
      parents[1] = 0; // boundary[1] is child of boundary[2]
      parents[2] = 1; // boundary[0] is child of boundary[1]
      assertTrue(
        world.validateSpanningTree(boundary, boundaryIdx, parents), "Permuted order with valid parents should be valid"
      );
    }

    // Additional Test case 22: Invalid - duplicate indices in boundaryIdx
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 0; // Duplicate
      boundaryIdx[2] = 2;
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      assertFalse(
        world.validateSpanningTree(boundary, boundaryIdx, parents), "Duplicate indices in boundaryIdx should be invalid"
      );
    }

    // Additional Test case 23: Invalid - missing indices in boundaryIdx
    {
      Vec3[] memory boundary = new Vec3[](3);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(2, 0, 0);
      uint8[] memory boundaryIdx = new uint8[](3);
      boundaryIdx[0] = 0;
      boundaryIdx[1] = 1;
      boundaryIdx[2] = 1; // Missing index 2
      uint8[] memory parents = new uint8[](3);
      parents[0] = 0;
      parents[1] = 0;
      parents[2] = 1;
      assertFalse(
        world.validateSpanningTree(boundary, boundaryIdx, parents), "Missing indices in boundaryIdx should be invalid"
      );
    }

    // Additional Test case 24: Valid - non-identity permutation with valid parents
    {
      Vec3[] memory boundary = new Vec3[](4);
      boundary[0] = vec3(0, 0, 0);
      boundary[1] = vec3(1, 0, 0);
      boundary[2] = vec3(0, 1, 0);
      boundary[3] = vec3(1, 1, 0);
      uint8[] memory boundaryIdx = new uint8[](4);
      boundaryIdx[0] = 3; // Order: [3,2,1,0]
      boundaryIdx[1] = 2;
      boundaryIdx[2] = 1;
      boundaryIdx[3] = 0;
      uint8[] memory parents = new uint8[](4);
      parents[0] = 0; // Root is boundary[3]
      parents[1] = 0; // boundary[2] -> boundary[3]
      parents[2] = 0; // boundary[1] -> boundary[3]
      parents[3] = 1; // boundary[0] -> boundary[2]
      assertTrue(
        world.validateSpanningTree(boundary, boundaryIdx, parents),
        "Non-identity permutation with valid parents should be valid"
      );
    }
  }

  function testForceFieldProgramCallbackInteractions() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Setup force field
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    // Create and attach a program to the force field
    TestForceFieldProgram program = new TestForceFieldProgram();
    attachTestProgram(forceFieldEntityId, program);

    // Add fragment normally
    Vec3 fragment1Coord = refFragmentCoord + vec3(1, 0, 0);
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, fragment1Coord, "");

    // Create another fragment for testing
    Vec3 fragment2Coord = refFragmentCoord + vec3(0, 1, 0);
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, fragment2Coord, "");

    // Create a third fragment
    Vec3 fragment3Coord = refFragmentCoord + vec3(0, 0, 1);
    vm.prank(alice);
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, fragment3Coord, "");

    // Prepare spanning tree for fragment2 removal
    uint8[] memory boundaryIdx = new uint8[](3);
    boundaryIdx[0] = 1;
    boundaryIdx[1] = 0;
    boundaryIdx[2] = 2;

    uint8[] memory parents = new uint8[](3);
    parents[0] = 0;
    parents[1] = 0;
    parents[2] = 1;

    // Set the program to revert on removal
    program.setRevertOnRemoveFragment(true);

    // Try to remove fragment2 - should fail due to program
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield");
    world.removeFragment(aliceEntityId, forceFieldEntityId, fragment2Coord, boundaryIdx, parents, "");

    // Turn off the forcefield energy
    Energy.setEnergy(forceFieldEntityId, 0);

    // Should now be able to remove fragment even with the program set to revert
    vm.prank(alice);
    world.removeFragment(aliceEntityId, forceFieldEntityId, fragment2Coord, boundaryIdx, parents, "");

    // Verify fragment was removed
    // Check if fragment is no longer part of the forcefield
    bool isFragment = TestForceFieldUtils.isFragment(forceFieldEntityId, fragment2Coord);
    assertFalse(isFragment, "Fragment should be removed");
  }

  function testForceFieldRemoveFragmentWithFragmentedBoundary() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    // Setup force field
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    EntityId forceField = setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    // Create a line of fragments (forceField - frag1 - frag2)
    Vec3 fragment1Coord = refFragmentCoord + vec3(1, 0, 0);
    Vec3 fragment2Coord = refFragmentCoord + vec3(1, 0, 1);

    vm.startPrank(alice);
    world.addFragment(aliceEntityId, forceField, refFragmentCoord, fragment1Coord, "");
    world.addFragment(aliceEntityId, forceField, fragment1Coord, fragment2Coord, "");
    vm.stopPrank();

    // Try to remove the middle fragment (fragment1)
    // This would disconnect fragment2 from the forcefield
    uint8[] memory boundaryIdx = new uint8[](2);
    boundaryIdx[0] = 0; // forceField
    boundaryIdx[1] = 1; // fragment2

    uint8[] memory parents = new uint8[](2);
    parents[0] = 0;
    parents[1] = 0;

    // This should fail because fragment2 is not actually a boundary of fragment1
    vm.prank(alice);
    vm.expectRevert("Invalid spanning tree");
    world.removeFragment(aliceEntityId, forceField, fragment1Coord, boundaryIdx, parents, "");

    // But we should be able to remove the last fragment (fragment2)
    uint8[] memory boundaryIdx2 = new uint8[](2);
    boundaryIdx2[0] = 0; // fragment1
    boundaryIdx2[1] = 1; // forceField

    uint8[] memory parents2 = new uint8[](2);
    parents2[0] = 0;
    parents2[0] = 0;

    Vec3[] memory boundary = world.computeBoundaryFragments(forceField, fragment2Coord);
    assertEq(boundary.length, 2, "Wrong number of fragments in boundary");
    for (uint8 i = 0; i < boundary.length; i++) {
      assertTrue(TestForceFieldUtils.isFragment(forceField, boundary[i]), "Boundary should be a fragment");
    }
    assertEq(boundary[0], fragment1Coord, "Wrong boundary");
    assertEq(boundary[1], refFragmentCoord, "Wrong boundary");

    vm.prank(alice);
    world.removeFragment(aliceEntityId, forceField, fragment2Coord, boundaryIdx2, parents2, "");

    // Verify fragment2 was removed
    assertFalse(TestForceFieldUtils.isFragment(forceField, fragment2Coord), "Fragment should be removed");
  }

  function testProgramValidatorHierarchySelection() public {
    // Setup player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Create force field
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    setupForceField(
      forceFieldCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 0 })
    );

    // Get the fragment
    (EntityId forceField, EntityId fragment) = TestForceFieldUtils.getForceField(forceFieldCoord);

    // Create chest in force field area
    Vec3 chestCoord = forceFieldCoord + vec3(1, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Create and attach validator program to fragment
    TestFragmentProgram fragmentProgram = new TestFragmentProgram();
    fragmentProgram.setRevertOnValidateProgram(true); // Fragment will reject programs
    attachTestProgram(fragment, fragmentProgram);

    // Create the chest program
    TestChestProgram chestProgram = new TestChestProgram();
    bytes14 namespace = bytes14(vm.randomBytes(14));
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, chestProgram, false);

    // Try to attach program - should be rejected by fragment validator
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield fragment");
    world.attachProgram(aliceEntityId, chestEntityId, ProgramId.wrap(programSystemId.unwrap()), "");

    // Detach fragment program
    vm.prank(alice);
    world.detachProgram(aliceEntityId, fragment, "");

    // Create and attach validator program to main force field
    TestForceFieldProgram forceFieldProgram = new TestForceFieldProgram();
    forceFieldProgram.setRevertOnValidateProgram(true); // Force field will reject programs too
    attachTestProgram(forceField, forceFieldProgram);

    // Try to attach program again - should be rejected by force field validator
    vm.prank(alice);
    vm.expectRevert("Not allowed by forcefield");
    world.attachProgram(aliceEntityId, chestEntityId, ProgramId.wrap(programSystemId.unwrap()), "");
  }

  function testAddFragmentWithExtraDrainRate() public {
    // Set up a flat chunk with a player
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupFlatChunkWithPlayer();

    EnergyData memory initialEnergyData =
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 });

    // Set up a force field with energy
    Vec3 forceFieldCoord = playerCoord + vec3(2, 0, 0);
    EntityId forceFieldEntityId = setupForceField(forceFieldCoord, initialEnergyData);

    // Define expansion area
    Vec3 refFragmentCoord = forceFieldCoord.toFragmentCoord();
    Vec3 newFragmentCoord = refFragmentCoord + vec3(1, 0, 0);

    EntityId fragment = TestForceFieldUtils.getOrCreateFragmentAt(newFragmentCoord);

    // Set extraDrainRate
    uint128 extraDrainRate = 1;
    Fragment.setExtraDrainRate(fragment, extraDrainRate);

    // Expand the force field
    vm.prank(alice);
    startGasReport("Add single fragment");
    world.addFragment(aliceEntityId, forceFieldEntityId, refFragmentCoord, newFragmentCoord, "");
    endGasReport();

    // Verify that the energy drain rate has increased
    EnergyData memory afterEnergyData = Energy.get(forceFieldEntityId);
    assertEq(
      afterEnergyData.drainRate,
      initialEnergyData.drainRate + MACHINE_ENERGY_DRAIN_RATE + extraDrainRate,
      "Energy drain rate did not increase correctly"
    );

    // Verify that each new fragment exists
    assertTrue(
      TestForceFieldUtils.isFragment(forceFieldEntityId, newFragmentCoord),
      "Force field fragment not found at coordinate"
    );
  }
}
