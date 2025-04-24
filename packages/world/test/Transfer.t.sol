// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { IERC165 } from "@latticexyz/world/src/IERC165.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { EntityId } from "../src/EntityId.sol";

import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";
import { EnergyData } from "../src/codegen/tables/Energy.sol";

import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { MovablePosition } from "../src/codegen/tables/MovablePosition.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { Player } from "../src/codegen/tables/Player.sol";

import { PlayerStatus } from "../src/codegen/tables/PlayerStatus.sol";
import { ReverseMovablePosition } from "../src/codegen/tables/ReverseMovablePosition.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { DustTest } from "./DustTest.sol";

import { CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "../src/Constants.sol";
import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { ProgramId } from "../src/ProgramId.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { SlotData, SlotTransfer } from "../src/utils/InventoryUtils.sol";
import { Position } from "../src/utils/Vec3Storage.sol";

import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract TestChestProgram is System {
  // Control revert behavior
  bool revertOnTransfer;

  function onTransfer(EntityId, EntityId, SlotData[] memory, SlotData[] memory, bytes memory) external view {
    require(!revertOnTransfer, "Transfer not allowed by chest");
  }

  function setRevertOnTransfer(bool _revertOnTransfer) external {
    revertOnTransfer = _revertOnTransfer;
  }

  // Function to test calling the world from an entity
  function call(IWorld world, bytes memory data) external {
    (bool success, bytes memory returnData) = address(world).call(data);
    if (!success) {
      revertWithBytes(returnData);
    }
  }

  fallback() external { }
}

contract TransferTest is DustTest {
  function attachTestProgram(EntityId entityId, System program, bytes14 namespace) internal {
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    ResourceId programSystemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, "programName");
    world.registerNamespace(namespaceId);
    world.registerSystem(programSystemId, program, false);
    world.transferOwnership(namespaceId, address(0));

    Vec3 coord = Position.get(entityId);

    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(coord - vec3(1, 0, 0));
    vm.prank(bob);
    world.attachProgram(bobEntityId, entityId, ProgramId.wrap(programSystemId.unwrap()), "");
  }

  function testTransferToChest() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    startGasReport("transfer to chest");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
    assertEq(Inventory.length(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.length(chestEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testTransferToolToChest() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("transfer tool to chest");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasTool(chestEntityId, toolEntityId, 1);
    assertInventoryHasTool(aliceEntityId, toolEntityId, 0);
    assertEq(Inventory.length(chestEntityId), 1, "Wrong number of occupied inventory slots");
    assertEq(Inventory.length(aliceEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testTransferFromChest() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Dirt;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    startGasReport("transfer from chest");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);
    assertEq(Inventory.length(aliceEntityId), 1, "Inventory not set");
    assertEq(Inventory.length(chestEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testTransferToolFromChest() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId1 = TestInventoryUtils.addEntity(chestEntityId, transferObjectType);
    EntityId toolEntityId2 = TestInventoryUtils.addEntity(chestEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, 2);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](2);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });
    slotsToTransfer[1] = SlotTransfer({ slotFrom: 1, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("transfer tools from chest");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasTool(aliceEntityId, toolEntityId1, 1);
    assertInventoryHasTool(aliceEntityId, toolEntityId2, 1);
    assertInventoryHasTool(chestEntityId, toolEntityId1, 0);
    assertInventoryHasTool(chestEntityId, toolEntityId2, 0);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.length(chestEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testTransferToChestFailsIfChestFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    uint16 maxChestInventorySlots = ObjectTypes.Chest.getMaxInventorySlots();
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(
      chestEntityId, transferObjectType, transferObjectType.getStackable() * maxChestInventorySlots
    );
    assertEq(Inventory.length(chestEntityId), maxChestInventorySlots, "Inventory slots is not max");

    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Object does not fit in slot");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferFromChestFailsIfPlayerFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    uint16 maxPlayerInventorySlots = ObjectTypes.Player.getMaxInventorySlots();
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(
      aliceEntityId, transferObjectType, transferObjectType.getStackable() * maxPlayerInventorySlots
    );
    assertEq(Inventory.length(aliceEntityId), maxPlayerInventorySlots, "Inventory slots is not max");

    TestInventoryUtils.addObject(chestEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 1);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Object does not fit in slot");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfInvalidObject() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId nonChestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Dirt);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(nonChestEntityId, transferObjectType, 0);

    assertEq(transferObjectType.getMaxInventorySlots(), 0, "Max inventory slots is not 0");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Invalid slot");
    world.transfer(aliceEntityId, aliceEntityId, nonChestEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 2 });

    vm.prank(alice);
    vm.expectRevert("Not enough objects in slot");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    // Transfer grass from alice to chest
    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, 1);

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 2 });

    vm.prank(alice);
    vm.expectRevert("Not enough objects in slot");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    // Transfer grass from chest to alice
    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    transferObjectType = ObjectTypes.WoodenPick;
    TestInventoryUtils.addEntity(chestEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, 1);

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 1, slotTo: 1, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Empty slot");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    // Transfer tool from chest to alice
    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    vm.prank(alice);
    vm.expectRevert("Empty slot");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfInvalidArgs() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);

    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    slotsToTransfer[0] = SlotTransfer({ slotFrom: 1, slotTo: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfTooFar() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.expectRevert("Caller not allowed");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    PlayerStatus.setBedEntityId(aliceEntityId, randomEntityId());

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferFailsIfProgramReverts() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");
    program.setRevertOnTransfer(true);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    vm.expectRevert("Transfer not allowed by chest");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferBetweenChests() public {
    Vec3 chestCoord = vec3(0, 0, 0);

    setupAirChunk(chestCoord);

    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    EntityId otherChestEntityId = setObjectAtCoord(chestCoord + vec3(1, 0, 0), ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(otherChestEntityId, transferObjectType, 0);

    setupForceField(
      chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000 * 10 ** 14, drainRate: 1 })
    );

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    program.call(
      world, abi.encodeCall(world.transfer, (chestEntityId, chestEntityId, otherChestEntityId, slotsToTransfer, ""))
    );

    assertInventoryHasObject(chestEntityId, transferObjectType, 0);
    assertInventoryHasObject(otherChestEntityId, transferObjectType, numToTransfer);
  }

  function testTransferBetweenChestsFailIfTooFar() public {
    Vec3 chestCoord = vec3(0, 0, 0);
    Vec3 otherChestCoord = chestCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 0, 0);

    setupAirChunk(chestCoord);

    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    EntityId otherChestEntityId = setObjectAtCoord(otherChestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(otherChestEntityId, transferObjectType, 0);

    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.expectRevert("Entity is too far");
    program.call(
      world, abi.encodeCall(world.transfer, (chestEntityId, chestEntityId, otherChestEntityId, slotsToTransfer, ""))
    );
  }

  function testSwapPartiallyFilledSlots() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.Grass;
    uint16 fromAmount = 10;
    TestInventoryUtils.addObject(aliceEntityId, fromType, fromAmount);

    ObjectType toType = ObjectTypes.Dirt;
    uint16 toAmount = 5;
    TestInventoryUtils.addObject(aliceEntityId, toType, toAmount);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 0);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, toAmount, 1);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: fromAmount });

    vm.prank(alice);
    startGasReport("swap partially filled slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, toAmount, 0);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");
  }

  function testSwapEntityAndObjectSlots() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.Grass;
    uint16 fromAmount = 10;
    TestInventoryUtils.addObject(aliceEntityId, fromType, fromAmount);

    ObjectType toType = ObjectTypes.NeptuniumPick;
    TestInventoryUtils.addEntity(aliceEntityId, toType);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 0);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 1);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");

    // Transfer all grass
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: fromAmount });

    vm.prank(alice);
    startGasReport("swap entity and object slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 0);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");
  }

  function testSwapEntitySlots() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.GoldPick;
    TestInventoryUtils.addEntity(aliceEntityId, fromType);

    ObjectType toType = ObjectTypes.NeptuniumPick;
    TestInventoryUtils.addEntity(aliceEntityId, toType);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 0);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 1);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("swap entity slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 0);
    assertEq(Inventory.length(aliceEntityId), 2, "Wrong number of occupied inventory slots");
  }

  function testSelfTransferEntityToNullSlot() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.GoldPick;
    TestInventoryUtils.addEntity(aliceEntityId, fromType);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 0);
    assertEq(Inventory.length(aliceEntityId), 1, "Wrong number of occupied inventory slots");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("swap entity with null slot");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 1);
    assertEq(Inventory.length(aliceEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testTransferWithinChestInventory() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();
    Vec3 chestCoord = vec3(0, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: numToTransfer });

    vm.prank(alice);
    startGasReport("transfer within chest inventory");
    world.transfer(aliceEntityId, chestEntityId, chestEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
  }

  function testTransferWithinChestInventoryFailsIfProgramReverts() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();
    Vec3 chestCoord = vec3(0, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);

    setupForceField(
      chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000 * 10 ** 14, drainRate: 1 })
    );

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    program.setRevertOnTransfer(true);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: numToTransfer });

    vm.prank(alice);
    vm.expectRevert("Transfer not allowed by chest");
    world.transfer(aliceEntityId, chestEntityId, chestEntityId, slotsToTransfer, "");
  }

  function testTransferFailsToOtherPlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();
    (, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    vm.expectRevert("Cannot access another player's inventory");
    world.transfer(aliceEntityId, aliceEntityId, bobEntityId, slotsToTransfer, "");
  }

  function testTransferFailsFromOtherPlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();
    (, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(bobEntityId, transferObjectType, numToTransfer);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    vm.expectRevert("Cannot access another player's inventory");
    world.transfer(aliceEntityId, bobEntityId, aliceEntityId, slotsToTransfer, "");
  }

  function testTransferFailsWithinOtherPlayers() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();
    (, EntityId bobEntityId) = createTestPlayer(coord + vec3(1, 0, 0));

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(bobEntityId, transferObjectType, numToTransfer);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: numToTransfer });

    vm.prank(alice);
    vm.expectRevert("Cannot access another player's inventory");
    world.transfer(aliceEntityId, bobEntityId, bobEntityId, slotsToTransfer, "");
  }
}
