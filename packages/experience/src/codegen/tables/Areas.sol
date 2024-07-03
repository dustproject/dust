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

struct AreasData {
  int16 lowerSouthwestCornerX;
  int16 lowerSouthwestCornerY;
  int16 lowerSouthwestCornerZ;
  int16 sizeX;
  int16 sizeY;
  int16 sizeZ;
  string name;
}

library Areas {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "experience", name: "Areas", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462657870657269656e63650000000041726561730000000000000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x000c060102020202020200000000000000000000000000000000000000000000);

  // Hex-encoded key schema of (address, bytes32)
  Schema constant _keySchema = Schema.wrap(0x00340200615f0000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (int16, int16, int16, int16, int16, int16, string)
  Schema constant _valueSchema = Schema.wrap(0x000c0601212121212121c5000000000000000000000000000000000000000000);

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "experience";
    keyNames[1] = "id";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](7);
    fieldNames[0] = "lowerSouthwestCornerX";
    fieldNames[1] = "lowerSouthwestCornerY";
    fieldNames[2] = "lowerSouthwestCornerZ";
    fieldNames[3] = "sizeX";
    fieldNames[4] = "sizeY";
    fieldNames[5] = "sizeZ";
    fieldNames[6] = "name";
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
   * @notice Get lowerSouthwestCornerX.
   */
  function getLowerSouthwestCornerX(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerX.
   */
  function _getLowerSouthwestCornerX(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerX (using the specified store).
   */
  function getLowerSouthwestCornerX(
    IStore _store,
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set lowerSouthwestCornerX.
   */
  function setLowerSouthwestCornerX(address experience, bytes32 id, int16 lowerSouthwestCornerX) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lowerSouthwestCornerX)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerX.
   */
  function _setLowerSouthwestCornerX(address experience, bytes32 id, int16 lowerSouthwestCornerX) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lowerSouthwestCornerX)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerX (using the specified store).
   */
  function setLowerSouthwestCornerX(
    IStore _store,
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerX
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((lowerSouthwestCornerX)), _fieldLayout);
  }

  /**
   * @notice Get lowerSouthwestCornerY.
   */
  function getLowerSouthwestCornerY(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerY.
   */
  function _getLowerSouthwestCornerY(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerY (using the specified store).
   */
  function getLowerSouthwestCornerY(
    IStore _store,
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set lowerSouthwestCornerY.
   */
  function setLowerSouthwestCornerY(address experience, bytes32 id, int16 lowerSouthwestCornerY) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((lowerSouthwestCornerY)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerY.
   */
  function _setLowerSouthwestCornerY(address experience, bytes32 id, int16 lowerSouthwestCornerY) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((lowerSouthwestCornerY)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerY (using the specified store).
   */
  function setLowerSouthwestCornerY(
    IStore _store,
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerY
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((lowerSouthwestCornerY)), _fieldLayout);
  }

  /**
   * @notice Get lowerSouthwestCornerZ.
   */
  function getLowerSouthwestCornerZ(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerZ.
   */
  function _getLowerSouthwestCornerZ(
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get lowerSouthwestCornerZ (using the specified store).
   */
  function getLowerSouthwestCornerZ(
    IStore _store,
    address experience,
    bytes32 id
  ) internal view returns (int16 lowerSouthwestCornerZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set lowerSouthwestCornerZ.
   */
  function setLowerSouthwestCornerZ(address experience, bytes32 id, int16 lowerSouthwestCornerZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((lowerSouthwestCornerZ)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerZ.
   */
  function _setLowerSouthwestCornerZ(address experience, bytes32 id, int16 lowerSouthwestCornerZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((lowerSouthwestCornerZ)), _fieldLayout);
  }

  /**
   * @notice Set lowerSouthwestCornerZ (using the specified store).
   */
  function setLowerSouthwestCornerZ(
    IStore _store,
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerZ
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((lowerSouthwestCornerZ)), _fieldLayout);
  }

  /**
   * @notice Get sizeX.
   */
  function getSizeX(address experience, bytes32 id) internal view returns (int16 sizeX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeX.
   */
  function _getSizeX(address experience, bytes32 id) internal view returns (int16 sizeX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeX (using the specified store).
   */
  function getSizeX(IStore _store, address experience, bytes32 id) internal view returns (int16 sizeX) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set sizeX.
   */
  function setSizeX(address experience, bytes32 id, int16 sizeX) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((sizeX)), _fieldLayout);
  }

  /**
   * @notice Set sizeX.
   */
  function _setSizeX(address experience, bytes32 id, int16 sizeX) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((sizeX)), _fieldLayout);
  }

  /**
   * @notice Set sizeX (using the specified store).
   */
  function setSizeX(IStore _store, address experience, bytes32 id, int16 sizeX) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((sizeX)), _fieldLayout);
  }

  /**
   * @notice Get sizeY.
   */
  function getSizeY(address experience, bytes32 id) internal view returns (int16 sizeY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeY.
   */
  function _getSizeY(address experience, bytes32 id) internal view returns (int16 sizeY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeY (using the specified store).
   */
  function getSizeY(IStore _store, address experience, bytes32 id) internal view returns (int16 sizeY) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set sizeY.
   */
  function setSizeY(address experience, bytes32 id, int16 sizeY) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((sizeY)), _fieldLayout);
  }

  /**
   * @notice Set sizeY.
   */
  function _setSizeY(address experience, bytes32 id, int16 sizeY) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((sizeY)), _fieldLayout);
  }

  /**
   * @notice Set sizeY (using the specified store).
   */
  function setSizeY(IStore _store, address experience, bytes32 id, int16 sizeY) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((sizeY)), _fieldLayout);
  }

  /**
   * @notice Get sizeZ.
   */
  function getSizeZ(address experience, bytes32 id) internal view returns (int16 sizeZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeZ.
   */
  function _getSizeZ(address experience, bytes32 id) internal view returns (int16 sizeZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Get sizeZ (using the specified store).
   */
  function getSizeZ(IStore _store, address experience, bytes32 id) internal view returns (int16 sizeZ) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes32 _blob = _store.getStaticField(_tableId, _keyTuple, 5, _fieldLayout);
    return (int16(uint16(bytes2(_blob))));
  }

  /**
   * @notice Set sizeZ.
   */
  function setSizeZ(address experience, bytes32 id, int16 sizeZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((sizeZ)), _fieldLayout);
  }

  /**
   * @notice Set sizeZ.
   */
  function _setSizeZ(address experience, bytes32 id, int16 sizeZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((sizeZ)), _fieldLayout);
  }

  /**
   * @notice Set sizeZ (using the specified store).
   */
  function setSizeZ(IStore _store, address experience, bytes32 id, int16 sizeZ) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setStaticField(_tableId, _keyTuple, 5, abi.encodePacked((sizeZ)), _fieldLayout);
  }

  /**
   * @notice Get name.
   */
  function getName(address experience, bytes32 id) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (string(_blob));
  }

  /**
   * @notice Get name.
   */
  function _getName(address experience, bytes32 id) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (string(_blob));
  }

  /**
   * @notice Get name (using the specified store).
   */
  function getName(IStore _store, address experience, bytes32 id) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    bytes memory _blob = _store.getDynamicField(_tableId, _keyTuple, 0);
    return (string(_blob));
  }

  /**
   * @notice Set name.
   */
  function setName(address experience, bytes32 id, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, bytes((name)));
  }

  /**
   * @notice Set name.
   */
  function _setName(address experience, bytes32 id, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, bytes((name)));
  }

  /**
   * @notice Set name (using the specified store).
   */
  function setName(IStore _store, address experience, bytes32 id, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setDynamicField(_tableId, _keyTuple, 0, bytes((name)));
  }

  /**
   * @notice Get the length of name.
   */
  function lengthName(address experience, bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get the length of name.
   */
  function _lengthName(address experience, bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get the length of name (using the specified store).
   */
  function lengthName(IStore _store, address experience, bytes32 id) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    uint256 _byteLength = _store.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * @notice Get an item of name.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemName(address experience, bytes32 id, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /**
   * @notice Get an item of name.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemName(address experience, bytes32 id, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /**
   * @notice Get an item of name (using the specified store).
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemName(
    IStore _store,
    address experience,
    bytes32 id,
    uint256 _index
  ) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _blob = _store.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 1, (_index + 1) * 1);
      return (string(_blob));
    }
  }

  /**
   * @notice Push a slice to name.
   */
  function pushName(address experience, bytes32 id, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, bytes((_slice)));
  }

  /**
   * @notice Push a slice to name.
   */
  function _pushName(address experience, bytes32 id, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, bytes((_slice)));
  }

  /**
   * @notice Push a slice to name (using the specified store).
   */
  function pushName(IStore _store, address experience, bytes32 id, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.pushToDynamicField(_tableId, _keyTuple, 0, bytes((_slice)));
  }

  /**
   * @notice Pop a slice from name.
   */
  function popName(address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 1);
  }

  /**
   * @notice Pop a slice from name.
   */
  function _popName(address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 1);
  }

  /**
   * @notice Pop a slice from name (using the specified store).
   */
  function popName(IStore _store, address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.popFromDynamicField(_tableId, _keyTuple, 0, 1);
  }

  /**
   * @notice Update a slice of name at `_index`.
   */
  function updateName(address experience, bytes32 id, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _encoded = bytes((_slice));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update a slice of name at `_index`.
   */
  function _updateName(address experience, bytes32 id, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _encoded = bytes((_slice));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update a slice of name (using the specified store) at `_index`.
   */
  function updateName(IStore _store, address experience, bytes32 id, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    unchecked {
      bytes memory _encoded = bytes((_slice));
      _store.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 1), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get the full data.
   */
  function get(address experience, bytes32 id) internal view returns (AreasData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

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
  function _get(address experience, bytes32 id) internal view returns (AreasData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data (using the specified store).
   */
  function get(IStore _store, address experience, bytes32 id) internal view returns (AreasData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = _store.getRecord(
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
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerX,
    int16 lowerSouthwestCornerY,
    int16 lowerSouthwestCornerZ,
    int16 sizeX,
    int16 sizeY,
    int16 sizeZ,
    string memory name
  ) internal {
    bytes memory _staticData = encodeStatic(
      lowerSouthwestCornerX,
      lowerSouthwestCornerY,
      lowerSouthwestCornerZ,
      sizeX,
      sizeY,
      sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(name);
    bytes memory _dynamicData = encodeDynamic(name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerX,
    int16 lowerSouthwestCornerY,
    int16 lowerSouthwestCornerZ,
    int16 sizeX,
    int16 sizeY,
    int16 sizeZ,
    string memory name
  ) internal {
    bytes memory _staticData = encodeStatic(
      lowerSouthwestCornerX,
      lowerSouthwestCornerY,
      lowerSouthwestCornerZ,
      sizeX,
      sizeY,
      sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(name);
    bytes memory _dynamicData = encodeDynamic(name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using individual values (using the specified store).
   */
  function set(
    IStore _store,
    address experience,
    bytes32 id,
    int16 lowerSouthwestCornerX,
    int16 lowerSouthwestCornerY,
    int16 lowerSouthwestCornerZ,
    int16 sizeX,
    int16 sizeY,
    int16 sizeZ,
    string memory name
  ) internal {
    bytes memory _staticData = encodeStatic(
      lowerSouthwestCornerX,
      lowerSouthwestCornerY,
      lowerSouthwestCornerZ,
      sizeX,
      sizeY,
      sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(name);
    bytes memory _dynamicData = encodeDynamic(name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(address experience, bytes32 id, AreasData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.lowerSouthwestCornerX,
      _table.lowerSouthwestCornerY,
      _table.lowerSouthwestCornerZ,
      _table.sizeX,
      _table.sizeY,
      _table.sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(_table.name);
    bytes memory _dynamicData = encodeDynamic(_table.name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(address experience, bytes32 id, AreasData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.lowerSouthwestCornerX,
      _table.lowerSouthwestCornerY,
      _table.lowerSouthwestCornerZ,
      _table.sizeX,
      _table.sizeY,
      _table.sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(_table.name);
    bytes memory _dynamicData = encodeDynamic(_table.name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct (using the specified store).
   */
  function set(IStore _store, address experience, bytes32 id, AreasData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.lowerSouthwestCornerX,
      _table.lowerSouthwestCornerY,
      _table.lowerSouthwestCornerZ,
      _table.sizeX,
      _table.sizeY,
      _table.sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(_table.name);
    bytes memory _dynamicData = encodeDynamic(_table.name);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
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
      int16 lowerSouthwestCornerX,
      int16 lowerSouthwestCornerY,
      int16 lowerSouthwestCornerZ,
      int16 sizeX,
      int16 sizeY,
      int16 sizeZ
    )
  {
    lowerSouthwestCornerX = (int16(uint16(Bytes.getBytes2(_blob, 0))));

    lowerSouthwestCornerY = (int16(uint16(Bytes.getBytes2(_blob, 2))));

    lowerSouthwestCornerZ = (int16(uint16(Bytes.getBytes2(_blob, 4))));

    sizeX = (int16(uint16(Bytes.getBytes2(_blob, 6))));

    sizeY = (int16(uint16(Bytes.getBytes2(_blob, 8))));

    sizeZ = (int16(uint16(Bytes.getBytes2(_blob, 10))));
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    EncodedLengths _encodedLengths,
    bytes memory _blob
  ) internal pure returns (string memory name) {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
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
  ) internal pure returns (AreasData memory _table) {
    (
      _table.lowerSouthwestCornerX,
      _table.lowerSouthwestCornerY,
      _table.lowerSouthwestCornerZ,
      _table.sizeX,
      _table.sizeY,
      _table.sizeZ
    ) = decodeStatic(_staticData);

    (_table.name) = decodeDynamic(_encodedLengths, _dynamicData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys (using the specified store).
   */
  function deleteRecord(IStore _store, address experience, bytes32 id) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    _store.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    int16 lowerSouthwestCornerX,
    int16 lowerSouthwestCornerY,
    int16 lowerSouthwestCornerZ,
    int16 sizeX,
    int16 sizeY,
    int16 sizeZ
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(lowerSouthwestCornerX, lowerSouthwestCornerY, lowerSouthwestCornerZ, sizeX, sizeY, sizeZ);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(string memory name) internal pure returns (EncodedLengths _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = EncodedLengthsLib.pack(bytes(name).length);
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(string memory name) internal pure returns (bytes memory) {
    return abi.encodePacked(bytes((name)));
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    int16 lowerSouthwestCornerX,
    int16 lowerSouthwestCornerY,
    int16 lowerSouthwestCornerZ,
    int16 sizeX,
    int16 sizeY,
    int16 sizeZ,
    string memory name
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(
      lowerSouthwestCornerX,
      lowerSouthwestCornerY,
      lowerSouthwestCornerZ,
      sizeX,
      sizeY,
      sizeZ
    );

    EncodedLengths _encodedLengths = encodeLengths(name);
    bytes memory _dynamicData = encodeDynamic(name);

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(address experience, bytes32 id) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(experience)));
    _keyTuple[1] = id;

    return _keyTuple;
  }
}
