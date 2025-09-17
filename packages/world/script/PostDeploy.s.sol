// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { REGISTRATION_SYSTEM_ID } from "@latticexyz/world/src/modules/init/constants.sol";
import { BEFORE_CALL_SYSTEM } from "@latticexyz/world/src/systemHookTypes.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";

import { DustScript } from "./DustScript.sol";

import { DrandBeacon as DrandBeaconTable } from "../src/codegen/tables/DrandBeacon.sol";
import { RegisterSelectorHook } from "./RegisterSelectorHook.sol";
import { initObjects } from "./initObjects.sol";
import { initRecipes } from "./initRecipes.sol";
import { initTerrain } from "./initTerrain.sol";

import { DrandBeacon } from "../src/utils/DrandBeacon.sol";

contract PostDeploy is DustScript {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Start broadcasting transactions from the deployer account
    startBroadcast();

    RegisterSelectorHook registerSelectorHook = new RegisterSelectorHook();
    IWorld(worldAddress).registerSystemHook(REGISTRATION_SYSTEM_ID, registerSelectorHook, BEFORE_CALL_SYSTEM);

    initTerrain();
    initObjects();
    initRecipes();

    uint256[4] memory publicKey_ = [
      2416910118189096557713698606232949750075245832257361418817199221841198809231,
      3565178688866727608783247307855519961161197286613423629330948765523825963906,
      18766085122067595057703228467555884757373773082319035490740181099798629248523,
      263980444642394177375858669180402387903005329333277938776544051059273779190
    ];
    uint256 genesisTimestamp_ = 1727521075;
    uint256 period_ = 3;

    DrandBeacon beacon = new DrandBeacon(publicKey_, genesisTimestamp_, period_);
    console.log("DrandBeacon deployed at:", address(beacon));
    DrandBeaconTable.setBeacon(address(beacon));

    vm.stopBroadcast();
  }
}
