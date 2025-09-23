// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IDrandBeacon } from "../../src/utils/IDrandBeacon.sol";

contract TestDrandBeacon is IDrandBeacon {
  constructor() { }

  /// @notice Get the public key of the beacon
  function publicKey() public view returns (bytes memory) {
    return "";
  }

  /// @notice Get the public key hash of the beacon
  function publicKeyHash() public view returns (bytes32) {
    return keccak256(publicKey());
  }

  /// @notice Get the genesis timestamp of the beacon
  function genesisTimestamp() public view returns (uint256) {
    return 0;
  }

  /// @notice Get the period of the beacon
  function period() public view returns (uint256) {
    return 1;
  }

  /// @notice Verify the signature produced by a drand beacon round against
  ///     the known public key. Reverts if the signature is invalid.
  /// @param round The beacon round to verify
  /// @param signature The signature to verify
  function verifyBeaconRound(uint256 round, uint256[2] memory signature) external view {
    return;
  }
}
