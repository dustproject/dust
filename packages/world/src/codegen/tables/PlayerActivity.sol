// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

library PlayerActivity {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "PlayerActivity", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x74620000000000000000000000000000506c6179657241637469766974790000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0010010010000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint128)
  Schema constant _valueSchema = Schema.wrap(0x001001000f000000000000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "entityId";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "lastActionTime";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get lastActionTime.
   */
  function getLastActionTime(bytes32 entityId) internal view returns (uint128 lastActionTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get lastActionTime.
   */
  function _getLastActionTime(bytes32 entityId) internal view returns (uint128 lastActionTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get lastActionTime.
   */
  function get(bytes32 entityId) internal view returns (uint128 lastActionTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get lastActionTime.
   */
  function _get(bytes32 entityId) internal view returns (uint128 lastActionTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set lastActionTime.
   */
  function setLastActionTime(bytes32 entityId, uint128 lastActionTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastActionTime)), _fieldLayout);
  }

  /**
   * @notice Set lastActionTime.
   */
  function _setLastActionTime(bytes32 entityId, uint128 lastActionTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastActionTime)), _fieldLayout);
  }

  /**
   * @notice Set lastActionTime.
   */
  function set(bytes32 entityId, uint128 lastActionTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastActionTime)), _fieldLayout);
  }

  /**
   * @notice Set lastActionTime.
   */
  function _set(bytes32 entityId, uint128 lastActionTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastActionTime)), _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(bytes32 entityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(bytes32 entityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(uint128 lastActionTime) internal pure returns (bytes memory) {
    return abi.encodePacked(lastActionTime);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(uint128 lastActionTime) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(lastActionTime);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(bytes32 entityId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    return _keyTuple;
  }
}
