
# yl_canned_food_mtg

## Purpose

This mod brings crafting recipes, nutritional values and unified inventory integration for yl_canned_food

## Download

Get it from https://gitea.your-land.de/your-land/yl_canned_food_mtg

## Dependencies

See [mod.conf](https://gitea.your-land.de/your-land/yl_canned_food_mtg/src/branch/master/mod.conf)

* [yl_canned_food](https://gitea.your-land.de/your-land/yl_canned_food)

## Installation

1. Copy the "yl_canned_food_mtg" folder to your mod directory.
2. Make sure the [dependencies](https://gitea.your-land.de/your-land/yl_canned_food_mtg#dependencies) are satisfied, if any.
3. Enable the mod in your world.mt file.

## Configuration

```
yl_canned_food_mtg.debug = false
```
Set to true to enable debug mode

```
yl_canned_food_mtg.enable_recipes = true
```
Set this to true if you want to enable recipes. Set this to false if you create recipes of your own in a different mod.

```
yl_canned_food_mtg.enable_eat = true
```
Set this to true if you want to enable eating. Set this to false if you create item_eat integration of your own in a different mod.

```
yl_canned_food_mtg.enable_unified_inventory = true
```
Set this to true if you want to enable unified_inventory integration

```
yl_canned_food_mtg.data_source = "default"
```
Set this to where the data shall be loaded from. Use "default" for a new world, "legacy" for a world where this mod replaces canned_food and "json" where you decide the data for yourself. Here is an example json: [yl_canned_food_mtg.json](https://gitea.your-land.de/your-land/yl_canned_food_mtg/src/branch/master/dev/yl_canned_food_mtg.json)

```
yl_canned_food_mtg.save_path
```
Set this to where in the worldfolder you want the JSON files stored.

## Usage

This mod can be used in singleplayer and multiplayer. It adds crafting recipes, nutritional values and unified inventory integration for minetest_game. If your game is a different one, use their canned_food integration instead.

## Limitations

* No integrations for other games than those which are based on [minetest_game](https://github.com/minetest/minetest_game)

## Alternatives

* [canned_food](https://github.com/h-v-smacker/canned_food)

## Supported versions

If you use yl_canned_food_mtg, but something is wrong, please [file a bug](https://gitea.your-land.de/your-land/yl_canned_food_mtg/issues/new). PRs also welcome.

There is no reason to believe it doesn't work anywhere, but you never know.

## Allied projects

If you know a project that uses this mod tell us and we will add it to the list.

## Uninstall

Remove it from your mod folder or deactivate it in your world.mt

Mods that depend on it will cease to work, if the mod is removed without proper replacement.

## License

See [LICENSE.md](https://gitea.your-land.de/your-land/yl_canned_food_mtg/src/LICENSE.md)

* Code MIT AliasAlreadyTaken
* Textures CC0 Styxcolor
* Screenshot CC0 Styxcolor

## Thank you

* Styxcolor
* tour