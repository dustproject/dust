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
import { EntityId } from "../../EntityId.sol";
import { ObjectTypeId } from "../../ObjectTypeId.sol";

library InventoryTypeSlots {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "InventoryTypeSlo", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x74620000000000000000000000000000496e76656e746f727954797065536c6f);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0000000100000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32, uint16)
  Schema constant _keySchema = Schema.wrap(0x002202005f010000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint16[])
  Schema constant _valueSchema = Schema.wrap(0x0000000163000000000000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "owner";
    keyNames[1] = "objectType";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "slots";
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
   * @notice Get slots.
   */
  function getSlots(EntityId owner, ObjectTypeId objectType) internal view returns (uint16[] memory slots) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Get slots.
   */
  function _getSlots(EntityId owner, ObjectTypeId objectType) internal view returns (uint16[] memory slots) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Get slots.
   */
  function get(EntityId owner, ObjectTypeId objectType) internal view returns (uint16[] memory slots) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Get slots.
   */
  function _get(EntityId owner, ObjectTypeId objectType) internal view returns (uint16[] memory slots) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Set slots.
   */
  function setSlots(EntityId owner, ObjectTypeId objectType, uint16[] memory slots) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((slots)));
  }

  /**
   * @notice Set slots.
   */
  function _setSlots(EntityId owner, ObjectTypeId objectType, uint16[] memory slots) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((slots)));
  }

  /**
   * @notice Set slots.
   */
  function set(EntityId owner, ObjectTypeId objectType, uint16[] memory slots) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((slots)));
  }

  /**
   * @notice Set slots.
   */
  function _set(EntityId owner, ObjectTypeId objectType, uint16[] memory slots) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((slots)));
  }

  /**
   * @notice Get the length of slots.
   */
  function lengthSlots(EntityId owner, ObjectTypeId objectType) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of slots.
   */
  function _lengthSlots(EntityId owner, ObjectTypeId objectType) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of slots.
   */
  function length(EntityId owner, ObjectTypeId objectType) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of slots.
   */
  function _length(EntityId owner, ObjectTypeId objectType) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of slots.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemSlots(EntityId owner, ObjectTypeId objectType, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Get an item of slots.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemSlots(EntityId owner, ObjectTypeId objectType, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Get an item of slots.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItem(EntityId owner, ObjectTypeId objectType, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Get an item of slots.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItem(EntityId owner, ObjectTypeId objectType, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Push an element to slots.
   */
  function pushSlots(EntityId owner, ObjectTypeId objectType, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to slots.
   */
  function _pushSlots(EntityId owner, ObjectTypeId objectType, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to slots.
   */
  function push(EntityId owner, ObjectTypeId objectType, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to slots.
   */
  function _push(EntityId owner, ObjectTypeId objectType, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from slots.
   */
  function popSlots(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Pop an element from slots.
   */
  function _popSlots(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Pop an element from slots.
   */
  function pop(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Pop an element from slots.
   */
  function _pop(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Update an element of slots at `_index`.
   */
  function updateSlots(EntityId owner, ObjectTypeId objectType, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of slots at `_index`.
   */
  function _updateSlots(EntityId owner, ObjectTypeId objectType, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of slots at `_index`.
   */
  function update(EntityId owner, ObjectTypeId objectType, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of slots at `_index`.
   */
  function _update(EntityId owner, ObjectTypeId objectType, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(EntityId owner, ObjectTypeId objectType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(uint16[] memory slots) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(slots.length * 2);
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(uint16[] memory slots) internal pure returns (bytes memory) {
    return abi.encodePacked(EncodeArray.encode((slots)));
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(uint16[] memory slots) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(slots);
    bytes memory _dynamicData = encodeDynamic(slots);

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(EntityId owner, ObjectTypeId objectType) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = EntityId.unwrap(owner);
    _keyTuple[1] = bytes32(uint256(ObjectTypeId.unwrap(objectType)));

    return _keyTuple;
  }
}
