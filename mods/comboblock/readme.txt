-------------------------------------------------------------------------------------
||                                                                                 ||
-------------------------------------------------------------------------------------
--    _________               ___.         __________.__                 __        --
--    \_   ___ \  ____   _____\_ |__   ____\______   \  |   ____   ____ |  | __    --
--    /    \  \/ /  _ \ /     \| __ \ /  _ \|    |  _/  |  /  _ \_/ ___\|  |/ /    --
--    \     \___(  <_> )  Y Y  \ \_\ (  <_> )    |   \  |_(  <_> )  \___|    <     --
--     \______  /\____/|__|_|  /___  /\____/|______  /____/\____/ \___  >__|_ \    --
--            \/             \/    \/              \/                 \/     \/    --
--                        ___             _   __  __                               --
--                       | _ \___ __ _ __| | |  \/  |___                           --
--                       |   / -_) _` / _` | | |\/| / -_)                          --
--                       |_|_\___\__,_\__,_| |_|  |_\___|                          --
-------------------------------------------------------------------------------------
||                 Orginally written/created by Pithydon/Pithy                     ||
||                           updated by Sirrobzeroone                              ||
-------------------------------------------------------------------------------------

------------------------------- Mod Folder Name -------------------------------------

The mod folder should only be called comboblock. Github on download will add a "-" 
then something: 
For releases download it'll add the release number to the end eg comboblock-5.2.0.1
For straight download it'll add the word master eg comboblock-master

Rename the folder to be just comboblock

---------------------- Set Base/Default Texture Pack Scale --------------------------

By default comboblock is configured to the correct resolution for the base minetest 
game texture resolution - 16x16px. This means any mods that use a higher resolution that 
include slabs will have the slabs resized to 16x16 when used in combo with another slab.
Note: when used on there own the Slab resolution will be unchanged.

If you have installed and enabled a texture pack that has a higher resoltuion you'll need
to adjust the comboblock scale setting udner settings to the correct value.
From the main minetest screen:
                              ~ "Settings" tab 
                              ~ "All Settings" button 
                              ~ "Mods" scroll to bottom of list
                              ~ Expand "Mods"	
                              ~ Expand "Comboblock"
                              ~ Double click "Scale Textures to"
                              ~ Change value to texture pack resolution eg 32,64,128 etc
                              ~ Save and close settings

You'll know if you have this configured incorrectly as comboblock blocks will behave in 
intresting ways.
							  
-------------------------------- Version Number -------------------------------------
Comboblock has been given a version number that helps align it to the version of minetest
it was developed against. It dosen't mean it wont work with an older or new version of 
minetest. BUt if possible grab the release number that most closely matches the version of
minetest you are using. It is very unlikely that the Comboblock updated version will work with
any version of Minetest before version 5.0.

The first 3 numbers in the version number are the version of minetest it was created 
against/for the last digit is the mod version. 
Check the releases tab for specific old version releases. Feel free to download from the main
git repository but consider that it could be under development and broken in someway. 
So always best to download from the releases tab.

-------------------------------- Known Issues -------------------------------------
I'll try and keep this updated but check git as I'll try and keep them updated there.

Issue 1 - Glass and Non-Glass slabs can't be stacked togther. this is an engine limitation
          and if allowed results in some strange display behaviour when viewed in game.
		  
Issue 2 - If you rotate a comboblock with a screwdriver type tool (lots out there), the block
		  will always retain the properties of the block that was ontop. I haven't been able
		  to work out a fix yet as Im trying to avoid changing the screwdriver(s) code.
		  
------------------------------------ Thanks ----------------------------------------
Big thanks to Pithy for writting the orginal mod and the help from various people on the 
MT forum boards even if they probably don't know they have helped:

blert2112, Linuxdirk, Krock, Rubenwardy, Pampogokiraly, Joe7575, Sorcerykid 

And of course the Coredevs and Celeron55 for designing/keeping the engine running 


Hope this mod is useful and not to buggy
Sirrobzeroone




