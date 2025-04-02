// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Direction } from "./codegen/common.sol";
import { MinedOreCount } from "./codegen/tables/MinedOreCount.sol";
import { TotalBurnedOreCount } from "./codegen/tables/TotalBurnedOreCount.sol";

import { IMachineSystem } from "./codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "./codegen/world/ITransferSystem.sol";

import { ObjectTypeId } from "./ObjectTypeId.sol";
import { Block, CATEGORY_MASK, Item, Misc, ObjectTypes, Tool } from "./ObjectTypes.sol";
import { Vec3, vec3 } from "./Vec3.sol";

struct ObjectAmount {
  ObjectTypeId objectTypeId;
  uint16 amount;
}

struct TreeData {
  ObjectTypeId logType;
  ObjectTypeId leafType;
  uint32 trunkHeight;
  uint32 canopyStart;
  uint32 canopyEnd;
  uint32 canopyWidth;
  uint32 stretchFactor;
  int32 centerOffset;
}

library ObjectTypeLib {
  function unwrap(ObjectTypeId self) internal pure returns (uint16) {
    return ObjectTypeId.unwrap(self);
  }

  function getObjectTypeSchema(ObjectTypeId objectTypeId) internal pure returns (Vec3[] memory) {
    if (objectTypeId == ObjectTypes.Player) {
      Vec3[] memory playerRelativePositions = new Vec3[](1);
      playerRelativePositions[0] = vec3(0, 1, 0);
      return playerRelativePositions;
    }

    if (objectTypeId == ObjectTypes.Bed) {
      Vec3[] memory bedRelativePositions = new Vec3[](1);
      bedRelativePositions[0] = vec3(0, 0, 1);
      return bedRelativePositions;
    }

    if (objectTypeId == ObjectTypes.TextSign || objectTypeId == ObjectTypes.SmartTextSign) {
      Vec3[] memory textSignRelativePositions = new Vec3[](1);
      textSignRelativePositions[0] = vec3(0, 1, 0);
      return textSignRelativePositions;
    }

    return new Vec3[](0);
  }

  /// @dev Get relative schema coords, including base coord
  function getRelativeCoords(ObjectTypeId self, Vec3 baseCoord, Direction direction)
    internal
    pure
    returns (Vec3[] memory)
  {
    Vec3[] memory schemaCoords = getObjectTypeSchema(self);
    Vec3[] memory coords = new Vec3[](schemaCoords.length + 1);

    coords[0] = baseCoord;

    for (uint256 i = 0; i < schemaCoords.length; i++) {
      coords[i + 1] = baseCoord + schemaCoords[i].rotate(direction);
    }

    return coords;
  }

  function getRelativeCoords(ObjectTypeId objectTypeId, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(objectTypeId, baseCoord, Direction.PositiveZ);
  }

  function getCategory(ObjectTypeId self) internal pure returns (uint16) {
    return ObjectTypeId.unwrap(self) & CATEGORY_MASK;
  }

  function isBlock(ObjectTypeId id) internal pure returns (bool) {
    return !id.isNull() && id.getCategory() == Block;
  }

  function isMineable(ObjectTypeId self) internal pure returns (bool) {
    return self.isBlock() && self != ObjectTypes.Air && self != ObjectTypes.Water && self != ObjectTypes.Lava;
  }

  function isTool(ObjectTypeId id) internal pure returns (bool) {
    return id.getCategory() == Tool;
  }

  function isItem(ObjectTypeId id) internal pure returns (bool) {
    return id.getCategory() == Item;
  }

  function isNull(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.Null;
  }

  function isAny(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.AnyLog || self == ObjectTypes.AnyPlanks;
  }

  function isWhacker(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.WoodenWhacker || objectTypeId == ObjectTypes.StoneWhacker
      || objectTypeId == ObjectTypes.SilverWhacker;
  }

  function isHoe(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.WoodenHoe;
  }

  function isMachine(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.ForceField;
  }

  function canHoldDisplay(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.TextSign || objectTypeId == ObjectTypes.SmartTextSign;
  }

  function isSmartDisplay(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.SmartTextSign;
  }

  function isFood(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId.isCrop();
  }

  function isSeed(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return isCropSeed(objectTypeId) || isTreeSeed(objectTypeId);
  }

  function isCropSeed(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.WheatSeed;
  }

  function isTreeSeed(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.OakSeed || objectTypeId == ObjectTypes.SpruceSeed;
  }

  function isCrop(ObjectTypeId objectTypeId) internal pure returns (bool) {
    return objectTypeId == ObjectTypes.Wheat;
  }

  // TODO: one possible way to optimize is to follow some kind of schema for crops and their seeds
  function getCrop(ObjectTypeId objectTypeId) internal pure returns (ObjectTypeId) {
    if (objectTypeId == ObjectTypes.WheatSeed) {
      return ObjectTypes.Wheat;
    }

    revert("Invalid crop seed type");
  }

  function getTreeData(ObjectTypeId seedTypeId) internal pure returns (TreeData memory) {
    if (seedTypeId == ObjectTypes.OakSeed) {
      return TreeData({
        logType: ObjectTypes.OakLog,
        leafType: ObjectTypes.OakLeaf,
        trunkHeight: 5,
        canopyStart: 3,
        canopyEnd: 7,
        canopyWidth: 2,
        stretchFactor: 2,
        centerOffset: -2
      });
    } else if (seedTypeId == ObjectTypes.SpruceSeed) {
      return TreeData({
        logType: ObjectTypes.SpruceLog,
        leafType: ObjectTypes.SpruceLeaf,
        trunkHeight: 7,
        canopyStart: 2,
        canopyEnd: 10,
        canopyWidth: 2,
        stretchFactor: 3,
        centerOffset: -5
      });
    }

    revert("Invalid tree seed type");
  }

  // TODO: one possible way to optimize is to follow some kind of schema for crops and their seeds
  function getSeedDrop(ObjectTypeId objectTypeId) internal pure returns (ObjectTypeId) {
    if (objectTypeId == ObjectTypes.Wheat) {
      return ObjectTypes.WheatSeed;
    }

    return ObjectTypes.Null;
  }

  function getMineDrop(ObjectTypeId objectTypeId) internal pure returns (ObjectAmount[] memory amounts) {
    // TODO: figure out conservation of fescue grass (no way to regenerate yet)
    if (objectTypeId == ObjectTypes.FescueGrass) {
      // TODO: add randomness?
      amounts = new ObjectAmount[](1);
      amounts[0] = ObjectAmount(ObjectTypes.WheatSeed, 1);
      return amounts;
    }

    if (objectTypeId == ObjectTypes.Farmland || objectTypeId == ObjectTypes.WetFarmland) {
      amounts = new ObjectAmount[](1);
      amounts[0] = ObjectAmount(ObjectTypes.Dirt, 1);
      return amounts;
    }

    ObjectTypeId seedTypeId = objectTypeId.getSeedDrop();
    if (seedTypeId != ObjectTypes.Null) {
      amounts = new ObjectAmount[](2);
      amounts[0] = ObjectAmount(objectTypeId, 1);
      amounts[1] = ObjectAmount(seedTypeId, 1);
      return amounts;
    }

    amounts = new ObjectAmount[](1);
    amounts[0] = ObjectAmount(objectTypeId, 1);
    return amounts;
  }

  function timeToGrow(ObjectTypeId objectTypeId) internal pure returns (uint128) {
    if (objectTypeId == ObjectTypes.WheatSeed) {
      return 15 minutes;
    }

    if (objectTypeId == ObjectTypes.OakSeed || objectTypeId == ObjectTypes.SpruceSeed) {
      return 5760 minutes;
    }

    return 0;
  }

  function getObjectTypes(ObjectTypeId self) internal pure returns (ObjectTypeId[] memory) {
    if (self == ObjectTypes.AnyLog) {
      return getLogObjectTypes();
    }

    if (self == ObjectTypes.AnyPlanks) {
      return getPlanksObjectTypes();
    }

    // Return empty array for non-Any types
    return new ObjectTypeId[](0);
  }

  /// @dev Get ore amounts that should be burned when this object is burned
  /// Currently it only supports tools, and assumes that only a single type of ore is used
  function getOreAmount(ObjectTypeId self) internal pure returns (ObjectAmount memory) {
    // Silver tools
    if (self == ObjectTypes.SilverPick || self == ObjectTypes.SilverAxe) {
      return ObjectAmount(ObjectTypes.SilverOre, 4); // 4 silver bars = 4 ores
    }
    if (self == ObjectTypes.SilverWhacker) {
      return ObjectAmount(ObjectTypes.SilverOre, 6); // 6 silver bars = 6 ores
    }

    // Gold tools
    if (self == ObjectTypes.GoldPick || self == ObjectTypes.GoldAxe) {
      return ObjectAmount(ObjectTypes.GoldOre, 4); // 4 gold bars = 4 ores
    }

    // Diamond tools
    if (self == ObjectTypes.DiamondPick || self == ObjectTypes.DiamondAxe) {
      return ObjectAmount(ObjectTypes.DiamondOre, 4); // 4 diamonds
    }

    // Neptunium tools
    if (self == ObjectTypes.NeptuniumPick || self == ObjectTypes.NeptuniumAxe) {
      return ObjectAmount(ObjectTypes.NeptuniumOre, 4); // 4 neptunium bars = 4 ores
    }

    // Return zero amount for any other tool
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function burnOres(ObjectTypeId self) internal {
    ObjectAmount memory ores = self.getOreAmount();
    ObjectTypeId objectTypeId = ores.objectTypeId;
    if (!objectTypeId.isNull()) {
      uint256 amount = ores.amount;
      // This increases the availability of the ores being burned
      MinedOreCount._set(objectTypeId, MinedOreCount._get(objectTypeId) - amount);
      // This allows the same amount of ores to respawn
      TotalBurnedOreCount._set(TotalBurnedOreCount._get() + amount);
    }
  }

  function isMovable(ObjectTypeId self) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    // TODO: support other movable entities
    return false;
  }

  function isActionAllowed(ObjectTypeId self, bytes4 sig) internal pure returns (bool) {
    if (self == ObjectTypes.Player) {
      return true;
    }

    if (self == ObjectTypes.SmartChest) {
      return sig == ITransferSystem.transfer.selector || sig == ITransferSystem.transferTool.selector
        || sig == ITransferSystem.transferTools.selector || sig == IMachineSystem.fuelMachine.selector;
    }

    return false;
  }
}

function getLogObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](7);
  result[0] = ObjectTypes.OakLog;
  result[1] = ObjectTypes.BirchLog;
  result[2] = ObjectTypes.JungleLog;
  result[3] = ObjectTypes.SakuraLog;
  result[4] = ObjectTypes.AcaciaLog;
  result[5] = ObjectTypes.SpruceLog;
  result[6] = ObjectTypes.DarkOakLog;
  return result;
}

function getPlanksObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](7);
  result[0] = ObjectTypes.OakPlanks;
  result[1] = ObjectTypes.BirchPlanks;
  result[2] = ObjectTypes.JunglePlanks;
  result[3] = ObjectTypes.SakuraPlanks;
  result[4] = ObjectTypes.SprucePlanks;
  result[5] = ObjectTypes.AcaciaPlanks;
  result[6] = ObjectTypes.DarkOakPlanks;
  return result;
}

function getOreObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](5);
  result[0] = ObjectTypes.CoalOre;
  result[1] = ObjectTypes.SilverOre;
  result[2] = ObjectTypes.GoldOre;
  result[3] = ObjectTypes.DiamondOre;
  result[4] = ObjectTypes.NeptuniumOre;
  return result;
}

using ObjectTypeLib for ObjectTypeId;
