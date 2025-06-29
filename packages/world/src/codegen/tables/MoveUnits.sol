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

// Import user types
import { EntityId } from "../../types/EntityId.sol";

library MoveUnits {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "MoveUnits", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x746200000000000000000000000000004d6f7665556e69747300000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0010010010000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32, uint256)
  Schema constant _keySchema = Schema.wrap(0x004002005f1f0000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint128)
  Schema constant _valueSchema = Schema.wrap(0x001001000f000000000000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "entityId";
    keyNames[1] = "blockNumber";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "units";
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
   * @notice Get units.
   */
  function getUnits(EntityId entityId, uint256 blockNumber) internal view returns (uint128 units) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get units.
   */
  function _getUnits(EntityId entityId, uint256 blockNumber) internal view returns (uint128 units) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get units.
   */
  function get(EntityId entityId, uint256 blockNumber) internal view returns (uint128 units) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get units.
   */
  function _get(EntityId entityId, uint256 blockNumber) internal view returns (uint128 units) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set units.
   */
  function setUnits(EntityId entityId, uint256 blockNumber, uint128 units) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((units)), _fieldLayout);
  }

  /**
   * @notice Set units.
   */
  function _setUnits(EntityId entityId, uint256 blockNumber, uint128 units) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((units)), _fieldLayout);
  }

  /**
   * @notice Set units.
   */
  function set(EntityId entityId, uint256 blockNumber, uint128 units) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((units)), _fieldLayout);
  }

  /**
   * @notice Set units.
   */
  function _set(EntityId entityId, uint256 blockNumber, uint128 units) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((units)), _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(EntityId entityId, uint256 blockNumber) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(EntityId entityId, uint256 blockNumber) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(uint128 units) internal pure returns (bytes memory) {
    return abi.encodePacked(units);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(uint128 units) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(units);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(EntityId entityId, uint256 blockNumber) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(entityId);
    _keyTuple[1] = bytes32(uint256(blockNumber));

    return _keyTuple;
  }
}
