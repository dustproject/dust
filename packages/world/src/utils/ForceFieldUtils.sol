// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";
import { Machine } from "../codegen/tables/Machine.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { Fragment, FragmentData, FragmentPosition, Position } from "../utils/Vec3Storage.sol";

import { MACHINE_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { getUniqueEntity } from "../Utils.sol";
import { Vec3 } from "../Vec3.sol";

/**
 * @dev Check if a fragment is active in a specific forcefield
 */
function _isFragmentActive(FragmentData memory fragmentData, EntityId forceFieldId) view returns (bool) {
  // Short-circuit to avoid unnecessary storage reads
  if (!forceFieldId.exists() || fragmentData.forceFieldId != forceFieldId) {
    return false;
  }

  // Only perform the storage read if the previous checks pass
  return fragmentData.forceFieldCreatedAt == Machine._getCreatedAt(forceFieldId);
}

/**
 * @dev Get the forcefield and fragment entity IDs for a given coordinate
 */
function getForceField(Vec3 coord) view returns (EntityId, EntityId) {
  Vec3 fragmentCoord = coord.toFragmentCoord();
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);

  if (!_isFragmentActive(fragmentData, fragmentData.forceFieldId)) {
    return (EntityId.wrap(0), fragmentData.entityId);
  }

  return (fragmentData.forceFieldId, fragmentData.entityId);
}

/**
 * @dev Check if the fragment at coord belongs to a forcefield
 */
function isFragment(EntityId forceField, Vec3 fragmentCoord) view returns (bool) {
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);
  return _isFragmentActive(fragmentData, forceField);
}

/**
 * @dev Check if the fragment at coord is active and belongs to any forcefield
 */
function isFragmentActive(Vec3 fragmentCoord) view returns (bool) {
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);
  return _isFragmentActive(fragmentData, fragmentData.forceFieldId);
}

/**
 * @dev Check if the is active and belongs to any forcefield
 */
function isFragmentActive(EntityId fragment) view returns (bool) {
  Vec3 fragmentCoord = FragmentPosition._get(fragment);
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);
  return _isFragmentActive(fragmentData, fragmentData.forceFieldId);
}

/**
 * @dev Check if the forcefield is active (exists and hasn't been destroyed
 */
function isForceFieldActive(EntityId forceField) view returns (bool) {
  return forceField.exists() && Machine._getCreatedAt(forceField) > 0;
}

/**
 * @dev Set up a new forcefield with its initial fragment
 */
function setupForceField(EntityId forceField, Vec3 coord) {
  // Set up the forcefield first
  Machine._setCreatedAt(forceField, uint128(block.timestamp));

  Vec3 fragmentCoord = coord.toFragmentCoord();
  setupFragment(forceField, fragmentCoord);
}

/**
 * @dev Add a fragment to an existing forcefield
 */
function setupFragment(EntityId forceField, Vec3 fragmentCoord) returns (EntityId) {
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);

  // Create a new fragment entity if needed
  if (!fragmentData.entityId.exists()) {
    fragmentData.entityId = getUniqueEntity();
    FragmentPosition._set(fragmentData.entityId, fragmentCoord);
    ObjectType._set(fragmentData.entityId, ObjectTypes.Fragment);
  }

  require(!fragmentData.entityId.getProgram().exists(), "Can't expand into a fragment with a program");
  EntityProgram._deleteRecord(fragmentData.entityId);

  // Update the fragment data to associate it with the forcefield
  fragmentData.forceFieldId = forceField;
  fragmentData.forceFieldCreatedAt = Machine._getCreatedAt(forceField);

  (EnergyData memory machineData,) = updateMachineEnergy(forceField);

  // Increase drain rate per new fragment
  Energy._setDrainRate(forceField, machineData.drainRate + MACHINE_ENERGY_DRAIN_RATE + fragmentData.extraDrainRate);

  Fragment._set(fragmentCoord, fragmentData);
  return fragmentData.entityId;
}

/**
 * @dev Remove a fragment from a forcefield
 */
function removeFragment(EntityId forceField, Vec3 fragmentCoord) returns (EntityId) {
  FragmentData memory fragmentData = Fragment._get(fragmentCoord);

  require(!fragmentData.entityId.getProgram().exists(), "Can't remove a fragment with a program");
  EntityProgram._deleteRecord(fragmentData.entityId);

  (EnergyData memory machineData,) = updateMachineEnergy(forceField);
  Energy._setDrainRate(forceField, machineData.drainRate - MACHINE_ENERGY_DRAIN_RATE - fragmentData.extraDrainRate);

  // Disassociate the fragment from the forcefield
  Fragment._deleteRecord(fragmentCoord);
  return fragmentData.entityId;
}

/**
 * @dev Destroys a forcefield, without cleaning up its shards
 */
function destroyForceField(EntityId forceField) {
  EntityProgram._deleteRecord(forceField);
  Machine._deleteRecord(forceField);
}
