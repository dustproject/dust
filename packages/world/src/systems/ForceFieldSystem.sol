// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Action } from "../codegen/common.sol";
import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { EntityObjectType } from "../codegen/tables/EntityObjectType.sol";

import { updateMachineEnergy } from "../utils/EnergyUtils.sol";

import { ForceFieldUtils } from "../utils/ForceFieldUtils.sol";
import { AddFragmentNotification, RemoveFragmentNotification, notify } from "../utils/NotifUtils.sol";
import { PlayerUtils } from "../utils/PlayerUtils.sol";

import { Position } from "../utils/Vec3Storage.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectType } from "../ObjectType.sol";
import { ObjectTypes } from "../ObjectType.sol";
import { IAddFragmentHook, IRemoveFragmentHook } from "../ProgramInterfaces.sol";
import { Vec3, vec3 } from "../Vec3.sol";

contract ForceFieldSystem is System {
  /**
   * @notice Validates that the boundary fragments form a connected component using a spanning tree
   * @param boundaryFragments Array of boundary fragment coordinates
   * @param len Number of boundaryFragments
   * @param parents Array indicating the parent of each fragment in the spanning tree
   * @return True if the spanning tree is valid and connects all boundary fragments
   */
  function validateSpanningTree(Vec3[26] memory boundaryFragments, uint256 len, uint256[] calldata parents)
    public
    pure
    returns (bool)
  {
    // If no boundary, it means no forcefield exists
    if (len == 0) return false;
    if (len == 1) return parents.length == 1 && parents[0] == 0;

    // Validate parents array
    if (parents.length != len || parents[0] != 0) return false;

    // Track visited nodes
    bool[] memory visited = new bool[](len);
    visited[0] = true; // Mark root as visited
    uint256 visitedCount = 1;

    // Validate each node's parent relationship
    for (uint256 i = 1; i < len; i++) {
      uint256 parent = parents[i];

      // Parent must be in valid range, already visited and adjacent
      if (
        parent >= len || !visited[parent] || !boundaryFragments[parent].inVonNeumannNeighborhood(boundaryFragments[i])
      ) {
        return false;
      }

      // Mark as visited
      visited[i] = true;
      visitedCount++;
    }

    return visitedCount == len;
  }

  /**
   * @notice Identify all boundary fragments of a forcefield that are adjacent to a fragment
   * @param forceField The forcefield entity ID
   * @param fragmentCoord The coordinate of the fragment
   * @return An array of boundary fragment coordinates and its length (the array can be longer)
   */
  function computeBoundaryFragments(EntityId forceField, Vec3 fragmentCoord)
    public
    view
    returns (Vec3[26] memory, uint256)
  {
    uint256 count = 0;

    // Iterate through the entire boundary
    Vec3[26] memory boundary;
    Vec3[26] memory neighbors = fragmentCoord.neighbors26();
    for (uint8 i = 0; i < neighbors.length; i++) {
      // Add to resulting boundary if it's a forcefield fragment
      if (ForceFieldUtils.isFragment(forceField, neighbors[i])) {
        boundary[count++] = neighbors[i];
      }
    }

    return (boundary, count);
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

    ObjectType objectType = EntityObjectType._get(forceField);
    require(objectType == ObjectTypes.ForceField, "Invalid object type");

    require(
      refFragmentCoord.inVonNeumannNeighborhood(fragmentCoord), "Reference fragment is not adjacent to new fragment"
    );

    require(ForceFieldUtils.isFragment(forceField, refFragmentCoord), "Reference fragment is not part of forcefield");

    EntityId fragment = ForceFieldUtils.getOrCreateFragmentAt(fragmentCoord);

    ForceFieldUtils.addFragment(forceField, fragment);

    bytes memory onAddFragment =
      abi.encodeCall(IAddFragmentHook.onAddFragment, (caller, forceField, fragment, extraData));

    forceField.getProgram().callOrRevert(onAddFragment);

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
    uint256[] calldata parents,
    bytes calldata extraData
  ) public {
    caller.activate();
    caller.requireAdjacentToFragment(fragmentCoord);

    ObjectType objectType = EntityObjectType._get(forceField);
    require(objectType == ObjectTypes.ForceField, "Invalid object type");

    Vec3 forceFieldFragmentCoord = Position._get(forceField).toFragmentCoord();
    require(forceFieldFragmentCoord != fragmentCoord, "Can't remove forcefield's fragment");

    EntityId fragment = ForceFieldUtils.getFragmentAt(fragmentCoord);
    require(ForceFieldUtils.isFragment(forceField, fragment), "Fragment is not part of forcefield");

    // First, identify all boundary fragments (fragments adjacent to the fragment to be removed)
    (Vec3[26] memory boundary, uint256 len) = computeBoundaryFragments(forceField, fragmentCoord);

    require(len > 0, "No boundary fragments found");

    // Validate that boundaryFragments are connected
    require(validateSpanningTree(boundary, len, parents), "Invalid spanning tree");

    ForceFieldUtils.removeFragment(forceField, fragment);

    bytes memory onRemoveFragment =
      abi.encodeCall(IRemoveFragmentHook.onRemoveFragment, (caller, forceField, fragment, extraData));

    forceField.getProgram().callOrRevert(onRemoveFragment);

    notify(caller, RemoveFragmentNotification({ forceField: forceField }));
  }
}
