// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";
import { ProgramId } from "@dust/world/src/ProgramId.sol";
import { Vec3 } from "@dust/world/src/Vec3.sol";

import { ReversePlayer } from "@dust/world/src/codegen/tables/ReversePlayer.sol";

import {
  IAddFragmentHook,
  IAttachProgramHook,
  IBuildHook,
  IDetachProgramHook,
  IMineHook,
  IProgramValidator,
  IRemoveFragmentHook
} from "@dust/world/src/ProgramInterfaces.sol";

import { Admin } from "../codegen/tables/Admin.sol";
import { AllowedPlayers } from "../codegen/tables/AllowedPlayers.sol";
import { AllowedPrograms } from "../codegen/tables/AllowedPrograms.sol";

/**
 * @title ForceFieldProgram
 */
contract ForceFieldProgram is
  IAttachProgramHook,
  IDetachProgramHook,
  IProgramValidator,
  IAddFragmentHook,
  IRemoveFragmentHook,
  IBuildHook,
  IMineHook,
  WorldConsumer
{
  /**
   * @notice Initializes the ForceFieldProgram
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

  function validateProgram(
    EntityId caller,
    EntityId target,
    EntityId programmed,
    ProgramId program,
    bytes memory extraData
  ) external view onlyWorld {
    require(AllowedPrograms.getAllowed(target, program), "Program is not allowed");
  }

  function onAddFragment(EntityId caller, EntityId target, EntityId added, bytes memory extraData) external onlyWorld {
    require(
      _isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can add fragments to the force field"
    );
  }

  function onRemoveFragment(EntityId caller, EntityId target, EntityId removed, bytes memory extraData)
    external
    onlyWorld
  {
    require(
      _isApprovedPlayer(target, ReversePlayer.get(caller)),
      "Only approved players can remove fragments from the force field"
    );
  }

  function onBuild(EntityId caller, EntityId target, ObjectTypeId objectTypeId, Vec3 coord, bytes memory extraData)
    external
    payable
    onlyWorld
  {
    require(_isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can build in the force field");
  }

  function onMine(EntityId caller, EntityId target, ObjectTypeId objectTypeId, Vec3 coord, bytes memory extraData)
    external
    payable
    onlyWorld
  {
    require(_isApprovedPlayer(target, ReversePlayer.get(caller)), "Only approved players can mine in the force field");
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

  function setAllowedPrograms(EntityId target, ProgramId program, bool allowed) external {
    require(Admin.get(target) == _msgSender(), "Only the admin can set allowed programs");
    AllowedPrograms.set(target, program, allowed);
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
