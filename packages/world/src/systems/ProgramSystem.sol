// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ERC165Checker } from "@latticexyz/world/src/ERC165Checker.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { EnergyData } from "../codegen/tables/Energy.sol";

import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { AttachProgramNotification, DetachProgramNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { SAFE_PROGRAM_GAS } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";

import { ObjectTypes } from "../ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../ProgramId.sol";
import { Vec3 } from "../Vec3.sol";

contract ProgramSystem is System {
  function attachProgram(EntityId caller, EntityId target, ProgramId program, bytes calldata extraData) public {
    caller.activate();

    ObjectType targetType = target._getObjectType();
    require(targetType.isSmartEntity(), "Can only attach programs to smart entities");

    Vec3 validatorCoord;
    if (targetType == ObjectTypes.Fragment) {
      (, Vec3 fragmentCoord) = caller.requireAdjacentToFragment(target);
      validatorCoord = fragmentCoord.fromFragmentCoord();
    } else {
      (, validatorCoord) = caller.requireConnected(target);
    }

    target = target.baseEntityId();

    require(!target._getProgram().exists(), "Existing program must be detached");

    (address programAddress, bool publicAccess) = Systems._get(program.toResourceId());
    require(programAddress != address(0), "Program does not exist");
    require(!publicAccess, "Program system must be private");

    (EntityId validator, ProgramId validatorProgram) = _getValidatorProgram(validatorCoord);

    bytes memory validateProgram = abi.encodeCall(
      Hooks.IProgramValidator.validateProgram,
      (
        Hooks.ValidateProgramContext({
          caller: caller,
          target: validator,
          programmed: target,
          program: program,
          extraData: extraData
        })
      )
    );

    // The validateProgram view function should revert if the program is not allowed
    validatorProgram.staticcallOrRevert(validateProgram);

    EntityProgram._set(target, program);

    program.callOrRevert(
      abi.encodeCall(
        Hooks.IAttachProgram.onAttachProgram,
        (Hooks.AttachProgramContext({ caller: caller, target: target, extraData: extraData }))
      )
    );

    notify(caller, AttachProgramNotification({ attachedTo: target, programSystemId: program.toResourceId() }));
  }

  function detachProgram(EntityId caller, EntityId target, bytes calldata extraData) public {
    caller.activate();

    Vec3 forceFieldCoord;
    if (target._getObjectType() == ObjectTypes.Fragment) {
      (, Vec3 fragmentCoord) = caller.requireAdjacentToFragment(target);
      forceFieldCoord = fragmentCoord.fromFragmentCoord();
    } else {
      (, forceFieldCoord) = caller.requireConnected(target);
    }

    target = target.baseEntityId();

    ProgramId program = target._getProgram();
    require(program.exists(), "No program attached");

    bytes memory onDetachProgram = abi.encodeCall(
      Hooks.IDetachProgram.onDetachProgram,
      (Hooks.DetachProgramContext({ caller: caller, target: target, extraData: extraData }))
    );

    (EntityId forceField,) = ForceFieldUtils.getForceField(forceFieldCoord);
    // If forcefield doesn't have energy, allow the program
    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    if (machineData.energy > 0) {
      program.callOrRevert(onDetachProgram);
    } else {
      program.call({ gas: SAFE_PROGRAM_GAS, hook: onDetachProgram });
    }

    EntityProgram._deleteRecord(target);

    notify(caller, DetachProgramNotification({ detachedFrom: target, programSystemId: program.toResourceId() }));
  }

  function _getValidatorProgram(Vec3 coord) internal returns (EntityId, ProgramId) {
    // Check if the forcefield (or fragment) allow the new program
    (EntityId forceField, EntityId fragment) = ForceFieldUtils.getForceField(coord);
    if (!forceField._exists()) {
      return (EntityId.wrap(0), ProgramId.wrap(0));
    }

    // If forcefield doesn't have energy, allow the program
    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    if (machineData.energy == 0) {
      return (EntityId.wrap(0), ProgramId.wrap(0));
    }

    // Try to get program from fragment first, then from force field if needed
    ProgramId program = fragment._getProgram();
    EntityId validator = fragment;

    // If fragment has no program, try the force field
    if (!program.exists()) {
      program = forceField._getProgram();
      validator = forceField;

      // If neither has a program, we're done
      if (!program.exists()) {
        return (EntityId.wrap(0), ProgramId.wrap(0));
      }
    }

    return (validator, program);
  }
}
