## Letters: A mod for Minetest! (modified)

This is a modified version of the Letters mod that only accepts baked clay (of any color) as input and letter nodes are colorable by Unified Dyes 32-color palette (use airbrush to color them).

The main reason for the modification is that the original mod creates enormous number of registered nodes, which slows down a server. Also most of materials are not really useful, because the color is usually more important than texture.

The majority of this code was taken (and altered significantly) from Calinou's [Moreblocks mod](https://forum.minetest.net/viewtopic.php?t=509). Code is licensed under the zlib license, textures under the CC BY-SA license.

The Letter Cutter textures use parts of the default wood and tree textures made by Blockmen and Cisoun respectively.

### Compatibility

WARNING: This version is completely incompatible with the original Letters mod! If you replace the original mod by this one, all your letter-nodes will become unkown nodes and you should replace all Letter Cutters by new ones to update their metadata!

### Rotation

Letter nodes may be rotated by a screwdriver, but *only six orientations are possible* (four vertical, top and bottom). (Letters can not be rotated upside down.)
