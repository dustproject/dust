// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { GasReporter } from "@latticexyz/gas-report/src/GasReporter.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";

import { Vec3, vec3 } from "../src/Vec3.sol";
import { BaseEntity } from "../src/codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";

import { Inventory } from "../src/codegen/tables/Inventory.sol";

import { EntityObjectType } from "../src/codegen/tables/EntityObjectType.sol";
import { InventorySlot } from "../src/codegen/tables/InventorySlot.sol";
import { InventoryTypeSlots } from "../src/codegen/tables/InventoryTypeSlots.sol";
import { Mass } from "../src/codegen/tables/Mass.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";

import { EntityPosition, LocalEnergyPool, ReverseMovablePosition } from "../src/utils/Vec3Storage.sol";

import { EntityId } from "../src/EntityId.sol";

import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "../src/ObjectType.sol";
import { ProgramId } from "../src/ProgramId.sol";
import { TestForceFieldUtils } from "./utils/TestUtils.sol";
import { encodeChunk } from "./utils/encodeChunk.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract DustAssertions is MudTest, GasReporter {
  struct EnergyDataSnapshot {
    EntityId playerEntityId;
    uint128 playerEnergy;
    uint128 localPoolEnergy;
    uint128 forceFieldEnergy;
  }

  function getObjectAmount(EntityId owner, ObjectType objectType) internal view returns (uint16) {
    uint16[] memory slots = InventoryTypeSlots.get(owner, objectType);
    if (slots.length == 0) {
      return 0;
    }

    uint16 total;
    for (uint256 i; i < slots.length; i++) {
      total += InventorySlot.getAmount(owner, slots[i]);
    }

    return total;
  }

  function inventoryHasObjectType(EntityId ownerEntityId, ObjectType objectType) internal view returns (bool) {
    return InventoryTypeSlots.length(ownerEntityId, objectType) > 0;
  }

  function inventoryGetOreAmounts(EntityId owner) internal view returns (ObjectAmount[] memory) {
    ObjectType[7] memory ores = ObjectTypeLib.getOreTypes();

    uint256 numOres = 0;
    for (uint256 i = 0; i < ores.length; i++) {
      if (InventoryTypeSlots.length(owner, ores[i]) > 0) numOres++;
    }

    ObjectAmount[] memory oreAmounts = new ObjectAmount[](numOres);
    for (uint256 i = 0; i < ores.length; i++) {
      uint256 count = getObjectAmount(owner, ores[i]);
      if (count > 0) {
        oreAmounts[numOres - 1] = ObjectAmount(ores[i], uint16(count));
        numOres--;
      }
    }

    return oreAmounts;
  }

  function assertInventoryHasObject(EntityId owner, ObjectType objectType, uint16 amount) internal view {
    uint256 actualAmount = getObjectAmount(owner, objectType);
    assertEq(actualAmount, amount, "Inventory object amount is not correct");
  }

  function assertInventoryHasObjectInSlot(EntityId owner, ObjectType objectType, uint16 amount, uint16 slot)
    internal
    view
  {
    assertEq(InventorySlot.getObjectType(owner, slot), objectType, "Inventory object type is not correct");
    uint16 actualAmount = InventorySlot.getAmount(owner, slot);
    assertEq(actualAmount, amount, "Inventory object amount is not correct");
  }

  function assertInventoryHasEntity(EntityId owner, EntityId entityId, uint16 amount) internal view {
    uint16[] memory slots = InventoryTypeSlots.get(owner, EntityObjectType.get(entityId));
    bool found;
    if (slots.length > 0) {
      for (uint256 i; i < slots.length; i++) {
        if (entityId == InventorySlot.getEntityId(owner, slots[i])) {
          found = true;
          break;
        }
      }
    }

    assertEq(found ? 1 : 0, amount, "Inventory entity doesn't match");
  }

  function getEnergyDataSnapshot(EntityId playerEntityId) internal returns (EnergyDataSnapshot memory) {
    EnergyDataSnapshot memory snapshot;
    snapshot.playerEntityId = playerEntityId;
    snapshot.playerEnergy = Energy.getEnergy(playerEntityId);
    Vec3 snapshotCoord = EntityPosition.get(playerEntityId);
    Vec3 shardCoord = snapshotCoord.toLocalEnergyPoolShardCoord();
    snapshot.localPoolEnergy = LocalEnergyPool.get(shardCoord);
    (EntityId forceFieldEntityId,) = TestForceFieldUtils.getForceField(snapshotCoord);
    snapshot.forceFieldEnergy = forceFieldEntityId.exists() ? Energy.getEnergy(forceFieldEntityId) : 0;
    return snapshot;
  }

  function assertEnergyFlowedFromPlayerToLocalPool(EnergyDataSnapshot memory previousSnapshot)
    internal
    returns (uint128 playerEnergyLost)
  {
    EnergyDataSnapshot memory currentSnapshot = getEnergyDataSnapshot(previousSnapshot.playerEntityId);
    playerEnergyLost = previousSnapshot.playerEnergy - currentSnapshot.playerEnergy;
    assertGt(playerEnergyLost, 0, "Player energy did not decrease");
    uint128 localPoolEnergyGained = currentSnapshot.localPoolEnergy - previousSnapshot.localPoolEnergy;
    assertEq(localPoolEnergyGained, playerEnergyLost, "Local pool energy did not gain all the player's energy");
  }

  function assertPlayerIsDead(EntityId player, Vec3 playerCoord) internal view {
    // Check energy is zero
    assertEq(Energy.getEnergy(player), 0, "Player energy is not 0");

    // Verify the player entity is still registered to the address, but removed from the grid
    assertEq(EntityPosition.get(player), vec3(0, 0, 0), "Player position was not deleted");
    assertEq(ReverseMovablePosition.get(playerCoord), EntityId.wrap(0), "Player reverse position was not deleted");
    assertEq(
      ReverseMovablePosition.get(playerCoord + vec3(0, 1, 0)),
      EntityId.wrap(0),
      "Player reverse position at head was not deleted"
    );
  }

  function assertEq(Vec3 a, Vec3 b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(Vec3 a, Vec3 b) internal pure {
    assertTrue(a == b);
  }

  function assertEq(EntityId a, EntityId b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(EntityId a, EntityId b) internal pure {
    assertTrue(a == b);
  }

  function assertNotEq(EntityId a, EntityId b) internal pure {
    assertNotEq(a, b);
  }

  function assertNotEq(EntityId a, EntityId b, string memory err) internal pure {
    assertNotEq(a.unwrap(), b.unwrap(), err);
  }

  function assertEq(ProgramId a, ProgramId b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(ProgramId a, ProgramId b) internal pure {
    assertTrue(a == b);
  }

  function assertEq(ObjectType a, ObjectType b, string memory err) internal pure {
    assertTrue(a == b, err);
  }

  function assertEq(ObjectType a, ObjectType b) internal pure {
    assertTrue(a == b);
  }

  function assertNotEq(ObjectType a, ObjectType b, string memory err) internal pure {
    assertTrue(a != b, err);
  }

  function assertNotEq(ObjectType a, ObjectType b) internal pure {
    assertTrue(a != b);
  }
}
