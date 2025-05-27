// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld, WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/EntityId.sol";
import { Vec3 } from "@dust/world/src/Vec3.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { Fragment, FragmentData } from "@dust/world/src/codegen/tables/Fragment.sol";
import { Machine } from "@dust/world/src/codegen/tables/Machine.sol";

import { IAttachProgramHook, IDetachProgramHook } from "@dust/world/src/ProgramInterfaces.sol";

import { defaultProgramSystem } from "../codegen/systems/DefaultProgramSystemLib.sol";
import { AccessGroupCount } from "../codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "../codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "../codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "../codegen/tables/EntityAccessGroup.sol";

abstract contract DefaultProgram is IAttachProgramHook, IDetachProgramHook, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) { }

  function onAttachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    (EntityId forceField,) = _getForceField(target);

    uint256 groupId;

    // If the force field is associated with an access group, use that groupId
    if (forceField.exists()) {
      groupId = EntityAccessGroup.get(forceField);
    }

    // If the force field is not associated with an access group, create a new one
    if (groupId == 0) {
      groupId = defaultProgramSystem.newAccessGroup(caller);
      AccessGroupOwner.set(groupId, caller);
      AccessGroupMember.set(groupId, caller, true);
    }

    EntityAccessGroup.set(target, groupId);
  }

  function onDetachProgram(EntityId caller, EntityId target, bytes memory) external onlyWorld {
    uint256 groupId = EntityAccessGroup.get(target);
    require(_isSafeCall(target) || AccessGroupOwner.get(groupId) == caller, "Only the owner can detach this program");

    EntityAccessGroup.deleteRecord(target);
  }

  function _isAllowed(EntityId target, EntityId caller) internal view returns (bool) {
    uint256 groupId = EntityAccessGroup.get(target);
    return AccessGroupMember.get(groupId, caller);
  }

  function _isSafeCall(EntityId target) internal view returns (bool) {
    return !_isProtected(target);
  }

  // TODO: extract to utils
  function _isProtected(EntityId target) internal view returns (bool) {
    (EntityId forceField,) = _getForceField(target);
    return forceField.exists() && Energy.getEnergy(forceField) != 0;
  }

  // TODO: extract to utils
  function _getForceField(EntityId target) internal view returns (EntityId, EntityId) {
    Vec3 fragmentCoord = target.getPosition().toFragmentCoord();
    EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
    if (!fragment.exists()) return (EntityId.wrap(0), fragment);

    FragmentData memory fragmentData = Fragment.get(fragment);

    bool isActive = fragmentData.forceField.exists()
      && fragmentData.forceFieldCreatedAt == Machine.getCreatedAt(fragmentData.forceField);

    return isActive ? (fragmentData.forceField, fragment) : (EntityId.wrap(0), fragment);
  }

  // We include a fallback function to prevent hooks not implemented
  // or new hooks added after the program is deployed, to be called
  // and not revert
  fallback() external {
    // Do nothing
  }
}
