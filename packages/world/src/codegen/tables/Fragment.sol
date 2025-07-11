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

struct FragmentData {
  EntityId forceField;
  uint128 forceFieldCreatedAt;
  uint128 extraDrainRate;
}

library Fragment {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Fragment", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x74620000000000000000000000000000467261676d656e740000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0040030020101000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (bytes32, uint128, uint128)
  Schema constant _valueSchema = Schema.wrap(0x004003005f0f0f00000000000000000000000000000000000000000000000000);

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
    fieldNames = new string[](3);
    fieldNames[0] = "forceField";
    fieldNames[1] = "forceFieldCreatedAt";
    fieldNames[2] = "extraDrainRate";
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
   * @notice Get forceField.
   */
  function getForceField(EntityId entityId) internal view returns (EntityId forceField) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return EntityId.wrap(bytes32(_blob));
  }

  /**
   * @notice Get forceField.
   */
  function _getForceField(EntityId entityId) internal view returns (EntityId forceField) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return EntityId.wrap(bytes32(_blob));
  }

  /**
   * @notice Set forceField.
   */
  function setForceField(EntityId entityId, EntityId forceField) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(EntityId.unwrap(forceField)), _fieldLayout);
  }

  /**
   * @notice Set forceField.
   */
  function _setForceField(EntityId entityId, EntityId forceField) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(EntityId.unwrap(forceField)), _fieldLayout);
  }

  /**
   * @notice Get forceFieldCreatedAt.
   */
  function getForceFieldCreatedAt(EntityId entityId) internal view returns (uint128 forceFieldCreatedAt) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get forceFieldCreatedAt.
   */
  function _getForceFieldCreatedAt(EntityId entityId) internal view returns (uint128 forceFieldCreatedAt) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set forceFieldCreatedAt.
   */
  function setForceFieldCreatedAt(EntityId entityId, uint128 forceFieldCreatedAt) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((forceFieldCreatedAt)), _fieldLayout);
  }

  /**
   * @notice Set forceFieldCreatedAt.
   */
  function _setForceFieldCreatedAt(EntityId entityId, uint128 forceFieldCreatedAt) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((forceFieldCreatedAt)), _fieldLayout);
  }

  /**
   * @notice Get extraDrainRate.
   */
  function getExtraDrainRate(EntityId entityId) internal view returns (uint128 extraDrainRate) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get extraDrainRate.
   */
  function _getExtraDrainRate(EntityId entityId) internal view returns (uint128 extraDrainRate) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set extraDrainRate.
   */
  function setExtraDrainRate(EntityId entityId, uint128 extraDrainRate) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((extraDrainRate)), _fieldLayout);
  }

  /**
   * @notice Set extraDrainRate.
   */
  function _setExtraDrainRate(EntityId entityId, uint128 extraDrainRate) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((extraDrainRate)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(EntityId entityId) internal view returns (FragmentData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(EntityId entityId) internal view returns (FragmentData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(EntityId entityId, EntityId forceField, uint128 forceFieldCreatedAt, uint128 extraDrainRate) internal {
    bytes memory _staticData = encodeStatic(forceField, forceFieldCreatedAt, extraDrainRate);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(EntityId entityId, EntityId forceField, uint128 forceFieldCreatedAt, uint128 extraDrainRate) internal {
    bytes memory _staticData = encodeStatic(forceField, forceFieldCreatedAt, extraDrainRate);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(EntityId entityId, FragmentData memory _table) internal {
    bytes memory _staticData = encodeStatic(_table.forceField, _table.forceFieldCreatedAt, _table.extraDrainRate);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(EntityId entityId, FragmentData memory _table) internal {
    bytes memory _staticData = encodeStatic(_table.forceField, _table.forceFieldCreatedAt, _table.extraDrainRate);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  ) internal pure returns (EntityId forceField, uint128 forceFieldCreatedAt, uint128 extraDrainRate) {
    forceField = EntityId.wrap(Bytes.getBytes32(_blob, 0));

    forceFieldCreatedAt = (uint128(Bytes.getBytes16(_blob, 32)));

    extraDrainRate = (uint128(Bytes.getBytes16(_blob, 48)));
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   *
   *
   */
  function decode(
    bytes memory _staticData,
    EncodedLengths,
    bytes memory
  ) internal pure returns (FragmentData memory _table) {
    (_table.forceField, _table.forceFieldCreatedAt, _table.extraDrainRate) = decodeStatic(_staticData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(EntityId entityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(EntityId entityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    EntityId forceField,
    uint128 forceFieldCreatedAt,
    uint128 extraDrainRate
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(forceField, forceFieldCreatedAt, extraDrainRate);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    EntityId forceField,
    uint128 forceFieldCreatedAt,
    uint128 extraDrainRate
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(forceField, forceFieldCreatedAt, extraDrainRate);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(EntityId entityId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    return _keyTuple;
  }
}
