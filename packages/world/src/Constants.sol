// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

uint32 constant MAX_ENTITY_INFLUENCE_HALF_WIDTH = 10;
uint32 constant MAX_RESPAWN_HALF_WIDTH = 10;

uint16 constant MAX_PLAYER_JUMPS = 3;
uint16 constant MAX_PLAYER_GLIDES = 10;
uint16 constant PLAYER_SAFE_FALL_DISTANCE = 3;

uint256 constant SPAWN_BLOCK_RANGE = 10;

int32 constant FRAGMENT_SIZE = 8; // 8x8x8 (3D)
int32 constant CHUNK_SIZE = 16; // 16x16x16 (3D)
int32 constant REGION_SIZE = 512; // 512x512 (2D)

uint256 constant SAFE_PROGRAM_GAS = 1_000_000;

uint256 constant CHUNK_COMMIT_EXPIRY_BLOCKS = 256;
uint256 constant CHUNK_COMMIT_HALF_WIDTH = 2;
uint256 constant RESPAWN_ORE_BLOCK_RANGE = 10;
uint8 constant MAX_FLUID_LEVEL = 15; // Maximum fluid level for water and lava

// ------------------------------------------------------------
// Values To Tune
// ------------------------------------------------------------
uint128 constant MAX_PLAYER_ENERGY = 817600000000000000;
uint128 constant PLAYER_ENERGY_DRAIN_RATE = 1351851852000;

uint128 constant MACHINE_ENERGY_DRAIN_RATE = 9488203935;

uint128 constant DEFAULT_MINE_ENERGY_COST = 8100000000000000;
uint128 constant TOOL_MINE_ENERGY_COST = 255500000000000;
uint128 constant DEFAULT_HIT_ENERGY_COST = 8100000000000000;
uint128 constant TOOL_HIT_ENERGY_COST = 255500000000000;
uint128 constant BUILD_ENERGY_COST = 255500000000000;
uint128 constant TILL_ENERGY_COST = 255500000000000;
uint128 constant CRAFT_ENERGY_COST = 255500000000000;
uint128 constant MOVE_ENERGY_COST = 25550000000000;
uint128 constant PLAYER_FALL_ENERGY_COST = MAX_PLAYER_ENERGY / 25; // This makes it so, with full energy, you die from a 25 block fall

uint128 constant DEFAULT_ORE_TOOL_MULTIPLIER = 3;
uint128 constant DEFAULT_WOODEN_TOOL_MULTIPLIER = 10;
uint128 constant SPECIALIZED_ORE_TOOL_MULTIPLIER = 9;
uint128 constant SPECIALIZED_WOODEN_TOOL_MULTIPLIER = 30;

// Resource caps
uint256 constant MAX_WHEAT_SEED = 29_659;
uint256 constant MAX_MELON_SEED = 7_493;
uint256 constant MAX_PUMPKIN_SEED = 1_410;

uint256 constant MAX_OAK_SAPLING = 44_745;
uint256 constant MAX_BIRCH_SAPLING = 35_656;
uint256 constant MAX_JUNGLE_SAPLING = 27_671;
uint256 constant MAX_SAKURA_SAPLING = 3_437;
uint256 constant MAX_ACACIA_SAPLING = 20_701;
uint256 constant MAX_SPRUCE_SAPLING = 19_594;
uint256 constant MAX_DARK_OAK_SAPLING = 13_732;
uint256 constant MAX_MANGROVE_SAPLING = 21_610;

uint256 constant MAX_COAL = 13_116_437;
uint256 constant MAX_COPPER = 7_661_934;
uint256 constant MAX_IRON = 4_213_327;
uint256 constant MAX_GOLD = 356_434;
uint256 constant MAX_DIAMOND = 23_046;
uint256 constant MAX_NEPTUNIUM = 18_696;

uint128 constant INITIAL_ENERGY_PER_VEGETATION = 10000000000000000;
uint128 constant INITIAL_LOCAL_ENERGY_BUFFER = 131480700000000000000;
