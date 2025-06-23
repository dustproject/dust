// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import { AddressAlreadyGuardian, AddressNotGuardian } from "../Errors.sol";
import { Guardians } from "../codegen/tables/Guardians.sol";
import { WorldStatus } from "../codegen/tables/WorldStatus.sol";

contract GuardianSystem is System {
  modifier onlyROOT() {
    _requireROOT();
    _;
  }

  modifier onlyGuardian() {
    if (!Guardians._get(_msgSender())) {
      _requireROOT();
    }

    _;
  }

  function pause() public onlyGuardian {
    WorldStatus._setIsPaused(true);
  }

  function unpause() public onlyROOT {
    WorldStatus._setIsPaused(false);
  }

  function addGuardian(address guardian) public onlyROOT {
    if (Guardians._get(guardian)) revert AddressAlreadyGuardian(guardian);
    Guardians._set(guardian, true);
  }

  function removeGuardian(address guardian) public onlyROOT {
    if (!Guardians._get(guardian)) revert AddressNotGuardian(guardian);
    Guardians._set(guardian, false);
  }

  function _requireROOT() internal view {
    AccessControl._requireOwner(ROOT_NAMESPACE_ID, _msgSender());
  }
}
