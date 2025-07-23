// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { FunctionSelectors } from "@latticexyz/world/src/codegen/tables/FunctionSelectors.sol";
import { ROOT_NAMESPACE } from "@latticexyz/world/src/constants.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { DebugSystem } from "../../src/systems/debug/DebugSystem.sol";

function ensureDebugSystem(IWorld world) {
  ResourceId debugSystemId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: ROOT_NAMESPACE, name: "DebugSystem" });
  DebugSystem debugSystem = new DebugSystem();
  world.registerSystem(debugSystemId, debugSystem, true);

  string[] memory worldFunctionSignatures = new string[](5);
  worldFunctionSignatures[0] = "debugAddToInventory(bytes32,uint16,uint16)";
  worldFunctionSignatures[1] = "debugAddToolToInventory(bytes32,uint16)";
  worldFunctionSignatures[2] = "debugRemoveFromInventory(bytes32,uint16,uint16)";
  worldFunctionSignatures[3] = "debugRemoveToolFromInventory(bytes32,bytes32)";
  worldFunctionSignatures[4] = "debugTeleportPlayer(address,uint96)";
  for (uint256 i = 0; i < worldFunctionSignatures.length; i++) {
    string memory worldFunctionSignature = worldFunctionSignatures[i];
    bytes4 worldFunctionSelector = bytes4(keccak256(bytes(worldFunctionSignature)));
    ResourceId existingSystemId = FunctionSelectors.getSystemId(worldFunctionSelector);
    if (ResourceId.unwrap(existingSystemId) == 0) {
      world.registerRootFunctionSelector(debugSystemId, worldFunctionSignature, worldFunctionSignature);
    }
  }
}
