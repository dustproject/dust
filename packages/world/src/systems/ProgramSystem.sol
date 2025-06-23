// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {
  ExistingProgramMustBeDetached,
  NoProgramAttached,
  ProgramDoesNotExist,
  ProgramSystemMustBePrivate,
  TargetIsNotSmartEntity
} from "../Errors.sol";
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
import { EntityId } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3 } from "../types/Vec3.sol";

contract ProgramSystem is System {
  function updateProgram(EntityId caller, EntityId target, ProgramId newProgram, bytes calldata extraData) public {
    caller.activate();

    // Validate and prepare target
    Vec3 validatorCoord = _getValidatorCoord(caller, target);
    target = _validateTarget(target);

    // Detach existing program if any
    ProgramId existingProgram = target._getProgram();
    if (existingProgram.exists()) {
      _detachProgram(caller, target, existingProgram, validatorCoord, extraData);
    }

    // Attach new program
    _attachProgram(caller, target, newProgram, validatorCoord, extraData);
  }

  function attachProgram(EntityId caller, EntityId target, ProgramId program, bytes calldata extraData) public {
    caller.activate();

    // Validate and prepare target
    Vec3 validatorCoord = _getValidatorCoord(caller, target);
    target = _validateTarget(target);

    if (target._getProgram().exists()) revert ExistingProgramMustBeDetached(target);

    _attachProgram(caller, target, program, validatorCoord, extraData);
  }

  function detachProgram(EntityId caller, EntityId target, bytes calldata extraData) public {
    caller.activate();

    // Validate and prepare target
    Vec3 validatorCoord = _getValidatorCoord(caller, target);
    target = _validateTarget(target);

    ProgramId program = target._getProgram();
    if (!program.exists()) revert NoProgramAttached(target);

    _detachProgram(caller, target, program, validatorCoord, extraData);
  }

  function _validateTarget(EntityId target) internal view returns (EntityId) {
    ObjectType targetType = target._getObjectType();
    if (!targetType.isSmartEntity()) revert TargetIsNotSmartEntity(targetType);
    return target.baseEntityId();
  }

  function _getValidatorCoord(EntityId caller, EntityId target) internal view returns (Vec3) {
    ObjectType targetType = target._getObjectType();

    if (targetType == ObjectTypes.Fragment) {
      (, Vec3 fragmentCoord) = caller.requireAdjacentToFragment(target);
      return fragmentCoord.fromFragmentCoord();
    } else {
      (, Vec3 coord) = caller.requireConnected(target);
      return coord;
    }
  }

  function _attachProgram(
    EntityId caller,
    EntityId target,
    ProgramId program,
    Vec3 validatorCoord,
    bytes calldata extraData
  ) internal {
    (address programAddress, bool publicAccess) = Systems._get(program.toResourceId());
    if (programAddress == address(0)) revert ProgramDoesNotExist(programAddress);
    if (publicAccess) revert ProgramSystemMustBePrivate(publicAccess);

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

  function _detachProgram(
    EntityId caller,
    EntityId target,
    ProgramId program,
    Vec3 forceFieldCoord,
    bytes calldata extraData
  ) internal {
    bytes memory onDetachProgram = abi.encodeCall(
      Hooks.IDetachProgram.onDetachProgram,
      (Hooks.DetachProgramContext({ caller: caller, target: target, extraData: extraData }))
    );

    (EntityId forceField,) = ForceFieldUtils.getForceField(forceFieldCoord);
    // If forcefield doesn't have energy, allow detachment
    EnergyData memory machineData = updateMachineEnergy(forceField);
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
    EnergyData memory machineData = updateMachineEnergy(forceField);
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
