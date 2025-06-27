// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DefaultProgram, IBaseWorld } from "../src/programs/DefaultProgram.sol";

import { Energy } from "@dust/world/src/codegen/tables/Energy.sol";
import { EntityObjectType } from "@dust/world/src/codegen/tables/EntityObjectType.sol";
import { Fragment, FragmentData } from "@dust/world/src/codegen/tables/Fragment.sol";
import { Machine } from "@dust/world/src/codegen/tables/Machine.sol";

import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";

import { ObjectTypes } from "@dust/world/src/types/ObjectType.sol";
import { Vec3, vec3 } from "@dust/world/src/types/Vec3.sol";

import { AccessGroupMember } from "../src/codegen/tables/AccessGroupMember.sol";
import { EntityAccessGroup } from "../src/codegen/tables/EntityAccessGroup.sol";
import { AttachProgramContext, DetachProgramContext, TransferContext } from "@dust/world/src/ProgramHooks.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ROOT_NAMESPACE_ID, WORLD_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";

contract DefaultProgramMock is DefaultProgram {
  constructor(IBaseWorld _world) DefaultProgram(_world) { }
}

contract DefaultProgramTest is MudTest {
  DefaultProgramMock defaultProgram;

  function randomEntityId() internal returns (EntityId) {
    return EntityId.wrap(bytes32(vm.randomUint()));
  }

  function blockEntityId(Vec3 coord) internal pure returns (EntityId) {
    return EntityTypeLib.encodeBlock(coord);
  }

  // Create a valid player that can perform actions
  function createTestPlayer() internal returns (address, EntityId) {
    address playerAddress = vm.randomAddress();
    EntityId playerEntityId = EntityTypeLib.encodePlayer(playerAddress);
    EntityObjectType.set(playerEntityId, ObjectTypes.Player);

    return (playerAddress, playerEntityId);
  }

  function mockForceField(Vec3 coord) internal returns (EntityId) {
    EntityId forceField = EntityTypeLib.encodeBlock(coord);
    EntityObjectType.set(forceField, ObjectTypes.ForceField);
    Machine.set({ entityId: forceField, createdAt: uint128(block.timestamp), depletedTime: 0 });
    Energy.setEnergy(forceField, 1);

    Vec3 fragmentCoord = coord.toFragmentCoord();
    EntityId fragment = EntityTypeLib.encodeFragment(fragmentCoord);
    EntityObjectType.set(fragment, ObjectTypes.Fragment);

    Fragment.set(
      fragment,
      FragmentData({ forceField: forceField, forceFieldCreatedAt: uint128(block.timestamp), extraDrainRate: 0 })
    );
    return forceField;
  }

  function setUp() public override {
    MudTest.setUp();

    address owner = NamespaceOwner.get(ROOT_NAMESPACE_ID);
    vm.prank(owner);
    IBaseWorld(worldAddress).transferOwnership(ROOT_NAMESPACE_ID, address(this));

    bytes14 namespace = "dfprograms_1";
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    owner = NamespaceOwner.get(namespaceId);
    vm.prank(owner);
    IBaseWorld(worldAddress).transferOwnership(namespaceId, address(this));

    defaultProgram = new DefaultProgramMock(IBaseWorld(worldAddress));

    ResourceId programId = WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: namespace, name: "default" });

    IBaseWorld(worldAddress).registerSystem(programId, defaultProgram, false);
  }

  function testAttachProgramWithoutForceField() public {
    (, EntityId playerEntityId) = createTestPlayer();

    EntityId entityId = randomEntityId();

    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: playerEntityId, target: entityId, extraData: "" }));

    assertEq(EntityAccessGroup.get(entityId), 0, "Entity should not have an access group");
  }

  function testAttachProgramToForceField() public {
    (, EntityId playerEntityId) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: playerEntityId, target: forceField, extraData: "" }));

    assertNotEq(EntityAccessGroup.get(forceField), 0, "ForceField should have an access group");
  }

  function testAttachProgramToEntityInForceFieldWithAccessGroup() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // First attach program to forcefield to create access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));

    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    assertNotEq(forceFieldGroupId, 0, "ForceField should have an access group");

    // Add alice to the forcefield's access group
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    // Now alice can attach program to entity within forcefield
    EntityId entityId = blockEntityId(coord + vec3(1, 0, 0));
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: entityId, extraData: "" }));

    // Bob (not a member) should fail
    EntityId entityId2 = blockEntityId(coord + vec3(0, 1, 0));
    vm.expectRevert("Only force field members can attach program");
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: bob, target: entityId2, extraData: "" }));
  }

  function testAttachProgramToEntityInForceFieldWithoutAccessGroup() public {
    (, EntityId playerEntityId) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    mockForceField(coord);
    // Forcefield has no access group (non-default forcefield)

    EntityId entityId = blockEntityId(coord + vec3(1, 0, 0));

    // Should fail because forcefield without access group is locked
    vm.expectRevert("Only force field members can attach program");
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: playerEntityId, target: entityId, extraData: "" }));
  }

  function testDetachProgramWithoutAccessGroup() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    EntityId entityId = randomEntityId();

    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: entityId, extraData: "" }));

    assertEq(EntityAccessGroup.get(entityId), 0, "Entity should not have an access group");

    // This should not revert
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: entityId, extraData: "" }));
  }

  function testDetachProgramWithAccessGroupByMember() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    EntityAccessGroup.get(forceField);

    // Create entity with its own access group
    EntityId entityId = blockEntityId(coord + vec3(1, 0, 0));
    EntityAccessGroup.set(entityId, 1);
    AccessGroupMember.set(1, bob, true);

    // Bob can detach (member of entity's access group)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: entityId, extraData: "" }));

    assertEq(EntityAccessGroup.get(entityId), 0, "Entity should not have an access group after detachment");
  }

  function testDetachProgramWithAccessGroupFailsIfNotMember() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);

    // Add alice to forcefield group but not bob
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    // Create entity with its own access group
    EntityId entityId = blockEntityId(coord + vec3(1, 0, 0));
    EntityAccessGroup.set(entityId, 1);
    AccessGroupMember.set(1, alice, true); // Only alice is member of entity's group

    // Bob cannot detach (not member of entity's group)
    vm.expectRevert("Caller not authorized to detach this program");
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: entityId, extraData: "" }));
  }

  // Test chest with its own group inside forcefield with group
  function testChestWithOwnGroupInForceFieldWithGroup() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();
    (, EntityId charlie) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    AccessGroupMember.set(forceFieldGroupId, alice, true);
    AccessGroupMember.set(forceFieldGroupId, bob, true);

    // Create chest with its own group
    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));
    EntityAccessGroup.set(chest, 2);
    AccessGroupMember.set(2, charlie, true);

    // Charlie can detach (member of chest's group)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: charlie, target: chest, extraData: "" }));

    // Reset chest group for next test
    EntityAccessGroup.set(chest, 2);

    // Alice cannot detach (member of forcefield but not chest)
    vm.expectRevert("Caller not authorized to detach this program");
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));
  }

  // Test chest without group falls back to forcefield's group
  function testChestWithoutGroupInForceFieldWithGroup() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    // Create chest without its own group
    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));

    // Alice can detach (member of forcefield's group)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));

    // Bob cannot detach (not member of forcefield's group)
    vm.expectRevert("Caller not authorized to detach this program");
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));
  }

  // Test chest in forcefield without access group is locked
  function testChestInForceFieldWithoutGroupIsLocked() public {
    (, EntityId alice) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    mockForceField(coord);
    // Forcefield has no access group

    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));

    // No one can detach from locked chest
    vm.expectRevert("Caller not authorized to detach this program");
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));
  }

  // Test chest outside forcefield is open to everyone
  function testChestOutsideForceFieldIsOpen() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    // Create chest outside any forcefield
    EntityId chest = blockEntityId(vec3(10, 10, 10));

    // Anyone can detach
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));

    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));
  }

  // Test forcefield energy depletion changes access
  function testForceFieldEnergyDepletionChangesAccess() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));

    // Alice can access while forcefield is active
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));

    // Deplete forcefield energy
    Energy.setEnergy(forceField, 0);

    // Now anyone can access (chest is no longer protected)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));
  }

  // Test forcefield without energy from the start
  function testForceFieldWithoutEnergyFromStart() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Immediately set energy to 0
    Energy.setEnergy(forceField, 0);

    // Setup forcefield with access group (even though it has no energy)
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    // Create chest with its own access group
    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));
    EntityAccessGroup.set(chest, 2);
    AccessGroupMember.set(2, alice, true);

    // Bob can access because forcefield has no energy (not protected)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));

    // Alice can also access
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));
  }

  // Test forcefield without energy and without access group
  function testForceFieldWithoutEnergyAndWithoutAccessGroup() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Immediately set energy to 0
    Energy.setEnergy(forceField, 0);
    // Forcefield has no access group

    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));

    // Anyone can access because forcefield has no energy
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));

    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));
  }

  // Test entity with program and access group inside forcefield without energy
  function testEntityWithProgramInDepletedForceField() public {
    (, EntityId alice) = createTestPlayer();
    (, EntityId bob) = createTestPlayer();
    (, EntityId charlie) = createTestPlayer();

    Vec3 coord = vec3(1, 2, 3);
    EntityId forceField = mockForceField(coord);

    // Setup forcefield with access group
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: forceField, extraData: "" }));
    uint256 forceFieldGroupId = EntityAccessGroup.get(forceField);
    AccessGroupMember.set(forceFieldGroupId, alice, true);

    // Create entity with program and its own access group
    EntityId chest = blockEntityId(coord + vec3(1, 0, 0));
    vm.prank(worldAddress);
    defaultProgram.onAttachProgram(AttachProgramContext({ caller: alice, target: chest, extraData: "" }));
    EntityAccessGroup.set(chest, 2);
    AccessGroupMember.set(2, bob, true); // Only bob is member of chest's group

    // While forcefield has energy, only bob can access (chest's group member)
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: bob, target: chest, extraData: "" }));

    // Reset chest group
    EntityAccessGroup.set(chest, 2);

    // Charlie cannot access (not in chest's group)
    vm.expectRevert("Caller not authorized to detach this program");
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: charlie, target: chest, extraData: "" }));

    // Deplete forcefield energy
    Energy.setEnergy(forceField, 0);

    // Now the chest is unprotected - anyone can access
    // Even though chest has its own access group, it's ignored because it's not in an active forcefield
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: charlie, target: chest, extraData: "" }));

    // Alice can also access now
    vm.prank(worldAddress);
    defaultProgram.onDetachProgram(DetachProgramContext({ caller: alice, target: chest, extraData: "" }));
  }
}
