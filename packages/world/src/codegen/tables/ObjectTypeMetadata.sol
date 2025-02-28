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
import { ObjectType } from "../../ObjectType.sol";

struct ObjectTypeMetadataData {
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
    FieldLayout.wrap(0x000d050001020204040000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (uint16)
  Schema constant _keySchema = Schema.wrap(0x0002010001000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (bool, uint16, uint16, uint32, uint32)
  Schema constant _valueSchema = Schema.wrap(0x000d050060010103030000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "objectType";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](5);
    fieldNames[0] = "canPassThrough";
    fieldNames[1] = "stackable";
    fieldNames[2] = "maxInventorySlots";
    fieldNames[3] = "mass";
    fieldNames[4] = "energy";
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
   * @notice Get canPassThrough.
   */
  function getCanPassThrough(ObjectType objectType) internal view returns (bool canPassThrough) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get canPassThrough.
   */
  function _getCanPassThrough(ObjectType objectType) internal view returns (bool canPassThrough) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Set canPassThrough.
   */
  function setCanPassThrough(ObjectType objectType, bool canPassThrough) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((canPassThrough)), _fieldLayout);
  }

  /**
   * @notice Set canPassThrough.
   */
  function _setCanPassThrough(ObjectType objectType, bool canPassThrough) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((canPassThrough)), _fieldLayout);
  }

  /**
   * @notice Get stackable.
   */
  function getStackable(ObjectType objectType) internal view returns (uint16 stackable) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Get stackable.
   */
  function _getStackable(ObjectType objectType) internal view returns (uint16 stackable) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Set stackable.
   */
  function setStackable(ObjectType objectType, uint16 stackable) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((stackable)), _fieldLayout);
  }

  /**
   * @notice Set stackable.
   */
  function _setStackable(ObjectType objectType, uint16 stackable) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((stackable)), _fieldLayout);
  }

  /**
   * @notice Get maxInventorySlots.
   */
  function getMaxInventorySlots(ObjectType objectType) internal view returns (uint16 maxInventorySlots) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Get maxInventorySlots.
   */
  function _getMaxInventorySlots(ObjectType objectType) internal view returns (uint16 maxInventorySlots) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Set maxInventorySlots.
   */
  function setMaxInventorySlots(ObjectType objectType, uint16 maxInventorySlots) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((maxInventorySlots)), _fieldLayout);
  }

  /**
   * @notice Set maxInventorySlots.
   */
  function _setMaxInventorySlots(ObjectType objectType, uint16 maxInventorySlots) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((maxInventorySlots)), _fieldLayout);
  }

  /**
   * @notice Get mass.
   */
  function getMass(ObjectType objectType) internal view returns (uint32 mass) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get mass.
   */
  function _getMass(ObjectType objectType) internal view returns (uint32 mass) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set mass.
   */
  function setMass(ObjectType objectType, uint32 mass) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((mass)), _fieldLayout);
  }

  /**
   * @notice Set mass.
   */
  function _setMass(ObjectType objectType, uint32 mass) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((mass)), _fieldLayout);
  }

  /**
   * @notice Get energy.
   */
  function getEnergy(ObjectType objectType) internal view returns (uint32 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get energy.
   */
  function _getEnergy(ObjectType objectType) internal view returns (uint32 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set energy.
   */
  function setEnergy(ObjectType objectType, uint32 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Set energy.
   */
  function _setEnergy(ObjectType objectType, uint32 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(ObjectType objectType) internal view returns (ObjectTypeMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

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
  function _get(ObjectType objectType) internal view returns (ObjectTypeMetadataData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

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
    ObjectType objectType,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal {
    bytes memory _staticData = encodeStatic(canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    ObjectType objectType,
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal {
    bytes memory _staticData = encodeStatic(canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(ObjectType objectType, ObjectTypeMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.canPassThrough,
      _table.stackable,
      _table.maxInventorySlots,
      _table.mass,
      _table.energy
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(ObjectType objectType, ObjectTypeMetadataData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.canPassThrough,
      _table.stackable,
      _table.maxInventorySlots,
      _table.mass,
      _table.energy
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

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
    returns (bool canPassThrough, uint16 stackable, uint16 maxInventorySlots, uint32 mass, uint32 energy)
  {
    canPassThrough = (_toBool(uint8(Bytes.getBytes1(_blob, 0))));

    stackable = (uint16(Bytes.getBytes2(_blob, 1)));

    maxInventorySlots = (uint16(Bytes.getBytes2(_blob, 3)));

    mass = (uint32(Bytes.getBytes4(_blob, 5)));

    energy = (uint32(Bytes.getBytes4(_blob, 9)));
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
    (_table.canPassThrough, _table.stackable, _table.maxInventorySlots, _table.mass, _table.energy) = decodeStatic(
      _staticData
    );
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(ObjectType objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(ObjectType objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(canPassThrough, stackable, maxInventorySlots, mass, energy);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    bool canPassThrough,
    uint16 stackable,
    uint16 maxInventorySlots,
    uint32 mass,
    uint32 energy
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(canPassThrough, stackable, maxInventorySlots, mass, energy);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(ObjectType objectType) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectType.unwrap(objectType)));

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
