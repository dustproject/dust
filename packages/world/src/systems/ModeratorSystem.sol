// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import { Moderators } from "../codegen/tables/Moderators.sol";
import { WorldStatus } from "../codegen/tables/WorldStatus.sol";

contract ModeratorSystem is System {
  modifier onlyAdmin() {
    _requireAdmin();
    _;
  }

  modifier onlyModerator() {
    if (!Moderators._get(_msgSender())) {
      _requireAdmin();
    }

    _;
  }

  function pause() public onlyModerator {
    WorldStatus._setIsPaused(true);
  }

  function unpause() public onlyAdmin {
    WorldStatus._setIsPaused(false);
  }

  function addModerator(address moderator) public onlyAdmin {
    require(!Moderators._get(moderator), "Address is already a moderator");
    Moderators._set(moderator, true);
  }

  function removeModerator(address moderator) public onlyAdmin {
    require(Moderators._get(moderator), "Address is not a moderator");
    Moderators._set(moderator, false);
  }

  function _requireAdmin() internal view {
    AccessControl._requireOwner(ROOT_NAMESPACE_ID, _msgSender());
  }
}
