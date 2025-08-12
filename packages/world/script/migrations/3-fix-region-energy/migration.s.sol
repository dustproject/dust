// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Vec3, vec3 } from "../../../src/types/Vec3.sol";
import { InitialEnergyPool, LocalEnergyPool } from "../../../src/utils/Vec3Storage.sol";
import { IndexerResult } from "../../utils/indexer.sol";

import { Migration } from "../Migration.sol";

contract FixRegionEnergy is Migration {
  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("3-fix-region-energy");
  }

  function runMigration() internal override {
    console.log("\nFixing Region energy (+= InitialEnergyPool)");

    // Query: All LocalEnergyPool entries
    console.log("\nCurrent Region energy:");
    IndexerResult memory regionEnergy =
      recordingQuery(string.concat("SELECT x, y, z, energy FROM LocalEnergyPool"), "(int32,int32,int32,uint128)");

    console.log("\nRunning Migration");

    for (uint256 i = 0; i < regionEnergy.rows.length; i++) {
      bytes memory row = regionEnergy.rows[i];
      (int32 x, int32 y, int32 z, uint128 energy) = abi.decode(row, (int32, int32, int32, uint128));
      Vec3 regionCoord = vec3(x, y, z);
      uint128 newEnergy = energy + InitialEnergyPool.get(regionCoord);
      console.log("Updating region %s: %s -> %s", regionCoord.toString(), energy, newEnergy);

      recordChange(
        string.concat("Update LocalEnergyPool ", regionCoord.toString(), "energy"),
        "LocalEnergyPool",
        regionCoord.toString(),
        vm.toString(energy),
        vm.toString(newEnergy)
      );

      LocalEnergyPool.set(regionCoord, newEnergy);
    }
  }
}
