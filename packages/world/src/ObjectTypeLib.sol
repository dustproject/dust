// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Direction } from "./codegen/common.sol";

import { BurnedResourceCount } from "./codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "./codegen/tables/ResourceCount.sol";

import { IMachineSystem } from "./codegen/world/IMachineSystem.sol";
import { ITransferSystem } from "./codegen/world/ITransferSystem.sol";

import { ObjectTypeId } from "./ObjectTypeId.sol";
import { Block, CATEGORY_MASK, Item, Misc, ObjectTypes, Tool } from "./ObjectTypes.sol";

import { Vec3, vec3 } from "./Vec3.sol";

import { isCropSeed as _isCropSeed, isFood as _isFood, isTreeSeed as _isTreeSeed } from "./ObjectTypeFlags.sol";
import { timeToGrow as _timeToGrow } from "./timeToGrow.sol";

struct ObjectAmount {
  ObjectTypeId objectTypeId;
  uint16 amount;
}

library ObjectTypeLib {
  function unwrap(ObjectTypeId self) internal pure returns (uint16) {
    return ObjectTypeId.unwrap(self);
  }

  function getObjectTypeSchema(ObjectTypeId self) internal pure returns (Vec3[] memory) {
    if (self == ObjectTypes.Player) {
      Vec3[] memory relativePositions = new Vec3[](1);
      relativePositions[0] = vec3(0, 1, 0);
      return relativePositions;
    }

    if (self == ObjectTypes.Bed) {
      Vec3[] memory relativePositions = new Vec3[](1);
      relativePositions[0] = vec3(0, 0, 1);
      return relativePositions;
    }

    if (self == ObjectTypes.TextSign) {
      Vec3[] memory relativePositions = new Vec3[](1);
      relativePositions[0] = vec3(0, 1, 0);
      return relativePositions;
    }

    if (self == ObjectTypes.Workbench) {
      Vec3[] memory relativePositions = new Vec3[](2);
      relativePositions[0] = vec3(0, 0, 1);
      relativePositions[1] = vec3(0, 0, 2);
      return relativePositions;
    }

    if (self == ObjectTypes.Furnace) {
      // 3x3x3
      Vec3[] memory relativePositions = new Vec3[](26);
      relativePositions[0] = vec3(0, 0, 1);
      relativePositions[1] = vec3(0, 0, 2);
      relativePositions[2] = vec3(1, 0, 0);
      relativePositions[3] = vec3(1, 0, 1);
      relativePositions[4] = vec3(1, 0, 2);
      relativePositions[5] = vec3(2, 0, 0);
      relativePositions[6] = vec3(2, 0, 1);
      relativePositions[7] = vec3(2, 0, 2);
      relativePositions[8] = vec3(0, 1, 0);
      relativePositions[9] = vec3(0, 1, 1);
      relativePositions[10] = vec3(0, 1, 2);
      relativePositions[11] = vec3(1, 1, 0);
      relativePositions[12] = vec3(1, 1, 1);
      relativePositions[13] = vec3(1, 1, 2);
      relativePositions[14] = vec3(2, 1, 0);
      relativePositions[15] = vec3(2, 1, 1);
      relativePositions[16] = vec3(2, 1, 2);
      relativePositions[17] = vec3(0, 2, 0);
      relativePositions[18] = vec3(0, 2, 1);
      relativePositions[19] = vec3(0, 2, 2);
      relativePositions[20] = vec3(1, 2, 0);
      relativePositions[21] = vec3(1, 2, 1);
      relativePositions[22] = vec3(1, 2, 2);
      relativePositions[23] = vec3(2, 2, 0);
      relativePositions[24] = vec3(2, 2, 1);
      relativePositions[25] = vec3(2, 2, 2);

      return relativePositions;
    }

    if (self == ObjectTypes.ForceField) {
      // 3x6x3
      Vec3[] memory relativePositions = new Vec3[](53);
      relativePositions[0] = vec3(0, 0, 1);
      relativePositions[1] = vec3(0, 0, 2);
      relativePositions[2] = vec3(1, 0, 0);
      relativePositions[3] = vec3(1, 0, 1);
      relativePositions[4] = vec3(1, 0, 2);
      relativePositions[5] = vec3(2, 0, 0);
      relativePositions[6] = vec3(2, 0, 1);
      relativePositions[7] = vec3(2, 0, 2);
      relativePositions[8] = vec3(0, 1, 0);
      relativePositions[9] = vec3(0, 1, 1);
      relativePositions[10] = vec3(0, 1, 2);
      relativePositions[11] = vec3(1, 1, 0);
      relativePositions[12] = vec3(1, 1, 1);
      relativePositions[13] = vec3(1, 1, 2);
      relativePositions[14] = vec3(2, 1, 0);
      relativePositions[15] = vec3(2, 1, 1);
      relativePositions[16] = vec3(2, 1, 2);
      relativePositions[17] = vec3(0, 2, 0);
      relativePositions[18] = vec3(0, 2, 1);
      relativePositions[19] = vec3(0, 2, 2);
      relativePositions[20] = vec3(1, 2, 0);
      relativePositions[21] = vec3(1, 2, 1);
      relativePositions[22] = vec3(1, 2, 2);
      relativePositions[23] = vec3(2, 2, 0);
      relativePositions[24] = vec3(2, 2, 1);
      relativePositions[25] = vec3(2, 2, 2);
      relativePositions[26] = vec3(0, 3, 0);
      relativePositions[27] = vec3(0, 3, 1);
      relativePositions[28] = vec3(0, 3, 2);
      relativePositions[29] = vec3(1, 3, 0);
      relativePositions[30] = vec3(1, 3, 1);
      relativePositions[31] = vec3(1, 3, 2);
      relativePositions[32] = vec3(2, 3, 0);
      relativePositions[33] = vec3(2, 3, 1);
      relativePositions[34] = vec3(2, 3, 2);
      relativePositions[35] = vec3(0, 4, 0);
      relativePositions[36] = vec3(0, 4, 1);
      relativePositions[37] = vec3(0, 4, 2);
      relativePositions[38] = vec3(1, 4, 0);
      relativePositions[39] = vec3(1, 4, 1);
      relativePositions[40] = vec3(1, 4, 2);
      relativePositions[41] = vec3(2, 4, 0);
      relativePositions[42] = vec3(2, 4, 1);
      relativePositions[43] = vec3(2, 4, 2);
      relativePositions[44] = vec3(0, 5, 0);
      relativePositions[45] = vec3(0, 5, 1);
      relativePositions[46] = vec3(0, 5, 2);
      relativePositions[47] = vec3(1, 5, 0);
      relativePositions[48] = vec3(1, 5, 1);
      relativePositions[49] = vec3(1, 5, 2);
      relativePositions[50] = vec3(2, 5, 0);
      relativePositions[51] = vec3(2, 5, 1);
      relativePositions[52] = vec3(2, 5, 2);

      return relativePositions;
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
      require(isDirectionSupported(self, direction), "Direction not supported");
      coords[i + 1] = baseCoord + schemaCoords[i].rotate(direction);
    }

    return coords;
  }

  function isDirectionSupported(ObjectTypeId self, Direction direction) internal pure returns (bool) {
    if (self == ObjectTypes.Bed) {
      // Note: before supporting more directions, we need to ensure clients can render it
      return direction == Direction.NegativeX || direction == Direction.NegativeZ;
    }

    return true;
  }

  function getRelativeCoords(ObjectTypeId self, Vec3 baseCoord) internal pure returns (Vec3[] memory) {
    return getRelativeCoords(self, baseCoord, Direction.PositiveZ);
  }

  function getCategory(ObjectTypeId self) internal pure returns (uint16) {
    return ObjectTypeId.unwrap(self) & CATEGORY_MASK;
  }

  function isBlock(ObjectTypeId self) internal pure returns (bool) {
    return !self.isNull() && self.getCategory() == Block;
  }

  function isMineable(ObjectTypeId self) internal pure returns (bool) {
    return self.isBlock() && self != ObjectTypes.Air && self != ObjectTypes.Water && self != ObjectTypes.Lava;
  }

  function isTool(ObjectTypeId self) internal pure returns (bool) {
    return self.getCategory() == Tool;
  }

  function isItem(ObjectTypeId self) internal pure returns (bool) {
    return self.getCategory() == Item;
  }

  function isNull(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.Null;
  }

  function isAny(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.AnyLog || self == ObjectTypes.AnyPlank || self == ObjectTypes.AnyLeaf;
  }

  function isSmartEntity(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.Chest || self == ObjectTypes.ForceField || self == ObjectTypes.Fragment
      || self == ObjectTypes.SpawnTile || self == ObjectTypes.Bed;
  }

  function isHoe(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.WoodenHoe;
  }

  function isMachine(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.ForceField;
  }

  function isOre(ObjectTypeId self) internal pure returns (bool) {
    ObjectTypeId[] memory oreTypes = getOreObjectTypes();
    for (uint256 i = 0; i < oreTypes.length; i++) {
      if (self == oreTypes[i]) {
        return true;
      }
    }

    return false;
  }

  function isFood(ObjectTypeId self) internal pure returns (bool) {
    return _isFood(self);
  }

  function isGrowable(ObjectTypeId self) internal pure returns (bool) {
    return isSeed(self) || isSapling(self);
  }

  function isSeed(ObjectTypeId self) internal pure returns (bool) {
    return _isCropSeed(self);
  }

  function isSapling(ObjectTypeId self) internal pure returns (bool) {
    return _isTreeSeed(self);
  }

  function isCrop(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.Wheat || self == ObjectTypes.Melon || self == ObjectTypes.Pumpkin;
  }

  function isLog(ObjectTypeId self) internal pure returns (bool) {
    ObjectTypeId[] memory logTypes = getLogObjectTypes();
    for (uint256 i = 0; i < logTypes.length; i++) {
      if (self == logTypes[i]) {
        return true;
      }
    }
    return false;
  }

  function isLeaf(ObjectTypeId self) internal pure returns (bool) {
    ObjectTypeId[] memory leafTypes = getLeafObjectTypes();
    for (uint256 i = 0; i < leafTypes.length; i++) {
      if (self == leafTypes[i]) {
        return true;
      }
    }
    return false;
  }

  function hasExtraDrops(ObjectTypeId self) internal pure returns (bool) {
    return self == ObjectTypes.FescueGrass || self.isCrop() || self.isLeaf();
  }

  function getSapling(ObjectTypeId self) internal pure returns (ObjectTypeId) {
    if (self == ObjectTypes.OakLeaf) {
      return ObjectTypes.OakSapling;
    } else if (self == ObjectTypes.SpruceLeaf) {
      return ObjectTypes.SpruceSapling;
    } else if (self == ObjectTypes.MangroveLeaf) {
      return ObjectTypes.MangroveSapling;
    } else if (self == ObjectTypes.SakuraLeaf) {
      return ObjectTypes.SakuraSapling;
    } else if (self == ObjectTypes.DarkOakLeaf) {
      return ObjectTypes.DarkOakSapling;
    } else if (self == ObjectTypes.BirchLeaf) {
      return ObjectTypes.BirchSapling;
    } else if (self == ObjectTypes.AcaciaLeaf) {
      return ObjectTypes.AcaciaSapling;
    } else if (self == ObjectTypes.JungleLeaf) {
      return ObjectTypes.JungleSapling;
    }

    revert("Invalid log type");
  }

  // TODO: one possible way to optimize is to follow some kind of schema for crops and their seeds
  function getCrop(ObjectTypeId self) internal pure returns (ObjectTypeId) {
    if (self == ObjectTypes.WheatSeed) {
      return ObjectTypes.Wheat;
    }

    revert("Invalid crop seed type");
  }

  function timeToGrow(ObjectTypeId objectTypeId) internal pure returns (uint128) {
    return _timeToGrow(objectTypeId);
  }

  function getObjectTypes(ObjectTypeId self) internal pure returns (ObjectTypeId[] memory) {
    if (self == ObjectTypes.AnyLog) {
      return getLogObjectTypes();
    }

    if (self == ObjectTypes.AnyPlank) {
      return getPlanksObjectTypes();
    }

    if (self == ObjectTypes.AnyLeaf) {
      return getLeafObjectTypes();
    }

    // Return empty array for non-Any types
    return new ObjectTypeId[](0);
  }

  /// @dev Get seed amounts that should be burned when this object is consumed
  function getSeedAmount(ObjectTypeId self) internal pure returns (ObjectAmount memory) {
    // TODO: add all foods
    if (self == ObjectTypes.Wheat) {
      return ObjectAmount(ObjectTypes.WheatSeed, 1);
    }
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  /// @dev Get ore amounts that should be burned when this object is burned
  /// Currently it only supports tools, and assumes that only a single type of ore is used
  function getOreAmount(ObjectTypeId self) internal pure returns (ObjectAmount memory) {
    // Copper tools
    if (self == ObjectTypes.CopperPick || self == ObjectTypes.CopperAxe) {
      return ObjectAmount(ObjectTypes.CopperOre, 3); // 3 copper bars = 3 ores
    }
    if (self == ObjectTypes.CopperWhacker) {
      return ObjectAmount(ObjectTypes.CopperOre, 6); // 6 copper bars = 6 ores
    }

    // Iron tools
    if (self == ObjectTypes.IronPick || self == ObjectTypes.IronAxe) {
      return ObjectAmount(ObjectTypes.IronOre, 3); // 3 iron bars = 3 ores
    }
    if (self == ObjectTypes.IronWhacker) {
      return ObjectAmount(ObjectTypes.IronOre, 6); // 6 iron bars = 6 ores
    }

    // Gold tools
    if (self == ObjectTypes.GoldPick || self == ObjectTypes.GoldAxe) {
      return ObjectAmount(ObjectTypes.GoldOre, 3); // 3 gold bars = 3 ores
    }

    // Diamond tools
    if (self == ObjectTypes.DiamondPick || self == ObjectTypes.DiamondAxe) {
      return ObjectAmount(ObjectTypes.DiamondOre, 3); // 3 diamonds = 3 ores
    }

    // Neptunium tools
    if (self == ObjectTypes.NeptuniumPick || self == ObjectTypes.NeptuniumAxe) {
      return ObjectAmount(ObjectTypes.NeptuniumOre, 3); // 3 neptunium bars = 3 ores
    }

    // Return zero amount for any other type
    return ObjectAmount(ObjectTypes.Null, 0);
  }

  function getToolPlankAmount(ObjectTypeId self) internal pure returns (uint16) {
    require(self.isTool(), "Not a tool");

    if (self == ObjectTypes.WoodenPick || self == ObjectTypes.WoodenAxe) {
      return 5;
    }

    if (self == ObjectTypes.WoodenHoe) {
      return 4;
    }

    if (self == ObjectTypes.WoodenWhacker) {
      return 8;
    }

    // All other tools use 2 planks
    return 2;
  }

  function burnOre(ObjectTypeId self, uint256 amount) internal {
    // This increases the availability of the ores being burned
    ResourceCount._set(self, ResourceCount._get(self) - amount);
    // This allows the same amount of ores to respawn
    BurnedResourceCount._set(ObjectTypes.AnyOre, BurnedResourceCount._get(ObjectTypes.AnyOre) + amount);
  }

  function burnOres(ObjectTypeId self) internal {
    ObjectAmount memory ores = self.getOreAmount();
    ObjectTypeId objectTypeId = ores.objectTypeId;
    if (!objectTypeId.isNull()) {
      objectTypeId.burnOre(ores.amount);
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

    if (self == ObjectTypes.Chest) {
      return sig == ITransferSystem.transfer.selector || sig == IMachineSystem.fuelMachine.selector;
    }

    return false;
  }
}

function getLogObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](8);
  result[0] = ObjectTypes.OakLog;
  result[1] = ObjectTypes.BirchLog;
  result[2] = ObjectTypes.JungleLog;
  result[3] = ObjectTypes.SakuraLog;
  result[4] = ObjectTypes.AcaciaLog;
  result[5] = ObjectTypes.SpruceLog;
  result[6] = ObjectTypes.DarkOakLog;
  result[7] = ObjectTypes.MangroveLog;
  return result;
}

function getLeafObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](8);
  result[0] = ObjectTypes.OakLeaf;
  result[1] = ObjectTypes.BirchLeaf;
  result[2] = ObjectTypes.JungleLeaf;
  result[3] = ObjectTypes.SakuraLeaf;
  result[4] = ObjectTypes.AcaciaLeaf;
  result[5] = ObjectTypes.SpruceLeaf;
  result[6] = ObjectTypes.DarkOakLeaf;
  result[7] = ObjectTypes.MangroveLeaf;
  return result;
}

function getPlanksObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](8);
  result[0] = ObjectTypes.OakPlanks;
  result[1] = ObjectTypes.BirchPlanks;
  result[2] = ObjectTypes.JunglePlanks;
  result[3] = ObjectTypes.SakuraPlanks;
  result[4] = ObjectTypes.SprucePlanks;
  result[5] = ObjectTypes.AcaciaPlanks;
  result[6] = ObjectTypes.DarkOakPlanks;
  result[7] = ObjectTypes.MangrovePlanks;
  return result;
}

function getOreObjectTypes() pure returns (ObjectTypeId[] memory) {
  ObjectTypeId[] memory result = new ObjectTypeId[](6);
  result[0] = ObjectTypes.CoalOre;
  result[1] = ObjectTypes.CopperOre;
  result[2] = ObjectTypes.IronOre;
  result[3] = ObjectTypes.GoldOre;
  result[4] = ObjectTypes.DiamondOre;
  result[5] = ObjectTypes.NeptuniumOre;
  return result;
}

using ObjectTypeLib for ObjectTypeId;
