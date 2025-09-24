// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BLS } from "@kevincharm/bls-bn254/contracts/BLS.sol";
import { System } from "@latticexyz/world/src/System.sol";

/// @notice System containing immutable information about a drand beacon.
// Adapted from https://github.com/frogworksio/anyrand/blob/master/contracts/beacon/DrandBeacon.sol
contract DrandEvmnetSystem is System {
  /// @notice Domain separation tag
  bytes public constant DST = bytes("BLS_SIG_BN254G1_XMD:KECCAK-256_SVDW_RO_NUL_");

  /// @notice Network info for drand evmnet
  // from https://api.drand.sh/v2/beacons/evmnet/info
  bytes private constant publicKey_ = abi.encodePacked(
    uint256(2416910118189096557713698606232949750075245832257361418817199221841198809231),
    uint256(3565178688866727608783247307855519961161197286613423629330948765523825963906),
    uint256(18766085122067595057703228467555884757373773082319035490740181099798629248523),
    uint256(263980444642394177375858669180402387903005329333277938776544051059273779190)
  );
  uint256 private constant genesisTimestamp_ = 1727521075;
  uint256 private constant period_ = 3;

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
    // Encode round for hash-to-point
    bytes memory hashedRoundBytes = new bytes(32);
    assembly {
      mstore(0x00, round)
      let hashedRound := keccak256(0x18, 0x08) // hash the last 8 bytes (uint64) of `round`
      mstore(add(0x20, hashedRoundBytes), hashedRound)
    }

    uint256[4] memory pubKey = _deserialisePublicKey();
    uint256[2] memory message = BLS.hashToPoint(DST, hashedRoundBytes);
    bool isValidSignature = BLS.isValidSignature(signature);
    if (!isValidSignature) {
      revert InvalidSignature(pubKey, message, signature);
    }

    (bool pairingSuccess, bool callSuccess) = BLS.verifySingle(signature, pubKey, message);
    // From EIP-197: If the length of the input is incorrect or any of the
    // inputs are not elements of the respective group or are not encoded
    // correctly, the call fails.
    // Ergo, this must never revert. Otherwise we have a bug.
    assert(callSuccess);
    if (!pairingSuccess) {
      revert InvalidSignature(pubKey, message, signature);
    }
  }
}
