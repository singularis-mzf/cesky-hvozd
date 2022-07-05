<!--
SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>

SPDX-License-Identifier: MIT OR CC-BY-SA-4.0
-->

# Complex livery painting library (multi_component_liveries)

This library provides functionality to paint multiple livery layers on e. g. advtrains wagons, using only one generic painting tool.

## How to paint

Get a painting tool (e. g. the `bike_painter` from the `bike` mod), and set all color channels to zero. (I. e. `#000000` 0% Alpha.)
Paint the entity with this tool.
You will get instructions sent via the chat.
There you can see which livery components are available for this entity, which components are in use right now, and which “meta colors” can be used to paint individual components.

A “meta color” is a color with the Red and Alpha channel set to zero.
(If your tool does not have an Alpha channel, set just the Red channel to zero.)
The Green and Blue channel are used to carry meta information.

### Components

Use the Green channel to select a livery component by its number.
Leave the Blue channel at zero.
Paint the entity with this meta color.
The livery component is now selected, and can be painted as usual.

You can not just select livery components, you can also move them in the layer stack.
To make a component appear on top of all others, set the Blue channel to 254.
To move it between the second and third layer, set the Blue channel to 3.
To remove it completely, set the Blue channel to 255.

When you paint the entity with `#000000` 0% Alpha, you can see the current component stack.

### Slots

To copy a complex livery from one entity to another, you can use “slots”.
There are 30 slots, of which 10 are private, and 20 are shared with all players.
Paint `#0000NN` 0% Alpha, where NN is a slot number plus 100, to store a livery in a slot.
Paint `#0000NN` 0% Alpha to load a livery from slot NN.

### Presets

If you do not want to paint individual components, you may check whether the entity provides “presets”.
Paint `#000000` 0% Alpha, and check the list of presets.
By painting `#0000NN` 0% Alpha, where NN is the index of the preset plus 200, you apply a preset.

## How it works

Entities in Minetest can use textures which are assembled from multiple different textures using “texture modifiers”.
Texture modifiers are able to put a colorized image on top of another image.
For example, `cat_texture.png^(cat_eye_texture.png^[multiply:blue)` changes the eyes of a cat to a blue color.

There are tools (like the `bike_painter`) that allow the player to provide colors to these texture modifiers.
Supported entities will recognize these tools when they are punched, and apply the color to the texture modifiers, which are then used to make textures for this entity.

This library provides logic to such entities, so they can use only one painting tool to receive multiple colors.
The player needs to use “meta colors”, which define how a certain color shall be used.
This way, complex liveries can be painted with tools designed for simple liveries.

## How to use this library

### Textures

Create a base texture file for your entity.
Your entity should look fine with just the base texture.

For every livery component, duplicate the base texture file, and make everything irrelevant transparent.
The relevant parts should usually be converted to monochrome, and brightened until the brightest pixels are white.
Minetest will then colorize these livery components by multiplying the pixels with the livery color.
You can use colorful components, but the colors will probably be desaturated by the multiplication.

The base texture should look identical to itself with the initial livery stack applied.
This way, your entity shows the initial livery even when this library can not be used, e. g. because it is an optional dependency.

### Code

Read the documentation for `livery_definition` and `livery_stack` (found in `api.lua`).
Then create a livery definition for your entity and store it somewhere.
Create a table which stores the livery of your entity, and store it together with the entity.

When a player paints on your entity, call `multi_component_liveries.paint_on_livery()` to apply appropriate changes on the livery.
When the livery has changed, create a new texture for your entity using `multi_component_liveries.calculate_texture_string()`, and apply it on the entity.

## advtrains interface

This library provides a function that implements livery painting on advtrains wagon definitions.

It uses the unofficial livery API from advtrains, added in commit 
[b71c72b4ab4d50c8f3a3a6ccbe15427548e1d2ff](https://git.bananach.space/advtrains.git/commit/?id=).

```txt
commit b71c72b4ab4d50c8f3a3a6ccbe15427548e1d2ff
Author: Gabriel Pérez-Cerezo <email@redacted>
Date:   Sun Dec 1 12:08:28 2019 +0100

    Add experimental liveries feature

    Please do not use this in your train mods yet, this may be subject to
    changes!
```

Essentially, wagon definitions have a `set_livery()` method, which is called when a player uses a painting tool on the wagon; and a `set_texture()` method, which is called when the lua entity of the wagon is created.
These methods have access to the lua entity (to apply textures), and to advtrains’ persistent data storage of the wagon, where a `livery` property must be stored.

advtrains only accepts the `bike_painter` tool, which provides the property strings `paint_color` and `alpha`.

As soon as advtrains gains official/stable livery API, this interface of this library shall be adapted.
(In that case, contact the maintainer of this library, multi_component_liveries!)

### How to use the advtrains interface

Create a livery_definition table as described above, and apply it to your wagon definition using `multi_component_liveries.setup_advtrains_wagon()`.

### How to use together with line number display

multi_component_liveries does not support line number displays.
Therefore, your model must use different texture slots for the livery and the line number displays.
Pass the livery slot to `setup_advtrains_wagon()`.

If you make your model with Blender and the `io_scene_b3d` B3D exporter, you need to make sure that everything affected by the livery must be only one mesh with only one material.
Join multiple mesh objects like usual with the _Join_ tool.

After joining meshes, your animations are probably broken.
To fix them, create a new armature object, which has one bone for every animated part.
This bone needs _Copy Location_ and _Copy Rotation_ constraints, which reference the bone with existing animation.
Then, apply _Bake Action_ to the armature, using _Visual Keying_ and _Bake Data = Bone_ options.
Now, you have exactly one armature, which is self-contained with all animations.

The _Join_ tool preserves vertex groups.
This means you need to make sure vertex group names do not collide, _before_ joining the meshes.

Finally, add _Armature Deform_ modifiers to the mesh, one modifier per bone.
These modifiers are unfortunately not preserved by the _Join_ tool.

Now you can export the model as B3D, with all animations on the single mesh, and only one texture slot for this mesh.

The Minetest Lua API allows you to set different textures for every texure slot, and multi_component_liveries will update only one of these textures.
