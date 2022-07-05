<!--
SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>

SPDX-License-Identifier: MIT
-->

# Minitram crafting recipes

These are crafting recipes and intermediate craft items for the Minitram Konstal 105.
The crafting recipe is intended to be expensive.

Crafting recipes use the idea of a “blueprint” item (`minitram_crafting_recipes:minitram_template`), which is used to avoid any collisions with crafting recipes from other mods.

Crafting ingredients are selected from a number of mods which are optional dependencies.
In most cases, `technic` is preferred, and `default` or nothing is used as last choice.
There are also `mesecons`, `morelights`, `basic_materials`, and some more mods supported.

## Inventory images

These are drawn in Inkscape.
Because Inkscape does not have any way to export images without antialiasing, exported images are always blurry.
As a workaround, images are exported at a very high resolution (1024x1024), and then downscaled with ImageMagick.

```bash
convert input_1024px.png -define 'sample:offset=50%x44%' -sample '32x32' -channel 'alpha' -level '50%' output_32px.png
```

* `-define 'sample:offset=50%x44%'` tells `-sample` which pixel to use of each 32px chunk. Here it is slightly above the center, to avoid the antialiased region of 45° lines.
* `-sample '32x32'` makes a new 32px image using just one pixel of each 32px chunk.
* `-channel 'alpha' -level '50%'` removes any left-over antialiasing from the alpha channel by comparing each pixel’s alpha to 50%.
