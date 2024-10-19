# Always Greener
...is a nature & worldgen mod focused on improving MTG's existing natural world & biomes, rather than just adding a bunch of new ones. It primarily deals with the visual quality of the game, for example giving plants better models and adding new foliage and natural nodes such as mud, but also adds new mechanics like the "cuttings" system for replicating plants.

Always Greener depends on [Et Cetera](https://content.minetest.net/packages/Hagatha/etcetera/), make sure it is also installed and enabled when using the mod.

## Overview

Always Greener has numerous features, and for convenience's sake these are divided into subsets below. The available settings and contained changes or additions will be listed for each.

### Grass Changes

Perhaps the main features of the mod are the changes made to grass and 'dirt with grass' nodes. Grass tufts are given new models as well as two extra stages of growth, an even taller stage 6 and a stage 7 with seedheads, which is more common in savanna biomes. Dirt with dry grass has been removed, and instead grass blocks will be colored according to the local heat and humidity. These factors are based on the biome as well as the altitude and proximity to water.  

Dead grass has been added, which replaces grass when a solid node is on top of it (rather than converting directly into dirt).  

Jungle grass has also been given a new model, as well as flowering and short variants.  

The following settings are available:

 - *Altitude Cooling Effect* (`awg.grass_alt_chill`): Grass color will get colder as altitude increases.
 - *Altitude Drying Effect* (`awg.grass_alt_dry`): Grass color will get drier as altitude increases.
 - *Water Proximity Effect* (`awg.grass_water_prox`): Grass color will get wetter toward nearby water.
 - *Enable Dead Grass* (`awg.dead_grass`): Grass will convert to dead grass instead of dirt when covered.

### Water Changes

Similar changes to the grass tweaks are also applied to water. Water will be colored based on the biome and altitude, with humid areas getting greener and cold areas getting darker.  

The following settings are available:

 - *Biome-Based Water Coloration* (`awg.water_color`): Enable water water colormapping.
 - *Blend Flowing Water* (`awg.water_blend_flowing`): Attempts to make transition between flowing and still water less jarring.
 - *Depth Drying Effect* (`awg.water_depth_dry`): Humidity goes down in caves.
 - *Altitude Cooling Effect* (`awg.water_alt_chill`): Temperature goes down as altitude goes up.
 - *Alternative Water Colormap* (`awg.water_color_dull`): Use a less exaggerated color map, making water less vibrant.

### Cuttings

The "Cuttings" system is a new mechanic for reproducing plants by taking cuttings with secateurs, which can then be grown into a new plant of the same kind. Plants have a limited number of cuttings that can be taken before they die.  

The following settings are available:

 - *Enable Cuttings System* (`awg.cuttings`): Enable or disable the whole system.
 - *Allow Crafting Dirt With Grass* (`awg.craft_grass_blocks`): Allow crafting dirt with grass from regular grass cuttings, which will otherwise have no use.
 - *Secateur Durability* (`awg.secateurs_num_uses`): How many times the secateurs can be used.
 - *Show Cuttings in Creative Inventory* (`awg.cuttings_list`): Show all available cuttings in the creative inventory. May cause clutter.

### Tree/Bush Changes

Tree leaves and bush leaves are given new models, with tree leaves appearing as a ball of foliage and bush leaves appearing as a cube with extra bushy bits sticking out and numerous twigs inside. Blueberries are also updated to appear as cubes rather than a flat overlay.  

Tree leaves will be made non-solid, and will instead be climbable like ladders.  

The following settings are available:

 - *Enable Tree Leaves Mesh* (`awg.tree_leaves`): Enable or disable the bushier tree leaves meshes.
 - *Climbable Tree Leaves* (`awg.tree_leaves_climbable`): Make tree leaves climbable rather than solid.
 - *Enable Bush Leaves Mesh* (`awg.bushes`): Enable or disable the bushier bush leaves meshes.

### Mud

Mud is a new soil type that will replace any dirt in direct contact with water on map generation, and will also slowly replace dirt touching water over time. Grass can grow on it just as it can on dirt. Mud will also dry out when not near water, resulting in dried mud.

### Plant Tweaks

Most of the plants and similar things in MTG have been given new models and textures, including the following:

 - Wheat from the `farming` mod;
 - Ferns, which also have a new variant with a new shoothead sprouting;
 - All of the flowers from the `flowers` mod, as well as mushrooms (which each have two new variants) and waterlilies, with three new variants;
 - Blue, Pink, and Cyan Coral;
 - Papyrus;
 - Kelp, which is now fully animated and with a rich brown color;
 - Cactus

### Sub-Biomes

Always Greener adds a new type of terrain generation: sub-biomes. These are sections of a larger biome with slightly (or greatly) differing ground and foliage, which are tied to the specific biome they spawn in. Every registered biome is able to have one sub-biome (but does not need to).  

Sub-biomes usually add new plants not found elsewhere, and increase the overall variety of MTG's map generation without polluting the global biome pool; this means that you can still find particular biomes as easily as in the vanilla game, but there will be more environmental regions overall.

### Biome Overhauls

#### Tundra Biome

Adds a bunch of new plants to the tundra biome, mostly including mosses and small shrubs.

 - *Tundra Overhaul* (`awg.load_module_tundra`): Enable or disable the tundra biome overhaul.

#### Grassland Biome

New decorations for grasslands including clover, large sage patches, and edible field mushrooms, as well as a marshy sub-biome with rushes, reeds, and pools of water.

 - *Grassland Overhaul* (`awg.load_module_grassland`): Enable or disable the grassland biome overhaul.
 - *Grassland Sub-Biome: Marsh* (`awg.grassland_marsh`): Enable or disable the marsh sub-biome for grasslands. Depends on the grassland biome overhaul.

### Mod Support

#### More Trees!

Basic support is provided for this mod, giving the new trees fluffy leaves if enabled.

#### Extra Biomes

The following Always Greener features also apply to this mod when installed:

 - Fluffy tree leaves
 - Biome colored grass

## Licensing
```
Always Greener (etcetera) (c) 2024 Hagatha (Sneglium)  

License of code & data files (*.lua, *.conf, *.txt): Apache-2.0  
https://www.apache.org/licenses/LICENSE-2.0.txt  
see LICENSING/code.LICENSE  

License of media and other files (*.obj, *.ogg, *.png, *.tr, *.md): Attribution-ShareAlike 4.0 International  
https://creativecommons.org/licenses/by-sa/4.0/legalcode.txt  
see LICENSING/media.LICENSE  
```
