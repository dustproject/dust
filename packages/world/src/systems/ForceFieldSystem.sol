// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";

import { EntityUtils } from "../utils/EntityUtils.sol";
import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { AddFragmentNotification, RemoveFragmentNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { SAFE_PROGRAM_GAS } from "../Constants.sol";
import { EntityId } from "../types/EntityId.sol";

import { ObjectType } from "../types/ObjectType.sol";
import { ObjectTypes } from "../types/ObjectType.sol";

import "../ProgramHooks.sol" as Hooks;
import { ProgramId } from "../types/ProgramId.sol";
import { Vec3, vec3 } from "../types/Vec3.sol";

contract ForceFieldSystem is System {
  /**
   * @notice Validates that the boundary fragments form a connected component using a spanning tree
   * @param boundary Array of boundary fragment coordinates
   * @param parents Array indicating the parent of each fragment in the spanning tree
   * @return True if the spanning tree is valid and connects all boundary fragments
   */
  function validateSpanningTree(Vec3[] memory boundary, uint8[] calldata boundaryIdx, uint8[] calldata parents)
    public
    pure
    returns (bool)
  {
    uint32 len = uint32(boundary.length);
    if (len == 0 || boundaryIdx.length != len || parents.length != len) return false;
    if (parents[0] != 0) return false;

    // permutation check with 32-bit bitmask (len ≤ 26)
    uint32 seen;
    for (uint8 i = 0; i < len; ++i) {
      uint8 r = boundaryIdx[i];
      if (r >= len) return false;
      uint32 bit = uint32(1) << r;
      if (seen & bit != 0) return false; // duplicate
      seen |= bit;
    }

    if (seen != (uint32(1) << len) - 1) return false; // missing index

    unchecked {
      for (uint8 i = 1; i < len; ++i) {
        uint8 p = parents[i];
        if (p >= i) return false; // order constraint

        Vec3 child = boundary[boundaryIdx[i]];
        Vec3 parent = boundary[boundaryIdx[p]];
        if (!child.inVonNeumannNeighborhood(parent)) return false;
      }
    }

    return true;
  }

  /**
   * @notice Identify all boundary fragments of a forcefield that are adjacent to a fragment
   * @param forceField The forcefield entity ID
   * @param fragmentCoord The coordinate of the fragment
   * @return An array of boundary fragment coordinates and its length (the array can be longer)
   */
  function computeBoundaryFragments(EntityId forceField, Vec3 fragmentCoord) public view returns (Vec3[] memory) {
    uint256 count = 0;

    // Iterate through the entire boundary
    Vec3[] memory boundary = new Vec3[](26);
    Vec3[26] memory neighbors = fragmentCoord.neighbors26();
    for (uint8 i = 0; i < neighbors.length; i++) {
      // Add to resulting boundary if it's a forcefield fragment
      if (ForceFieldUtils.isFragment(forceField, neighbors[i])) {
        boundary[count++] = neighbors[i];
      }
    }

    /// @solidity memory-safe-assembly
    assembly {
      // Resize the array to the actual count
      mstore(boundary, count)
    }

    return boundary;
  }

  function addFragment(
    EntityId caller,
    EntityId forceField,
    Vec3 refFragmentCoord,
    Vec3 fragmentCoord,
    bytes calldata extraData
  ) public {
    caller.activate();
    caller.requireAdjacentToFragment(fragmentCoord);

    ObjectType objectType = forceField._getObjectType();
    require(objectType == ObjectTypes.ForceField, "Invalid object type");

    require(
      refFragmentCoord.inVonNeumannNeighborhood(fragmentCoord), "Reference fragment is not adjacent to new fragment"
    );

    require(ForceFieldUtils.isFragment(forceField, refFragmentCoord), "Reference fragment is not part of forcefield");

    EntityId fragment = EntityUtils.getOrCreateFragmentAt(fragmentCoord);

    ForceFieldUtils.addFragment(forceField, fragment);

    bytes memory onAddFragment = abi.encodeCall(
      Hooks.IAddFragment.onAddFragment,
      (Hooks.AddFragmentContext({ caller: caller, target: forceField, added: fragment, extraData: extraData }))
    );

    _callForceFieldHook(forceField, onAddFragment);

    notify(caller, AddFragmentNotification({ forceField: forceField }));
  }

  /**
   * @notice Removes a fragment from a forcefield
   * @param forceField The forcefield entity ID
   * @param fragmentCoord The coordinate of the fragment
   * @param parents Indicates the parent of each boundary fragment in the spanning tree, parents must be ordered (each parent comes before its children)
   */
  function removeFragment(
    EntityId caller,
    EntityId forceField,
    Vec3 fragmentCoord,
    uint8[] calldata boundaryIdx,
    uint8[] calldata parents,
    bytes calldata extraData
  ) public {
    caller.activate();
    caller.requireAdjacentToFragment(fragmentCoord);

    ObjectType objectType = forceField._getObjectType();
    require(objectType == ObjectTypes.ForceField, "Invalid object type");

    Vec3 forceFieldFragmentCoord = forceField._getPosition().toFragmentCoord();
    require(forceFieldFragmentCoord != fragmentCoord, "Can't remove forcefield's fragment");

    EntityId fragment = EntityUtils.getFragmentAt(fragmentCoord);
    require(ForceFieldUtils.isFragment(forceField, fragment), "Fragment is not part of forcefield");

    {
      // First, identify all boundary fragments (fragments adjacent to the fragment to be removed)
      Vec3[] memory boundary = computeBoundaryFragments(forceField, fragmentCoord);

      require(boundary.length > 0, "No boundary fragments found");

      // Validate that boundaryFragments are connected
      require(validateSpanningTree(boundary, boundaryIdx, parents), "Invalid spanning tree");
    }

    ForceFieldUtils.removeFragment(forceField, fragment);

    bytes memory onRemoveFragment = abi.encodeCall(
      Hooks.IRemoveFragment.onRemoveFragment,
      (Hooks.RemoveFragmentContext({ caller: caller, target: forceField, removed: fragment, extraData: extraData }))
    );

    _callForceFieldHook(forceField, onRemoveFragment);

    notify(caller, RemoveFragmentNotification({ forceField: forceField }));
  }

  function _callForceFieldHook(EntityId forceField, bytes memory hook) private {
    ProgramId program = forceField._getProgram();
    if (!program.exists()) {
      return;
    }

    (EnergyData memory machineData,) = updateMachineEnergy(forceField);
    if (machineData.energy > 0) {
      program.callOrRevert(hook);
    } else {
      program.call({ gas: SAFE_PROGRAM_GAS, hook: hook });
    }
  }
}
