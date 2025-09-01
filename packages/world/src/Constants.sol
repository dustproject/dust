// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

uint256 constant PRECISION_MULTIPLIER = 1e18;

uint32 constant MAX_ENTITY_INFLUENCE_RADIUS = 10;
uint32 constant MAX_PICKUP_RADIUS = 6;
uint32 constant MAX_HIT_RADIUS = 6;
uint32 constant MAX_RESPAWN_HALF_WIDTH = 10;

uint16 constant MAX_PLAYER_JUMPS = 3;
uint16 constant MAX_PLAYER_GLIDES = 10;
uint16 constant PLAYER_SAFE_FALL_DISTANCE = 3;

uint256 constant SPAWN_BLOCK_RANGE = 20;

int32 constant FRAGMENT_SIZE = 8; // 8x8x8 (3D)
int32 constant CHUNK_SIZE = 16; // 16x16x16 (3D)
int32 constant REGION_SIZE = 512; // 512x512 (2D)

uint256 constant SAFE_PROGRAM_GAS = 1_000_000;

uint256 constant CHUNK_COMMIT_EXPIRY_BLOCKS = 256;
uint256 constant CHUNK_COMMIT_HALF_WIDTH = 2;
uint256 constant RESPAWN_ORE_BLOCK_RANGE = 10;
uint8 constant MAX_FLUID_LEVEL = 15; // Maximum fluid level for water and lava

uint128 constant BLOCK_TIME = 2 seconds;

// ------------------------------------------------------------
// Values To Tune
// ------------------------------------------------------------
uint128 constant MAX_PLAYER_ENERGY = 817600000000000000;

// IMPORTANT: These drain rates are used for detecting sleeping players in forcefields
// The detection relies on PLAYER_ENERGY_DRAIN_RATE % MACHINE_ENERGY_DRAIN_RATE != 0
// Current: 1351851852000 % 9488203935 = 4526893230 (non-zero, so detection works)
// If you change these values, verify the modulo is still non-zero or update the detection logic in MineSystem
uint128 constant PLAYER_ENERGY_DRAIN_RATE = 1351851852000;
uint128 constant PLAYER_SWIM_ENERGY_DRAIN_RATE = MAX_PLAYER_ENERGY / 5 minutes; // 5 minutes to drain all energy if fully submerged
uint128 constant PLAYER_LAVA_ENERGY_DRAIN_RATE = MAX_PLAYER_ENERGY / 10 seconds; // 10 seconds to drain all energy if standing on lava

uint128 constant MACHINE_ENERGY_DRAIN_RATE = 9488203935;

uint128 constant TOOL_ACTION_ENERGY_COST = 255500000000000;
uint128 constant BARE_HANDS_ACTION_ENERGY_COST = 8100000000000000;
uint128 constant BUILD_ENERGY_COST = 255500000000000;
uint128 constant CRAFT_ENERGY_COST = 255500000000000;
uint128 constant MOVE_ENERGY_COST = 25550000000000;
uint128 constant WATER_MOVE_ENERGY_COST = MAX_PLAYER_ENERGY / 4000; // 4000 moves in water to die
uint128 constant LAVA_MOVE_ENERGY_COST = MAX_PLAYER_ENERGY / 10; // 10 moves on lava to die
uint128 constant PLAYER_FALL_ENERGY_COST = MAX_PLAYER_ENERGY / 25; // This makes it so, with full energy, you die from a 25 + 3 block fall

// Base tool effectiveness (relative to bare hands)
uint128 constant WOODEN_TOOL_BASE_MULTIPLIER = 10; // 10x base effectiveness
uint128 constant ORE_TOOL_BASE_MULTIPLIER = 3; // 3x base effectiveness

// Specialization bonus (when tool matches task)
uint128 constant SPECIALIZATION_MULTIPLIER = 3; // 3x bonus for using the right tool

// Action modifiers (fractional values use ACTION_MODIFIER_DENOMINATOR)
uint128 constant ACTION_MODIFIER_DENOMINATOR = 1e18;
uint128 constant MINE_ACTION_MODIFIER = ACTION_MODIFIER_DENOMINATOR; // 1x (no change for mining)
uint128 constant HIT_ACTION_MODIFIER = ACTION_MODIFIER_DENOMINATOR / 100; // ~1/100x

// Resource caps
uint256 constant MAX_WHEAT_SEED = 29_659;
uint256 constant MAX_MELON_SEED = 7_493;
uint256 constant MAX_PUMPKIN_SEED = 1_410;
// uint256 constant MAX_COTTON_SEED = 20_000;

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

// Rate limit constants
uint128 constant MAX_RATE_LIMIT_UNITS_PER_BLOCK = 1e18;
uint128 constant MAX_RATE_LIMIT_UNITS_PER_SECOND = MAX_RATE_LIMIT_UNITS_PER_BLOCK / BLOCK_TIME;

// Movement rate limits
uint128 constant WALK_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_SECOND / 15; // 15 blocks per second
uint128 constant SWIM_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_SECOND * 10 / 135; // 13.5 blocks per second (90% of walking speed)

// Combat rate limits
uint128 constant HIT_PLAYER_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_BLOCK; // player vs player: 1 per block
uint128 constant HIT_MACHINE_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_SECOND / 10; // player vs machine: 20 per block

// Work rate limits
uint128 constant MINE_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_SECOND / 10; // 10 mines per second (20 per block)
uint128 constant BUILD_UNIT_COST = MAX_RATE_LIMIT_UNITS_PER_SECOND / 10; // 10 builds per second (20 per block)

// Progress decay constants
int128 constant LN2_WAD = 693147180559945309; // ln(2) in 1e18
uint256 constant PROGRESS_DECAY_HALF_LIFE = 7 days; // every 7 days progress decays by half
int128 constant PROGRESS_DECAY_LAMBDA_WAD = int128(int256(LN2_WAD) / int256(PROGRESS_DECAY_HALF_LIFE));
