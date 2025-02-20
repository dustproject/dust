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

struct RecipesData {
  uint16[] outputTypes;
  uint16[] outputAmounts;
}

library Recipes {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Recipes", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000052656369706573000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0000000200000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint16[], uint16[])
  Schema constant _valueSchema = Schema.wrap(0x0000000263630000000000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "recipeId";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](2);
    fieldNames[0] = "outputTypes";
    fieldNames[1] = "outputAmounts";
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
   * @notice Get outputTypes.
   */
  function getOutputTypes(bytes32 recipeId) internal view returns (uint16[] memory outputTypes) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Get outputTypes.
   */
  function _getOutputTypes(bytes32 recipeId) internal view returns (uint16[] memory outputTypes) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Set outputTypes.
   */
  function setOutputTypes(bytes32 recipeId, uint16[] memory outputTypes) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((outputTypes)));
  }

  /**
   * @notice Set outputTypes.
   */
  function _setOutputTypes(bytes32 recipeId, uint16[] memory outputTypes) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((outputTypes)));
  }

  /**
   * @notice Get the length of outputTypes.
   */
  function lengthOutputTypes(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of outputTypes.
   */
  function _lengthOutputTypes(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of outputTypes.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemOutputTypes(bytes32 recipeId, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Get an item of outputTypes.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemOutputTypes(bytes32 recipeId, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Push an element to outputTypes.
   */
  function pushOutputTypes(bytes32 recipeId, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to outputTypes.
   */
  function _pushOutputTypes(bytes32 recipeId, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from outputTypes.
   */
  function popOutputTypes(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Pop an element from outputTypes.
   */
  function _popOutputTypes(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 2);
  }

  /**
   * @notice Update an element of outputTypes at `_index`.
   */
  function updateOutputTypes(bytes32 recipeId, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of outputTypes at `_index`.
   */
  function _updateOutputTypes(bytes32 recipeId, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get outputAmounts.
   */
  function getOutputAmounts(bytes32 recipeId) internal view returns (uint16[] memory outputAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Get outputAmounts.
   */
  function _getOutputAmounts(bytes32 recipeId) internal view returns (uint16[] memory outputAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint16());
  }

  /**
   * @notice Set outputAmounts.
   */
  function setOutputAmounts(bytes32 recipeId, uint16[] memory outputAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((outputAmounts)));
  }

  /**
   * @notice Set outputAmounts.
   */
  function _setOutputAmounts(bytes32 recipeId, uint16[] memory outputAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((outputAmounts)));
  }

  /**
   * @notice Get the length of outputAmounts.
   */
  function lengthOutputAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get the length of outputAmounts.
   */
  function _lengthOutputAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 2;
    }
  }

  /**
   * @notice Get an item of outputAmounts.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemOutputAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Get an item of outputAmounts.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemOutputAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint16) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 2, (_index + 1) * 2);
      return (uint16(bytes2(_blob)));
    }
  }

  /**
   * @notice Push an element to outputAmounts.
   */
  function pushOutputAmounts(bytes32 recipeId, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to outputAmounts.
   */
  function _pushOutputAmounts(bytes32 recipeId, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from outputAmounts.
   */
  function popOutputAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 1, 2);
  }

  /**
   * @notice Pop an element from outputAmounts.
   */
  function _popOutputAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 1, 2);
  }

  /**
   * @notice Update an element of outputAmounts at `_index`.
   */
  function updateOutputAmounts(bytes32 recipeId, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of outputAmounts at `_index`.
   */
  function _updateOutputAmounts(bytes32 recipeId, uint256 _index, uint16 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 2), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get the full data.
   */
  function get(bytes32 recipeId) internal view returns (RecipesData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

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
  function _get(bytes32 recipeId) internal view returns (RecipesData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

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
  function set(bytes32 recipeId, uint16[] memory outputTypes, uint16[] memory outputAmounts) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(outputTypes, outputAmounts);
    bytes memory _dynamicData = encodeDynamic(outputTypes, outputAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(bytes32 recipeId, uint16[] memory outputTypes, uint16[] memory outputAmounts) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(outputTypes, outputAmounts);
    bytes memory _dynamicData = encodeDynamic(outputTypes, outputAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(bytes32 recipeId, RecipesData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(_table.outputTypes, _table.outputAmounts);
    bytes memory _dynamicData = encodeDynamic(_table.outputTypes, _table.outputAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(bytes32 recipeId, RecipesData memory _table) internal {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(_table.outputTypes, _table.outputAmounts);
    bytes memory _dynamicData = encodeDynamic(_table.outputTypes, _table.outputAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    EncodedLengths _encodedLengths,
    bytes memory _blob
  ) internal pure returns (uint16[] memory outputTypes, uint16[] memory outputAmounts) {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    outputTypes = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint16());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(1);
    }
    outputAmounts = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint16());
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
  ) internal pure returns (RecipesData memory _table) {
    (_table.outputTypes, _table.outputAmounts) = decodeDynamic(_encodedLengths, _dynamicData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(
    uint16[] memory outputTypes,
    uint16[] memory outputAmounts
  ) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(outputTypes.length * 2, outputAmounts.length * 2);
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(
    uint16[] memory outputTypes,
    uint16[] memory outputAmounts
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(EncodeArray.encode((outputTypes)), EncodeArray.encode((outputAmounts)));
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    uint16[] memory outputTypes,
    uint16[] memory outputAmounts
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData;
    EncodedLengths _encodedLengths = encodeLengths(outputTypes, outputAmounts);
    bytes memory _dynamicData = encodeDynamic(outputTypes, outputAmounts);

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(bytes32 recipeId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    return _keyTuple;
  }
}
