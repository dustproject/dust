// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityProgram } from "../codegen/tables/EntityProgram.sol";

import { ObjectTypes } from "../ObjectType.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";
import { Fragment, FragmentData } from "../codegen/tables/Fragment.sol";
import { Machine } from "../codegen/tables/Machine.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";
import { EntityUtils } from "../utils/EntityUtils.sol";
import { EntityPosition } from "../utils/Vec3Storage.sol";

import { MACHINE_ENERGY_DRAIN_RATE } from "../Constants.sol";
import { EntityId } from "../EntityId.sol";
import { Vec3 } from "../Vec3.sol";

library ForceFieldUtils {
  /**
   * @dev Get the forcefield and fragment entity IDs for a given coordinate
   */
  function getForceField(Vec3 coord) internal view returns (EntityId, EntityId) {
    Vec3 fragmentCoord = coord.toFragmentCoord();
    EntityId fragment = EntityUtils.getFragmentAt(fragmentCoord);
    if (!fragment._exists()) return (EntityId.wrap(0), fragment);

    FragmentData memory fragmentData = Fragment._get(fragment);
    bool isActive = _isFragmentActive(fragmentData, fragmentData.forceField);
    return isActive ? (fragmentData.forceField, fragment) : (EntityId.wrap(0), fragment);
  }

  /**
   * @dev Check if the fragment at coord belongs to a forcefield
   */
  function isFragment(EntityId forceField, Vec3 fragmentCoord) internal view returns (bool) {
    return isFragment(forceField, EntityUtils.getFragmentAt(fragmentCoord));
  }

  /**
   * @dev Check if the fragment at coord belongs to a forcefield
   */
  function isFragment(EntityId forceField, EntityId fragment) internal view returns (bool) {
    return _isFragmentActive(Fragment._get(fragment), forceField);
  }

  /**
   * @dev Check if the fragment is active and belongs to any forcefield
   */
  function isFragmentActive(EntityId fragment) internal view returns (bool) {
    FragmentData memory fragmentData = Fragment._get(fragment);
    return _isFragmentActive(fragmentData, fragmentData.forceField);
  }

  /**
   * @dev Check if the forcefield is active (exists and hasn't been destroyed)
   */
  function isForceFieldActive(EntityId forceField) internal view returns (bool) {
    return forceField._exists() && Machine._getCreatedAt(forceField) > 0;
  }

  /**
   * @dev Set up a new forcefield with its initial fragment
   */
  function setupForceField(EntityId forceField, Vec3 coord) internal {
    Machine._setCreatedAt(forceField, uint128(block.timestamp));
    addFragment(forceField, EntityUtils.getOrCreateFragmentAt(coord.toFragmentCoord()));
  }

  /**
   * @dev Add a fragment to an existing forcefield
   */
  function addFragment(EntityId forceField, EntityId fragment) internal {
    require(!fragment._getProgram().exists(), "Can't expand into a fragment with a program");

    FragmentData memory fragmentData = Fragment._get(fragment);
    require(!_isFragmentActive(fragmentData, fragmentData.forceField), "Fragment already belongs to a forcefield");

    fragmentData.forceField = forceField;
    fragmentData.forceFieldCreatedAt = Machine._getCreatedAt(forceField);

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    Energy._setDrainRate(forceField, machineData.drainRate + MACHINE_ENERGY_DRAIN_RATE + fragmentData.extraDrainRate);
    Fragment._set(fragment, fragmentData);
  }

  /**
   * @dev Remove a fragment from a forcefield
   */
  function removeFragment(EntityId forceField, EntityId fragment) internal {
    require(!fragment._getProgram().exists(), "Can't remove a fragment with a program");

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    Energy._setDrainRate(
      forceField, machineData.drainRate - MACHINE_ENERGY_DRAIN_RATE - Fragment._getExtraDrainRate(fragment)
    );
    Fragment._deleteRecord(fragment);
  }

  /**
   * @dev Check if a fragment is active in a specific forcefield
   */
  function _isFragmentActive(FragmentData memory fragmentData, EntityId forceField) private view returns (bool) {
    return forceField._exists() && fragmentData.forceField == forceField
      && fragmentData.forceFieldCreatedAt == Machine._getCreatedAt(forceField);
  }
}
