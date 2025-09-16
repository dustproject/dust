// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IDrandBeacon } from "./IDrandBeacon.sol";
import { BLS } from "@kevincharm/bls-bn254/contracts/BLS.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

/// @title DrandBeacon
/// @author Kevin Charm <kevin@frogworks.io>
/// @notice Contract containing immutable information about a drand beacon.
contract DrandBeacon is IDrandBeacon {
  /// @notice Domain separation tag
  bytes public constant DST = bytes("BLS_SIG_BN254G1_XMD:KECCAK-256_SVDW_RO_NUL_");

  /**
   * ---------------------+-------+
   * var                  |  size |
   * ---------------------+-------+
   * publicKey            |   128 |
   * genesisTimestamp     |    32 |
   * period               |    32 |
   * ---------------------+-------+
   */
  uint256 private constant PTR_PUBLIC_KEY = 0;
  uint256 private constant LEN_PUBLIC_KEY = 128;
  uint256 private constant PTR_GENESIS_TIMESTAMP = 128;
  uint256 private constant LEN_GENESIS_TIMESTAMP = 32;
  uint256 private constant PTR_PERIOD = 160;
  uint256 private constant LEN_PERIOD = 32;

  /// @notice Pointer to immutable data
  address public immutable data;

  error InvalidPublicKey(uint256[4] pubKey);
  error InvalidBeaconConfiguration(uint256 genesisTimestamp, uint256 period);
  error InvalidSignature(uint256[4] pubKey, uint256[2] message, uint256[2] signature);

  constructor(uint256[4] memory publicKey_, uint256 genesisTimestamp_, uint256 period_) {
    if (!BLS.isValidPublicKey(publicKey_)) {
      revert InvalidPublicKey(publicKey_);
    }
    bytes memory pubKey = abi.encodePacked(publicKey_[0], publicKey_[1], publicKey_[2], publicKey_[3]);

    if (genesisTimestamp_ == 0 || period_ == 0) {
      revert InvalidBeaconConfiguration(genesisTimestamp_, period_);
    }

    data = SSTORE2.write(abi.encodePacked(pubKey, genesisTimestamp_, period_));

    // Sanity checks
    assert(keccak256(publicKey()) == keccak256(pubKey));
    assert(genesisTimestamp() == genesisTimestamp_);
    assert(period() == period_);
  }

  /// @notice Get the public key of the beacon
  function publicKey() public view returns (bytes memory) {
    return SSTORE2.read(data, PTR_PUBLIC_KEY, PTR_PUBLIC_KEY + LEN_PUBLIC_KEY);
  }

  /// @notice Get the public key hash of the beacon
  function publicKeyHash() public view returns (bytes32) {
    return keccak256(publicKey());
  }

  /// @notice Get the genesis timestamp of the beacon
  function genesisTimestamp() public view returns (uint256) {
    return
      abi.decode(SSTORE2.read(data, PTR_GENESIS_TIMESTAMP, PTR_GENESIS_TIMESTAMP + LEN_GENESIS_TIMESTAMP), (uint256));
  }

  /// @notice Get the period of the beacon
  function period() public view returns (uint256) {
    return abi.decode(SSTORE2.read(data, PTR_PERIOD, PTR_PERIOD + LEN_PERIOD), (uint256));
  }

  /// @notice Deserialise the public key from raw bytes for ecpairing
  function _deserialisePublicKey() private view returns (uint256[4] memory) {
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
