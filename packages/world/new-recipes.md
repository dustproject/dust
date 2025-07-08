Tracking upcoming recipe changes discussion here.

TODO:
- Decide if we want to have stairs/slabs/etc for each wood type or just have a single "Wood stair" built with any logs/planks
- Make sure mass/energy is conserved
- Do we want to use minecraft style ratios for building? for example, in the current proposal you need 3 bamboos to craft 3 papers, but we could just make it 1-1

## New Crafting Station

| Station | Recipe | Purpose |
|---------|--------|---------|
| Stonecutter | 1 IronBar + 3 Stone → 1 Stonecutter | Precise stone shaping for variants |

## New Base Materials (8)

| Material | How to Obtain | Used For |
|----------|---------------|----------|
| Cotton | Drop from CottonBush (0-1) | Carpets, Beds, Books |
| Glass | Sand + CoalOre → Glass (Furnace) | Windows, decoration |
| Brick | Clay + CoalOre → Brick (Furnace) | BrickBlock, FlowerPot |
| BrickBlock | 4 Brick → 1 BrickBlock | Building material |
| PackedMud | 4 Mud → 4 PackedMud | Intermediate for MudBricks |
| MudBricks | 4 PackedMud → 4 MudBricks (Furnace) | Building material |
| Paper | 3 BambooBush → 3 Paper | Books |
| Book | 3 Paper + 1 Cotton → 1 Book | Bookshelf |
| Stick | 2 AnyPlank → 4 Stick | Ladders, crafting |

## Dye System

**Note**: All dyes have 0 mass to ensure colored variants have exactly the same mass as their base materials.

### Primary Dyes

| Dye | Source Materials | Recipe |
|-----|------------------|--------|
| RedDye | RoseFlower, RedMushroom, StrawberryBush | 1 Source → 2 RedDye |
| YellowDye | SunFlower, DandelionFlower | 1 Source → 2 YellowDye |
| BlueDye | Ultraviolet | 1 Ultraviolet → 2 BlueDye |
| GreenDye | Any Leaf type, Moss | 1 Source → 1 GreenDye |
| WhiteDye | Calcite | 1 Calcite → 3 WhiteDye |
| BlackDye | CoalOre | 1 CoalOre → 2 BlackDye |
| BrownDye | Mud, BrownMushroomBlock | 1 Source → 2 BrownDye |

### Mixed Dyes

| Dye | Recipe |
|-----|--------|
| OrangeDye | 1 RedDye + 1 YellowDye → 2 OrangeDye |
| PinkDye | 1 RedDye + 1 WhiteDye → 2 PinkDye |
| LimeDye | 1 GreenDye + 1 WhiteDye → 2 LimeDye |
| CyanDye | 1 BlueDye + 1 GreenDye → 2 CyanDye |
| GrayDye | 1 BlackDye + 1 WhiteDye → 2 GrayDye |
| PurpleDye | 1 RedDye + 1 BlueDye → 2 PurpleDye |

## All Recipes Table

| Station | Inputs | Outputs | Category |
|---------|--------|---------|----------|
| - | 4 Mud | 4 PackedMud | Material |
| Furnace | 4 PackedMud + 1 CoalOre | 4 MudBricks | Construction |
| - | 1 IronBar + 3 Stone | 1 Stonecutter | Station |
| - | 3 BambooBush | 3 Paper | Material |
| - | 3 Paper + 1 Cotton | 1 Book | Material |
| Furnace | 1 Sand + 1 CoalOre | 1 Glass | Material |
| Furnace | 1 Clay + 1 CoalOre | 1 Brick | Material |
| Furnace | 1 Clay | 1 Terracotta | Material |
| - | 4 Brick | 1 BrickBlock | Material |
| Workbench | 4 Sand + 4 Gravel + 1 [Color]Dye | 8 [Color]ConcretePowder | Material |
| - | 1 [Color]ConcretePowder + 1 WaterBucket | 1 [Color]Concrete + 1 Bucket | Material |
| Furnace | 1 Cobblestone + 1 CoalOre | 1 Stone | Material |
| Furnace | 1 CobbledDeepslate + 1 CoalOre | 1 Deepslate | Material |
| - | 1 RoseFlower | 2 RedDye | Dye |
| - | 1 RedMushroom | 2 RedDye | Dye |
| - | 1 StrawberryBush | 2 RedDye | Dye |
| - | 1 SunFlower | 2 YellowDye | Dye |
| - | 1 DandelionFlower | 2 YellowDye | Dye |
| - | 1 Ultraviolet | 2 BlueDye | Dye |
| - | 1 AnyLeaf | 1 GreenDye | Dye |
| - | 1 Moss | 1 GreenDye | Dye |
| - | 1 Calcite | 3 WhiteDye | Dye |
| - | 1 Bone | 3 WhiteDye | Dye |
| - | 1 CoalOre | 2 BlackDye | Dye |
| - | 1 Mud | 2 BrownDye | Dye |
| - | 1 BrownMushroomBlock | 2 BrownDye | Dye |
| - | 1 RedDye + 1 YellowDye | 2 OrangeDye | Dye |
| - | 1 RedDye + 1 WhiteDye | 2 PinkDye | Dye |
| - | 1 GreenDye + 1 WhiteDye | 2 LimeDye | Dye |
| - | 1 BlueDye + 1 GreenDye | 2 CyanDye | Dye |
| - | 1 BlackDye + 1 WhiteDye | 2 GrayDye | Dye |
| - | 1 RedDye + 1 BlueDye | 2 PurpleDye | Dye |
| - | 2 AnyPlank | 4 Stick | Material |
| - | 4 Stone | 4 StoneBricks | Construction |
| - | 4 Tuff | 4 TuffBricks | Construction |
| - | 4 CobbledDeepslate | 4 DeepslateBricks | Construction |
| - | 4 Sand | 4 Sandstone | Construction |
| - | 4 RedSand | 4 RedSandstone | Construction |
| Stonecutter | 4 Andesite | 4 PolishedAndesite | Construction |
| Stonecutter | 4 Granite | 4 PolishedGranite | Construction |
| Stonecutter | 4 Diorite | 4 PolishedDiorite | Construction |
| Stonecutter | 4 Tuff | 4 PolishedTuff | Construction |
| Stonecutter | 4 Basalt | 4 PolishedBasalt | Construction |
| Stonecutter | 4 Blackstone | 4 PolishedBlackstone | Construction |
| Stonecutter | 2 StoneBricks | 1 ChiseledStoneBricks | Construction |
| Stonecutter | 2 TuffBricks | 1 ChiseledTuffBricks | Construction |
| Stonecutter | 2 DeepslateBricks | 1 ChiseledDeepslate | Construction |
| Stonecutter | 2 PolishedBlackstone | 1 ChiseledPolishedBlackstone | Construction |
| Stonecutter | 2 Sandstone | 1 ChiseledSandstone | Construction |
| Stonecutter | 2 RedSandstone | 1 ChiseledRedSandstone | Construction |
| Workbench | 4 StoneBricks | 4 CrackedStoneBricks | Construction |
| Workbench | 4 TuffBricks | 4 CrackedTuffBricks | Construction |
| Workbench | 4 DeepslateBricks | 4 CrackedDeepslateBricks | Construction |
| Stonecutter | 4 Sandstone | 4 SmoothSandstone | Construction |
| Stonecutter | 4 RedSandstone | 4 SmoothRedSandstone | Construction |
| Stonecutter | 4 Stone | 4 SmoothStone | Construction |
| Stonecutter | 1 [Material] | 1 [Material]Stairs | Shape Variant |
| Stonecutter | 1 [Material] | 2 [Material]Slab | Shape Variant |
| Stonecutter | 1 [Material] | 1 [Material]Wall | Shape Variant |
| Workbench | 8 Cotton + 1 [Color]Dye | 8 [Color]Cotton | Colored |
| Workbench | 8 Terracotta + 1 [Color]Dye | 8 [Color]Terracotta | Colored |
| Workbench | 6 Glass | 16 GlassPane | Functional |
| - | 6 [Wood]Planks | 3 [Wood]Door | Functional |
| - | 6 IronBar | 3 IronDoor | Functional |
| - | 6 [Wood]Planks | 2 [Wood]Trapdoor | Functional |
| - | 4 IronBar | 1 IronTrapdoor | Functional |
| - | 4 [Wood]Planks + 2 Stick | 3 [Wood]Fence | Functional |
| - | 4 Stick + 2 [Wood]Planks | 1 [Wood]FenceGate | Functional |
| - | 6 IronBar | 16 IronBars | Functional |
| - | 1 IronBar + 1 Torch | 1 Lantern | Functional |
| - | 7 Stick | 3 Ladder | Functional |
| - | 6 AnyPlank + 2 [Wood]Slab | 1 Barrel | Storage |
| - | 6 AnyPlank + 3 Book | 1 Bookshelf | Storage |
| - | 2 Cotton | 3 Carpet | Decoration |
| - | 2 [Color]Cotton | 3 [Color]Carpet | Decoration |
| - | 3 Brick | 1 FlowerPot | Decoration |
| - | 8 Stone + 1 NeptuniumBar | 1 Lodestone | Special |
| - | 3 Cotton + 3 AnyPlank | 1 Bed | Special |
| - | 1 FlowerPot + 1 [Tree]Sapling | 1 Potted[Tree]Sapling | Decoration |

## Shape Variant Materials

Materials that can be made into stairs, slabs, and walls:
- Stone, Cobblestone, MossyCobblestone, StoneBricks, SmoothStone
- Andesite, Granite, Diorite, Tuff, Basalt, Blackstone (and their polished variants)
- Deepslate, CobbledDeepslate, DeepslateBricks
- Sandstone, RedSandstone, SmoothSandstone, SmoothRedSandstone
- BrickBlock, MudBricks, TuffBricks
- Concrete (all colors)
- All 8 wood plank types

## Colored Block Variants

Each of the 13 dye colors can be applied to:
- Cotton (can be dyed into 13 colors)
- Terracotta (base terracotta + dye) - Note: Need to add BrownTerracotta
- Concrete (colored via ConcretePowder + dye)
- Carpet (crafted from white or colored cotton)

**Important**: All colored variants have exactly the same mass as their base material since dyes have 0 mass.

## New drops

| Block | Drop | Probability |
|-------|------|-------------|
| CottonBush | Cotton + CottonSeed | Cotton (0: 50%, 1: 50%), Seeds (0: 43%, 1: 57%) |

