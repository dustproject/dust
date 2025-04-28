// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { EntityId } from "../src/EntityId.sol";

import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { LocalEnergyPool } from "../src/codegen/tables/LocalEnergyPool.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { EntityProgram } from "../src/codegen/tables/EntityProgram.sol";
import { MovablePosition } from "../src/codegen/tables/MovablePosition.sol";
import { Player } from "../src/codegen/tables/Player.sol";

import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { DustTest } from "./DustTest.sol";

import { CHUNK_SIZE } from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { ProgramId } from "../src/ProgramId.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { Position } from "../src/utils/Vec3Storage.sol";

import { SlotData, SlotTransfer } from "../src/utils/InventoryUtils.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

// Mock program for testing mine hooks
contract TestProgram is System {
  bool public shouldRevert = false;

  function setShouldRevert(bool _shouldRevert) external {
    shouldRevert = _shouldRevert;
  }

  fallback() external {
    require(!shouldRevert, "Mining not allowed by program");
  }
}

contract ProgramTest is DustTest {
  function attachTestProgram(EntityId entityId, System program, bytes14 namespace) internal returns (ProgramId) {
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, program, false);

    Vec3 coord = Position.get(entityId);

    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(coord - vec3(1, 0, 0));
    vm.prank(bob);
    world.attachProgram(bobEntityId, entityId, ProgramId.wrap(programSystemId.unwrap()), "");

    return ProgramId.wrap(programSystemId.unwrap());
  }

  function testTransferWithProgram() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Add object to player inventory
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    // Attach program to chest that allows transfers
    TestProgram program = new TestProgram();
    attachTestProgram(chestEntityId, program, "testNamespace");

    // Set up transfer data
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    // Execute transfer - should work
    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    // Verify transfer succeeded
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
  }

  function testDetachProgram() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Attach program to chest
    TestProgram program = new TestProgram();
    ProgramId programId = attachTestProgram(chestEntityId, program, "testNamespace");

    // Verify program is attached
    ProgramId attachedProgram = EntityProgram.getProgram(chestEntityId);
    assertEq(attachedProgram.unwrap(), programId.unwrap(), "Program not properly attached");

    // Detach program
    vm.prank(alice);
    world.detachProgram(aliceEntityId, chestEntityId, "");

    // Verify program is detached
    attachedProgram = EntityProgram.getProgram(chestEntityId);
    assertEq(attachedProgram.unwrap(), bytes32(0), "Program was not detached");
  }

  function testCannotAttachProgramIfAlreadyAttached() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Attach first program
    TestProgram program1 = new TestProgram();
    ProgramId programId1 = attachTestProgram(chestEntityId, program1, "namespace1");

    // Create second program
    TestProgram program2 = new TestProgram();
    ResourceId namespaceId2 = WorldResourceIdLib.encodeNamespace("namespace2");
    ResourceId programSystemId2 = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "namespace2", "programName");
    world.registerNamespace(namespaceId2);
    world.registerSystem(programSystemId2, program2, false);
    world.transferOwnership(namespaceId2, address(0));
    ProgramId programId2 = ProgramId.wrap(programSystemId2.unwrap());

    // Try to attach second program - should fail
    vm.prank(alice);
    vm.expectRevert("Existing program must be detached");
    world.attachProgram(aliceEntityId, chestEntityId, programId2, "");

    // Verify first program is still attached
    ProgramId attachedProgram = EntityProgram.getProgram(chestEntityId);
    assertEq(attachedProgram.unwrap(), programId1.unwrap(), "Original program was changed");
  }
}
