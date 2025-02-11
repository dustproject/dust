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
import { ObjectCategory } from "../common.sol";

struct ObjectTypeMetadataData {
  ObjectCategory objectCategory;
  bool canPassThrough;
  uint16 stackable;
  uint16 maxInventorySlots;
  uint32 mass;
  uint32 energy;
}

library ObjectTypeMetadata {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "ObjectTypeMetada", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x746200000000000000000000000000004f626a656374547970654d6574616461);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x000e060001010202040400000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (uint16)
  Schema constant _keySchema = Schema.wrap(0x0002010001000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint8, bool, uint16, uint16, uint32, uint32)
  Schema constant _valueSchema = Schema.wrap(0x000e060000600101030300000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "objectTypeId";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](6);
    fieldNames[0] = "objectCategory";
    fieldNames[1] = "canPassThrough";
    fieldNames[2] = "stackable";
    fieldNames[3] = "maxInventorySlots";
    fieldNames[4] = "mass";
    fieldNames[5] = "energy";
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
   * @notice Get objectCategory.
   */
  function getObjectCategory(uint16 objectTypeId) internal view returns (ObjectCategory objectCategory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ObjectCategory(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get objectCategory.
   */
  function _getObjectCategory(uint16 objectTypeId) internal view returns (ObjectCategory objectCategory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ObjectCategory(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set objectCategory.
   */
  function setObjectCategory(uint16 objectTypeId, ObjectCategory objectCategory) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(objectCategory)), _fieldLayout);
  }

  /**
   * @notice Set objectCategory.
   */
  function _setObjectCategory(uint16 objectTypeId, ObjectCategory objectCategory) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(objectCategory)), _fieldLayout);
  }

  /**
   * @notice Get canPassThrough.
   */
  function getCanPassThrough(uint16 objectTypeId) internal view returns (bool canPassThrough) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get canPassThrough.
   */
  function _getCanPassThrough(uint16 objectTypeId) internal view returns (bool canPassThrough) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Set canPassThrough.
   */
  function setCanPassThrough(uint16 objectTypeId, bool canPassThrough) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((canPassThrough)), _fieldLayout);
  }

  /**
   * @notice Set canPassThrough.
   */
  function _setCanPassThrough(uint16 objectTypeId, bool canPassThrough) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((canPassThrough)), _fieldLayout);
  }

  /**
   * @notice Get stackable.
   */
  function getStackable(uint16 objectTypeId) internal view returns (uint16 stackable) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Get stackable.
   */
  function _getStackable(uint16 objectTypeId) internal view returns (uint16 stackable) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Set stackable.
   */
  function setStackable(uint16 objectTypeId, uint16 stackable) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((stackable)), _fieldLayout);
  }

  /**
   * @notice Set stackable.
   */
  function _setStackable(uint16 objectTypeId, uint16 stackable) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((stackable)), _fieldLayout);
  }

  /**
   * @notice Get maxInventorySlots.
   */
  function getMaxInventorySlots(uint16 objectTypeId) internal view returns (uint16 maxInventorySlots) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Get maxInventorySlots.
   */
  function _getMaxInventorySlots(uint16 objectTypeId) internal view returns (uint16 maxInventorySlots) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Set maxInventorySlots.
   */
  function setMaxInventorySlots(uint16 objectTypeId, uint16 maxInventorySlots) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((maxInventorySlots)), _fieldLayout);
  }

  /**
   * @notice Set maxInventorySlots.
   */
  function _setMaxInventorySlots(uint16 objectTypeId, uint16 maxInventorySlots) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((maxInventorySlots)), _fieldLayout);
  }

  /**
   * @notice Get mass.
   */
  function getMass(uint16 objectTypeId) internal view returns (uint32 mass) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get mass.
   */
  function _getMass(uint16 objectTypeId) internal view returns (uint32 mass) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set mass.
   */
  function setMass(uint16 objectTypeId, uint32 mass) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((mass)), _fieldLayout);
  }

  /**
   * @notice Set mass.
   */
  function _setMass(uint16 objectTypeId, uint32 mass) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((mass)), _fieldLayout);
  }

  /**
   * @notice Get energy.
   */
  function getEnergy(uint16 objectTypeId) internal view returns (uint32 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get energy.
   */
  function _getEnergy(uint16 objectTypeId) internal view returns (uint32 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set energy.
   */
  function setEnergy(uint16 objectTypeId, uint32 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Set energy.
   */
  function _setEnergy(uint16 objectTypeId, uint32 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(uint16 objectTypeId) internal view returns (ObjectTypeMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

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
  function _get(uint16 objectTypeId) internal view returns (ObjectTypeMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

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
  function set(
    uint16 objectTypeId,
    ObjectCategory objectCategory,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal {
    bytes memory _staticData = encodeStatic(objectCategory, canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    uint16 objectTypeId,
    ObjectCategory objectCategory,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal {
    bytes memory _staticData = encodeStatic(objectCategory, canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(uint16 objectTypeId, ObjectTypeMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.objectCategory,
      _table.canPassThrough,
      _table.stackable,
      _table.maxInventorySlots,
      _table.mass,
      _table.energy
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(uint16 objectTypeId, ObjectTypeMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.objectCategory,
      _table.canPassThrough,
      _table.stackable,
      _table.maxInventorySlots,
      _table.mass,
      _table.energy
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  )
    internal
    pure
    returns (
      ObjectCategory objectCategory,
      bool canPassThrough,
      uint16 stackable,
      uint16 maxInventorySlots,
      uint32 mass,
      uint32 energy
    )
  {
    objectCategory = ObjectCategory(uint8(Bytes.getBytes1(_blob, 0)));

    canPassThrough = (_toBool(uint8(Bytes.getBytes1(_blob, 1))));

    stackable = (uint16(Bytes.getBytes2(_blob, 2)));

    maxInventorySlots = (uint16(Bytes.getBytes2(_blob, 4)));

    mass = (uint32(Bytes.getBytes4(_blob, 6)));

    energy = (uint32(Bytes.getBytes4(_blob, 10)));
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
  ) internal pure returns (ObjectTypeMetadataData memory _table) {
    (
      _table.objectCategory,
      _table.canPassThrough,
      _table.stackable,
      _table.maxInventorySlots,
      _table.mass,
      _table.energy
    ) = decodeStatic(_staticData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(uint16 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(uint16 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    ObjectCategory objectCategory,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(objectCategory, canPassThrough, stackable, maxInventorySlots, mass, energy);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    ObjectCategory objectCategory,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(objectCategory, canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(uint16 objectTypeId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(objectTypeId));

    return _keyTuple;
  }
}

/**
 * @notice Cast a value to a bool.
 * @dev Boolean values are encoded as uint8 (1 = true, 0 = false), but Solidity doesn't allow casting between uint8 and bool.
 * @param value The uint8 value to convert.
 * @return result The boolean value.
 */
function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
