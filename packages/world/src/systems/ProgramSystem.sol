// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EnergyData } from "../codegen/tables/Energy.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { AttachProgramNotification, DetachProgramNotification, notify } from "../utils/NotifUtils.sol";

import { EntityId, EntityTypeLib } from "../types/EntityId.sol";
import { ObjectType } from "../types/ObjectType.sol";

import { ObjectTypes } from "../types/ObjectType.sol";

import { ProgramId } from "../types/ProgramId.sol";
import { Vec3 } from "../types/Vec3.sol";

contract ProgramSystem is System {
  function updateProgram(EntityId caller, EntityId target, ProgramId newProgram, bytes calldata extraData) public {
    caller.activate();

    // Detach existing program if any
    if (target._getProgram().exists()) {
      _detachProgram(caller, target, extraData);
    }

    // Attach new program
    _attachProgram(caller, target, newProgram, extraData);
  }

  function updateProgram(EntityId target, ProgramId newProgram, bytes calldata extraData) public {
    EntityId caller = EntityTypeLib.encodePlayer(_msgSender());
    updateProgram(caller, target, newProgram, extraData);
  }

  function attachProgram(EntityId caller, EntityId target, ProgramId program, bytes calldata extraData) public {
    caller.activate();

    _attachProgram(caller, target, program, extraData);
  }

  function detachProgram(EntityId caller, EntityId target, bytes calldata extraData) public {
    caller.activate();

    _detachProgram(caller, target, extraData);
  }

  function _validateTarget(EntityId target) internal view returns (EntityId) {
    ObjectType targetType = target._getObjectType();
    require(targetType.isSmartEntity(), "Target is not a smart entity");
    return target._baseEntityId();
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

  function _attachProgram(EntityId caller, EntityId target, ProgramId program, bytes calldata extraData) internal {
    // Validate and prepare target
    Vec3 validatorCoord = _getValidatorCoord(caller, target);
    target = _validateTarget(target);

    (address programAddress, bool publicAccess) = Systems._get(program.toResourceId());
    require(programAddress != address(0), "Program does not exist");
    require(!publicAccess, "Program system must be private");
    require(!target._getProgram().exists(), "Existing program must be detached");

    (EntityId validator, ProgramId validatorProgram) = _getValidatorProgram(validatorCoord);

    // The validateProgram view function should revert if the program is not allowed
    validatorProgram.hook({ caller: caller, target: validator, revertOnFailure: true, extraData: extraData })
      .validateProgram({ programmed: target, program: program });

    EntityProgram._set(target, program);

    program.hook({ caller: caller, target: target, revertOnFailure: true, extraData: extraData }).onAttachProgram();

    notify(caller, AttachProgramNotification({ attachedTo: target, programSystemId: program.toResourceId() }));
  }

  function _detachProgram(EntityId caller, EntityId target, bytes calldata extraData) internal {
    // Validate and prepare target
    Vec3 forceFieldCoord = _getValidatorCoord(caller, target);
    target = _validateTarget(target);

    ProgramId program = target._getProgram();
    require(program.exists(), "No program attached");

    (EntityId forceField,) = ForceFieldUtils.getForceField(forceFieldCoord);
    // If forcefield doesn't have energy, allow detachment
    EnergyData memory machineData = updateMachineEnergy(forceField);

    program.hook({ caller: caller, target: target, revertOnFailure: machineData.energy > 0, extraData: extraData })
      .onDetachProgram();

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
