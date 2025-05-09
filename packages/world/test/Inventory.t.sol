// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { Direction } from "../src/codegen/common.sol";
import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { Inventory } from "../src/codegen/tables/Inventory.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";
import { Player } from "../src/codegen/tables/Player.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { Position, ReversePosition } from "../src/utils/Vec3Storage.sol";

import { CHUNK_SIZE, MAX_ENTITY_INFLUENCE_HALF_WIDTH } from "../src/Constants.sol";
import { EntityId } from "../src/EntityId.sol";

import { ObjectType } from "../src/ObjectType.sol";

import { ObjectTypes } from "../src/ObjectType.sol";

import { SlotTransfer } from "../src/utils/InventoryUtils.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";

import { DustTest } from "./DustTest.sol";
import { TestInventoryUtils } from "./utils/TestUtils.sol";

contract InventoryTest is DustTest {
  function testDropTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord.getNeighbor(Direction.PositiveY);
    setTerrainAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    EntityId airEntityId = ReversePosition.get(dropCoord);
    assertFalse(airEntityId.exists(), "Drop entity already exists");

    vm.prank(alice);
    startGasReport("drop terrain");
    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    airEntityId = ReversePosition.get(dropCoord);
    assertTrue(airEntityId.exists(), "Drop entity does not exist");
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testDropNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    EntityId airEntityId = ReversePosition.get(dropCoord);
    assertTrue(airEntityId.exists(), "Drop entity doesn't exist");

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    startGasReport("drop non-terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testDropToolTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setTerrainAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    EntityId airEntityId = ReversePosition.get(dropCoord);
    assertFalse(airEntityId.exists(), "Drop entity already exists");

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("drop tool terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    airEntityId = ReversePosition.get(dropCoord);
    assertTrue(airEntityId.exists(), "Drop entity does not exist");
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
    assertInventoryHasEntity(airEntityId, toolEntityId, 1);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testDropToolNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    EntityId airEntityId = ReversePosition.get(dropCoord);
    assertTrue(airEntityId.exists(), "Drop entity already exists");

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("drop tool non-terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
    assertInventoryHasEntity(airEntityId, toolEntityId, 1);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testDropNonAirButPassable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.FescueGrass);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    EntityId airEntityId = ReversePosition.get(dropCoord);
    assertTrue(airEntityId.exists(), "Drop entity doesn't exist");

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToTransfer });

    vm.prank(alice);
    world.drop(aliceEntityId, drops, dropCoord);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 1, "Wrong number of occupied inventory slots");
  }

  function testPickup() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToPickup = 10;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToPickup });

    vm.prank(alice);
    startGasReport("pickup");
    world.pickup(aliceEntityId, drops, pickupCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 1, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupTool() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(airEntityId, transferObjectType);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("pickup tool");
    world.pickup(aliceEntityId, pickup, pickupCoord);
    endGasReport();

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertInventoryHasEntity(airEntityId, toolEntityId, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 1, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupMultiple() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType objectObjectType = ObjectTypes.Grass;
    uint16 numToPickup = 10;
    ObjectType toolObjectType = ObjectTypes.WoodenPick;
    TestInventoryUtils.addObject(airEntityId, objectObjectType, numToPickup);
    EntityId toolEntityId = TestInventoryUtils.addEntity(airEntityId, toolObjectType);
    assertInventoryHasEntity(airEntityId, toolEntityId, 1);
    assertInventoryHasObject(aliceEntityId, toolObjectType, 0);
    assertInventoryHasObject(airEntityId, objectObjectType, numToPickup);

    SlotTransfer[] memory pickup = new SlotTransfer[](2);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToPickup });
    pickup[1] = SlotTransfer({ slotFrom: 1, slotTo: 1, amount: 1 });

    vm.prank(alice);
    startGasReport("pickup multiple");

    world.pickup(aliceEntityId, pickup, pickupCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, objectObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, objectObjectType, 0);
    assertInventoryHasEntity(aliceEntityId, toolEntityId, 1);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupAll() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType objectObjectType = ObjectTypes.Grass;
    uint16 numToPickup = 10;
    ObjectType toolObjectType1 = ObjectTypes.WoodenPick;
    TestInventoryUtils.addObject(airEntityId, objectObjectType, numToPickup);
    EntityId toolEntityId1 = TestInventoryUtils.addEntity(airEntityId, toolObjectType1);
    ObjectType toolObjectType2 = ObjectTypes.WoodenAxe;
    EntityId toolEntityId2 = TestInventoryUtils.addEntity(airEntityId, toolObjectType2);
    assertInventoryHasEntity(airEntityId, toolEntityId1, 1);
    assertInventoryHasEntity(airEntityId, toolEntityId2, 1);
    assertInventoryHasObject(airEntityId, objectObjectType, numToPickup);

    vm.prank(alice);
    startGasReport("pickup all");
    world.pickupAll(aliceEntityId, pickupCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, objectObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, objectObjectType, 0);
    assertInventoryHasEntity(aliceEntityId, toolEntityId1, 1);
    assertInventoryHasEntity(airEntityId, toolEntityId1, 0);
    assertInventoryHasEntity(aliceEntityId, toolEntityId2, 1);
    assertInventoryHasEntity(airEntityId, toolEntityId2, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 3, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupMinedChestDrops() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 chestCoord = playerCoord + vec3(0, 0, 1);
    ObjectPhysics.setMass(ObjectTypes.Chest, playerHandMassReduction - 1);
    EntityId chestEntityId = setObjectAtCoord(chestCoord, ObjectTypes.Chest);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToPickup = 10;
    TestInventoryUtils.addObject(chestEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(chestEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    vm.prank(alice);
    world.mine(aliceEntityId, chestCoord, "");

    EntityId airEntityId = ReversePosition.get(chestCoord);
    assertEq(airEntityId.exists(), true, "Drop entity does not exist");
    assertEq(EntityObjectType.get(airEntityId), ObjectTypes.Air, "Drop entity is not air");
    assertInventoryHasObject(airEntityId, transferObjectType, numToPickup);

    vm.prank(alice);
    world.pickupAll(aliceEntityId, chestCoord);

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupFromNonAirButPassable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.FescueGrass);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToPickup = 10;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: numToPickup });

    vm.prank(alice);
    world.pickup(aliceEntityId, pickup, pickupCoord);

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, 0);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 1, "Wrong number of occupied inventory slots");
    assertEq(Inventory.lengthOccupiedSlots(airEntityId), 0, "Wrong number of occupied inventory slots");
  }

  function testPickupFailsIfInventoryFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    TestInventoryUtils.addObject(
      aliceEntityId, transferObjectType, ObjectTypes.Player.getMaxInventorySlots() * transferObjectType.getStackable()
    );
    assertEq(
      Inventory.lengthOccupiedSlots(aliceEntityId),
      ObjectTypes.Player.getMaxInventorySlots(),
      "Wrong number of occupied inventory slots"
    );

    vm.prank(alice);
    vm.expectRevert("Inventory is full");
    world.pickupAll(aliceEntityId, pickupCoord);
  }

  function testDropFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 0, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);

    SlotTransfer[] memory drop = new SlotTransfer[](1);
    drop[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Empty slot");
    world.drop(aliceEntityId, drop, dropCoord);
  }

  function testPickupFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 0, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });
    vm.prank(alice);
    vm.expectRevert("Empty slot");
    world.pickup(aliceEntityId, pickup, dropCoord);
  }

  function testPickupFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.pickup(aliceEntityId, pickup, pickupCoord);
  }

  function testDropFailsIfInvalidCoord() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_HALF_WIDTH) + 1, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotTransfer[] memory drop = new SlotTransfer[](1);
    drop[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Entity is too far");
    world.drop(aliceEntityId, drop, dropCoord);

    dropCoord = playerCoord - vec3(CHUNK_SIZE / 2 + 1, 1, 0);

    vm.prank(alice);
    vm.expectRevert("Chunk not explored yet");
    world.drop(aliceEntityId, drop, dropCoord);
  }

  function testDropFailsIfNonAirBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Dirt);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Cannot drop on a non-passable block");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testPickupFailsIfNonAirBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 1);
    setTerrainAtCoord(pickupCoord, ObjectTypes.Air);
    EntityId airEntityId = ReversePosition.get(pickupCoord);
    assertFalse(airEntityId.exists(), "Drop entity doesn't exists");

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });
    vm.prank(alice);
    vm.expectRevert("No entity at pickup location");
    world.pickup(aliceEntityId, pickup, pickupCoord);

    EntityId chestEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Chest);
    TestInventoryUtils.addObject(chestEntityId, ObjectTypes.Grass, 1);

    vm.prank(alice);
    vm.expectRevert("Cannot pickup from a non-passable block");
    world.pickup(aliceEntityId, pickup, pickupCoord);
  }

  function testPickupFailsIfInvalidArgs() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.pickup(aliceEntityId, pickup, pickupCoord);
  }

  function testDropFailsIfInvalidArgs() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    TestInventoryUtils.addEntity(aliceEntityId, ObjectTypes.WoodenPick);

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.drop(aliceEntityId, drops, dropCoord);

    drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 1, slotTo: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testPickupFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.expectRevert("Caller not allowed");
    world.pickup(aliceEntityId, pickup, pickupCoord);
  }

  function testDropFailsIfNoPlayer() public {
    (, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.expectRevert("Caller not allowed");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testPickupFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 1);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(airEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);

    PlayerBed.setBedEntityId(aliceEntityId, randomEntityId());

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.pickup(aliceEntityId, pickup, pickupCoord);
  }

  function testDropFailsIfSleeping() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    PlayerBed.setBedEntityId(aliceEntityId, randomEntityId());

    SlotTransfer[] memory drops = new SlotTransfer[](1);
    drops[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testInventorySlotManagement() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add different types of items to test slot management
    ObjectType[] memory itemTypes = new ObjectType[](3);
    itemTypes[0] = ObjectTypes.Grass;
    itemTypes[1] = ObjectTypes.Dirt;
    itemTypes[2] = ObjectTypes.Stone;

    // Add items to inventory
    for (uint256 i = 0; i < itemTypes.length; i++) {
      TestInventoryUtils.addObject(aliceEntityId, itemTypes[i], 10);
    }

    // Check that each item is in its own slot
    for (uint256 i = 0; i < itemTypes.length; i++) {
      assertInventoryHasObject(aliceEntityId, itemTypes[i], 10);
    }

    // Check total occupied slots
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), itemTypes.length, "Wrong number of occupied slots");

    // Remove items and check slot cleanup
    for (uint256 i = 0; i < itemTypes.length; i++) {
      TestInventoryUtils.removeObject(aliceEntityId, itemTypes[i], 10);
      assertInventoryHasObject(aliceEntityId, itemTypes[i], 0);
    }

    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 0, "Slots should be empty after removal");
  }

  function testItemStacking() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add same item type multiple times
    ObjectType itemType = ObjectTypes.Grass;
    uint16 amount1 = 5;
    uint16 amount2 = 7;

    TestInventoryUtils.addObject(aliceEntityId, itemType, amount1);
    TestInventoryUtils.addObject(aliceEntityId, itemType, amount2);

    // Check that items are stacked
    assertInventoryHasObject(aliceEntityId, itemType, amount1 + amount2);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 1, "Items should be in same slot");

    // Remove partial stack
    uint16 removeAmount = 3;
    TestInventoryUtils.removeObject(aliceEntityId, itemType, removeAmount);
    assertInventoryHasObject(aliceEntityId, itemType, amount1 + amount2 - removeAmount);
  }

  function testInventoryLimits() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Get max slots from player inventory type
    uint16 maxSlots = ObjectTypes.Player.getMaxInventorySlots();

    // Add full stacks of same item type to fill inventory
    // Each stack of 99 will go into a new slot
    for (uint256 i = 0; i < maxSlots; i++) {
      TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 99);
      assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 99 * uint16(i + 1));
    }

    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), maxSlots, "Should have filled all slots");

    // Try to add one more item
    vm.expectRevert("Inventory is full");
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Diamond, 1);

    // Remove a stack and verify we can add a new item
    TestInventoryUtils.removeObject(aliceEntityId, ObjectTypes.Grass, 99);
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Diamond, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Diamond, 1);
  }

  function testTransferPartialStack() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Add items to Alice's inventory
    ObjectType itemType = ObjectTypes.Grass;
    uint16 totalAmount = 10;
    uint16 transferAmount = 4;
    TestInventoryUtils.addObject(aliceEntityId, itemType, totalAmount);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: transferAmount });

    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, transfers, "");

    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Wrong number of occupied slots after transfer");
    assertInventoryHasObject(aliceEntityId, itemType, totalAmount);
    assertEq(InventorySlot.get(aliceEntityId, 0).amount, totalAmount - transferAmount, "Wrong amount in source slot");
    assertEq(InventorySlot.get(aliceEntityId, 1).amount, transferAmount, "Wrong amount in destination slot");
  }

  function testInventoryStackingLimits() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    // Test stacking up to the limit (99 for most items)
    ObjectType stackableType = ObjectTypes.Dirt;
    uint16 maxStack = stackableType.getStackable();

    // First add max stack amount
    TestInventoryUtils.addObject(aliceEntityId, stackableType, maxStack);
    assertInventoryHasObject(aliceEntityId, stackableType, maxStack);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 1, "Should only have one occupied slot");

    // Try to add one more - should go to a new slot
    TestInventoryUtils.addObject(aliceEntityId, stackableType, 1);
    assertInventoryHasObject(aliceEntityId, stackableType, maxStack + 1);
    assertEq(Inventory.lengthOccupiedSlots(aliceEntityId), 2, "Should now have two occupied slots");

    // Check slot distribution
    assertEq(InventorySlot.getObjectType(aliceEntityId, 0), stackableType, "First slot type mismatch");
    assertEq(InventorySlot.getAmount(aliceEntityId, 0), maxStack, "First slot amount mismatch");
    assertEq(InventorySlot.getObjectType(aliceEntityId, 1), stackableType, "Second slot type mismatch");
    assertEq(InventorySlot.getAmount(aliceEntityId, 1), 1, "Second slot amount mismatch");
  }
}
