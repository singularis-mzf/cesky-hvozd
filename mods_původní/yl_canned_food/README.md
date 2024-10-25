
# yl_canned_food

## Purpose

This mod is a contentlevel reimplementation of canned_food. yl_canned_food intends to be as extensible as possible.

## Download

Get it from https://gitea.your-land.de/your-land/yl_canned_food

## Dependencies

See [mod.conf](mod.conf)

* [yl_api_nodestages](https://gitea.your-land.de/your-land/yl_api_nodestages)

## Installation

1. Copy the "yl_canned_food" folder to your mod directory.
2. Make sure the [dependencies](#dependencies) are satisfied, if any.
3. Enable the mod in your world.mt file.

## Configuration

```
yl_canned_food.debug = false
```
Set to true to enable debug mode

```
yl_canned_food.freeze = false
```
Set to true to prevent the nodes from changing into the next stage

```
yl_canned_food.legacy = false
```

Set to true if you need drop-in replacement for canned_food. Set to false if you want uniform naming

```
yl_canned_food.duration = 600
```

Set this to a time in seconds. This time is necessary to go from the first to the second stage.

```
yl_canned_food.max_light = 5
```

Set this to a light level beetween 0 and 15. This time is the maximum light level the position may have to allow the first stage go to the second stage. A max_light of 5 means, that a position which receives 0 to 5 light can switch stage, while a position that receives 6 to 15 light cannot.

```
yl_canned_food.chance = 33
```

Set this to a number in percent between 0 and 100. This is the chance to go from the first to the second stage. 33 means, one in three will go to the next stage, the remaining restart their timer.

## Usage

This mod can be used in singleplayer and multiplayer. It comes with the canned food items, but no crafting recipes. To get those, install the integration mod for your game. The minetest_game integration is here: [yl_canned_food_mtg](https://gitea.your-land.de/your-land/yl_canned_food_mtg)

### Modmakers

Add to this mod or make your own based on yl_api_nodestages

## Limitations

Although this mod intends to achieve everything and more the canned_food mod brings with it, there is no guarantee it will look and feel entirely the same.

## Alternatives

* [canned_food](https://github.com/h-v-smacker/canned_food)

## Supported versions

If you use yl_canned_food, but something is wrong, please [file a bug](https://gitea.your-land.de/your-land/yl_canned_food/issues/new). PRs also welcome.

There is no reason to believe it doesn't work anywhere, but you never know.

## Allied projects

If you know a project that uses this mod tell us and we will add it to the list.

## Uninstall

Remove it from your mod folder or deactivate it in your world.mt

Mods that depend on it will cease to work, if the mod is removed without proper replacement.

## License

See [LICENSE.md](https://gitea.your-land.de/your-land/yl_canned_food/src/LICENSE.md)

* Code MIT AliasAlreadyTaken
* Textures CC0 Styxcolor
* Screenshot CC0 Styxcolor

## Thank you

* Original canned_food author: https://github.com/h-v-smacker
* AspireMint
* Styxcolor