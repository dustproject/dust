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
  bytes32 stationObjectTypeId;
  bytes32 outputObjectTypeId;
  uint8 outputObjectTypeAmount;
  bytes32[] inputObjectTypeIds;
  uint8[] inputObjectTypeAmounts;
}

library Recipes {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Recipes", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000052656369706573000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0041030220200100000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (bytes32, bytes32, uint8, bytes32[], uint8[])
  Schema constant _valueSchema = Schema.wrap(0x004103025f5f00c1620000000000000000000000000000000000000000000000);

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
    fieldNames = new string[](5);
    fieldNames[0] = "stationObjectTypeId";
    fieldNames[1] = "outputObjectTypeId";
    fieldNames[2] = "outputObjectTypeAmount";
    fieldNames[3] = "inputObjectTypeIds";
    fieldNames[4] = "inputObjectTypeAmounts";
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
   * @notice Get stationObjectTypeId.
   */
  function getStationObjectTypeId(bytes32 recipeId) internal view returns (bytes32 stationObjectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Get stationObjectTypeId.
   */
  function _getStationObjectTypeId(bytes32 recipeId) internal view returns (bytes32 stationObjectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Set stationObjectTypeId.
   */
  function setStationObjectTypeId(bytes32 recipeId, bytes32 stationObjectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((stationObjectTypeId)), _fieldLayout);
  }

  /**
   * @notice Set stationObjectTypeId.
   */
  function _setStationObjectTypeId(bytes32 recipeId, bytes32 stationObjectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((stationObjectTypeId)), _fieldLayout);
  }

  /**
   * @notice Get outputObjectTypeId.
   */
  function getOutputObjectTypeId(bytes32 recipeId) internal view returns (bytes32 outputObjectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Get outputObjectTypeId.
   */
  function _getOutputObjectTypeId(bytes32 recipeId) internal view returns (bytes32 outputObjectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Set outputObjectTypeId.
   */
  function setOutputObjectTypeId(bytes32 recipeId, bytes32 outputObjectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((outputObjectTypeId)), _fieldLayout);
  }

  /**
   * @notice Set outputObjectTypeId.
   */
  function _setOutputObjectTypeId(bytes32 recipeId, bytes32 outputObjectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((outputObjectTypeId)), _fieldLayout);
  }

  /**
   * @notice Get outputObjectTypeAmount.
   */
  function getOutputObjectTypeAmount(bytes32 recipeId) internal view returns (uint8 outputObjectTypeAmount) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint8(bytes1(_blob)));
  }

  /**
   * @notice Get outputObjectTypeAmount.
   */
  function _getOutputObjectTypeAmount(bytes32 recipeId) internal view returns (uint8 outputObjectTypeAmount) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint8(bytes1(_blob)));
  }

  /**
   * @notice Set outputObjectTypeAmount.
   */
  function setOutputObjectTypeAmount(bytes32 recipeId, uint8 outputObjectTypeAmount) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((outputObjectTypeAmount)), _fieldLayout);
  }

  /**
   * @notice Set outputObjectTypeAmount.
   */
  function _setOutputObjectTypeAmount(bytes32 recipeId, uint8 outputObjectTypeAmount) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((outputObjectTypeAmount)), _fieldLayout);
  }

  /**
   * @notice Get inputObjectTypeIds.
   */
  function getInputObjectTypeIds(bytes32 recipeId) internal view returns (bytes32[] memory inputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /**
   * @notice Get inputObjectTypeIds.
   */
  function _getInputObjectTypeIds(bytes32 recipeId) internal view returns (bytes32[] memory inputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /**
   * @notice Set inputObjectTypeIds.
   */
  function setInputObjectTypeIds(bytes32 recipeId, bytes32[] memory inputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((inputObjectTypeIds)));
  }

  /**
   * @notice Set inputObjectTypeIds.
   */
  function _setInputObjectTypeIds(bytes32 recipeId, bytes32[] memory inputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((inputObjectTypeIds)));
  }

  /**
   * @notice Get the length of inputObjectTypeIds.
   */
  function lengthInputObjectTypeIds(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 32;
    }
  }

  /**
   * @notice Get the length of inputObjectTypeIds.
   */
  function _lengthInputObjectTypeIds(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 32;
    }
  }

  /**
   * @notice Get an item of inputObjectTypeIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemInputObjectTypeIds(bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 32, (_index + 1) * 32);
      return (bytes32(_blob));
    }
  }

  /**
   * @notice Get an item of inputObjectTypeIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemInputObjectTypeIds(bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 32, (_index + 1) * 32);
      return (bytes32(_blob));
    }
  }

  /**
   * @notice Push an element to inputObjectTypeIds.
   */
  function pushInputObjectTypeIds(bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to inputObjectTypeIds.
   */
  function _pushInputObjectTypeIds(bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from inputObjectTypeIds.
   */
  function popInputObjectTypeIds(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 32);
  }

  /**
   * @notice Pop an element from inputObjectTypeIds.
   */
  function _popInputObjectTypeIds(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 32);
  }

  /**
   * @notice Update an element of inputObjectTypeIds at `_index`.
   */
  function updateInputObjectTypeIds(bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 32), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of inputObjectTypeIds at `_index`.
   */
  function _updateInputObjectTypeIds(bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 32), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get inputObjectTypeAmounts.
   */
  function getInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint8[] memory inputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /**
   * @notice Get inputObjectTypeAmounts.
   */
  function _getInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint8[] memory inputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 1);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /**
   * @notice Set inputObjectTypeAmounts.
   */
  function setInputObjectTypeAmounts(bytes32 recipeId, uint8[] memory inputObjectTypeAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((inputObjectTypeAmounts)));
  }

  /**
   * @notice Set inputObjectTypeAmounts.
   */
  function _setInputObjectTypeAmounts(bytes32 recipeId, uint8[] memory inputObjectTypeAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setDynamicField(_tableId, _keyTuple, 1, EncodeArray.encode((inputObjectTypeAmounts)));
  }

  /**
   * @notice Get the length of inputObjectTypeAmounts.
   */
  function lengthInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get the length of inputObjectTypeAmounts.
   */
  function _lengthInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 1);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get an item of inputObjectTypeAmounts.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemInputObjectTypeAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 1, (_index + 1) * 1);
      return (uint8(bytes1(_blob)));
    }
  }

  /**
   * @notice Get an item of inputObjectTypeAmounts.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemInputObjectTypeAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 1, _index * 1, (_index + 1) * 1);
      return (uint8(bytes1(_blob)));
    }
  }

  /**
   * @notice Push an element to inputObjectTypeAmounts.
   */
  function pushInputObjectTypeAmounts(bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to inputObjectTypeAmounts.
   */
  function _pushInputObjectTypeAmounts(bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 1, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from inputObjectTypeAmounts.
   */
  function popInputObjectTypeAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 1, 1);
  }

  /**
   * @notice Pop an element from inputObjectTypeAmounts.
   */
  function _popInputObjectTypeAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 1, 1);
  }

  /**
   * @notice Update an element of inputObjectTypeAmounts at `_index`.
   */
  function updateInputObjectTypeAmounts(bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of inputObjectTypeAmounts at `_index`.
   */
  function _updateInputObjectTypeAmounts(bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 1, uint40(_index * 1), uint40(_encoded.length), _encoded);
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
  function set(
    bytes32 recipeId,
    bytes32 stationObjectTypeId,
    bytes32 outputObjectTypeId,
    uint8 outputObjectTypeAmount,
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts
  ) internal {
    bytes memory _staticData = encodeStatic(stationObjectTypeId, outputObjectTypeId, outputObjectTypeAmount);

    EncodedLengths _encodedLengths = encodeLengths(inputObjectTypeIds, inputObjectTypeAmounts);
    bytes memory _dynamicData = encodeDynamic(inputObjectTypeIds, inputObjectTypeAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    bytes32 recipeId,
    bytes32 stationObjectTypeId,
    bytes32 outputObjectTypeId,
    uint8 outputObjectTypeAmount,
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts
  ) internal {
    bytes memory _staticData = encodeStatic(stationObjectTypeId, outputObjectTypeId, outputObjectTypeAmount);

    EncodedLengths _encodedLengths = encodeLengths(inputObjectTypeIds, inputObjectTypeAmounts);
    bytes memory _dynamicData = encodeDynamic(inputObjectTypeIds, inputObjectTypeAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(bytes32 recipeId, RecipesData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.stationObjectTypeId,
      _table.outputObjectTypeId,
      _table.outputObjectTypeAmount
    );

    EncodedLengths _encodedLengths = encodeLengths(_table.inputObjectTypeIds, _table.inputObjectTypeAmounts);
    bytes memory _dynamicData = encodeDynamic(_table.inputObjectTypeIds, _table.inputObjectTypeAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(bytes32 recipeId, RecipesData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.stationObjectTypeId,
      _table.outputObjectTypeId,
      _table.outputObjectTypeAmount
    );

    EncodedLengths _encodedLengths = encodeLengths(_table.inputObjectTypeIds, _table.inputObjectTypeAmounts);
    bytes memory _dynamicData = encodeDynamic(_table.inputObjectTypeIds, _table.inputObjectTypeAmounts);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  ) internal pure returns (bytes32 stationObjectTypeId, bytes32 outputObjectTypeId, uint8 outputObjectTypeAmount) {
    stationObjectTypeId = (Bytes.getBytes32(_blob, 0));

    outputObjectTypeId = (Bytes.getBytes32(_blob, 32));

    outputObjectTypeAmount = (uint8(Bytes.getBytes1(_blob, 64)));
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    EncodedLengths _encodedLengths,
    bytes memory _blob
  ) internal pure returns (bytes32[] memory inputObjectTypeIds, uint8[] memory inputObjectTypeAmounts) {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    inputObjectTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_bytes32());

    _start = _end;
    unchecked {
      _end += _encodedLengths.atIndex(1);
    }
    inputObjectTypeAmounts = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint8());
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   * @param _encodedLengths Encoded lengths of dynamic fields.
   * @param _dynamicData Tightly packed dynamic fields.
   */
  function decode(
    bytes memory _staticData,
    EncodedLengths _encodedLengths,
    bytes memory _dynamicData
  ) internal pure returns (RecipesData memory _table) {
    (_table.stationObjectTypeId, _table.outputObjectTypeId, _table.outputObjectTypeAmount) = decodeStatic(_staticData);

    (_table.inputObjectTypeIds, _table.inputObjectTypeAmounts) = decodeDynamic(_encodedLengths, _dynamicData);
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
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    bytes32 stationObjectTypeId,
    bytes32 outputObjectTypeId,
    uint8 outputObjectTypeAmount
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(stationObjectTypeId, outputObjectTypeId, outputObjectTypeAmount);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts
  ) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(inputObjectTypeIds.length * 32, inputObjectTypeAmounts.length * 1);
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(EncodeArray.encode((inputObjectTypeIds)), EncodeArray.encode((inputObjectTypeAmounts)));
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    bytes32 stationObjectTypeId,
    bytes32 outputObjectTypeId,
    uint8 outputObjectTypeAmount,
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(stationObjectTypeId, outputObjectTypeId, outputObjectTypeAmount);

    EncodedLengths _encodedLengths = encodeLengths(inputObjectTypeIds, inputObjectTypeAmounts);
    bytes memory _dynamicData = encodeDynamic(inputObjectTypeIds, inputObjectTypeAmounts);

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
