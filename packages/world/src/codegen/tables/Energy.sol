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

struct EnergyData {
  uint128 lastUpdatedTime;
  uint128 energy;
  uint128 drainRate;
  uint128 accDepletedTime;
}

library Energy {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Energy", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x74620000000000000000000000000000456e6572677900000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0040040010101010000000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (bytes32)
  Schema constant _keySchema = Schema.wrap(0x002001005f000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint128, uint128, uint128, uint128)
  Schema constant _valueSchema = Schema.wrap(0x004004000f0f0f0f000000000000000000000000000000000000000000000000);

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
    fieldNames = new string[](4);
    fieldNames[0] = "lastUpdatedTime";
    fieldNames[1] = "energy";
    fieldNames[2] = "drainRate";
    fieldNames[3] = "accDepletedTime";
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
   * @notice Get lastUpdatedTime.
   */
  function getLastUpdatedTime(EntityId entityId) internal view returns (uint128 lastUpdatedTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get lastUpdatedTime.
   */
  function _getLastUpdatedTime(EntityId entityId) internal view returns (uint128 lastUpdatedTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set lastUpdatedTime.
   */
  function setLastUpdatedTime(EntityId entityId, uint128 lastUpdatedTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastUpdatedTime)), _fieldLayout);
  }

  /**
   * @notice Set lastUpdatedTime.
   */
  function _setLastUpdatedTime(EntityId entityId, uint128 lastUpdatedTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lastUpdatedTime)), _fieldLayout);
  }

  /**
   * @notice Get energy.
   */
  function getEnergy(EntityId entityId) internal view returns (uint128 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get energy.
   */
  function _getEnergy(EntityId entityId) internal view returns (uint128 energy) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set energy.
   */
  function setEnergy(EntityId entityId, uint128 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Set energy.
   */
  function _setEnergy(EntityId entityId, uint128 energy) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((energy)), _fieldLayout);
  }

  /**
   * @notice Get drainRate.
   */
  function getDrainRate(EntityId entityId) internal view returns (uint128 drainRate) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get drainRate.
   */
  function _getDrainRate(EntityId entityId) internal view returns (uint128 drainRate) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set drainRate.
   */
  function setDrainRate(EntityId entityId, uint128 drainRate) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((drainRate)), _fieldLayout);
  }

  /**
   * @notice Set drainRate.
   */
  function _setDrainRate(EntityId entityId, uint128 drainRate) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((drainRate)), _fieldLayout);
  }

  /**
   * @notice Get accDepletedTime.
   */
  function getAccDepletedTime(EntityId entityId) internal view returns (uint128 accDepletedTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Get accDepletedTime.
   */
  function _getAccDepletedTime(EntityId entityId) internal view returns (uint128 accDepletedTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint128(bytes16(_blob)));
  }

  /**
   * @notice Set accDepletedTime.
   */
  function setAccDepletedTime(EntityId entityId, uint128 accDepletedTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((accDepletedTime)), _fieldLayout);
  }

  /**
   * @notice Set accDepletedTime.
   */
  function _setAccDepletedTime(EntityId entityId, uint128 accDepletedTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((accDepletedTime)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(EntityId entityId) internal view returns (EnergyData memory _table) {
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
  function _get(EntityId entityId) internal view returns (EnergyData memory _table) {
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
  function set(
    EntityId entityId,
    uint128 lastUpdatedTime,
    uint128 energy,
    uint128 drainRate,
    uint128 accDepletedTime
  ) internal {
    bytes memory _staticData = encodeStatic(lastUpdatedTime, energy, drainRate, accDepletedTime);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    EntityId entityId,
    uint128 lastUpdatedTime,
    uint128 energy,
    uint128 drainRate,
    uint128 accDepletedTime
  ) internal {
    bytes memory _staticData = encodeStatic(lastUpdatedTime, energy, drainRate, accDepletedTime);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(EntityId entityId, EnergyData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.lastUpdatedTime,
      _table.energy,
      _table.drainRate,
      _table.accDepletedTime
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = EntityId.unwrap(entityId);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(EntityId entityId, EnergyData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.lastUpdatedTime,
      _table.energy,
      _table.drainRate,
      _table.accDepletedTime
    );

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
  ) internal pure returns (uint128 lastUpdatedTime, uint128 energy, uint128 drainRate, uint128 accDepletedTime) {
    lastUpdatedTime = (uint128(Bytes.getBytes16(_blob, 0)));

    energy = (uint128(Bytes.getBytes16(_blob, 16)));

    drainRate = (uint128(Bytes.getBytes16(_blob, 32)));

    accDepletedTime = (uint128(Bytes.getBytes16(_blob, 48)));
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
  ) internal pure returns (EnergyData memory _table) {
    (_table.lastUpdatedTime, _table.energy, _table.drainRate, _table.accDepletedTime) = decodeStatic(_staticData);
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
    uint128 lastUpdatedTime,
    uint128 energy,
    uint128 drainRate,
    uint128 accDepletedTime
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(lastUpdatedTime, energy, drainRate, accDepletedTime);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    uint128 lastUpdatedTime,
    uint128 energy,
    uint128 drainRate,
    uint128 accDepletedTime
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(lastUpdatedTime, energy, drainRate, accDepletedTime);

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
