// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { EntityId } from "@dust/world/src/EntityId.sol";
import { Player } from "@dust/world/src/codegen/tables/Player.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { AllowedCallers } from "../codegen/tables/AllowedCallers.sol";
import { Owner } from "../codegen/tables/Owner.sol";

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
    Owner.set(target, caller);
    bytes32[] memory callers = new bytes32[](1);
    callers[0] = caller.unwrap();
    AllowedCallers.set(target, callers);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    EntityId owner = Owner.get(target);
    if (owner.exists()) {
      require(owner == caller, "Only the owner can detach this program");
      Owner.deleteRecord(target);
    }
    AllowedCallers.deleteRecord(target);
  }

  function _isApproved(EntityId target, EntityId caller) internal view returns (bool) {
    bytes32[] memory callers = AllowedCallers.get(target);
    for (uint256 i = 0; i < callers.length; i++) {
      if (callers[i] == caller.unwrap()) {
        return true;
      }
    }
    return false;
  }

  function setApprovedCallers(EntityId target, EntityId[] memory callers) external {
    require(Owner.get(target) == Player.get(_msgSender()), "Only the owner can set approved callers");
    bytes32[] memory callersBytes = new bytes32[](callers.length);
    for (uint256 i = 0; i < callers.length; i++) {
      callersBytes[i] = callers[i].unwrap();
    }
    AllowedCallers.set(target, callersBytes);
  }

  function setOwner(EntityId target, EntityId owner) external {
    require(Owner.get(target) == Player.get(_msgSender()), "Only the owner can set a new owner");
    Owner.set(target, owner);
  }
}
