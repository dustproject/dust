// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";

import { ReversePlayer } from "@dust/world/src/codegen/tables/ReversePlayer.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { Admin } from "../codegen/tables/Admin.sol";
import { AllowedPlayers } from "../codegen/tables/AllowedPlayers.sol";

/**
 * @title DefaultProgram
 */
contract DefaultProgram is IAttachProgramHook, IDetachProgramHook, WorldConsumer {
  /**
   * @notice Initializes the DefaultProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    address player = ReversePlayer.get(caller);
    require(player != address(0), "Caller is not a player");
    Admin.set(target, player);
    address[] memory approvedPlayers = new address[](1);
    approvedPlayers[0] = player;
    AllowedPlayers.set(target, approvedPlayers);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    address admin = Admin.get(target);
    if (admin != address(0)) {
      require(ReversePlayer.get(caller) == admin, "Only the admin can detach this program");
      Admin.deleteRecord(target);
    }
    AllowedPlayers.deleteRecord(target);
  }

  function _isApprovedPlayer(EntityId target, address player) internal view returns (bool) {
    address[] memory approvedPlayers = AllowedPlayers.get(target);
    for (uint256 i = 0; i < approvedPlayers.length; i++) {
      if (approvedPlayers[i] == player) {
        return true;
      }
    }
    return false;
  }

  function setApprovedPlayers(EntityId target, address[] memory players) external {
    require(Admin.get(target) == _msgSender(), "Only the admin can set approved players");
    AllowedPlayers.set(target, players);
  }

  function setAdmin(EntityId target, address admin) external {
    require(Admin.get(target) == _msgSender(), "Only the admin can set a new admin");
    Admin.set(target, admin);
  }
}
