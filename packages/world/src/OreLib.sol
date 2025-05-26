// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "./codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "./codegen/tables/ResourceCount.sol";

import { TerrainLib } from "./systems/libraries/TerrainLib.sol";
import { ChunkCommitment } from "./utils/Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_COAL,
  MAX_COPPER,
  MAX_DIAMOND,
  MAX_GOLD,
  MAX_IRON,
  MAX_NEPTUNIUM
} from "./Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "./ObjectType.sol";

import { NatureLib } from "./NatureLib.sol";
import { RandomLib } from "./RandomLib.sol";
import { Vec3, vec3 } from "./Vec3.sol";

library OreLib {
  function getRandomOre(Vec3 coord) internal view returns (ObjectType) {
    uint256 randomSeed = NatureLib.getRandomSeed(coord);

    // Get ore options and their weights (based on remaining amounts and multipliers)
    ObjectType[6] memory oreTypes = ObjectTypeLib.getOreTypes();

    uint8 biome = TerrainLib._getBiome(coord);
    uint256[6] memory biomeMultipliers = _getBiomeMultipliers(biome);

    uint256[] memory weights = new uint256[](oreTypes.length);

    for (uint256 i = 0; i < oreTypes.length; i++) {
      (uint256 cap, uint256 remaining) = NatureLib.getCapAndRemaining(oreTypes[i]);
      weights[i] = biomeMultipliers[i] * remaining / cap;
    }

    // Select ore based on availability
    return oreTypes[RandomLib.selectByWeight(weights, randomSeed)];
  }

  /// @dev ore index order must match getOreTypes()
  function _getBiomeMultipliers(uint256 biomeIndex) public pure returns (uint256[6] memory) {
    // biomeIndex == 0: lush_caves
    if (biomeIndex == 0) return [uint256(1433781), 1173465, 1366742, 428359, 369632, 135];
    // biomeIndex == 1: mantle_caves
    else if (biomeIndex == 1) return [uint256(748748), 566093, 778619, 342314, 313924, 25];
    // biomeIndex == 2: thermal_caves
    else if (biomeIndex == 2) return [uint256(236770), 127777, 126447, 34498, 22813, 59];
    // biomeIndex == 3: granite_caves
    else if (biomeIndex == 3) return [uint256(941030), 436557, 363609, 59301, 28370, 122];
    // biomeIndex == 4: deep_ocean
    else if (biomeIndex == 4) return [uint256(877), 7499, 22198, 12122, 5262, 0];
    // biomeIndex == 5: ocean
    else if (biomeIndex == 5) return [uint256(103206), 113110, 91257, 9939, 2272, 0];
    // biomeIndex == 6: skylands_spring
    else if (biomeIndex == 6) return [uint256(548), 857, 3842, 2416, 1880, 0];
    // biomeIndex == 7: andesite_caves
    else if (biomeIndex == 7) return [uint256(607673), 423945, 383418, 76794, 38956, 3];
    // biomeIndex == 8: badlands
    else if (biomeIndex == 8) return [uint256(158630), 40481, 38193, 64501, 0, 10];
    // biomeIndex == 9: eroded_badlands
    else if (biomeIndex == 9) return [uint256(145324), 13519, 33882, 54786, 16, 3];
    // biomeIndex == 10: wooded_badlands
    else if (biomeIndex == 10) return [uint256(12160), 10851, 4567, 7064, 4, 0];
    // biomeIndex == 11: sparse_jungle
    else if (biomeIndex == 11) return [uint256(260045), 128533, 27375, 38, 0, 0];
    // biomeIndex == 12: brushland
    else if (biomeIndex == 12) return [uint256(413920), 164927, 86133, 874, 64, 15];
    // biomeIndex == 13: river
    else if (biomeIndex == 13) return [uint256(118554), 114143, 55566, 1656, 47, 1];
    // biomeIndex == 14: dark_forest
    else if (biomeIndex == 14) return [uint256(53449), 28113, 5193, 0, 0, 0];
    // biomeIndex == 15: bamboo_jungle
    else if (biomeIndex == 15) return [uint256(57471), 31767, 4289, 0, 0, 0];
    // biomeIndex == 16: jungle
    else if (biomeIndex == 16) return [uint256(171088), 35114, 37347, 55, 0, 12];
    // biomeIndex == 17: dripstone_caves
    else if (biomeIndex == 17) return [uint256(1944385), 2575960, 615503, 69362, 39301, 268];
    // biomeIndex == 18: tropical_jungle
    else if (biomeIndex == 18) return [uint256(166016), 84063, 12838, 0, 0, 6];
    // biomeIndex == 19: fungal_caves
    else if (biomeIndex == 19) return [uint256(999188), 136396, 105961, 22242, 13792, 42];
    // biomeIndex == 20: underground_jungle
    else if (biomeIndex == 20) return [uint256(1188059), 173213, 177469, 55380, 46659, 0];
    // biomeIndex == 21: savanna
    else if (biomeIndex == 21) return [uint256(235597), 60799, 50702, 629, 51, 0];
    // biomeIndex == 22: painted_mountains
    else if (biomeIndex == 22) return [uint256(111780), 60, 52729, 211, 0, 3067];
    // biomeIndex == 23: rocky_jungle
    else if (biomeIndex == 23) return [uint256(166294), 63442, 7068, 0, 0, 10];
    // biomeIndex == 24: deep_dark
    else if (biomeIndex == 24) return [uint256(283659), 326206, 372641, 128409, 75506, 0];
    // biomeIndex == 25: red_oasis
    else if (biomeIndex == 25) return [uint256(436), 5306, 1365, 46, 0, 0];
    // biomeIndex == 26: amethyst_rainforest
    else if (biomeIndex == 26) return [uint256(66788), 28984, 2889, 0, 0, 0];
    // biomeIndex == 27: sakura_grove
    else if (biomeIndex == 27) return [uint256(3769), 2136, 336, 0, 0, 0];
    // biomeIndex == 28: mangrove_swamp
    else if (biomeIndex == 28) return [uint256(108941), 17131, 15688, 0, 0, 0];
    // biomeIndex == 29: desert
    else if (biomeIndex == 29) return [uint256(24979), 11337, 5129, 267, 36, 0];
    // biomeIndex == 30: warm_river
    else if (biomeIndex == 30) return [uint256(91), 75, 82, 0, 0, 0];
    // biomeIndex == 31: warm_ocean
    else if (biomeIndex == 31) return [uint256(4193), 5809, 6773, 1554, 379, 0];
    // biomeIndex == 32: volcanic_peaks
    else if (biomeIndex == 32) return [uint256(312563), 65, 2211, 0, 0, 9711];
    // biomeIndex == 33: savanna_plateau
    else if (biomeIndex == 33) return [uint256(122850), 21487, 27411, 192, 11, 9];
    // biomeIndex == 34: gravel_beach
    else if (biomeIndex == 34) return [uint256(18221), 14444, 5236, 384, 22, 0];
    // biomeIndex == 35: lukewarm_ocean
    else if (biomeIndex == 35) return [uint256(42689), 51221, 52918, 10300, 2874, 0];
    // biomeIndex == 36: beach
    else if (biomeIndex == 36) return [uint256(27683), 21550, 10145, 399, 47, 1];
    // biomeIndex == 37: infested_caves
    else if (biomeIndex == 37) return [uint256(116609), 104126, 123571, 38410, 25798, 1];
    // biomeIndex == 38: ashen_savanna
    else if (biomeIndex == 38) return [uint256(18133), 0, 7054, 0, 0, 17];
    // biomeIndex == 39: deep_caves
    else if (biomeIndex == 39) return [uint256(109319), 141845, 285160, 177931, 223616, 0];
    // biomeIndex == 40: hot_shrubland
    else if (biomeIndex == 40) return [uint256(21814), 7571, 2482, 34, 2, 0];
    // biomeIndex == 41: diorite_caves
    else if (biomeIndex == 41) return [uint256(200901), 150917, 137323, 23369, 10666, 9];
    // biomeIndex == 42: stony_peaks
    else if (biomeIndex == 42) return [uint256(254920), 0, 187421, 4, 0, 9636];
    // biomeIndex == 43: arid_highlands
    else if (biomeIndex == 43) return [uint256(234757), 74873, 39135, 84, 0, 0];
    // biomeIndex == 44: old_growth_pine_taiga
    else if (biomeIndex == 44) return [uint256(20109), 8862, 2825, 6, 0, 1];
    // biomeIndex == 45: rocky_mountains
    else if (biomeIndex == 45) return [uint256(50559), 15, 19955, 0, 0, 1284];
    // biomeIndex == 46: forest
    else if (biomeIndex == 46) return [uint256(83114), 32743, 15175, 126, 7, 4];
    // biomeIndex == 47: frozen_peaks
    else if (biomeIndex == 47) return [uint256(6038), 0, 3155, 0, 0, 181];
    // biomeIndex == 48: jagged_peaks
    else if (biomeIndex == 48) return [uint256(29774), 0, 17387, 0, 0, 997];
    // biomeIndex == 49: highlands
    else if (biomeIndex == 49) return [uint256(145699), 90692, 16966, 30, 0, 0];
    // biomeIndex == 50: old_growth_spruce_taiga
    else if (biomeIndex == 50) return [uint256(82084), 2807, 23332, 0, 0, 6];
    // biomeIndex == 51: old_growth_birch_forest
    else if (biomeIndex == 51) return [uint256(9927), 4335, 1846, 14, 0, 0];
    // biomeIndex == 52: steppe
    else if (biomeIndex == 52) return [uint256(48251), 30340, 5903, 19, 0, 0];
    // biomeIndex == 53: frostfire_caves
    else if (biomeIndex == 53) return [uint256(3032), 4257, 15727, 10087, 10967, 0];
    // biomeIndex == 54: tuff_caves
    else if (biomeIndex == 54) return [uint256(0), 389, 25936, 29314, 45757, 0];
    // biomeIndex == 55: yellowstone
    else if (biomeIndex == 55) return [uint256(125109), 32588, 35424, 265, 0, 4];
    // biomeIndex == 56: swamp
    else if (biomeIndex == 56) return [uint256(18145), 4713, 2704, 1, 0, 0];
    // biomeIndex == 57: alpine_highlands
    else if (biomeIndex == 57) return [uint256(119229), 64409, 13800, 24, 0, 0];
    // biomeIndex == 58: meadow
    else if (biomeIndex == 58) return [uint256(76), 54, 5, 0, 0, 1];
    // biomeIndex == 59: shield
    else if (biomeIndex == 59) return [uint256(33), 10, 0, 0, 0, 1];
    // biomeIndex == 60: plains
    else if (biomeIndex == 60) return [uint256(51709), 35117, 8474, 50, 0, 0];
    // biomeIndex == 61: forested_highlands
    else if (biomeIndex == 61) return [uint256(237795), 97146, 29175, 32, 0, 0];
    // biomeIndex == 62: temperate_highlands
    else if (biomeIndex == 62) return [uint256(56394), 30594, 7983, 35, 0, 0];
    // biomeIndex == 63: taiga
    else if (biomeIndex == 63) return [uint256(4708), 1429, 1411, 0, 0, 0];
    // biomeIndex == 64: birch_taiga
    else if (biomeIndex == 64) return [uint256(8708), 722, 2568, 2, 0, 0];
    // biomeIndex == 65: sakura_valley
    else if (biomeIndex == 65) return [uint256(5332), 3662, 812, 0, 0, 0];
    // biomeIndex == 66: snowy_taiga
    else if (biomeIndex == 66) return [uint256(71081), 39136, 12169, 93, 3, 2];
    // biomeIndex == 67: siberian_taiga
    else if (biomeIndex == 67) return [uint256(19346), 8388, 1456, 0, 0, 0];
    // biomeIndex == 68: lavender_valley
    else if (biomeIndex == 68) return [uint256(10894), 4897, 521, 0, 0, 2];
    // biomeIndex == 69: frozen_river
    else if (biomeIndex == 69) return [uint256(11816), 11806, 6657, 216, 32, 0];
    // biomeIndex == 70: snowy_plains
    else if (biomeIndex == 70) return [uint256(207954), 71349, 33988, 77, 3, 8];
    // biomeIndex == 71: windswept_forest
    else if (biomeIndex == 71) return [uint256(11644), 6600, 1000, 0, 0, 219];
    // biomeIndex == 72: cold_shrubland
    else if (biomeIndex == 72) return [uint256(81455), 35975, 8905, 106, 12, 1];
    // biomeIndex == 73: snowy_cherry_grove
    else if (biomeIndex == 73) return [uint256(28414), 1521, 7796, 7, 0, 710];
    // biomeIndex == 74: deep_lukewarm_ocean
    else if (biomeIndex == 74) return [uint256(81), 653, 1702, 1671, 880, 0];
    // biomeIndex == 75: cold_ocean
    else if (biomeIndex == 75) return [uint256(14560), 16742, 15917, 3239, 1175, 1];
    // biomeIndex == 76: deep_cold_ocean
    else if (biomeIndex == 76) return [uint256(1899), 14055, 56715, 39434, 23289, 0];
    // biomeIndex == 77: windswept_hills
    else if (biomeIndex == 77) return [uint256(7117), 5073, 1067, 0, 0, 146];
    // biomeIndex == 78: ice_marsh
    else if (biomeIndex == 78) return [uint256(20087), 9800, 4161, 180, 21, 0];
    // biomeIndex == 79: birch_forest
    else if (biomeIndex == 79) return [uint256(10803), 7176, 1527, 0, 0, 0];
    // biomeIndex == 80: lush_valley
    else if (biomeIndex == 80) return [uint256(3005), 1919, 656, 11, 0, 0];
    // biomeIndex == 81: glacial_chasm
    else if (biomeIndex == 81) return [uint256(52750), 21697, 4579, 66, 4, 0];
    // biomeIndex == 82: blooming_valley
    else if (biomeIndex == 82) return [uint256(165), 86, 58, 0, 0, 0];
    // biomeIndex == 83: snowy_beach
    else if (biomeIndex == 83) return [uint256(938), 872, 538, 42, 0, 1];
    // biomeIndex == 84: frozen_ocean
    else if (biomeIndex == 84) return [uint256(4771), 6153, 7345, 1963, 1296, 0];
    // biomeIndex == 85: windswept_gravelly_hills
    else if (biomeIndex == 85) return [uint256(763), 946, 532, 50, 20, 15];
    // biomeIndex == 86: deep_frozen_ocean
    else if (biomeIndex == 86) return [uint256(124), 1076, 3544, 3066, 3200, 0];
    // biomeIndex == 87: skylands_autumn
    else if (biomeIndex == 87) return [uint256(17), 21, 88, 86, 75, 0];
    // biomeIndex == 88: sunflower_plains
    else if (biomeIndex == 88) return [uint256(95), 88, 19, 0, 0, 0];
    // biomeIndex == 89: snowy_slopes
    else if (biomeIndex == 89) return [uint256(7303), 0, 2929, 0, 0, 201];
    // biomeIndex == 90: flower_forest
    else if (biomeIndex == 90) return [uint256(8624), 5506, 1095, 0, 0, 0];
    // biomeIndex == 91: snowy_badlands
    else if (biomeIndex == 91) return [uint256(511), 57, 81, 222, 0, 2];
    // biomeIndex == 92: ice_spikes
    else if (biomeIndex == 92) return [uint256(6), 54, 8, 0, 0, 0];
    else revert("Invalid biome index");
  }

  function burnOre(ObjectType self, uint256 amount) internal {
    // This increases the availability of the ores being burned
    ResourceCount._set(self, ResourceCount._get(self) - amount);
    // This allows the same amount of ores to respawn
    BurnedResourceCount._set(ObjectTypes.UnrevealedOre, BurnedResourceCount._get(ObjectTypes.UnrevealedOre) + amount);
  }

  function burnOres(ObjectType self) internal {
    ObjectAmount memory oreAmount = self.getOreAmount();
    if (!oreAmount.objectType.isNull()) {
      burnOre(oreAmount.objectType, oreAmount.amount);
    }
  }
}
