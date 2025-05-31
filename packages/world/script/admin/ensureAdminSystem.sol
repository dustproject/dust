// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IWorld } from "../../src/codegen/world/IWorld.sol";

import { ResourceId, WorldResourceIdInstance, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { FunctionSelectors } from "@latticexyz/world/src/codegen/tables/FunctionSelectors.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ROOT_NAMESPACE } from "@latticexyz/world/src/constants.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { AdminSystem } from "../../src/systems/admin/AdminSystem.sol";

function ensureAdminSystem(IWorld world) {
  ResourceId adminSystemId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: ROOT_NAMESPACE, name: "AdminSystem" });
  address existingAdminSystem = Systems.getSystem(adminSystemId);
  if (existingAdminSystem == address(0)) {
    AdminSystem adminSystem = new AdminSystem();
    world.registerSystem(adminSystemId, adminSystem, true);
  }
  string[] memory worldFunctionSignatures = new string[](5);
  worldFunctionSignatures[0] = "adminAddToInventory(bytes32,uint16,uint16)";
  worldFunctionSignatures[1] = "adminAddToolToInventory(bytes32,uint16)";
  worldFunctionSignatures[2] = "adminRemoveFromInventory(bytes32,uint16,uint16)";
  worldFunctionSignatures[3] = "adminRemoveToolFromInventory(bytes32,bytes32)";
  worldFunctionSignatures[4] = "adminTeleportPlayer(address,uint96)";
  for (uint256 i = 0; i < worldFunctionSignatures.length; i++) {
    string memory worldFunctionSignature = worldFunctionSignatures[i];
    bytes4 worldFunctionSelector = bytes4(keccak256(bytes(worldFunctionSignature)));
    ResourceId existingSystemId = FunctionSelectors.getSystemId(worldFunctionSelector);
    if (ResourceId.unwrap(existingSystemId) == 0) {
      world.registerRootFunctionSelector(adminSystemId, worldFunctionSignature, worldFunctionSignature);
    }
  }
}
