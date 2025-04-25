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
  // Store the last inputs received by onTransfer
  EntityId public lastCaller;
  EntityId public lastTarget;
  bytes public lastExtraData;
  SlotData[] private _lastDeposits;
  SlotData[] private _lastWithdrawals;

  // Flag to control whether the hook should revert
  bool public shouldRevert;

  function onTransfer(
    EntityId caller,
    EntityId target,
    SlotData[] memory deposits,
    SlotData[] memory withdrawals,
    bytes memory extraData
  ) external {
    require(!shouldRevert, "Transfer not allowed by chest");

    lastCaller = caller;
    lastTarget = target;
    lastExtraData = extraData;

    delete _lastDeposits;
    delete _lastWithdrawals;

    for (uint256 i = 0; i < deposits.length; i++) {
      _lastDeposits.push(deposits[i]);
    }

    for (uint256 i = 0; i < withdrawals.length; i++) {
      _lastWithdrawals.push(withdrawals[i]);
    }
  }

  function lastDeposits() external view returns (SlotData[] memory) {
    return _lastDeposits;
  }

  function lastWithdrawals() external view returns (SlotData[] memory) {
    return _lastDeposits;
  }

  function setShouldRevert(bool _shouldRevert) external {
    shouldRevert = _shouldRevert;
  }

  // Function for the chest to call the world
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
    program.setShouldRevert(true);

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

    program.setShouldRevert(true);

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

  function testChestHookTransferInputsDeposit() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Setup energy field for the chest program
    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    // Add objects to player's inventory
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);

    // Setup transfer data
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    // Custom extra data to verify it gets passed through
    bytes memory extraData = abi.encode("test data");

    // Execute transfer as player
    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, extraData);

    // Verify the hook inputs
    assertEq(program.lastCaller(), aliceEntityId, "Incorrect caller entity ID");
    assertEq(program.lastTarget(), chestEntityId, "Incorrect target entity ID");
    assertEq(program.lastExtraData(), extraData, "Extra data not passed correctly");

    // Verify deposits (from player to chest)
    SlotData[] memory deposits = program.lastDeposits();
    assertEq(deposits.length, 1, "Should have 1 deposit");
    SlotData memory deposit = deposits[0];

    assertEq(deposit.entityId, EntityId.wrap(0), "Deposit entity ID should be zero for regular objects");
    assertEq(deposit.objectType, transferObjectType, "Incorrect deposit object type");
    assertEq(deposit.amount, numToTransfer, "Incorrect deposit amount");

    // Verify no withdrawals (nothing taken from chest)
    assertEq(program.lastWithdrawals().length, 0, "Should have 0 withdrawals");
  }

  function testChestHookTransferInputsWithdrawal() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Setup energy field for the chest program
    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    // Add objects to chest's inventory
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);

    // Setup transfer data
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    // Custom extra data to verify it gets passed through
    bytes memory extraData = abi.encode("test withdrawal data");

    // Execute transfer as player
    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, extraData);

    // Verify the hook inputs
    assertEq(program.lastCaller(), aliceEntityId, "Incorrect caller entity ID");
    assertEq(program.lastTarget(), chestEntityId, "Incorrect target entity ID");
    assertEq(program.lastExtraData(), extraData, "Extra data not passed correctly");

    // Verify withdrawals (from chest to player)
    SlotData[] memory withdrawals = program.lastWithdrawals();
    assertEq(withdrawals.length, 1, "Should have 1 withdrawal");
    SlotData memory withdrawal = withdrawals[0];
    assertEq(withdrawal.entityId, EntityId.wrap(0), "Withdrawal entity ID should be zero for regular objects");
    assertEq(withdrawal.objectType, transferObjectType, "Incorrect withdrawal object type");
    assertEq(withdrawal.amount, numToTransfer, "Incorrect withdrawal amount");

    // Verify no deposits (nothing added to chest)
    assertEq(program.lastDeposits().length, 0, "Should have 0 deposits");
  }

  function testChestHookTransferInputsToolDeposit() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Setup energy field for the chest program
    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    // Add a tool to player's inventory
    ObjectType toolType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, toolType);

    // Setup transfer data
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    // Execute transfer as player
    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    // Verify deposits (tool from player to chest)
    SlotData[] memory deposits = program.lastDeposits();
    assertEq(deposits.length, 1, "Should have 1 deposit");
    SlotData memory deposit = deposits[0];

    assertEq(deposit.entityId, toolEntityId, "Incorrect deposit entity ID for tool");
    assertEq(deposit.objectType, toolType, "Incorrect deposit object type");
    assertEq(deposit.amount, 1, "Tool deposit amount should be 1");
  }

  function testChestHookTransferInputsMultipleItems() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Setup energy field for the chest program
    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    // Add multiple object types to chest
    ObjectType objectType1 = ObjectTypes.Grass;
    ObjectType objectType2 = ObjectTypes.Dirt;
    TestInventoryUtils.addObject(chestEntityId, objectType1, 5);
    TestInventoryUtils.addObject(chestEntityId, objectType2, 5);

    // Setup transfer for multiple items
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](2);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 2 });
    slotsToTransfer[1] = SlotTransfer({ slotFrom: 1, slotTo: 1, amount: 3 });

    // Execute transfer as player
    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");

    // Verify the hook inputs
    SlotData[] memory withdrawals = program.lastWithdrawals();
    assertEq(withdrawals.length, 2, "Should have 2 withdrawals");

    // Check first withdrawal
    SlotData memory withdrawal1 = withdrawals[0];
    assertEq(withdrawal1.entityId, EntityId.wrap(0), "First withdrawal entity ID should be zero");
    assertEq(withdrawal1.objectType, objectType1, "Incorrect first withdrawal object type");
    assertEq(withdrawal1.amount, 2, "Incorrect first withdrawal amount");

    // Check second withdrawal
    SlotData memory withdrawal2 = withdrawals[1];
    assertEq(withdrawal2.entityId, EntityId.wrap(0), "Second withdrawal entity ID should be zero");
    assertEq(withdrawal2.objectType, objectType2, "Incorrect second withdrawal object type");
    assertEq(withdrawal2.amount, 3, "Incorrect second withdrawal amount");
  }

  function testChestHookTransferInputsInternalTransfer() public {
    // Setup player and chest
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Setup energy field for the chest program
    setupForceField(chestCoord, EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 }));

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    // Add object to chest's inventory
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);

    // Setup internal transfer (slot 0 to slot 1)
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: numToTransfer });

    // Execute internal transfer as player
    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, chestEntityId, slotsToTransfer, "");

    // Verify the hook inputs
    assertEq(program.lastCaller(), aliceEntityId, "Incorrect caller entity ID");
    assertEq(program.lastTarget(), chestEntityId, "Incorrect target entity ID");

    // For internal transfers, there should be both a withdrawal and deposit of the same item
    SlotData[] memory withdrawals = program.lastWithdrawals();
    assertEq(withdrawals.length, 1, "Should have 1 withdrawal for internal transfer");
    SlotData[] memory deposits = program.lastDeposits();
    assertEq(deposits.length, 1, "Should have 1 deposit for internal transfer");

    // Check withdrawal
    SlotData memory withdrawal = withdrawals[0];
    assertEq(withdrawal.entityId, EntityId.wrap(0), "Withdrawal entity ID should be zero");
    assertEq(withdrawal.objectType, transferObjectType, "Incorrect withdrawal object type");
    assertEq(withdrawal.amount, numToTransfer, "Incorrect withdrawal amount");

    // Check deposit
    SlotData memory deposit = deposits[0];
    assertEq(deposit.entityId, EntityId.wrap(0), "Deposit entity ID should be zero");
    assertEq(deposit.objectType, transferObjectType, "Incorrect deposit object type");
    assertEq(deposit.amount, numToTransfer, "Incorrect deposit amount");
  }
}
