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
import { ShopType } from "./../common.sol";

struct ShopData {
  ShopType shopType;
  uint8 objectTypeId;
  uint256 buyPrice;
  uint256 sellPrice;
  address paymentToken;
  uint256 balance;
}

library Shop {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "experience", name: "Shop", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462657870657269656e63650000000053686f70000000000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0076060001012020142000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint8, uint8, uint256, uint256, address, uint256)
  Schema constant _valueSchema = Schema.wrap(0x0076060000001f1f611f00000000000000000000000000000000000000000000);

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
    fieldNames = new string[](6);
    fieldNames[0] = "shopType";
    fieldNames[1] = "objectTypeId";
    fieldNames[2] = "buyPrice";
    fieldNames[3] = "sellPrice";
    fieldNames[4] = "paymentToken";
    fieldNames[5] = "balance";
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
   * @notice Get shopType.
   */
  function getShopType(bytes32 entityId) internal view returns (ShopType shopType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ShopType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get shopType.
   */
  function _getShopType(bytes32 entityId) internal view returns (ShopType shopType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return ShopType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set shopType.
   */
  function setShopType(bytes32 entityId, ShopType shopType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(shopType)), _fieldLayout);
  }

  /**
   * @notice Set shopType.
   */
  function _setShopType(bytes32 entityId, ShopType shopType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(shopType)), _fieldLayout);
  }

  /**
   * @notice Get objectTypeId.
   */
  function getObjectTypeId(bytes32 entityId) internal view returns (uint8 objectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint8(bytes1(_blob)));
  }

  /**
   * @notice Get objectTypeId.
   */
  function _getObjectTypeId(bytes32 entityId) internal view returns (uint8 objectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint8(bytes1(_blob)));
  }

  /**
   * @notice Set objectTypeId.
   */
  function setObjectTypeId(bytes32 entityId, uint8 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((objectTypeId)), _fieldLayout);
  }

  /**
   * @notice Set objectTypeId.
   */
  function _setObjectTypeId(bytes32 entityId, uint8 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((objectTypeId)), _fieldLayout);
  }

  /**
   * @notice Get buyPrice.
   */
  function getBuyPrice(bytes32 entityId) internal view returns (uint256 buyPrice) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get buyPrice.
   */
  function _getBuyPrice(bytes32 entityId) internal view returns (uint256 buyPrice) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set buyPrice.
   */
  function setBuyPrice(bytes32 entityId, uint256 buyPrice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((buyPrice)), _fieldLayout);
  }

  /**
   * @notice Set buyPrice.
   */
  function _setBuyPrice(bytes32 entityId, uint256 buyPrice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((buyPrice)), _fieldLayout);
  }

  /**
   * @notice Get sellPrice.
   */
  function getSellPrice(bytes32 entityId) internal view returns (uint256 sellPrice) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get sellPrice.
   */
  function _getSellPrice(bytes32 entityId) internal view returns (uint256 sellPrice) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set sellPrice.
   */
  function setSellPrice(bytes32 entityId, uint256 sellPrice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((sellPrice)), _fieldLayout);
  }

  /**
   * @notice Set sellPrice.
   */
  function _setSellPrice(bytes32 entityId, uint256 sellPrice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((sellPrice)), _fieldLayout);
  }

  /**
   * @notice Get paymentToken.
   */
  function getPaymentToken(bytes32 entityId) internal view returns (address paymentToken) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (address(bytes20(_blob)));
  }

  /**
   * @notice Get paymentToken.
   */
  function _getPaymentToken(bytes32 entityId) internal view returns (address paymentToken) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (address(bytes20(_blob)));
  }

  /**
   * @notice Set paymentToken.
   */
  function setPaymentToken(bytes32 entityId, address paymentToken) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((paymentToken)), _fieldLayout);
  }

  /**
   * @notice Set paymentToken.
   */
  function _setPaymentToken(bytes32 entityId, address paymentToken) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((paymentToken)), _fieldLayout);
  }

  /**
   * @notice Get balance.
   */
  function getBalance(bytes32 entityId) internal view returns (uint256 balance) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get balance.
   */
  function _getBalance(bytes32 entityId) internal view returns (uint256 balance) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set balance.
   */
  function setBalance(bytes32 entityId, uint256 balance) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((balance)), _fieldLayout);
  }

  /**
   * @notice Set balance.
   */
  function _setBalance(bytes32 entityId, uint256 balance) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((balance)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(bytes32 entityId) internal view returns (ShopData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

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
  function _get(bytes32 entityId) internal view returns (ShopData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

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
    bytes32 entityId,
    ShopType shopType,
    uint8 objectTypeId,
    uint256 buyPrice,
    uint256 sellPrice,
    address paymentToken,
    uint256 balance
  ) internal {
    bytes memory _staticData = encodeStatic(shopType, objectTypeId, buyPrice, sellPrice, paymentToken, balance);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    bytes32 entityId,
    ShopType shopType,
    uint8 objectTypeId,
    uint256 buyPrice,
    uint256 sellPrice,
    address paymentToken,
    uint256 balance
  ) internal {
    bytes memory _staticData = encodeStatic(shopType, objectTypeId, buyPrice, sellPrice, paymentToken, balance);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(bytes32 entityId, ShopData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.shopType,
      _table.objectTypeId,
      _table.buyPrice,
      _table.sellPrice,
      _table.paymentToken,
      _table.balance
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(bytes32 entityId, ShopData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.shopType,
      _table.objectTypeId,
      _table.buyPrice,
      _table.sellPrice,
      _table.paymentToken,
      _table.balance
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = entityId;

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
      ShopType shopType,
      uint8 objectTypeId,
      uint256 buyPrice,
      uint256 sellPrice,
      address paymentToken,
      uint256 balance
    )
  {
    shopType = ShopType(uint8(Bytes.getBytes1(_blob, 0)));

    objectTypeId = (uint8(Bytes.getBytes1(_blob, 1)));

    buyPrice = (uint256(Bytes.getBytes32(_blob, 2)));

    sellPrice = (uint256(Bytes.getBytes32(_blob, 34)));

    paymentToken = (address(Bytes.getBytes20(_blob, 66)));

    balance = (uint256(Bytes.getBytes32(_blob, 86)));
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
  ) internal pure returns (ShopData memory _table) {
    (
      _table.shopType,
      _table.objectTypeId,
      _table.buyPrice,
      _table.sellPrice,
      _table.paymentToken,
      _table.balance
    ) = decodeStatic(_staticData);
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
  function encodeStatic(
    ShopType shopType,
    uint8 objectTypeId,
    uint256 buyPrice,
    uint256 sellPrice,
    address paymentToken,
    uint256 balance
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(shopType, objectTypeId, buyPrice, sellPrice, paymentToken, balance);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    ShopType shopType,
    uint8 objectTypeId,
    uint256 buyPrice,
    uint256 sellPrice,
    address paymentToken,
    uint256 balance
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(shopType, objectTypeId, buyPrice, sellPrice, paymentToken, balance);

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
