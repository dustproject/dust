# Changelog

## 2025-09-09

- Body progression
    - Progress tracking for crafting, mining, building and moving
    - Progress decays with inactivity up to 1/3 of the accumulated progress
    - Both current progress and accumulated progress are halved on death
    - Energy discount of up to 30% is applied depending on progress
- Wooden tools now require a station to craft

## 2025-09-01

- Added ability to hit players
- Updated onHit hook data to include an additional target entity (reused for both hitting force fields and players)
- Updated default programs to make use of new onHit hook data
- New rate limits for Mining (20 per block), Building (20 per block), Hitting Players (1 per block) and Hitting Force Fields (20 per block)

## 2025-08-20

- Added ability to set player names (`PlayerName` and `ReversePlayerName` tables, `NameSystem` with `setPlayerName` function)
- Initialized table with previously set offchain names

## 2025-07-25

- Improved Program hooks:
  - All hooks now receive a `HookContext` struct with `caller`, `target`, `revertOnFailure` and `extraData`.
  - Some hooks receive an additional struct with metadata for that specific action (hit damage, tool used for mining, etc).
- Updated default programs to use new hooks.

## 2025-07-17

- Add view function for getting object type at coordinate

## 2025-07-16

- Add new objects and their recipes:
  - GreenTerracotta
  - PinkTerracotta
  - LimeTerracotta
  - GrayTerracotta
  - Stonecutter
  - StoneBricks
  - TuffBricks
  - DeepslateBricks
  - PolishedAndesite
  - PolishedGranite
  - PolishedDiorite
  - PolishedTuff
  - PolishedBasalt
  - PolishedBlackstone
  - ChiseledStoneBricks
  - ChiseledTuffBricks
  - ChiseledDeepslate
  - ChiseledPolishedBlackstone
  - ChiseledSandstone
  - ChiseledRedSandstone
  - CrackedStoneBricks
  - CrackedDeepslateBricks
  - SmoothSandstone
  - SmoothRedSandstone
  - SmoothStone
  - PolishedDeepslate
  - PolishedBlackstoneBricks
  - CrackedPolishedBlackstoneBricks
  - MossyStoneBricks
  - CutSandstone
  - CutRedSandstone
  - RedDye
  - YellowDye
  - BlueDye
  - GreenDye
  - WhiteDye
  - BlackDye
  - BrownDye
  - OrangeDye
  - PinkDye
  - LimeDye
  - CyanDye
  - GrayDye
  - PurpleDye
  - MagentaDye
  - LightBlueDye
  - LightGrayDye
  - WhiteConcretePowder
  - OrangeConcretePowder
  - MagentaConcretePowder
  - LightBlueConcretePowder
  - YellowConcretePowder
  - LimeConcretePowder
  - PinkConcretePowder
  - GrayConcretePowder
  - LightGrayConcretePowder
  - CyanConcretePowder
  - PurpleConcretePowder
  - BlueConcretePowder
  - BrownConcretePowder
  - GreenConcretePowder
  - RedConcretePowder
  - BlackConcretePowder
  - WhiteConcrete
  - OrangeConcrete
  - MagentaConcrete
  - LightBlueConcrete
  - YellowConcrete
  - LimeConcrete
  - PinkConcrete
  - GrayConcrete
  - LightGrayConcrete
  - CyanConcrete
  - PurpleConcrete
  - BlueConcrete
  - BrownConcrete
  - GreenConcrete
  - RedConcrete
  - BlackConcrete
  - Brick
  - BrickBlock
  - MudBricks
  - Paper
  - Stick
  - Lodestone
  - Glass
  - WhiteGlass
  - OrangeGlass
  - YellowGlass
  - PinkGlass
  - PurpleGlass
  - BlueGlass
  - GreenGlass
  - RedGlass
  - BlackGlass

## 2025-07-09

- Add back DefaultProgramSystem function to get group id.

## 2025-07-08

- Fix access control for setting entity access group.
- Support setting access group by smart entity programs.
- Add overloaded functions to DefaultProgramSystem that don't receive a caller.

## 2025-07-07

- Fix precision loss for seed drops.

## 2025-07-04

- Fix clearing access group when mining unprotected entities.
- Decrease hit action modifier 1/30 -> 1/100.

## 2025-07-03

- Fix mining Mangrove Leafs.
- Fix access control for setting text sign content.

## 2025-06-24

- Use chunk randomness for tree growth.
- Allow planting saplings on moss.

## 2025-06-23

- Pack move directions in a single uint256 to decrease tx calldata size.
- New transferAmounts function that doesn't require specifying destination slots, which simplifies app interactions with chests.
- Fix: Lazily assign mass on mine for blocks that were set up incorrectly.
- Fix: Don't revert if trying to pickup multiple drops that don't fit in the inventory.

## 2025-06-16

- Wake up player when mining their bed instead of killing them.
- Prevent mining forcefields and adding/removing fragments if there are players sleeping inside.
- Fix: Seeds and saplings in circulation were not being tracked correctly.
- Fix: Correctly set mass of crops and trees grown from seeds and saplings.
- Fix: Support waking up for players that had their forcefields mined while sleeping.
