<!--
SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>

SPDX-License-Identifier: MIT
-->

# Konstal 105N 3D Model

## Bogie

The bogie is an approximation from photos.
It would not be possible to make an exact model that looks appropriate in advtrains.
There exist more detailed variants of the bogies, e. g. here:

https://www.3dcadbrowser.com/3d-model/konstal-105-tram-rail

## Pantograph

The current collector is intentionally in the lowered position, to not emphasize missing overhead wires.
I have chosen the older model, because it has a unique appearance.
There exists a more detailed variant of the newer model here:

https://www.3dcadbrowser.com/3d-model/konstal-105-tram-pantograph

## Downscaling

The Konstal 105N is 13.5m long, and that is too much for advtrains gauge.
The Minitram Konstal 105 shall be 8.5m long.
This is done by:
 * Scaling the whole body uniformly from 2.4m width to 2.0m width, with a scale of 0.83.
   This reduces the length to 11.2m.
   This reduces the inner height (floor to ceiling) from 1.99m to 1.65m.
   In turn, the floor will be moved right above the wheels, to a height of 0.61m. (0.73m original)
   This results in an inner height of 1.88m, which is sufficient.
   The roof height will be 2.51m above rails, or 1.66m above 1m platform edge.
 * Removing one of the two middle sections, so there is only one door pair in the middle (on each side).
   This reduces the length to 10.0m. (12.0m original)
 * Removing the front/back-most door of the outer door pairs.
   This makes the tapered end sections 0.74m shorter.
   They will be moved 13cm (15cm original) outwards, so the angles are preserved.
   This reduces the length to 8.8m, which is fine.

## B3D Creation Process

This section explains the steps I have used to create a working B3D file from my Blender model.
You may realize that I am a beginner in Blender, and these steps may be a bit awkward.

### Door Animations

There are 8 doors, all of them with the same mechanism, but transformed to different places.
It makes sense to use the same animation for all of them.
Because left doors and right doors need to open at different times, the single animation then needs to be duplicated and delayed.
Additionally, these two animations need to be duplicated to be mirrored at the Z euler rotation axis, because there are mirrored doors.

The animation armature is found in the “Door” collection.
When creating the collection duplicates, the armatures need to be duplicated too, so they can be assigned different animation actions, and can get the final transformation applied individually.

Because instantiating individual object duplicates (meshes, armatures) is “not yet implenented” in Blender 2.82, I append the collection instances to individual .blend files, and append them back into the main file.

### Line Number Signs

Line number signs need an individual texture slot.
The reason for this is explained in the multi_component_liveries mod.

This also means that the rest needs to utilize only one (the second) texture slot.
So I have joined all the meshes and removed all but one material.
The line number signs are a second mesh with another material.

To apply all 8 door animations to the one mesh, which is usually not possible with the B3D exporter, I have collected all animations in a “copy” armature.
This procedure is somewhat outlined in the multi_component_liveries mod.
The original armatures with editable animations are no longer present.

### Blender Files

I have exported B3D from `minitram_konstal_105_assembled_7_2_2.blend`.
As you can already guess, I needed several attempts until I got a working B3D export.

First issue is that the B3D exporter frequently added hundreds of additional vertices, which damaged any UV mappings.
The final result was to export to OBJ first, then reimport, add the animations from `minitram_konstal_105_doors_5.blend`, then export as B3D.
This stage is at `minitram_konstal_105_assembled_7_2.blend`.

Next issue is that this model contains multiple mesh objects with many materials, which results in many texture slots being present in the B3D.
To fix this, I have done the stuff from [Line Number Signs], resulting in `minitram_konstal_105_assembled_7_2_2.blend`.

You can look through Blender files with lower numbers at the end to find better organized modelling data, which is not ready for exporting though.

## Texture Baking

I made a lot attempts to bake textures using Cycles in Blender 2.82.
That failed very much.
With Blender 3.0 (from snap), it worked fine.
The Blender file used to bake textures is `minitram_konstal_105_assembled_7_3.blend`.
It has the correct materials set for all used material slots.
