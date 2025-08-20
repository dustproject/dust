// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { DustTest } from "./DustTest.sol";

import { EntityId, EntityTypeLib } from "../src/types/EntityId.sol";

import { PlayerName } from "../src/codegen/tables/PlayerName.sol";
import { ReversePlayerName } from "../src/codegen/tables/ReversePlayerName.sol";

contract NameTest is DustTest {
  function testSetPlayerName() public {
    address alice = vm.randomAddress();
    EntityId aliceEntityId = EntityTypeLib.encodePlayer(alice);

    address bob = vm.randomAddress();
    EntityId bobEntityId = EntityTypeLib.encodePlayer(bob);

    assertEq(PlayerName.get(alice), "");
    assertEq(ReversePlayerName.get("alice"), address(0));

    assertEq(PlayerName.get(bob), "");
    assertEq(ReversePlayerName.get("bob"), address(0));

    vm.prank(alice);
    world.setPlayerName(aliceEntityId, "alice");

    assertEq(PlayerName.get(alice), "alice");
    assertEq(ReversePlayerName.get("alice"), alice);

    vm.prank(bob);
    vm.expectRevert("Name is already in use.");
    world.setPlayerName(bobEntityId, "alice");

    vm.prank(bob);
    world.setPlayerName(bobEntityId, "bob");

    assertEq(PlayerName.get(bob), "bob");
    assertEq(ReversePlayerName.get("bob"), bob);
  }

  // TODO: switch this to a fuzz test?
  function testSetInvalidPlayerName() public {
    address alice = vm.randomAddress();
    EntityId aliceEntityId = EntityTypeLib.encodePlayer(alice);

    vm.prank(alice);
    vm.expectRevert("Name must be 1-32 characters long.");
    world.setPlayerName(aliceEntityId, "");

    vm.prank(alice);
    vm.expectRevert("Name must be 1-32 characters long.");
    world.setPlayerName(aliceEntityId, "a_player_name_that_is_definitely_too_long");

    vm.prank(alice);
    vm.expectRevert("Name has invalid characters.");
    world.setPlayerName(aliceEntityId, "%");
  }

  function testChangePlayerName() public {
    address alice = vm.randomAddress();
    EntityId aliceEntityId = EntityTypeLib.encodePlayer(alice);

    assertEq(PlayerName.get(alice), "");
    assertEq(ReversePlayerName.get("alice"), address(0));
    assertEq(ReversePlayerName.get("alice2"), address(0));

    vm.prank(alice);
    world.setPlayerName(aliceEntityId, "alice");

    assertEq(PlayerName.get(alice), "alice");
    assertEq(ReversePlayerName.get("alice"), alice);
    assertEq(ReversePlayerName.get("alice2"), address(0));

    vm.prank(alice);
    world.setPlayerName(aliceEntityId, "alice2");

    assertEq(PlayerName.get(alice), "alice2");
    assertEq(ReversePlayerName.get("alice2"), alice);
    assertEq(ReversePlayerName.get("alice"), address(0));
  }
}
