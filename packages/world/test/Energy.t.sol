// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BiomesTest } from "./BiomesTest.sol";
import { EntityId } from "../src/EntityId.sol";
import { Chip } from "../src/codegen/tables/Chip.sol";
import { ExploredChunkCount } from "../src/codegen/tables/ExploredChunkCount.sol";
import { ObjectTypeMetadata } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { WorldStatus } from "../src/codegen/tables/WorldStatus.sol";
import { Player } from "../src/codegen/tables/Player.sol";
import { Energy, EnergyData } from "../src/codegen/tables/Energy.sol";
import { InventoryCount } from "../src/codegen/tables/InventoryCount.sol";
import { InventorySlots } from "../src/codegen/tables/InventorySlots.sol";
import { ObjectType } from "../src/codegen/tables/ObjectType.sol";
import { TotalMinedOreCount } from "../src/codegen/tables/TotalMinedOreCount.sol";
import { MinedOreCount } from "../src/codegen/tables/MinedOreCount.sol";
import { TotalBurnedOreCount } from "../src/codegen/tables/TotalBurnedOreCount.sol";

import { MinedOrePosition, ExploredChunk, ExploredChunkByIndex, ForceField, LocalEnergyPool, ReversePosition, PlayerPosition, Position, OreCommitment } from "../src/utils/Vec3Storage.sol";

import { TerrainLib } from "../src/systems/libraries/TerrainLib.sol";
import { massToEnergy } from "../src/utils/EnergyUtils.sol";
import { ObjectTypes.Player, ObjectTypes.Air, WaterObjectID, DirtObjectID, SpawnTileObjectID, GrassObjectID, ForceFieldObjectID, SmartChestObjectID, TextSignObjectID } from "../src/ObjectTypeIds.sol";
import { ObjectTypeId } from "../src/ObjectTypeIds.sol";
import { Vec3, vec3 } from "../src/Vec3.sol";
import { CHUNK_SIZE, MAX_PLAYER_INFLUENCE_HALF_WIDTH, WORLD_BORDER_LOW_X, MACHINE_ENERGY_DRAIN_RATE } from "../src/Constants.sol";
import { TestUtils } from "./utils/TestUtils.sol";

contract EnergyTest is BiomesTest {
  function testPlayerLosesEnergyWhenIdle() public {
    (address alice, EntityId aliceEntityId, Vec3 playerCoord) = setupAirChunkWithPlayer();

    uint128 aliceEnergyBefore = Energy.getEnergy(aliceEntityId);
    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord);

    // pass some time
    vm.warp(block.timestamp + 2);
    world.activatePlayer(alice);

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(Energy.getEnergy(aliceEntityId), aliceEnergyBefore - energyGainedInPool, "Player did not lose energy");
  }

  function testMachineLosesEnergyWhenIdle() public {
    (, , Vec3 playerCoord) = setupAirChunkWithPlayer();

    Vec3 forceFieldCoord = playerCoord + vec3(0, 0, 1);
    EntityId forceFieldEntityId = setupForceField(
      forceFieldCoord,
      EnergyData({
        lastUpdatedTime: uint128(block.timestamp),
        energy: 10000,
        drainRate: MACHINE_ENERGY_DRAIN_RATE,
        accDepletedTime: 0
      })
    );

    uint128 forceFieldEnergyBefore = Energy.getEnergy(forceFieldEntityId);
    Vec3 shardCoord = playerCoord.toLocalEnergyPoolShardCoord();
    uint128 localEnergyPoolBefore = LocalEnergyPool.get(shardCoord);

    // pass some time
    vm.warp(block.timestamp + 2);
    world.activate(forceFieldEntityId);

    uint128 energyGainedInPool = LocalEnergyPool.get(shardCoord) - localEnergyPoolBefore;
    assertTrue(energyGainedInPool > 0, "Local energy pool did not gain energy");
    assertEq(
      Energy.getEnergy(forceFieldEntityId),
      forceFieldEnergyBefore - energyGainedInPool,
      "Machine did not lose energy"
    );
  }
}
