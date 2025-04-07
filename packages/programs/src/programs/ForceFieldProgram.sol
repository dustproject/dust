// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { ObjectTypeId } from "@dust/world/src/ObjectTypeId.sol";
import { ObjectAmount } from "@dust/world/src/ObjectTypeLib.sol";
import { ProgramId } from "@dust/world/src/ProgramId.sol";
import { Vec3 } from "@dust/world/src/Vec3.sol";

import { ReversePlayer } from "@dust/world/src/codegen/tables/ReversePlayer.sol";

import {
  IAddFragmentHook,
  IBuildHook,
  IMineHook,
  IProgramValidator,
  IRemoveFragmentHook
} from "@dust/world/src/ProgramInterfaces.sol";

import { Admin } from "../codegen/tables/Admin.sol";
import { AllowedPlayers } from "../codegen/tables/AllowedPlayers.sol";
import { AllowedPrograms } from "../codegen/tables/AllowedPrograms.sol";
import { DefaultPrograms } from "../codegen/tables/DefaultPrograms.sol";

import { DefaultProgram } from "./DefaultProgram.sol";

/**
 * @title ForceFieldProgram
 */
contract ForceFieldProgram is
  DefaultProgram,
  IProgramValidator,
  IAddFragmentHook,
  IRemoveFragmentHook,
  IBuildHook,
  IMineHook
{
  /**
   * @notice Initializes the ForceFieldProgram
   * @param _world The world contract
   */
  constructor(IBaseWorld _world) DefaultProgram(_world) { }

  function validateProgram(
    EntityId caller,
    EntityId target,
    EntityId programmed,
    ProgramId program,
    bytes memory extraData
  ) external view onlyWorld {
    bytes32[] memory defaultPrograms = DefaultPrograms.get();
    for (uint256 i = 0; i < defaultPrograms.length; i++) {
      if (defaultPrograms[i] == program.unwrap()) {
        return;
      }
    }
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

  function setAllowedPrograms(EntityId target, ProgramId program, bool allowed) external {
    require(Admin.get(target) == _msgSender(), "Only the admin can set allowed programs");
    AllowedPrograms.set(target, program, allowed);
  }
}
