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
import { ObjectTypeId } from "../../ObjectTypeIds.sol";

struct ObjectTypeSchemaData {
  int32[] relativePositionsX;
  int32[] relativePositionsY;
  int32[] relativePositionsZ;
}

library ObjectTypeSchema {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "ObjectTypeSchema", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x746200000000000000000000000000004f626a65637454797065536368656d61);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0000000300000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (uint16)
  Schema constant _keySchema = Schema.wrap(0x0002010001000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (int32[], int32[], int32[])
  Schema constant _valueSchema = Schema.wrap(0x0000000385858500000000000000000000000000000000000000000000000000);

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
    fieldNames = new string[](3);
    fieldNames[0] = "relativePositionsX";
    fieldNames[1] = "relativePositionsY";
    fieldNames[2] = "relativePositionsZ";
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
   * @notice Get relativePositionsX.
   */
  function getRelativePositionsX(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsX) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Get relativePositionsX.
   */
  function _getRelativePositionsX(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsX) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Set relativePositionsX.
   */
  function setRelativePositionsX(ObjectTypeId objectTypeId, int32[] memory relativePositionsX) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((relativePositionsX)));
  }

  /**
   * @notice Set relativePositionsX.
   */
  function _setRelativePositionsX(ObjectTypeId objectTypeId, int32[] memory relativePositionsX) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((relativePositionsX)));
  }

  /**
   * @notice Get the length of relativePositionsX.
   */
  function lengthRelativePositionsX(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get the length of relativePositionsX.
   */
  function _lengthRelativePositionsX(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get an item of relativePositionsX.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsX(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsX.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsX(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsX.
   */
  function pushRelativePositionsX(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsX.
   */
  function _pushRelativePositionsX(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsX.
   */
  function popRelativePositionsX(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 4);
  }

  /**
   * @notice Pop an element from relativePositionsX.
   */
  function _popRelativePositionsX(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 4);
  }

  /**
   * @notice Update an element of relativePositionsX at `_index`.
   */
  function updateRelativePositionsX(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsX at `_index`.
   */
  function _updateRelativePositionsX(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get relativePositionsY.
   */
  function getRelativePositionsY(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsY) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Get relativePositionsY.
   */
  function _getRelativePositionsY(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsY) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Set relativePositionsY.
   */
  function setRelativePositionsY(ObjectTypeId objectTypeId, int32[] memory relativePositionsY) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((relativePositionsY)));
  }

  /**
   * @notice Set relativePositionsY.
   */
  function _setRelativePositionsY(ObjectTypeId objectTypeId, int32[] memory relativePositionsY) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((relativePositionsY)));
  }

  /**
   * @notice Get the length of relativePositionsY.
   */
  function lengthRelativePositionsY(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get the length of relativePositionsY.
   */
  function _lengthRelativePositionsY(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get an item of relativePositionsY.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsY(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsY.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsY(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsY.
   */
  function pushRelativePositionsY(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsY.
   */
  function _pushRelativePositionsY(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsY.
   */
  function popRelativePositionsY(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 1, 4);
  }

  /**
   * @notice Pop an element from relativePositionsY.
   */
  function _popRelativePositionsY(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 1, 4);
  }

  /**
   * @notice Update an element of relativePositionsY at `_index`.
   */
  function updateRelativePositionsY(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsY at `_index`.
   */
  function _updateRelativePositionsY(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get relativePositionsZ.
   */
  function getRelativePositionsZ(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsZ) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 2);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Get relativePositionsZ.
   */
  function _getRelativePositionsZ(ObjectTypeId objectTypeId) internal view returns (int32[] memory relativePositionsZ) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 2);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_int32());
  }

  /**
   * @notice Set relativePositionsZ.
   */
  function setRelativePositionsZ(ObjectTypeId objectTypeId, int32[] memory relativePositionsZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 2, EncodeArray.encode((relativePositionsZ)));
  }

  /**
   * @notice Set relativePositionsZ.
   */
  function _setRelativePositionsZ(ObjectTypeId objectTypeId, int32[] memory relativePositionsZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.setDynamicField(_tableId, _keyTuple, 2, EncodeArray.encode((relativePositionsZ)));
  }

  /**
   * @notice Get the length of relativePositionsZ.
   */
  function lengthRelativePositionsZ(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 2);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get the length of relativePositionsZ.
   */
  function _lengthRelativePositionsZ(ObjectTypeId objectTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 2);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get an item of relativePositionsZ.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemRelativePositionsZ(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 2, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Get an item of relativePositionsZ.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemRelativePositionsZ(ObjectTypeId objectTypeId, uint256 _index) internal view returns (int32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 2, _index * 4, (_index + 1) * 4);
      return (int32(uint32(bytes4(_blob))));
    }
  }

  /**
   * @notice Push an element to relativePositionsZ.
   */
  function pushRelativePositionsZ(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 2, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to relativePositionsZ.
   */
  function _pushRelativePositionsZ(ObjectTypeId objectTypeId, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 2, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from relativePositionsZ.
   */
  function popRelativePositionsZ(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 2, 4);
  }

  /**
   * @notice Pop an element from relativePositionsZ.
   */
  function _popRelativePositionsZ(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 2, 4);
  }

  /**
   * @notice Update an element of relativePositionsZ at `_index`.
   */
  function updateRelativePositionsZ(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 2, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of relativePositionsZ at `_index`.
   */
  function _updateRelativePositionsZ(ObjectTypeId objectTypeId, uint256 _index, int32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 2, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get the full data.
   */
  function get(ObjectTypeId objectTypeId) internal view returns (ObjectTypeSchemaData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

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
  function _get(ObjectTypeId objectTypeId) internal view returns (ObjectTypeSchemaData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

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
    ObjectTypeId objectTypeId,
    int32[] memory relativePositionsX,
    int32[] memory relativePositionsY,
    int32[] memory relativePositionsZ
  ) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(relativePositionsX, relativePositionsY, relativePositionsZ);
    bytes memory _dynamicData = encodeDynamic(relativePositionsX, relativePositionsY, relativePositionsZ);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    ObjectTypeId objectTypeId,
    int32[] memory relativePositionsX,
    int32[] memory relativePositionsY,
    int32[] memory relativePositionsZ
  ) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(relativePositionsX, relativePositionsY, relativePositionsZ);
    bytes memory _dynamicData = encodeDynamic(relativePositionsX, relativePositionsY, relativePositionsZ);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(ObjectTypeId objectTypeId, ObjectTypeSchemaData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(ObjectTypeId objectTypeId, ObjectTypeSchemaData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );
    bytes memory _dynamicData = encodeDynamic(
      _table.relativePositionsX,
      _table.relativePositionsY,
      _table.relativePositionsZ
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    EncodedLengths _encodedLengths,
    bytes memory _blob
  )
    internal
    pure
    returns (int32[] memory relativePositionsX, int32[] memory relativePositionsY, int32[] memory relativePositionsZ)
  {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    relativePositionsX = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int32());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(1);
    }
    relativePositionsY = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int32());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(2);
    }
    relativePositionsZ = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_int32());
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   *
   * @param _encodedLengths Encoded lengths of dynamic fields.
   * @param _dynamicData Tightly packed dynamic fields.
   */
  function decode(
    bytes memory,
    EncodedLengths _encodedLengths,
    bytes memory _dynamicData
  ) internal pure returns (ObjectTypeSchemaData memory _table) {
    (_table.relativePositionsX, _table.relativePositionsY, _table.relativePositionsZ) = decodeDynamic(
      _encodedLengths,
      _dynamicData
    );
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(ObjectTypeId objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(
    int32[] memory relativePositionsX,
    int32[] memory relativePositionsY,
    int32[] memory relativePositionsZ
  ) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(
        relativePositionsX.length * 4,
        relativePositionsY.length * 4,
        relativePositionsZ.length * 4
      );
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(
    int32[] memory relativePositionsX,
    int32[] memory relativePositionsY,
    int32[] memory relativePositionsZ
  ) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        EncodeArray.encode((relativePositionsX)),
        EncodeArray.encode((relativePositionsY)),
        EncodeArray.encode((relativePositionsZ))
      );
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    int32[] memory relativePositionsX,
    int32[] memory relativePositionsY,
    int32[] memory relativePositionsZ
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(relativePositionsX, relativePositionsY, relativePositionsZ);
    bytes memory _dynamicData = encodeDynamic(relativePositionsX, relativePositionsY, relativePositionsZ);

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(ObjectTypeId objectTypeId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(ObjectTypeId.unwrap(objectTypeId)));

    return _keyTuple;
  }
}
