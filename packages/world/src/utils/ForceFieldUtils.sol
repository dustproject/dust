// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { Fragment, FragmentData } from "../codegen/tables/Fragment.sol";
import { Machine } from "../codegen/tables/Machine.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { FragmentPosition, Position, ReverseFragmentPosition } from "../utils/Vec3Storage.sol";

import { MACHINE_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { ObjectTypes } from "../ObjectTypes.sol";
import { getUniqueEntity } from "../Utils.sol";
import { Vec3 } from "../Vec3.sol";

library ForceFieldUtils {
  /**
   * @dev Get the forcefield and fragment entity IDs for a given coordinate
   */
  function getForceField(Vec3 coord) internal returns (EntityId, EntityId) {
    Vec3 fragmentCoord = coord.toFragmentCoord();
    EntityId fragment = getOrCreateFragmentAt(fragmentCoord);

    FragmentData memory fragmentData = Fragment._get(fragment);

    if (!_isFragmentActive(fragmentData, fragmentData.forceField)) {
      return (EntityId.wrap(0), fragment);
    }

    return (fragmentData.forceField, fragment);
  }

  function getFragmentAt(Vec3 fragmentCoord) internal view returns (EntityId) {
    return ReverseFragmentPosition._get(fragmentCoord);
  }

  function getOrCreateFragmentAt(Vec3 fragmentCoord) internal returns (EntityId) {
    EntityId fragment = getFragmentAt(fragmentCoord);

    // Create a new fragment entity if needed
    if (!fragment.exists()) {
      fragment = getUniqueEntity();
      FragmentPosition._set(fragment, fragmentCoord);
      ReverseFragmentPosition._set(fragmentCoord, fragment);
      ObjectType._set(fragment, ObjectTypes.Fragment);
    }

    return fragment;
  }

  /**
   * @dev Check if the fragment at coord belongs to a forcefield
   */
  function isFragment(EntityId forceField, Vec3 fragmentCoord) internal view returns (bool) {
    return isFragment(forceField, getFragmentAt(fragmentCoord));
  }

  /**
   * @dev Check if the fragment at coord belongs to a forcefield
   */
  function isFragment(EntityId forceField, EntityId fragment) internal view returns (bool) {
    FragmentData memory fragmentData = Fragment._get(fragment);
    return _isFragmentActive(fragmentData, forceField);
  }

  /**
   * @dev Check if the fragment is active and belongs to any forcefield
   */
  function isFragmentActive(EntityId fragment) internal view returns (bool) {
    FragmentData memory fragmentData = Fragment._get(fragment);
    return _isFragmentActive(fragmentData, fragmentData.forceField);
  }

  /**
   * @dev Check if the forcefield is active (exists and hasn't been destroyed
   */
  function isForceFieldActive(EntityId forceField) internal view returns (bool) {
    return forceField.exists() && Machine._getCreatedAt(forceField) > 0;
  }

  /**
   * @dev Set up a new forcefield with its initial fragment
   */
  function setupForceField(EntityId forceField, Vec3 coord) internal {
    // Set up the forcefield first
    Machine._setCreatedAt(forceField, uint128(block.timestamp));

    Vec3 fragmentCoord = coord.toFragmentCoord();
    EntityId fragment = getOrCreateFragmentAt(fragmentCoord);
    addFragment(forceField, fragment);
  }

  /**
   * @dev Add a fragment to an existing forcefield
   */
  function addFragment(EntityId forceField, EntityId fragment) internal {
    require(!fragment.getProgram().exists(), "Can't expand into a fragment with a program");

    FragmentData memory fragmentData = Fragment._get(fragment);
    require(!_isFragmentActive(fragmentData, fragmentData.forceField), "Fragment already belongs to a forcefield");

    // Update the fragment data to associate it with the forcefield
    fragmentData.forceField = forceField;
    fragmentData.forceFieldCreatedAt = Machine._getCreatedAt(forceField);

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);

    // Increase drain rate per new fragment
    Energy._setDrainRate(forceField, machineData.drainRate + MACHINE_ENERGY_DRAIN_RATE + fragmentData.extraDrainRate);

    Fragment._set(fragment, fragmentData);
  }

  /**
   * @dev Remove a fragment from a forcefield
   */
  function removeFragment(EntityId forceField, EntityId fragment) internal {
    require(!fragment.getProgram().exists(), "Can't remove a fragment with a program");

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);

    Energy._setDrainRate(
      forceField, machineData.drainRate - MACHINE_ENERGY_DRAIN_RATE - Fragment._getExtraDrainRate(fragment)
    );

    // Disassociate the fragment from the forcefield
    Fragment._deleteRecord(fragment);
  }

  /**
   * @dev Destroys a forcefield, without cleaning up its shards
   */
  function destroyForceField(EntityId forceField) internal {
    EntityProgram._deleteRecord(forceField);
    Machine._deleteRecord(forceField);
  }

  /**
   * @dev Check if a fragment is active in a specific forcefield
   */
  function _isFragmentActive(FragmentData memory fragmentData, EntityId forceField) private view returns (bool) {
    // Short-circuit to avoid unnecessary storage reads
    if (!forceField.exists() || fragmentData.forceField != forceField) {
      return false;
    }

    // Only perform the storage read if the previous checks pass
    return fragmentData.forceFieldCreatedAt == Machine._getCreatedAt(forceField);
  }
}
