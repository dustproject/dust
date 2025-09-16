// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/// @title IDrandBeacon
/// @author Kevin Charm (kevin@frogworks.io)
/// @notice Contract containing immutable information about a drand beacon.
interface IDrandBeacon {
  /// @notice Get the public key of the beacon
  function publicKey() external view returns (bytes memory);

  /// @notice Get the public key hash of the beacon
  function publicKeyHash() external view returns (bytes32);

  /// @notice Get the genesis timestamp of the beacon
  function genesisTimestamp() external view returns (uint256);

  /// @notice Get the period of the beacon
  function period() external view returns (uint256);

  /// @notice Verify the signature produced by a drand beacon round against
  ///     the known public key. Should revert if the signature is invalid.
  /// @param round The beacon round to verify
  /// @param signature The signature to verify
  function verifyBeaconRound(uint256 round, uint256[2] memory signature) external;
}
