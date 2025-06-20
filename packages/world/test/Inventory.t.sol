// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { console } from "forge-std/console.sol";

import { Direction } from "../src/codegen/common.sol";
import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { ObjectPhysics } from "../src/codegen/tables/ObjectPhysics.sol";

import { PlayerBed } from "../src/codegen/tables/PlayerBed.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { EntityPosition } from "../src/utils/Vec3Storage.sol";

import { CHUNK_SIZE, MAX_ENTITY_INFLUENCE_RADIUS } from "../src/Constants.sol";
import { EntityId } from "../src/types/EntityId.sol";

import { ObjectType } from "../src/types/ObjectType.sol";

import { ObjectTypes } from "../src/types/ObjectType.sol";

import { SlotAmount, SlotTransfer } from "../src/utils/InventoryUtils.sol";

import { Orientation } from "../src/types/Orientation.sol";
import { Vec3, vec3 } from "../src/types/Vec3.sol";

import { DustTest } from "./DustTest.sol";
import { TestEntityUtils, TestInventoryUtils } from "./utils/TestUtils.sol";

contract InventoryTest is DustTest {
  function testDropTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord.getNeighbor(Direction.PositiveY);
    setTerrainAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(dropCoord);

    vm.prank(alice);
    startGasReport("drop terrain");
    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: numToTransfer });
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
  }

  function testDropNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(dropCoord);

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: numToTransfer });

    vm.prank(alice);
    startGasReport("drop non-terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
  }

  function testDropToolTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setTerrainAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(dropCoord);

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("drop tool terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
    assertInventoryHasEntity(airEntityId, toolEntityId, 1);
  }

  function testDropToolNonTerrain() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.WoodenPick;
    EntityId toolEntityId = TestInventoryUtils.addEntity(aliceEntityId, transferObjectType);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);
    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(dropCoord);

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 1 });

    vm.prank(alice);
    startGasReport("drop tool non-terrain");
    world.drop(aliceEntityId, drops, dropCoord);
    endGasReport();

    assertInventoryHasEntity(aliceEntityId, toolEntityId, 0);
    assertInventoryHasEntity(airEntityId, toolEntityId, 1);
  }

  function testDropNonAirButPassable() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.FescueGrass);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 numToTransfer = 10;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, numToTransfer);
    assertInventoryHasObject(aliceEntityId, transferObjectType, numToTransfer);
    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(dropCoord);

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: numToTransfer });

    vm.prank(alice);
    world.drop(aliceEntityId, drops, dropCoord);

    assertInventoryHasObject(aliceEntityId, transferObjectType, 0);
    assertInventoryHasObject(airEntityId, transferObjectType, numToTransfer);
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

    (EntityId airEntityId,) = TestEntityUtils.getBlockAt(chestCoord);
    assertInventoryHasObject(airEntityId, transferObjectType, numToPickup);

    vm.prank(alice);
    world.pickupAll(aliceEntityId, chestCoord);

    assertInventoryHasObject(aliceEntityId, transferObjectType, numToPickup);
    assertInventoryHasObject(airEntityId, transferObjectType, 0);
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
  }

  function testPickupAllPartialWhenInventoryAlmostFull() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    uint16 stackSize = transferObjectType.getStackable();
    uint16 maxSlots = ObjectTypes.Player.getMaxInventorySlots();

    // Fill inventory except for space for 50 items
    uint16 spaceLeft = 50;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, maxSlots * stackSize - spaceLeft);

    // Try to pickup 100 items (only 50 will fit)
    uint16 numToPickup = 100;
    TestInventoryUtils.addObject(airEntityId, transferObjectType, numToPickup);

    vm.prank(alice);
    world.pickupAll(aliceEntityId, pickupCoord);

    // Check that only 50 items were picked up
    assertInventoryHasObject(aliceEntityId, transferObjectType, maxSlots * stackSize);
    assertInventoryHasObject(airEntityId, transferObjectType, numToPickup - spaceLeft);
  }

  function testPickupAllMultipleItemTypes() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);

    // Add multiple item types to the drop location
    TestInventoryUtils.addObject(airEntityId, ObjectTypes.Grass, 50);
    TestInventoryUtils.addObject(airEntityId, ObjectTypes.Stone, 30);
    TestInventoryUtils.addObject(airEntityId, ObjectTypes.Sand, 20);

    vm.prank(alice);
    world.pickupAll(aliceEntityId, pickupCoord);

    // All items should be picked up
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 50);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Stone, 30);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Sand, 20);

    // Drop location should be empty
    assertInventoryHasObject(airEntityId, ObjectTypes.Grass, 0);
    assertInventoryHasObject(airEntityId, ObjectTypes.Stone, 0);
    assertInventoryHasObject(airEntityId, ObjectTypes.Sand, 0);
  }

  function testPickupAllWithEntities() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 0);
    EntityId airEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Air);

    // Add a tool entity to the drop location
    TestInventoryUtils.addEntity(airEntityId, ObjectTypes.WoodenPick);

    vm.prank(alice);
    world.pickupAll(aliceEntityId, pickupCoord);

    // Tool should be picked up
    assertInventoryHasObject(aliceEntityId, ObjectTypes.WoodenPick, 1);

    // Drop location should be empty
    assertInventoryEmpty(airEntityId);
  }

  function testDropFailsIfDoesntHaveBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 dropCoord = playerCoord + vec3(0, 0, 1);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);

    SlotAmount[] memory drop = new SlotAmount[](1);
    drop[0] = SlotAmount({ slot: 0, amount: 1 });

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

    Vec3 pickupCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 1, 0);
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

    Vec3 dropCoord = playerCoord + vec3(int32(MAX_ENTITY_INFLUENCE_RADIUS) + 1, 1, 0);
    setObjectAtCoord(dropCoord, ObjectTypes.Air);
    ObjectType transferObjectType = ObjectTypes.Grass;
    TestInventoryUtils.addObject(aliceEntityId, transferObjectType, 1);
    assertInventoryHasObject(aliceEntityId, transferObjectType, 1);

    SlotAmount[] memory drop = new SlotAmount[](1);
    drop[0] = SlotAmount({ slot: 0, amount: 1 });

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

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Cannot drop on a non-passable block");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testPickupFailsIfNonAirBlock() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 pickupCoord = playerCoord + vec3(0, 1, 1);
    setTerrainAtCoord(pickupCoord, ObjectTypes.Air);

    EntityId chestEntityId = setObjectAtCoord(pickupCoord, ObjectTypes.Chest);
    TestInventoryUtils.addObject(chestEntityId, ObjectTypes.Grass, 1);

    SlotTransfer[] memory pickup = new SlotTransfer[](1);
    pickup[0] = SlotTransfer({ slotFrom: 0, slotTo: 0, amount: 1 });

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

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 0 });

    vm.prank(alice);
    vm.expectRevert("Amount must be greater than 0");
    world.drop(aliceEntityId, drops, dropCoord);

    drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 1, amount: 0 });

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

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 1 });

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

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

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

    EntityId bed = setObjectAtCoord(vec3(0, 0, 0), ObjectTypes.Bed, Orientation.wrap(44));
    PlayerBed.setBedEntityId(aliceEntityId, bed);

    SlotAmount[] memory drops = new SlotAmount[](1);
    drops[0] = SlotAmount({ slot: 0, amount: 1 });

    vm.prank(alice);
    vm.expectRevert("Player is sleeping");
    world.drop(aliceEntityId, drops, dropCoord);
  }

  function testInventorySlotManagement() public {
    (, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

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

    // Remove items and check slot cleanup
    for (uint256 i = 0; i < itemTypes.length; i++) {
      TestInventoryUtils.removeObject(aliceEntityId, itemTypes[i], 10);
      assertInventoryHasObject(aliceEntityId, itemTypes[i], 0);
    }
  }

  function testItemStacking() public {
    (, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Add same item type multiple times
    ObjectType itemType = ObjectTypes.Grass;
    uint16 amount1 = 5;
    uint16 amount2 = 7;

    TestInventoryUtils.addObject(aliceEntityId, itemType, amount1);
    TestInventoryUtils.addObject(aliceEntityId, itemType, amount2);

    // Check that items are stacked
    assertInventoryHasObject(aliceEntityId, itemType, amount1 + amount2);
    assertEq(TestInventoryUtils.getSlotsWithType(aliceEntityId, itemType).length, 1);

    // Remove partial stack
    uint16 removeAmount = 3;
    TestInventoryUtils.removeObject(aliceEntityId, itemType, removeAmount);
    assertEq(TestInventoryUtils.getSlotsWithType(aliceEntityId, itemType).length, 1);
  }

  function testInventoryLimits() public {
    (, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Get max slots from player inventory type
    uint16 maxSlots = ObjectTypes.Player.getMaxInventorySlots();

    // Add full stacks of same item type to fill inventory
    // Each stack of 99 will go into a new slot
    for (uint256 i = 0; i < maxSlots; i++) {
      TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Grass, 99);
      assertInventoryHasObject(aliceEntityId, ObjectTypes.Grass, 99 * uint16(i + 1));
    }

    // Try to add one more item
    vm.expectRevert("Inventory is full");
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Diamond, 1);

    // Remove a stack and verify we can add a new item
    TestInventoryUtils.removeObject(aliceEntityId, ObjectTypes.Grass, 99);
    TestInventoryUtils.addObject(aliceEntityId, ObjectTypes.Diamond, 1);
    assertInventoryHasObject(aliceEntityId, ObjectTypes.Diamond, 1);
  }

  function testTransferPartialStack() public {
    (address alice, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Add items to Alice's inventory
    ObjectType itemType = ObjectTypes.Grass;
    uint16 totalAmount = 10;
    uint16 transferAmount = 4;
    TestInventoryUtils.addObject(aliceEntityId, itemType, totalAmount);

    SlotTransfer[] memory transfers = new SlotTransfer[](1);
    transfers[0] = SlotTransfer({ slotFrom: 0, slotTo: 1, amount: transferAmount });

    vm.prank(alice);
    world.transfer(aliceEntityId, aliceEntityId, aliceEntityId, transfers, "");

    assertInventoryHasObject(aliceEntityId, itemType, totalAmount);
    assertEq(InventorySlot.get(aliceEntityId, 0).amount, totalAmount - transferAmount, "Wrong amount in source slot");
    assertEq(InventorySlot.get(aliceEntityId, 1).amount, transferAmount, "Wrong amount in destination slot");
  }

  function testInventoryStackingLimits() public {
    (, EntityId aliceEntityId,) = setupAirChunkWithPlayer();

    // Test stacking up to the limit (99 for most items)
    ObjectType stackableType = ObjectTypes.Dirt;
    uint16 maxStack = stackableType.getStackable();

    // First add max stack amount
    TestInventoryUtils.addObject(aliceEntityId, stackableType, maxStack);
    assertInventoryHasObject(aliceEntityId, stackableType, maxStack);

    // Try to add one more - should go to a new slot
    TestInventoryUtils.addObject(aliceEntityId, stackableType, 1);
    assertInventoryHasObject(aliceEntityId, stackableType, maxStack + 1);

    // Check slot distribution
    assertEq(InventorySlot.getObjectType(aliceEntityId, 0), stackableType, "First slot type mismatch");
    assertEq(InventorySlot.getAmount(aliceEntityId, 0), maxStack, "First slot amount mismatch");
    assertEq(InventorySlot.getObjectType(aliceEntityId, 1), stackableType, "Second slot type mismatch");
    assertEq(InventorySlot.getAmount(aliceEntityId, 1), 1, "Second slot amount mismatch");
  }
}
