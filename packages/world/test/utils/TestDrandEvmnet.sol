// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BLS } from "@kevincharm/bls-bn254/contracts/BLS.sol";
import { System } from "@latticexyz/world/src/System.sol";

contract TestDrandEvmnet is System {
  /// @notice Domain separation tag
  bytes public constant DST = bytes("BLS_SIG_BN254G1_XMD:KECCAK-256_SVDW_RO_NUL_");

  /// @notice Network info for drand evmnet
  // from https://api.drand.sh/v2/beacons/evmnet/info
  bytes private constant publicKey_ = abi.encodePacked(uint256(0), uint256(0), uint256(0), uint256(0));
  uint256 private constant genesisTimestamp_ = 0;
  uint256 private constant period_ = 1;

  error InvalidSignature(uint256[4] pubKey, uint256[2] message, uint256[2] signature);

  /// @notice Get the public key of the beacon
  function publicKey() public pure returns (bytes memory) {
    return publicKey_;
  }

  /// @notice Get the public key hash of the beacon
  function publicKeyHash() public pure returns (bytes32) {
    return keccak256(publicKey());
  }

  /// @notice Get the genesis timestamp of the beacon
  function genesisTimestamp() public pure returns (uint256) {
    return genesisTimestamp_;
  }

  /// @notice Get the period of the beacon
  function period() public pure returns (uint256) {
    return period_;
  }

  /// @notice Deserialise the public key from raw bytes for ecpairing
  function _deserialisePublicKey() private pure returns (uint256[4] memory) {
    (uint256 pubKey0, uint256 pubKey1, uint256 pubKey2, uint256 pubKey3) =
      abi.decode(publicKey(), (uint256, uint256, uint256, uint256));
    return [pubKey0, pubKey1, pubKey2, pubKey3];
  }

  /// @notice Verify the signature produced by a drand beacon round against
  ///     the known public key. Reverts if the signature is invalid.
  /// @param round The beacon round to verify
  /// @param signature The signature to verify
  function verifyBeaconRound(uint256 round, uint256[2] memory signature) external view {
    return;
  }
}
