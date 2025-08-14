// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BurnedResourceCount } from "../codegen/tables/BurnedResourceCount.sol";
import { ResourceCount } from "../codegen/tables/ResourceCount.sol";

import { TerrainLib } from "../systems/libraries/TerrainLib.sol";
import { ChunkCommitment } from "./Vec3Storage.sol";

import {
  CHUNK_COMMIT_EXPIRY_BLOCKS,
  MAX_COAL,
  MAX_COPPER,
  MAX_DIAMOND,
  MAX_GOLD,
  MAX_IRON,
  MAX_NEPTUNIUM,
  PRECISION_MULTIPLIER
} from "../Constants.sol";
import { ObjectAmount, ObjectType, ObjectTypeLib, ObjectTypes } from "../types/ObjectType.sol";

import { NatureLib } from "./NatureLib.sol";
import { RandomLib } from "./RandomLib.sol";

import { Vec3, vec3 } from "../types/Vec3.sol";

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
      weights[i] = biomeMultipliers[i] * remaining * PRECISION_MULTIPLIER / cap;
    }

    // Select ore based on availability
    return oreTypes[RandomLib.selectByWeight(weights, randomSeed)];
  }

  function _getBiomeMultipliers(uint8 biomeIndex) public pure returns (uint256[6] memory) {
    // biomeIndex == 0: badlands
    if (biomeIndex == 0) {
      return [uint256(158630), uint256(40481), uint256(38193), uint256(64501), uint256(0), uint256(10)];
    }
    // biomeIndex == 1: bamboo_jungle
    else if (biomeIndex == 1) {
      return [uint256(57471), uint256(31767), uint256(4289), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 3: beach
    else if (biomeIndex == 3) {
      return [uint256(27683), uint256(21550), uint256(10145), uint256(399), uint256(47), uint256(1)];
    }
    // biomeIndex == 4: birch_forest
    else if (biomeIndex == 4) {
      return [uint256(10803), uint256(7176), uint256(1527), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 6: cold_ocean
    else if (biomeIndex == 6) {
      return [uint256(14560), uint256(16742), uint256(15917), uint256(3239), uint256(1175), uint256(1)];
    }
    // biomeIndex == 8: dark_forest
    else if (biomeIndex == 8) {
      return [uint256(53449), uint256(28113), uint256(5193), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 9: deep_cold_ocean
    else if (biomeIndex == 9) {
      return [uint256(1899), uint256(14055), uint256(56715), uint256(39434), uint256(23289), uint256(0)];
    }
    // biomeIndex == 10: deep_dark
    else if (biomeIndex == 10) {
      return [uint256(283659), uint256(326206), uint256(372641), uint256(128409), uint256(75506), uint256(0)];
    }
    // biomeIndex == 11: deep_frozen_ocean
    else if (biomeIndex == 11) {
      return [uint256(124), uint256(1076), uint256(3544), uint256(3066), uint256(3200), uint256(0)];
    }
    // biomeIndex == 12: deep_lukewarm_ocean
    else if (biomeIndex == 12) {
      return [uint256(81), uint256(653), uint256(1702), uint256(1671), uint256(880), uint256(0)];
    }
    // biomeIndex == 13: deep_ocean
    else if (biomeIndex == 13) {
      return [uint256(877), uint256(7499), uint256(22198), uint256(12122), uint256(5262), uint256(0)];
    }
    // biomeIndex == 14: desert
    else if (biomeIndex == 14) {
      return [uint256(24979), uint256(11337), uint256(5129), uint256(267), uint256(36), uint256(0)];
    }
    // biomeIndex == 15: dripstone_caves
    else if (biomeIndex == 15) {
      return [uint256(1944385), uint256(2575960), uint256(615503), uint256(69362), uint256(39301), uint256(268)];
    }
    // biomeIndex == 19: eroded_badlands
    else if (biomeIndex == 19) {
      return [uint256(145324), uint256(13519), uint256(33882), uint256(54786), uint256(16), uint256(3)];
    }
    // biomeIndex == 20: flower_forest
    else if (biomeIndex == 20) {
      return [uint256(8624), uint256(5506), uint256(1095), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 21: forest
    else if (biomeIndex == 21) {
      return [uint256(83114), uint256(32743), uint256(15175), uint256(126), uint256(7), uint256(4)];
    }
    // biomeIndex == 22: frozen_ocean
    else if (biomeIndex == 22) {
      return [uint256(4771), uint256(6153), uint256(7345), uint256(1963), uint256(1296), uint256(0)];
    }
    // biomeIndex == 23: frozen_peaks
    else if (biomeIndex == 23) {
      return [uint256(6038), uint256(0), uint256(3155), uint256(0), uint256(0), uint256(181)];
    }
    // biomeIndex == 24: frozen_river
    else if (biomeIndex == 24) {
      return [uint256(11816), uint256(11806), uint256(6657), uint256(216), uint256(32), uint256(0)];
    }
    // biomeIndex == 26: ice_spikes
    else if (biomeIndex == 26) {
      return [uint256(6), uint256(54), uint256(8), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 27: jagged_peaks
    else if (biomeIndex == 27) {
      return [uint256(29774), uint256(0), uint256(17387), uint256(0), uint256(0), uint256(997)];
    }
    // biomeIndex == 28: jungle
    else if (biomeIndex == 28) {
      return [uint256(171088), uint256(35114), uint256(37347), uint256(55), uint256(0), uint256(12)];
    }
    // biomeIndex == 29: lukewarm_ocean
    else if (biomeIndex == 29) {
      return [uint256(42689), uint256(51221), uint256(52918), uint256(10300), uint256(2874), uint256(0)];
    }
    // biomeIndex == 30: lush_caves
    else if (biomeIndex == 30) {
      return [uint256(1433781), uint256(1173465), uint256(1366742), uint256(428359), uint256(369632), uint256(135)];
    }
    // biomeIndex == 31: mangrove_swamp
    else if (biomeIndex == 31) {
      return [uint256(108941), uint256(17131), uint256(15688), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 32: meadow
    else if (biomeIndex == 32) {
      return [uint256(76), uint256(54), uint256(5), uint256(0), uint256(0), uint256(1)];
    }
    // biomeIndex == 35: ocean
    else if (biomeIndex == 35) {
      return [uint256(103206), uint256(113110), uint256(91257), uint256(9939), uint256(2272), uint256(0)];
    }
    // biomeIndex == 36: old_growth_birch_forest
    else if (biomeIndex == 36) {
      return [uint256(9927), uint256(4335), uint256(1846), uint256(14), uint256(0), uint256(0)];
    }
    // biomeIndex == 37: old_growth_pine_taiga
    else if (biomeIndex == 37) {
      return [uint256(20109), uint256(8862), uint256(2825), uint256(6), uint256(0), uint256(1)];
    }
    // biomeIndex == 38: old_growth_spruce_taiga
    else if (biomeIndex == 38) {
      return [uint256(82084), uint256(2807), uint256(23332), uint256(0), uint256(0), uint256(6)];
    }
    // biomeIndex == 39: plains
    else if (biomeIndex == 39) {
      return [uint256(51709), uint256(35117), uint256(8474), uint256(50), uint256(0), uint256(0)];
    }
    // biomeIndex == 40: river
    else if (biomeIndex == 40) {
      return [uint256(118554), uint256(114143), uint256(55566), uint256(1656), uint256(47), uint256(1)];
    }
    // biomeIndex == 41: savanna
    else if (biomeIndex == 41) {
      return [uint256(235597), uint256(60799), uint256(50702), uint256(629), uint256(51), uint256(0)];
    }
    // biomeIndex == 42: savanna_plateau
    else if (biomeIndex == 42) {
      return [uint256(122850), uint256(21487), uint256(27411), uint256(192), uint256(11), uint256(9)];
    }
    // biomeIndex == 44: snowy_beach
    else if (biomeIndex == 44) {
      return [uint256(938), uint256(872), uint256(538), uint256(42), uint256(0), uint256(1)];
    }
    // biomeIndex == 45: snowy_plains
    else if (biomeIndex == 45) {
      return [uint256(207954), uint256(71349), uint256(33988), uint256(77), uint256(3), uint256(8)];
    }
    // biomeIndex == 46: snowy_slopes
    else if (biomeIndex == 46) {
      return [uint256(7303), uint256(0), uint256(2929), uint256(0), uint256(0), uint256(201)];
    }
    // biomeIndex == 47: snowy_taiga
    else if (biomeIndex == 47) {
      return [uint256(71081), uint256(39136), uint256(12169), uint256(93), uint256(3), uint256(2)];
    }
    // biomeIndex == 49: sparse_jungle
    else if (biomeIndex == 49) {
      return [uint256(260045), uint256(128533), uint256(27375), uint256(38), uint256(0), uint256(0)];
    }
    // biomeIndex == 50: stony_peaks
    else if (biomeIndex == 50) {
      return [uint256(254920), uint256(0), uint256(187421), uint256(4), uint256(0), uint256(9636)];
    }
    // biomeIndex == 52: sunflower_plains
    else if (biomeIndex == 52) {
      return [uint256(95), uint256(88), uint256(19), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 53: swamp
    else if (biomeIndex == 53) {
      return [uint256(18145), uint256(4713), uint256(2704), uint256(1), uint256(0), uint256(0)];
    }
    // biomeIndex == 54: taiga
    else if (biomeIndex == 54) {
      return [uint256(4708), uint256(1429), uint256(1411), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 57: warm_ocean
    else if (biomeIndex == 57) {
      return [uint256(4193), uint256(5809), uint256(6773), uint256(1554), uint256(379), uint256(0)];
    }
    // biomeIndex == 59: windswept_forest
    else if (biomeIndex == 59) {
      return [uint256(11644), uint256(6600), uint256(1000), uint256(0), uint256(0), uint256(219)];
    }
    // biomeIndex == 60: windswept_gravelly_hills
    else if (biomeIndex == 60) {
      return [uint256(763), uint256(946), uint256(532), uint256(50), uint256(20), uint256(15)];
    }
    // biomeIndex == 61: windswept_hills
    else if (biomeIndex == 61) {
      return [uint256(7117), uint256(5073), uint256(1067), uint256(0), uint256(0), uint256(146)];
    }
    // biomeIndex == 63: wooded_badlands
    else if (biomeIndex == 63) {
      return [uint256(12160), uint256(10851), uint256(4567), uint256(7064), uint256(4), uint256(0)];
    }
    // biomeIndex == 65: andesite_caves
    else if (biomeIndex == 65) {
      return [uint256(607673), uint256(423945), uint256(383418), uint256(76794), uint256(38956), uint256(3)];
    }
    // biomeIndex == 67: deep_caves
    else if (biomeIndex == 67) {
      return [uint256(109319), uint256(141845), uint256(285160), uint256(177931), uint256(223616), uint256(0)];
    }
    // biomeIndex == 69: diorite_caves
    else if (biomeIndex == 69) {
      return [uint256(200901), uint256(150917), uint256(137323), uint256(23369), uint256(10666), uint256(9)];
    }
    // biomeIndex == 70: frostfire_caves
    else if (biomeIndex == 70) {
      return [uint256(3032), uint256(4257), uint256(15727), uint256(10087), uint256(10967), uint256(0)];
    }
    // biomeIndex == 71: fungal_caves
    else if (biomeIndex == 71) {
      return [uint256(999188), uint256(136396), uint256(105961), uint256(22242), uint256(13792), uint256(42)];
    }
    // biomeIndex == 72: granite_caves
    else if (biomeIndex == 72) {
      return [uint256(941030), uint256(436557), uint256(363609), uint256(59301), uint256(28370), uint256(122)];
    }
    // biomeIndex == 74: infested_caves
    else if (biomeIndex == 74) {
      return [uint256(116609), uint256(104126), uint256(123571), uint256(38410), uint256(25798), uint256(1)];
    }
    // biomeIndex == 75: mantle_caves
    else if (biomeIndex == 75) {
      return [uint256(748748), uint256(566093), uint256(778619), uint256(342314), uint256(313924), uint256(25)];
    }
    // biomeIndex == 76: thermal_caves
    else if (biomeIndex == 76) {
      return [uint256(236770), uint256(127777), uint256(126447), uint256(34498), uint256(22813), uint256(59)];
    }
    // biomeIndex == 77: tuff_caves
    else if (biomeIndex == 77) {
      return [uint256(0), uint256(389), uint256(25936), uint256(29314), uint256(45757), uint256(0)];
    }
    // biomeIndex == 78: underground_jungle
    else if (biomeIndex == 78) {
      return [uint256(1188059), uint256(173213), uint256(177469), uint256(55380), uint256(46659), uint256(0)];
    }
    // biomeIndex == 82: alpine_highlands
    else if (biomeIndex == 82) {
      return [uint256(119229), uint256(64409), uint256(13800), uint256(24), uint256(0), uint256(0)];
    }
    // biomeIndex == 84: amethyst_rainforest
    else if (biomeIndex == 84) {
      return [uint256(66788), uint256(28984), uint256(2889), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 86: arid_highlands
    else if (biomeIndex == 86) {
      return [uint256(234757), uint256(74873), uint256(39135), uint256(84), uint256(0), uint256(0)];
    }
    // biomeIndex == 87: ashen_savanna
    else if (biomeIndex == 87) {
      return [uint256(18133), uint256(0), uint256(7054), uint256(0), uint256(0), uint256(17)];
    }
    // biomeIndex == 89: birch_taiga
    else if (biomeIndex == 89) {
      return [uint256(8708), uint256(722), uint256(2568), uint256(2), uint256(0), uint256(0)];
    }
    // biomeIndex == 91: blooming_valley
    else if (biomeIndex == 91) {
      return [uint256(165), uint256(86), uint256(58), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 92: brushland
    else if (biomeIndex == 92) {
      return [uint256(413920), uint256(164927), uint256(86133), uint256(874), uint256(64), uint256(15)];
    }
    // biomeIndex == 96: cold_shrubland
    else if (biomeIndex == 96) {
      return [uint256(81455), uint256(35975), uint256(8905), uint256(106), uint256(12), uint256(1)];
    }
    // biomeIndex == 100: forested_highlands
    else if (biomeIndex == 100) {
      return [uint256(237795), uint256(97146), uint256(29175), uint256(32), uint256(0), uint256(0)];
    }
    // biomeIndex == 103: glacial_chasm
    else if (biomeIndex == 103) {
      return [uint256(52750), uint256(21697), uint256(4579), uint256(66), uint256(4), uint256(0)];
    }
    // biomeIndex == 105: gravel_beach
    else if (biomeIndex == 105) {
      return [uint256(18221), uint256(14444), uint256(5236), uint256(384), uint256(22), uint256(0)];
    }
    // biomeIndex == 108: highlands
    else if (biomeIndex == 108) {
      return [uint256(145699), uint256(90692), uint256(16966), uint256(30), uint256(0), uint256(0)];
    }
    // biomeIndex == 109: hot_shrubland
    else if (biomeIndex == 109) {
      return [uint256(21814), uint256(7571), uint256(2482), uint256(34), uint256(2), uint256(0)];
    }
    // biomeIndex == 110: ice_marsh
    else if (biomeIndex == 110) {
      return [uint256(20087), uint256(9800), uint256(4161), uint256(180), uint256(21), uint256(0)];
    }
    // biomeIndex == 113: lavender_valley
    else if (biomeIndex == 113) {
      return [uint256(10894), uint256(4897), uint256(521), uint256(0), uint256(0), uint256(2)];
    }
    // biomeIndex == 115: lush_valley
    else if (biomeIndex == 115) {
      return [uint256(3005), uint256(1919), uint256(656), uint256(11), uint256(0), uint256(0)];
    }
    // biomeIndex == 121: painted_mountains
    else if (biomeIndex == 121) {
      return [uint256(111780), uint256(60), uint256(52729), uint256(211), uint256(0), uint256(3067)];
    }
    // biomeIndex == 122: red_oasis
    else if (biomeIndex == 122) {
      return [uint256(436), uint256(5306), uint256(1365), uint256(46), uint256(0), uint256(0)];
    }
    // biomeIndex == 123: rocky_jungle
    else if (biomeIndex == 123) {
      return [uint256(166294), uint256(63442), uint256(7068), uint256(0), uint256(0), uint256(10)];
    }
    // biomeIndex == 124: rocky_mountains
    else if (biomeIndex == 124) {
      return [uint256(50559), uint256(15), uint256(19955), uint256(0), uint256(0), uint256(1284)];
    }
    // biomeIndex == 126: sakura_grove
    else if (biomeIndex == 126) {
      return [uint256(3769), uint256(2136), uint256(336), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 127: sakura_valley
    else if (biomeIndex == 127) {
      return [uint256(5332), uint256(3662), uint256(812), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 133: shield
    else if (biomeIndex == 133) {
      return [uint256(33), uint256(10), uint256(0), uint256(0), uint256(0), uint256(1)];
    }
    // biomeIndex == 136: siberian_taiga
    else if (biomeIndex == 136) {
      return [uint256(19346), uint256(8388), uint256(1456), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 137: skylands_autumn
    else if (biomeIndex == 137) {
      return [uint256(17), uint256(21), uint256(88), uint256(86), uint256(75), uint256(0)];
    }
    // biomeIndex == 138: skylands_spring
    else if (biomeIndex == 138) {
      return [uint256(548), uint256(857), uint256(3842), uint256(2416), uint256(1880), uint256(0)];
    }
    // biomeIndex == 142: snowy_badlands
    else if (biomeIndex == 142) {
      return [uint256(511), uint256(57), uint256(81), uint256(222), uint256(0), uint256(2)];
    }
    // biomeIndex == 143: snowy_cherry_grove
    else if (biomeIndex == 143) {
      return [uint256(28414), uint256(1521), uint256(7796), uint256(7), uint256(0), uint256(710)];
    }
    // biomeIndex == 146: steppe
    else if (biomeIndex == 146) {
      return [uint256(48251), uint256(30340), uint256(5903), uint256(19), uint256(0), uint256(0)];
    }
    // biomeIndex == 148: temperate_highlands
    else if (biomeIndex == 148) {
      return [uint256(56394), uint256(30594), uint256(7983), uint256(35), uint256(0), uint256(0)];
    }
    // biomeIndex == 149: tropical_jungle
    else if (biomeIndex == 149) {
      return [uint256(166016), uint256(84063), uint256(12838), uint256(0), uint256(0), uint256(6)];
    }
    // biomeIndex == 152: volcanic_peaks
    else if (biomeIndex == 152) {
      return [uint256(312563), uint256(65), uint256(2211), uint256(0), uint256(0), uint256(9711)];
    }
    // biomeIndex == 153: warm_river
    else if (biomeIndex == 153) {
      return [uint256(91), uint256(75), uint256(82), uint256(0), uint256(0), uint256(0)];
    }
    // biomeIndex == 160: yellowstone
    else if (biomeIndex == 160) {
      return [uint256(125109), uint256(32588), uint256(35424), uint256(265), uint256(0), uint256(4)];
    }

    revert("Invalid biome index");
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
