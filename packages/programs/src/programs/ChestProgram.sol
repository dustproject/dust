// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";

import { ReversePlayer } from "@dust/world/src/codegen/tables/ReversePlayer.sol";

import { IAttachProgramHook, IDetachProgramHook, ITransferHook } from "@dust/world/src/ProgramInterfaces.sol";

import { Admin } from "../codegen/tables/Admin.sol";
import { AllowedPlayers } from "../codegen/tables/AllowedPlayers.sol";

/**
 * @title ChestProgram
 */
contract ChestProgram is IAttachProgramHook, IDetachProgramHook, ITransferHook, WorldConsumer {
  /**
   * @notice Initializes the ChestProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    address player = ReversePlayer.get(caller);
    require(player != address(0), "Caller is not a player");
    Admin.set(target, player);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    address admin = Admin.get(target);
    if (admin != address(0)) {
      require(ReversePlayer.get(caller) == admin, "Only the admin can detach the chest program");
      Admin.deleteRecord(target);
    }
  }

  function onTransfer(
    EntityId caller,
    EntityId target,
    EntityId from,
    EntityId to,
    ObjectAmount[] memory objectAmounts,
    EntityId[] memory toolEntities,
    bytes memory extraData
  ) external onlyWorld {
    require(
      _isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can transfer to/from the chest"
    );
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
