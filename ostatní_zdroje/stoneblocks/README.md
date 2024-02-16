# Stoneblocks Mod for minetest based games (most functionality works in other minetest based games like kawaii and multicraft)

## Release log


### Release v 1.1.0
- Add French, Dutch and Russian localizations
- Minor tweaks

### Release v 1.0.0

## Overview
StoneBlocks adds a variety of stone-based blocks with unique properties, including light-emitting stones and decorative blocks. Some block reacts to player proximity, creating a dynamic and immersive environment.

## List of blocks
### Blocks That Emit Light (Lit Blocks)

- Ruby Block with Emerald: stoneblocks:rubyblock_with_emerald
- Stone with Turquoise Glass: stoneblocks:stone_with_turquoise_glass
- Emeraldblock with Ruby: stoneblocks:emeraldblock_with_ruby
- Mixed Stone Block: stoneblocks:mixed_stone_block
- Red Granite Turquoise Block: stoneblocks:red_granite_turquoise_block
- Turquoise Glass Stone: stoneblocks:turquoise_glass

### Sensitive Lanterns (lit when player is close)

- Sensitive Glass Block: stoneblocks:sensitive_glass_block
- Yellow Stone Lantern: stoneblocks:lantern_yellow
- Blue Stone Lantern: stoneblocks:lantern_blue
- Green Stone Lantern: stoneblocks:lantern_green
- Red and Green with Yellow Stone Lantern: stoneblocks:lantern_red_green_yellow
- Red Stone Lantern: stoneblocks:lantern_red

### Blocks Without Light
- Black Granite Stone: stoneblocks:black_granite_block
- Grey Granite Stone: stoneblocks:grey_granite
- Ruby Block: stoneblocks:rubyblock
- Cat's Eye: stoneblocks:cats_eye
- Stone with Ruby: stoneblocks:stone_with_ruby
- Stone with Emerald: stoneblocks:stone_with_emerald
- Granite Stone: stoneblocks:granite_block
- Red Granite Stone: stoneblocks:red_granite_block
- Rose Granite Stone: stoneblocks:rose_granite_block
- Emerald Block: stoneblocks:emeraldblock
- Stone with Turquoise: stoneblocks:stone_with_turquoise
- Sapphire Stone: stoneblocks:sapphire_block
- Stone with Sapphire: stoneblocks:stone_with_sapphire
- Turquoise Stone: stoneblocks:turquoise_block

## Installation
- Standard installation via ContentDB 

### Manual install for single player games
1. Download the StoneBlocks mod.
2. Unzip and place the `stoneblocks` folder into your Minetest `mods` directory or Multicraft <game_name>/worldmods
3. Enable the mod through the Minetest UI or add `load_mod_stoneblocks = true` to your `minetest.conf` file.

## Features
- Light-emitting blocks that activate when players are nearby.
- A range of decorative stone blocks for building and crafting.
- Customizable settings for block light emission and sound effects.

## Usage
- Place the blocks within the game world like any standard block.
- Configure the mod settings in `minetest.conf` to adjust the proximity detection range and light duration.

## Configuration
- `stoneblocks_check_player_within`: Range (in blocks) to detect player proximity. Default is 2. Valid values 1 - 20. 
- `stoneblocks_stay_lit_for`: Duration (in seconds) the blocks remain lit after activation. Default is 2. Valid range 1 - 600.


## Ores (only in Minetest)

The StoneBlocks mod introduces several unique ores into the Minetest world, enriching the mining and exploration experience. Below are the details of these ores, including their generation parameters and where they can be found:

### Sapphire Stone
- **Ore ID**: `stoneblocks:stone_with_sapphire`
- **Generation Depth**: Between -500 and -60
- **Cluster Scarcity**: 1 ore per approximately 3,584 nodes
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone

### Ruby Stone
- **Ore ID**: `stoneblocks:stone_with_ruby`
- **Generation Depth**: Between -600 and -70
- **Cluster Scarcity**: 1 ore per approximately 3,584 nodes
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone

### Emerald Stone
- **Ore ID**: `stoneblocks:stone_with_emerald`
- **Generation Depth**: Between -500 and -60
- **Cluster Scarcity**: 1 ore per approximately 4,096 nodes (Blob)
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone

### Turquoise Glass Stone
- **Ore ID**: `stoneblocks:stone_with_turquoise_glass`
- **Generation Depth**: Between -600 and -50
- **Cluster Scarcity**: 1 ore per approximately 2,100 nodes (Blob)
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone

### Turquoise Stone
- **Ore ID**: `stoneblocks:stone_with_turquoise`
- **Generation Depth**: Between -600 and -50
- **Cluster Scarcity**: 1 ore per approximately 3,380 nodes
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone

### Granite Variants
- **Ores ID**: `stoneblocks:black_granite_block`, `stoneblocks:grey_granite`, `stoneblocks:rose_granite_block`, `stoneblocks:granite_block`
- **Generation Depth**: Up to 100 for some, extending to -700 for others, including above ground for `stoneblocks:red_granite_block`
- **Cluster Scarcity**: Varies, with 1 ore per approximately 455 nodes for some
- **Cluster Size**: 8 ores per cluster
- **Location**: Within default stone, with specific depth ranges detailed above

These ores are designed to blend seamlessly with the Minetest world, offering both aesthetic value and utility for crafting and building. Players are encouraged to explore various biomes and depths to discover these valuable resources.

## Crafting Recipes (only minetest)

The StoneBlocks mod enriches Minetest with a variety of crafting recipes, allowing players to transform natural resources into a range of decorative and functional blocks. Below is an overview of what can be crafted:

- **Sapphire Block**: Crafted from Stone with Sapphire.
- **Ruby Block**: Made using Stone with Ruby.
- **Emerald Block**: Created from Stone with Emerald.
- **Turquoise Glass and Turquoise Block**: Derived from Stone with Turquoise and Stone with Turquoise Glass.
- **Stone Lanterns**: A series of decorative lanterns in various colors (Yellow, Red, Blue, Green, and Red/Green/Yellow) can be crafted using combinations of Ruby Blocks, Sapphire Blocks, Emerald Blocks, Turquoise Glass, and basic stones.
- **Mixed Stone Block**: A special block combining Turquoise Glass, Ruby Blocks, Emerald Blocks, and other stones.
- **Sensitive Glass Block**: Utilizes Turquoise Glass and Stone with Turquoise Glass.
- **Ruby Block with Emerald**: A unique combination of Ruby and Emerald stones.
- **Emerald Block with Ruby**: Another unique combination, emphasizing the versatility of Ruby and Emerald stones.
- **Red Granite Turquoise Block and Cats Eye**: Special blocks that utilize the mod's unique stones for crafting.

These recipes encourage exploration and mining, as players collect the necessary resources to craft these unique blocks. For the exact crafting patterns, players are encouraged to explore the crafting guide within the game.

Enjoy creating and decorating with StoneBlocks' diverse range of materials and colors!

Created by Scottii & homiak
