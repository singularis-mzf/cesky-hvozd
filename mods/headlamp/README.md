# Headlamp [headlamp]

[![luacheck](https://github.com/OgelGames/headlamp/workflows/luacheck/badge.svg)](https://github.com/OgelGames/headlamp/actions)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%204.0-green.svg)](LICENSE.md)
[![Minetest](https://img.shields.io/badge/Minetest-5.3+-blue.svg)](https://www.minetest.net)
[![ContentDB](https://content.minetest.net/packages/OgelGames/headlamp/shields/downloads/)](https://content.minetest.net/packages/OgelGames/headlamp/)

## Table of Contents

- [Overview](#overview)
- [Usage](#usage)
- [Crafting](#crafting)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [License](#license)

## Overview

A simple mod that adds a headlamp that can be worn as armor, providing a bright light source.

![Overview Screenshot](images/overview.png?raw=true "Overview Screenshot")

## Usage

Using the headlamp is very simple, just "use" the item to turn it on (left-click) and put it in one of your armor slots. You can also "place" the item to equip it (right-click).

Note that the headlamp works slightly different depending on whether the `technic` mod is installed; if `technic` is installed, the headlamp can be recharged like other electric tools, if not, the headlamp will simply wear out, and can be repaired like any other tool.

## Crafting

The crafting recipe for the headlamp depends on which mods are installed:

- Minetest Game only:

![Default Recipe](images/default_recipe.png?raw=true "Default Recipe")

- With Technic installed:

![Technic Recipe](images/technic_recipe.png?raw=true "Technic Recipe")

If another game is used that doesn't include `default` or `farming`, no recipe will be added.


## Dependencies

**Required**

- [`illumination`](https://github.com/mt-mods/illumination) (mt-mods version)
- [`3d_armor`](https://github.com/minetest-mods/3d_armor)


**Optional**

- [`technic`](https://github.com/minetest-mods/technic)
- `default` (included in [Minetest Game](https://github.com/minetest/minetest_game))
- `farming` (included in [Minetest Game](https://github.com/minetest/minetest_game))

## Installation

Download the [master branch](https://github.com/OgelGames/headlamp/archive/master.zip) or the [latest release](https://github.com/OgelGames/headlamp/releases), and follow [the usual installation steps](https://dev.minetest.net/Installing_Mods).

Alternatively, you can download and install the mod from [ContentDB](https://content.minetest.net/packages/OgelGames/headlamp) or the online content tab in Minetest.

## License

Except for any exceptions stated in [LICENSE.md](LICENSE.md#exceptions), all code is licensed under the [MIT License](LICENSE.md#mit-license), with all textures, models, sounds, and other media licensed under the [CC BY-SA 4.0 License](LICENSE.md#cc-by-sa-40-license). 
