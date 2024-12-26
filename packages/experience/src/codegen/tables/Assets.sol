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
import { ResourceType } from "./../common.sol";

library Assets {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "experience", name: "Assets", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462657870657269656e63650000000041737365747300000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0001010001000000000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (address, address)
  Schema constant _keySchema = Schema.wrap(0x0028020061610000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint8)
  Schema constant _valueSchema = Schema.wrap(0x0001010000000000000000000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "experience";
    keyNames[1] = "asset";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "assetType";
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
   * @notice Register the table with its config (using the specified store).
   */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get assetType.
   */
  function getAssetType(address experience, address asset) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get assetType.
   */
  function _getAssetType(address experience, address asset) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get assetType (using the specified store).
   */
  function getAssetType(
    IStore _store,
    address experience,
    address asset
  ) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get assetType.
   */
  function get(address experience, address asset) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get assetType.
   */
  function _get(address experience, address asset) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get assetType (using the specified store).
   */
  function get(IStore _store, address experience, address asset) internal view returns (ResourceType assetType) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ResourceType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set assetType.
   */
  function setAssetType(address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Set assetType.
   */
  function _setAssetType(address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Set assetType (using the specified store).
   */
  function setAssetType(IStore _store, address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    _store.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Set assetType.
   */
  function set(address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Set assetType.
   */
  function _set(address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Set assetType (using the specified store).
   */
  function set(IStore _store, address experience, address asset, ResourceType assetType) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    _store.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(assetType)), _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(address experience, address asset) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(address experience, address asset) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys (using the specified store).
   */
  function deleteRecord(IStore _store, address experience, address asset) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    _store.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(ResourceType assetType) internal pure returns (bytes memory) {
    return abi.encodePacked(assetType);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(ResourceType assetType) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(assetType);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(address experience, address asset) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = bytes32(uint256(uint160(asset)));

    return _keyTuple;
  }
}
