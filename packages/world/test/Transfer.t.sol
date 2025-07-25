// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { EntityId } from "../src/types/EntityId.sol";

import { EnergyData } from "../src/codegen/tables/Energy.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { DustTest } from "./DustTest.sol";

import { MAX_ENTITY_INFLUENCE_RADIUS } from "../src/Constants.sol";
import { ObjectType } from "../src/types/ObjectType.sol";

import { ObjectTypes } from "../src/types/ObjectType.sol";

import { Orientation } from "../src/types/Orientation.sol";
import { ProgramId } from "../src/types/ProgramId.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { HookContext, ITransfer } from "../src/ProgramHooks.sol";
import { SlotAmount, SlotData, SlotTransfer } from "../src/utils/InventoryUtils.sol";
import { EntityPosition } from "../src/utils/Vec3Storage.sol";

import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract TestChestProgram is System, ITransfer {
  // Store the last inputs received by onTransfer
  EntityId public lastCaller;
  EntityId public lastTarget;
  bytes public lastExtraData;
  SlotData[] private _lastDeposits;
  SlotData[] private _lastWithdrawals;

  // Flag to control whether the hook should revert
  bool public shouldRevert;

  function onTransfer(HookContext calldata ctx, TransferData calldata transfer) external {
    require(!shouldRevert, "Transfer not allowed by chest");

    lastCaller = ctx.caller;
    lastTarget = ctx.target;
    lastExtraData = ctx.extraData;

    delete _lastDeposits;
    delete _lastWithdrawals;

    for (uint256 i = 0; i < transfer.deposits.length; i++) {
      _lastDeposits.push(transfer.deposits[i]);
    }

    for (uint256 i = 0; i < transfer.withdrawals.length; i++) {
      _lastWithdrawals.push(transfer.withdrawals[i]);
    }
  }

  function lastDeposits() external view returns (SlotData[] memory) {
    return _lastDeposits;
  }

  function lastWithdrawals() external view returns (SlotData[] memory) {
    return _lastWithdrawals;
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

    Vec3 coord = EntityPosition.get(entityId);

    // Attach program with test player
    (address bob, EntityId bobEntityId) = createTestPlayer(coord + vec3(0, 0, 2));
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

    assertInventoryHasEntity(chestEntityId, toolEntityId, 1);
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
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

    assertInventoryHasEntity(aliceEntityId, toolEntityId1, 1);
    assertInventoryHasEntity(aliceEntityId, toolEntityId2, 1);
    assertInventoryHasEntity(chestEntityId, toolEntityId1, 0);
    assertInventoryHasEntity(chestEntityId, toolEntityId2, 0);
  }

  function testSwapToChestWorksIfChestFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    uint16 maxChestInventorySlots = ObjectTypes.Chest.getMaxInventorySlots();
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(
      chestEntityId, transferObjectType, transferObjectType.getStackable() * maxChestInventorySlots
    );

    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId, slotsToTransfer, "");

    assertInventoryHasObject(aliceEntityId, transferObjectType, transferObjectType.getStackable());
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
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 2);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 2);

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

    // Add two object so it is not a swap
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, 2);
    assertInventoryHasObject(chestEntityId, transferObjectType, 2);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Object does not fit in slot");
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
  }

  function testSwapFromChestWorksIfPlayerFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    uint16 maxPlayerInventorySlots = ObjectTypes.Player.getMaxInventorySlots();
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(
      aliceEntityId, transferObjectType, transferObjectType.getStackable() * maxPlayerInventorySlots
    );

    TestInventoryUtils.addObject(chestEntityId, transferObjectType, 1);
    assertInventoryHasObject(chestEntityId, transferObjectType, 1);

    // This will swap the chest's object with the player's objects
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    world.transfer(aliceEntityId, chestEntityId, aliceEntityId, slotsToTransfer, "");
    assertInventoryHasObject(chestEntityId, transferObjectType, transferObjectType.getStackable());
    assertInventoryHasObject(
      aliceEntityId, transferObjectType, transferObjectType.getStackable() * (maxPlayerInventorySlots - 1) + 1
    );
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

    Vec3 chestCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, 1);
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

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

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

    setupForceField(
      chestCoord + vec3(0, 0, 3), EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

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
      chestCoord + vec3(3, 0, 0),
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000 * 10 ** 14, drainRate: 1 })
    );

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    // Use the program to transfer between chests
    vm.prank(address(program));
    world.transfer(chestEntityId, chestEntityId, otherChestEntityId, slotsToTransfer, "");

    assertInventoryHasObject(chestEntityId, transferObjectType, 0);
    assertInventoryHasObject(otherChestEntityId, transferObjectType, numToTransfer);
  }

  function testTransferBetweenChestsFailIfTooFar() public {
    Vec3 chestCoord = vec3(0, 0, 0);
    Vec3 otherChestCoord = chestCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 0, 0);

    setupAirChunk(chestCoord);

    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    EntityId otherChestEntityId = setObjectAtCoord(otherChestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(otherChestEntityId, transferObjectType, 0);

    setupForceField(
      chestCoord + vec3(0, 0, 3), EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000, drainRate: 1 })
    );

    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    // Use the program to transfer between chests
    vm.prank(address(program));
    vm.expectRevert("Entity is too far");
    world.transfer(chestEntityId, chestEntityId, otherChestEntityId, slotsToTransfer, "");
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

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: fromAmount });

    vm.prank(alice);
    startGasReport("swap partially filled slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, toAmount, 0);
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

    // Transfer all grass
    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: fromAmount });

    vm.prank(alice);
    startGasReport("swap entity and object slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, fromAmount, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 0);
  }

  function testSwapEntitySlots() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.GoldPick;
    TestInventoryUtils.addEntity(aliceEntityId, fromType);

    ObjectType toType = ObjectTypes.NeptuniumPick;
    TestInventoryUtils.addEntity(aliceEntityId, toType);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 0);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 1);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("swap entity slots");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 1);
    assertInventoryHasObjectInSlot(aliceEntityId, toType, 1, 0);
  }

  function testSelfTransferEntityToNullSlot() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType fromType = ObjectTypes.GoldPick;
    TestInventoryUtils.addEntity(aliceEntityId, fromType);

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 0);

    SlotTransfer[] memory slotsToTransfer = new SlotTransfer[](1);
    slotsToTransfer[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("swap entity with null slot");
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, slotsToTransfer, "");
    endGasReport();

    assertInventoryHasObjectInSlot(aliceEntityId, fromType, 1, 1);
  }

  function testTransferWithinChestInventory() public {
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = coord + vec3(1, 0, 0);
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
    (address alice, EntityId aliceEntityId, Vec3 coord) = setupAirChunkWithPlayer();
    Vec3 chestCoord = coord + vec3(1, 0, 0);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);

    setupForceField(
      chestCoord + vec3(0, 0, 3),
      EnergyData({ lastUpdatedTime: uint128(block.timestamp), energy: 1000 * 10 ** 14, drainRate: 1 })
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

  // Tests for SlotAmount transfer function
  function testTransferSlotAmountBasic() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: numToTransfer });

    vm.prank(alice);
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToTransfer);
  }

  function testTransferSlotAmountMultipleItems() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType objectType1 = ObjectTypes.Grass;
    ObjectType objectType2 = ObjectTypes.Stone;
    uint16 amount1 = 10;
    uint16 amount2 = 20;

    TestInventoryUtils.addObject(aliceEntityId, objectType1, amount1);
    TestInventoryUtils.addObject(aliceEntityId, objectType2, amount2);

    assertInventoryHasObject(aliceEntityId, objectType1, amount1);
    assertInventoryHasObject(aliceEntityId, objectType2, amount2);

    SlotAmount[] memory amounts = new SlotAmount[](2);
    amounts[0] = SlotAmount({ slot: 0, amount: amount1 });
    amounts[1] = SlotAmount({ slot: 1, amount: amount2 });

    vm.prank(alice);
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    assertInventoryHasObject(aliceEntityId, objectType1, 0);
    assertInventoryHasObject(aliceEntityId, objectType2, 0);
    assertInventoryHasObject(chestEntityId, objectType1, amount1);
    assertInventoryHasObject(chestEntityId, objectType2, amount2);
  }

  function testTransferSlotAmountPartialTransfer() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 totalAmount = 20;
    uint16 transferAmount = 15;

    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, totalAmount);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: transferAmount });

    vm.prank(alice);
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    assertInventoryHasObject(aliceEntityId, transferObjectType, totalAmount - transferAmount);
    assertInventoryHasObject(chestEntityId, transferObjectType, transferAmount);
  }

  function testTransferSlotAmountWithEntities() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertInventoryHasEntity(chestEntityId, toolEntityId, 0);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: 1 });

    vm.prank(alice);
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
    assertInventoryHasEntity(chestEntityId, toolEntityId, 1);
  }

  function testTransferSlotAmountFailsSelfTransfer() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 10);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: 10 });

    vm.prank(alice);
    vm.expectRevert("Cannot transfer amounts to self");
    world.transferAmounts(aliceEntityId, aliceEntityId, aliceEntityId, amounts, "");
  }

  function testTransferSlotAmountFailsIfCallerNotInvolved() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    (, EntityId bobEntityId,) = spawnPlayerOnAirChunk(playerCoord + vec3(5, 0, 0));

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(bobEntityId, transferObjectType, 10);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: 10 });

    // Alice tries to transfer from Bob to chest
    vm.prank(alice);
    vm.expectRevert("Caller is not involved in transfer");
    world.transferAmounts(aliceEntityId, bobEntityId, chestEntityId, amounts, "");
  }

  function testTransferSlotAmountHookValidation() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 transferAmount = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, transferAmount);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: transferAmount });

    // Test that hook can block transfer
    program.setShouldRevert(true);
    vm.prank(alice);
    vm.expectRevert("Transfer not allowed by chest");
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    // Test successful transfer with hook
    program.setShouldRevert(false);
    vm.prank(alice);
    world.transferAmounts(aliceEntityId, aliceEntityId, chestEntityId, amounts, "");

    // Verify hook received correct data from target's perspective
    assertEq(program.lastCaller(), aliceEntityId, "Incorrect caller");
    assertEq(program.lastTarget(), chestEntityId, "Incorrect target");

    // From chest's perspective, it received deposits
    SlotData[] memory deposits = program.lastDeposits();
    assertEq(deposits.length, 1, "Should have 1 deposit");
    assertEq(deposits[0].objectType, transferObjectType, "Incorrect deposit type");
    assertEq(deposits[0].amount, transferAmount, "Incorrect deposit amount");

    SlotData[] memory withdrawals = program.lastWithdrawals();
    assertEq(withdrawals.length, 0, "Should have no withdrawals");
  }

  function testTransferSlotAmountReverseDirection() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);

    // Attach program to chest
    TestChestProgram program = new TestChestProgram();
    attachTestProgram(chestEntityId, program, "namespace");

    ObjectType transferObjectType = ObjectTypes.Stone;
    uint16 transferAmount = 15;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, transferAmount);

    SlotAmount[] memory amounts = new SlotAmount[](1);
    amounts[0] = SlotAmount({ slot: 0, amount: transferAmount });

    // Transfer from chest to player
    vm.prank(alice);
    world.transferAmounts(aliceEntityId, chestEntityId, aliceEntityId, amounts, "");

    assertInventoryHasObject(aliceEntityId, transferObjectType, transferAmount);
    assertInventoryHasObject(chestEntityId, transferObjectType, 0);

    // Verify hook received correct data from target's perspective
    assertEq(program.lastCaller(), aliceEntityId, "Incorrect caller");
    assertEq(program.lastTarget(), chestEntityId, "Incorrect target");

    // From chest's perspective, it had withdrawals
    SlotData[] memory withdrawals = program.lastWithdrawals();
    assertEq(withdrawals.length, 1, "Should have 1 withdrawal");
    assertEq(withdrawals[0].objectType, transferObjectType, "Incorrect withdrawal type");
    assertEq(withdrawals[0].amount, transferAmount, "Incorrect withdrawal amount");

    SlotData[] memory deposits = program.lastDeposits();
    assertEq(deposits.length, 0, "Should have no deposits");
  }

  function testTransferSlotAmountGasComparison() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();
    (address bob, EntityId bobEntityId,) = spawnPlayerOnAirChunk(playerCoord + vec3(5, 0, 0));

    Vec3 chestCoord1 = playerCoord + vec3(0, 0, 1);
    Vec3 chestCoord2 = playerCoord + vec3(0, 0, 2);
    EntityId chestEntityId1 = setObjectAtCoord(chestCoord1, ObjectTypes.Chest);
    EntityId chestEntityId2 = setObjectAtCoord(chestCoord2, ObjectTypes.Chest);

    // Setup identical inventories for both players
    ObjectType objectType1 = ObjectTypes.Grass;
    ObjectType objectType2 = ObjectTypes.Stone;
    TestInventoryUtils.addObject(aliceEntityId, objectType1, 10);
    TestInventoryUtils.addObject(aliceEntityId, objectType2, 20);
    TestInventoryUtils.addObject(bobEntityId, objectType1, 10);
    TestInventoryUtils.addObject(bobEntityId, objectType2, 20);

    // Transfer with SlotTransfer (specifying destination slots)
    SlotTransfer[] memory transfers = new SlotTransfer[](2);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 5, amount: 10 });
    transfers[1] = SlotTransfer({ slotFrom: 1, slotTo: 6, amount: 20 });

    vm.prank(alice);
    startGasReport("transfer with SlotTransfer");
    world.transfer(aliceEntityId, aliceEntityId, chestEntityId1, transfers, "");
    endGasReport();

    // Transfer with SlotAmount (automatic destination slots)
    SlotAmount[] memory amounts = new SlotAmount[](2);
    amounts[0] = SlotAmount({ slot: 0, amount: 10 });
    amounts[1] = SlotAmount({ slot: 1, amount: 20 });

    vm.prank(bob);
    startGasReport("transferAmounts with SlotAmount");
    world.transferAmounts(bobEntityId, bobEntityId, chestEntityId2, amounts, "");
    endGasReport();

    // Verify both transfers had same effect
    assertInventoryHasObject(chestEntityId1, objectType1, 10);
    assertInventoryHasObject(chestEntityId1, objectType2, 20);
    assertInventoryHasObject(chestEntityId2, objectType1, 10);
    assertInventoryHasObject(chestEntityId2, objectType2, 20);
  }
}
